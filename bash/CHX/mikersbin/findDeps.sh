#!/bin/bash
#
# In a directory that contains at least one debian package file (*.deb) determine the dependent pakcages
# and then determine if they are already installed or not.
# Querry the user if download is requested
######################

if ls *deb >/dev/null 2>&1
then
	FND=DepsFound.txt
	NtFND=DepsNotFound.txt
	DWNLD=DepsDownload.txt
	rm -f $FND $NtFND
	TMPFL=$(mktemp)
	for d in *deb
	{ echo "+++++++++++ $d +++++++++++"
 		for p in $(dpkg-deb -I $d |grep "^ Depends" |sed -e 's/Depends://' -e 's/:any//g' -e's/,/ /g'|sed 's/[(][^)]*[)]//g')
 		{
			if dpkg -l $p >/dev/null 2>&1
			then
				echo $p found
				echo $p >> ${FND}
			else
				echo $p NOT found
				echo $p >> ${NtFND}
			fi
 		}
	}
	sort -u $FND > $TMPFL ; cp $TMPFL $FND ; sed -i -e '/dpkg$/d' -e '/install-info/d' $FND
	sort -u $NtFND > $TMPFL ; cp $TMPFL $NtFND ; sed -i '/[|]$/d' $NtFND
	rm -f $TMPFL
	rm -f $DWNLD
	for pkg in $(<$NtFND)
	{
  		if ls ${pkg}*deb >/dev/null 2>&1
  		then
			echo -e "		$pkg available"
  		else
			echo $pkg needs download
			echo $pkg >> $DWNLD
  		fi
	}
	if [ -e $DWNLD ]
	then
		for p in $(< $DWNLD)
		{
			read -p "Download ${p} ?[N] " ans
			[[ ${#ans} < 1 ]] && ans="N"
			if [ $ans = "Y" ] || [ $ans = "y" ]
			then
				echo "Downloading $p"
				apt download ${p}
			fi

		}
	fi
else
	echo "No Debian package files found in $PWD"
fi
