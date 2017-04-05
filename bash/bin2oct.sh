#!/bin/bash

# convert input value and base to output base
# behavior is based on command name. all are hardlinks
#

prog="${0##*/}"

# create command links
function createLinks() {
        BASES="hex bin dec oct"
        for i in ${BASES}
        {
                for j in ${BASES}
                {
                        if [[ ${i} != ${j} ]]
                        then
                                lnProg="${i}2${j}.sh"
                                [[ ! -f ${lnProg} ]] && \
                                        ln ${prog} ${lnProg}
                        fi
                }
        }
}

function usage() {
        echo "${prog}: [-c] | [[-v] value]"
        echo -e "\t-c create harlinks to conversion commands"
        echo -e "\t-v turn on verbose output"
        exit 1
}

verbose=0

(( ${#} < 1 )) && usage

if [[ ${1} = '-c' ]]
then
        echo "creating hardlinks to base conversion commands"
        createLinks
        exit 0
fi

if [[ ${1} = '-v' ]]
then
        verbose=1
        shift 1
elif [[ ${1} = '-?' ]] || [[ ${1} = '-h' ]] 
then
        usage
fi

iStr='Decimal: ';IN=''
oStr='Decimal: ';OUT=''

#     Command name  Output base   Input base  Output string    Input string
#     ############  ###########   ##########  #############    ############
case ${prog} in
        hex2bin.sh) OUT='2 o';    IN='16 i';  oStr='Binary: '; iStr='Hex: '   ;;
        hex2oct.sh) OUT='8 o';    IN='16 i';  oStr='Octal: ';  iStr='Hex: '   ;;
        hex2dec.sh)               IN='16 i';                   iStr='Hex: '   ;;
        dec2hex.sh) OUT='16 o';               oStr='Hex: '                    ;;
        dec2oct.sh) OUT='8 o';                oStr='Octal: '                  ;;
        dec2bin.sh) OUT='2 o';                oStr='Binary: '                 ;;
        bin2hex.sh) OUT='16 o';   IN='2 i';   oStr='Hex: ';    iStr='Binary: ';;
        bin2oct.sh) OUT='8 o';    IN='2 i';   oStr='Octal: ';  iStr='Binary: ';;
        bin2dec.sh)               IN='2 i';                    iStr='Binary: ';;
        oct2hex.sh) OUT='16 o';   IN='8 i';   oStr='Hex: ';    iStr='Octal: ' ;;
        oct2bin.sh) OUT='2 o';    IN='8 i';   oStr='Binary: '; iStr='Octal: ' ;;
        oct2dec.sh)               IN='8 i';                    iStr='Octal: ' ;;
                *) echo 'UNKNOWN CONVERSION' ; exit 1
esac

# make input all upper case for hex conversion
VAL=$(echo ${@} | tr '[[:lower:]]' '[[:upper:]]')

# print the base conversion names if verbose mode
if (( verbose ))
then
        echo "Convert ${iStr}${VAL}"
        echo -e "To ${oStr}\c"
fi

# use 'dc' command to convert between bases

dc << eon
${OUT}
${IN}
${VAL}
p
eon
