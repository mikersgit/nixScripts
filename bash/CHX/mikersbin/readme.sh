#!/usr/local/bin/bash
# intended for use on exodus.center. bash is in an unusual location there.
# as well md5 has a "-q" option there that just prints out the sum
##
# using printf so that there isn't a crlf until after the md5 is run. that puts
# everything on one line
##
echo "Updating README.txt"
MD5="/sbin/md5 -q"
for f in *exe *xz *deb *img *mbn *msi
{
        if [[ -e "${f}" ]];then
                ls -lh "${f}" |awk '{printf("%s %s %s ",$5,$6,$7)
		for ( a=9,a <= $NF,a++)
		{
			printf("%s ",a)
		}
		printf(" MD5: ")
		}'
                $MD5 "${f}"
        fi
}
