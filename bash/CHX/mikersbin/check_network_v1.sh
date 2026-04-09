#!/bin/bash

# Network IP Conflict Checker for Debian 9
# Checks /etc/network/interfaces.d/ for IP conflicts with eth0 and default gateway

set -euo pipefail

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to extract IP from CIDR notation
get_ip_from_cidr() {
    echo "$1" | cut -d'/' -f1
}

# Function to get network address from IP/CIDR
get_network_from_cidr() {
    local cidr=$1
    local ip=$(echo "$cidr" | cut -d'/' -f1)
    local prefix=$(echo "$cidr" | cut -d'/' -f2)
    
    # Use ipcalc if available, otherwise use a simple approach
    if command -v ipcalc >/dev/null 2>&1; then
        ipcalc -n "$cidr" 2>/dev/null | cut -d'=' -f2
    else
        # Simple network calculation for common cases
        echo "$ip" | cut -d'.' -f1-3
    fi
}

# Function to check if two IPs are in the same network
same_network() {
    local ip1=$1
    local ip2=$2
    local prefix1=${3:-24}  # Default to /24 if not specified
    local prefix2=${4:-24}
    
    # Simple check for same /24 network
    local net1=$(echo "$ip1" | cut -d'.' -f1-3)
    local net2=$(echo "$ip2" | cut -d'.' -f1-3)
    
    [[ "$net1" == "$net2" ]]
}

# Get current eth0 configuration
print_status "$GREEN" "=== Network IP Conflict Checker ==="
echo

# Get eth0 IP address
ETH0_IP=$(ip addr show eth0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1 || echo "")
if [[ -z "$ETH0_IP" ]]; then
    print_status "$YELLOW" "Warning: Could not determine eth0 IP address"
    ETH0_IP=""
else
    print_status "$GREEN" "eth0 IP address: $ETH0_IP"
fi

# Get default gateway
DEFAULT_GW=$(ip route show default 2>/dev/null | grep -oP '(?<=via\s)\d+(\.\d+){3}' | head -1 || echo "")
if [[ -z "$DEFAULT_GW" ]]; then
    print_status "$YELLOW" "Warning: Could not determine default gateway"
    DEFAULT_GW=""
else
    print_status "$GREEN" "Default gateway: $DEFAULT_GW"
fi

echo

# Check if interfaces.d directory exists
INTERFACES_DIR="/etc/network/interfaces.d"
if [[ ! -d "$INTERFACES_DIR" ]]; then
    print_status "$YELLOW" "Directory $INTERFACES_DIR does not exist"
    exit 1
fi

# Find all configuration files
CONFIG_FILES=$(find "$INTERFACES_DIR" -type f -name "*.cfg" -o -name "*" | grep -v "~$" | sort)

if [[ -z "$CONFIG_FILES" ]]; then
    print_status "$YELLOW" "No configuration files found in $INTERFACES_DIR"
    exit 0
fi

print_status "$GREEN" "Checking configuration files in $INTERFACES_DIR"
echo

CONFLICTS_FOUND=0

# Process each configuration file
while IFS= read -r file; do
    if [[ -z "$file" ]]; then
        continue
    fi
    
    echo "Checking file: $file"
    
    # Extract IP addresses from the file
    # Look for 'address' lines and 'gateway' lines
    ADDRESSES=$(grep -E "^\s*(address|gateway)\s+" "$file" 2>/dev/null | awk '{print $2}' | grep -E "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(/[0-9]+)?$" || echo "")
    
    if [[ -z "$ADDRESSES" ]]; then
        echo "  No IP addresses found"
        continue
    fi
    
    # Check each address found in the file
    while IFS= read -r addr; do
        if [[ -z "$addr" ]]; then
            continue
        fi
        
        # Handle CIDR notation
        if [[ "$addr" == *"/"* ]]; then
            IP=$(get_ip_from_cidr "$addr")
            echo "  Found IP: $IP (CIDR: $addr)"
        else
            IP="$addr"
            echo "  Found IP: $IP"
        fi
        
        # Check for conflicts with eth0 IP
        if [[ -n "$ETH0_IP" && "$IP" == "$ETH0_IP" ]]; then
            print_status "$RED" "  *** CONFLICT: IP $IP conflicts with eth0 interface!"
            CONFLICTS_FOUND=$((CONFLICTS_FOUND + 1))
        fi
        
        # Check for conflicts with default gateway
        if [[ -n "$DEFAULT_GW" && "$IP" == "$DEFAULT_GW" ]]; then
            print_status "$RED" "  *** CONFLICT: IP $IP conflicts with default gateway!"
            CONFLICTS_FOUND=$((CONFLICTS_FOUND + 1))
        fi
        
        # Check if IP is in the same network as eth0 (potential conflict)
        if [[ -n "$ETH0_IP" && "$IP" != "$ETH0_IP" ]]; then
            if same_network "$IP" "$ETH0_IP"; then
                print_status "$YELLOW" "  Warning: IP $IP is in the same network as eth0 ($ETH0_IP)"
            fi
        fi
        
    done <<< "$ADDRESSES"
    
    echo
    
done <<< "$CONFIG_FILES"

# Summary
echo "=== Summary ==="
if [[ $CONFLICTS_FOUND -eq 0 ]]; then
    print_status "$GREEN" "No IP conflicts detected!"
else
    print_status "$RED" "Found $CONFLICTS_FOUND IP conflict(s)!"
fi

# Additional checks
echo
print_status "$GREEN" "Additional recommendations:"
echo "• Review all network configurations for consistency"
echo "• Ensure static IPs don't conflict with DHCP ranges"
echo "• Check that gateway IPs are not assigned to interfaces"
echo "• Consider using different subnets for different purposes"

exit $CONFLICTS_FOUND
