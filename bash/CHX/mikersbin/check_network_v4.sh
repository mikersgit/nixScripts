#!/bin/bash

# Network IP Conflict Checker for Debian 9
# Checks /etc/network/interfaces.d/ for IP conflicts with eth0 and default gateway
# Automatically comments out conflicting entries

set -euo pipefail

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root to modify configuration files"
    exit 1
fi

# Colors for output - only use if in interactive session
if [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]]; then
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color
    USE_COLOR=1
else
    RED=''
    YELLOW=''
    GREEN=''
    NC=''
    USE_COLOR=0
fi

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    if [[ $USE_COLOR -eq 1 ]]; then
        echo -e "${color}${message}${NC}"
    else
        # Add prefix for non-color output to distinguish message types
        case "$color" in
            "$RED") echo "ERROR: $message" ;;
            "$YELLOW") echo "WARNING: $message" ;;
            "$GREEN") echo "INFO: $message" ;;
            *) echo "$message" ;;
        esac
    fi
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

# Function to create backup of a file
backup_file() {
    local file=$1
    local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$file" "$backup"
    print_status "$GREEN" "Backup created: $backup"
}

# Function to comment out a line in a file
comment_out_line() {
    local file=$1
    local line_content=$2
    local temp_file=$(mktemp)
    
    # Create backup before modifying
    backup_file "$file"
    
    # Comment out the line and add explanation
    awk -v line="$line_content" '
    {
        if ($0 ~ line && $0 !~ /^[[:space:]]*#/) {
            print "# COMMENTED OUT - IP CONFLICT DETECTED: " $0
        } else {
            print $0
        }
    }' "$file" > "$temp_file"
    
    # Replace original file
    mv "$temp_file" "$file"
    print_status "$YELLOW" "Line commented out in $file"
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
MODIFICATIONS_MADE=0

# Process each configuration file
while IFS= read -r file; do
    if [[ -z "$file" ]]; then
        continue
    fi
    
    echo "Checking file: $file"
    
    # Extract IP addresses from the file with line numbers
    # Look for 'address' lines and 'gateway' lines
    ADDRESSES_WITH_LINES=$(grep -n -E "^\s*(address|gateway)\s+" "$file" 2>/dev/null | grep -E "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(/[0-9]+)?$" || echo "")
    
    if [[ -z "$ADDRESSES_WITH_LINES" ]]; then
        echo "  No IP addresses found"
        continue
    fi
    
    FILE_MODIFIED=0
    
    # Check if this is an eth0 configuration file
    IS_ETH0_CONFIG=0
    if [[ "$file" == *"eth0"* ]] || grep -q "iface eth0" "$file" 2>/dev/null; then
        IS_ETH0_CONFIG=1
    fi
    
    # Check each address found in the file
    while IFS= read -r line_info; do
        if [[ -z "$line_info" ]]; then
            continue
        fi
        
        # Extract line number and full line content
        LINE_NUM=$(echo "$line_info" | cut -d':' -f1)
        FULL_LINE=$(echo "$line_info" | cut -d':' -f2-)
        
        # Extract IP address from the line
        IP_WITH_CIDR=$(echo "$FULL_LINE" | grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(/[0-9]+)?$")
        
        # Handle CIDR notation
        if [[ "$IP_WITH_CIDR" == *"/"* ]]; then
            IP=$(get_ip_from_cidr "$IP_WITH_CIDR")
            echo "  Found IP: $IP (CIDR: $IP_WITH_CIDR)"
        else
            IP="$IP_WITH_CIDR"
            echo "  Found IP: $IP"
        fi
        
        CONFLICT_DETECTED=0
        
        # Check for conflicts with eth0 IP
        if [[ -n "$ETH0_IP" && "$IP" == "$ETH0_IP" ]]; then
            if [[ $IS_ETH0_CONFIG -eq 1 ]]; then
                print_status "$YELLOW" "  Warning: IP $IP matches eth0 interface (eth0 config file - not modified)"
            else
                print_status "$RED" "  *** CONFLICT: IP $IP conflicts with eth0 interface!"
                CONFLICTS_FOUND=$((CONFLICTS_FOUND + 1))
                CONFLICT_DETECTED=1
            fi
        fi
        
        # Check for conflicts with default gateway
        if [[ -n "$DEFAULT_GW" && "$IP" == "$DEFAULT_GW" ]]; then
            if [[ $IS_ETH0_CONFIG -eq 1 ]]; then
                print_status "$YELLOW" "  Warning: IP $IP matches default gateway (eth0 config file - not modified)"
            else
                print_status "$RED" "  *** CONFLICT: IP $IP conflicts with default gateway!"
                CONFLICTS_FOUND=$((CONFLICTS_FOUND + 1))
                CONFLICT_DETECTED=1
            fi
        fi
        
        # If conflict detected and not in eth0 config, comment out the line
        if [[ $CONFLICT_DETECTED -eq 1 && $IS_ETH0_CONFIG -eq 0 ]]; then
            comment_out_line "$file" "$FULL_LINE"
            FILE_MODIFIED=1
            MODIFICATIONS_MADE=$((MODIFICATIONS_MADE + 1))
        fi
        
        # Check if IP is in the same network as eth0 (potential conflict)
        if [[ -n "$ETH0_IP" && "$IP" != "$ETH0_IP" && $CONFLICT_DETECTED -eq 0 ]]; then
            if same_network "$IP" "$ETH0_IP"; then
                if [[ $IS_ETH0_CONFIG -eq 1 ]]; then
                    print_status "$YELLOW" "  Info: IP $IP is in the same network as eth0 ($ETH0_IP) - eth0 config"
                else
                    print_status "$YELLOW" "  Warning: IP $IP is in the same network as eth0 ($ETH0_IP)"
                fi
            fi
        fi
        
    done <<< "$ADDRESSES_WITH_LINES"
    
    if [[ $FILE_MODIFIED -eq 1 ]]; then
        print_status "$GREEN" "  File $file has been modified"
    elif [[ $IS_ETH0_CONFIG -eq 1 ]]; then
        print_status "$GREEN" "  eth0 config file checked (no modifications made)"
    fi
    
    echo
    
done <<< "$CONFIG_FILES"

# Summary
echo "=== Summary ==="
if [[ $CONFLICTS_FOUND -eq 0 ]]; then
    print_status "$GREEN" "No IP conflicts detected!"
else
    print_status "$RED" "Found $CONFLICTS_FOUND IP conflict(s)!"
    if [[ $MODIFICATIONS_MADE -gt 0 ]]; then
        print_status "$GREEN" "Successfully commented out $MODIFICATIONS_MADE conflicting entries"
        echo
        print_status "$YELLOW" "IMPORTANT NOTES:"
        echo "• Backup files have been created with timestamp suffixes"
        echo "• You may need to restart networking: 'systemctl restart networking'"
        echo "• eth0 configuration files are never modified - only warnings are shown"
        echo "• Review commented lines and adjust configuration as needed"
        echo "• Test network connectivity after changes"
    fi
fi

# Additional checks
echo
print_status "$GREEN" "Additional recommendations:"
echo "• Review all network configurations for consistency"
echo "• Ensure static IPs don't conflict with DHCP ranges"
echo "• Check that gateway IPs are not assigned to interfaces"
echo "• Consider using different subnets for different purposes"

if [[ $MODIFICATIONS_MADE -gt 0 ]]; then
    echo
    print_status "$YELLOW" "To restore original configuration:"
    echo "• Find backup files with: find /etc/network/interfaces.d/ -name '*.backup.*'"
    echo "• Restore with: cp backup_file original_file"
fi

exit $CONFLICTS_FOUND
