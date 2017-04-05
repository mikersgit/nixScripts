 #!/bin/bash

#
# use dd to create files of specific sizes, either append or not
# data written is from /dev/urandom
#########

INFILE='/dev/urandom'
OUTPFX='file'
COUNT=1
PROG=${0##*/}
NameSet=0
Repeat=0;numr=0;rept=""
holes='n'
apnd='n'

function usage() {
    echo -e "usage: ${PROG} [-n numFiles] [-z writeSize] [-a append y/n] \c"
    echo "[-p fileNamePrefix] [-r numRepeat] [-H holes y/n]"
    echo -e "\tuses /dev/urandom as the input"
    exit 1
}

while getopts n:z:a:p:r:H:h? OPT
do
    case ${OPT} in
        n) numf="${OPTARG}";;
        z) wsz="${OPTARG}";;
        a) apnd="${OPTARG}";;
        p) OUTPFX="${OPTARG}";NameSet=1;;
        r) numr="${OPTARG}";Repeat=1
            rept="${numr} times";;
        H) holes="${OPTARG}";;
        *) usage
    esac
done

# prompt for anything not provided
#
[[ -z ${numf} ]] &&
     read -p"Manipulate how many files: " numf ; [[ -z ${numf} ]] && usage
[[ -z ${wsz} ]] &&
     read -p "Write size in bytes: " wsz ; [[ -z ${wsz} ]] && usage
[[ -z ${apnd} ]] &&
     read -p "Append to existing? (y/n): " apnd ; [[ -z ${apnd} ]] && usage
(( ! NameSet )) &&
    read -p "file name prefix (def: \"${OUTPFX}\"): " OUTPFX
    : ${OUTPFX:="file"}

# set append options
if [[ ${apnd} = [yY] ]]
then
    convFlg="conv=notrunc oflag=append"
    mode="appended"
else
    convFlg=""
    mode="truncated"
fi
# set seek options
if [[ ${holes} = [yY] ]]
then
    seek="seek=1"
    mode="notruncate, with holes"
    # take off 'append' oflag
    if (( ${#convFlg} ))
    then
        convFlg="conv=notrunc"
    fi
else
    seek=""
fi

# use the 'seq' command to generate list of sequential numbers
#
for i in $(seq 1 ${numf})
{
    for ((j=0;j<=numr;j++))
    {
        if (( ${#seek} ))
        then
            (( k = j+1 ))
            seek="seek=${k}"
        fi
        dd  if=${INFILE} \
            of=${OUTPFX}${i} \
            ${convFlg} \
            ${seek} \
            count=${COUNT} \
            bs=${wsz} >/dev/null 2>&1
    }
}
echo -e "\n${wsz} bytes written ${mode} to each of ${numf} \
files ${rept} with names of the form \"${OUTPFX}NUM\"."
