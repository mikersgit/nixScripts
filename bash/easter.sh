#!/bin/bash
#
# Date of Easter based on the calculation published at:
# http://www.usno.navy.mil/USNO/astronomical-applications/astronomical-information-center/date-easter
#
# Ash Wednesday is 46 days before Easter Sunday
#
#################

thisyear=$(date '+%Y')


if [[ $# > 0 ]]
then
	# if first arg is not a digit show usage and exit
	if [[ $1 != [[:digit:]]* ]]
	then
		echo "usage: ${0##*/} | ${0##*/} <year>"
		exit 1
	fi
   year=$1
   pre='In the'
   (( thisyear > year )) && w='was'
   (( thisyear < year )) && w='will be'
   (( thisyear == year )) && w='is'
else
   year=$(date '+%Y')
   pre='This'
   w='is'
fi

shortyear=$(echo $year| awk '{f=substr($0,(length($0)-1));print f}')

days[1]=31 #Jan
days[2]=28 #Feb
days[3]=31 #Mar
days[4]=30 #Apr
days[5]=31 #May
mo[1]='Jan'
mo[2]='Feb'
mo[3]='Mar'
mo[4]='Apr'
mo[5]='May'

#
# is this a leap year?
#
(( ! (year % 4) )) &&  days[2]=29 #assume it is if div by 4

#
# set back to 28 if is a century year and ! div by 400, like 1900
#
if [[ $shortyear = "00" ]]
then
   (( year%400 )) && days[2]=28
fi

    (( c=year / 100 ))
    (( n=year - 19 * ( year / 19 ) ))
    (( k=( c - 17 ) / 25 ))
    (( i=c - c / 4 - ( c - k ) / 3 + 19 * n + 15 ))
    (( i=i - 30 * ( i / 30 ) ))
    (( i = i - ( i / 28 ) * ( 1 - ( i / 28 ) * ( 29 / ( i + 1 ) ) * ( ( 21 - n ) / 11 ) ) ))
    (( j=year + year / 4 + i + 2 - c + c / 4 ))
    (( j=j - 7 * ( j / 7 ) ))
    (( l=i - j ))
    (( m=3 + ( l + 40 ) / 44 ))
    (( d=l + 28 - 31 * ( m / 4 ) ))

awm=$m
awd=46
cont=1

(( awd=awd-d )) # subtract the days into the Easter month
(( awm=awm-1 ))

while (( cont ))
do

    if (( awd < ${days[${awm}]} ))
    then
	(( awd=(${days[${awm}]}-$awd) ))
	cont=0
    else
	(( awd=($awd-${days[${awm}]}) ))
	(( awm=awm-1 ))
    fi
   
done

echo -e "${pre} year: ${year}"
echo -e "Ash Wednesday $w on\n\tmonth: ($awm)${mo[$awm]} day: $awd"
echo -e "Easter $w on\n\tmonth: ($m)${mo[$m]} day: $d"

