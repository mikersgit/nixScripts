#!/bin/bash
###
# DayOfYear2Date.sh
# Date2DayOfYear.sh
###

if [[ $1 =~ "link" ]]; then
	if [ ! -e Date2DayOfYear.sh ];then
		ln DayOfYear2Date.sh Date2DayOfYear.sh
	fi
	ls -l DayOfYear2Date.sh Date2DayOfYear.sh
	exit
fi
PROG=${0##*/}
YEAR=$(date "+%Y")
read -p "Year [${YEAR}]: " yr
[[ ${#yr} -eq 0 ]] && yr=${YEAR}

if [ $PROG = "DayOfYear2Date.sh" ]; then
	JUL=$(date "+%-j")
	read -p "day of year [${JUL}]: " doy
	[[ ${#doy} -eq 0 ]] && doy=${JUL}
	((doy-=1))
 	date -d "${doy} days ${yr}-01-01" +"Date: %Y %b %d"
else
	#
	# to go from date to jul
	#
	# date -d "2025-02-28" +"%-j"
	MO=$(date "+%m")
	read -p "Month [${MO}]: " mo
	[[ ${#mo} -eq 0 ]] && mo=${MO}
	DAY=$(date "+%d")
	read -p "Day [${DAY}]: " dy
	[[ ${#dy} -eq 0 ]] && dy=${DAY}

	date -d "${yr}-${mo}-${dy}" +"Day of year: %-j"
fi
