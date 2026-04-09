#!/bin/bash
if [ $# -lt 6 ]
then
        echo "USAGE: ${0##*/} -i <Git deltas file> -d <Copy Dest Dir> -g <git directory>"
        echo "eg. ${0##*/} -i /home/exodus/tmp/deltas.txt -d /build/rootfs-20230706/ -g rootfs/current/"
        echo "eg. ${0##*/} -i /home/exodus/tmp/deltas.txt -d /build/userdata-20230706/ -g rootfs/current/"
        echo "Expectation is the git deltas were generated with getGitDeltas.sh."
        echo "========== USE ABSOLUTE PATH FOR Deltas, Dest Dir"
        echo ""
        echo "SPECIAL HANDLING:"
        echo "• userdata destinations: Only copy /var/, /etc/network/, /home/exodus/ with /vault prefix"
        echo "• rootfs destinations: Exclude /var/, /etc/network/, /home/exodus/ folders"
        exit
fi


# a ":" following an option on the "getopts" line means the option takes an argument
# the variable ${OPTARG} will contain that value
# use "shift 1" to skip over args other than the automatic OPTARG
# OPTIND is the current index in the list of supplied arguments
#

while getopts "d:i:g:" arg;
do
case ${arg} in
        d) DEST=${OPTARG}
            ;;
        i) DELTAS=${OPTARG}
            ;;
        g) GitDir=${OPTARG}
            ;;
esac
done
# shift passed declared options to anything remaining on command line
# access with ${@}
shift $((OPTIND-1))

# Determine destination type and filtering logic
isUserdata=false
isRootfs=false

if [[ ${DEST} == *"userdata"* ]]; then
    isUserdata=true
    echo "Userdata destination detected - filtering for /var/, /etc/network/, /home/exodus/ with /vault prefix"
elif [[ ${DEST} == *"rootfs"* ]]; then
    isRootfs=true
    echo "Rootfs destination detected - excluding /var/, /etc/network/, /home/exodus/ folders"
fi

# Function to check if file should be processed based on destination type
function shouldProcessFile() {
    local filepath="$1"
    
    # Check if file is in one of the special folders
    if [[ "$filepath" == var/* ]] || [[ "$filepath" == etc/network/* ]] || [[ "$filepath" == home/exodus/* ]]; then
        if [ "$isUserdata" = true ]; then
            return 0  # Process for userdata
        elif [ "$isRootfs" = true ]; then
            return 1  # Skip for rootfs
        fi
    fi
    
    # For other files
    if [ "$isUserdata" = true ]; then
        return 1  # Skip other files for userdata
    else
        return 0  # Process other files for rootfs or standard destinations
    fi
}

# Function to get the destination path with vault prefix if needed
function getDestinationPath() {
    local filepath="$1"
    local destBase="$2"
    
    if [ "$isUserdata" = true ]; then
        # Add /vault prefix for userdata destinations
        echo "${destBase}/vault/${filepath}"
    else
        # Standard path for rootfs or other destinations
        echo "${destBase}/${filepath}"
    fi
}

cd ${GitDir}
#for f in $(< ${DELTAS} )
cat ${DELTAS} | sort -u | while read s f
do
    # Check if this file should be processed based on destination type
    if ! shouldProcessFile "$f"; then
        echo "Skipping $f (filtered out for $(basename ${DEST}))"
        continue
    fi
    
    # Get the appropriate destination path
    destPath=$(getDestinationPath "$f" "${DEST}")
    
    case $s in
    D)
            echo "Delete ${destPath}"
            if test -e "${destPath}" ;then
                    rm "${destPath}"
            fi
            ;;
    *)
            fDIR=${f%/*}
            fFILE=${f##*/}
            
            # Create destination directory with vault prefix if needed
            if [ "$isUserdata" = true ]; then
                finalDestDir="${DEST}/vault/${fDIR}"
            else
                finalDestDir="${DEST}/${fDIR}"
            fi
            
            echo "Copying ${f} to ${finalDestDir}/${fFILE}"
            mkdir -p "${finalDestDir}"
            
            # Check if source file exists
            if [ ! -e "${f}" ]; then
                echo "Warning: Source file ${f} not found, skipping"
                continue
            fi
            
            cp "${f}" "${finalDestDir}/${fFILE}"
            if [ $? -eq 0 ]; then
                md5sum "${f}" "${finalDestDir}/${fFILE}"
            else
                echo "Error: Failed to copy ${f} to ${finalDestDir}/${fFILE}"
            fi
            ;;
    esac
done

echo -e "\nProcessing complete for $(basename ${DEST})"
if [ "$isUserdata" = true ]; then
    echo "Files copied to vault subdirectory for userdata destination"
elif [ "$isRootfs" = true ]; then
    echo "Special folders (/var/, /etc/network/, /home/exodus/) excluded for rootfs destination"
fi
