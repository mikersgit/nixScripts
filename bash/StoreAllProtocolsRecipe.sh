#!/bin/bash

# This command will take a list of RPMs (I've tested on cygwin and RHEL) and
# generate the XML recipe file needed by the Astra program to generate the
# release ISO
#
# Expects that the list of RPMs is fed in via a pipe.
# eg. ls *.rpms | thisScript.sh
# this builds the RPM specific part of the file.
#
# @author Michael Roberts
# @date 7-Feb-2014
#

IR='IR10'
ReleaseNumber="1"
StoreAllVer="0.4.0"
ServerName="http://ftchome.ibftc.vpi.hp.com"
ServerLocation="${ServerName}/platform/Unity/${IR}/StoreAll/HPProtocols/latest"

ReleaseStr="<Release>${ReleaseNumber}</Release>"
OUT="StoreAllProtocolsRecipe_${IR}.xml"

# The xhead* variables build up the beginning of the XML file
#
xhead_0="<?xml version=\"1.0\" encoding=\"utf-8\"?>
<SoftwareRecipe>
  <Name>StoreAll</Name>
  <Version>${StoreAllVer}</Version>"

xhead_1="  ${ReleaseStr}"

xhead_2=' <Description>StoreAll RPMs</Description>
  <ComponentCategory>
    <Name>HP SMB Protocol</Name>
    <Description>HP SMB Protocol RPMs</Description>
    <Version></Version>
    <Release></Release>
    <ComponentList> '


# The xtail variable closes out the XML file
#
xtail="    </ComponentList>
    <YumRepoList>
      <YumRepo>
        <Type>http</Type>
	<Path>${ServerLocation}</Path>
      </YumRepo>
    </YumRepoList>
  </ComponentCategory>
</SoftwareRecipe>"

# Begin populating the recipe file
#
echo -e "${xhead_0}\n${xhead_1}\n${xhead_2}" > ${OUT}

#
# Expects that the list of RPMs is fed in via a pipe.
# eg. ls *.rpms | thisScript.sh
# this builds the RPM specific part of the file.
#
while read line
do
        # reduce to just RPM name. take into account that the list
        # can contain either windows or linux style paths
	l=${line##*/}
	l=${l##*\\}

        # Separate the RPM name into name and version chunks
        #
	declare -a b=($(echo ${l} |awk '{c=match($0,/[[:digit:]]/);sub(".rpm","");printf("%s ",substr($0,0,(c-2)));printf("%s",substr($0,c))}'))
	cName=${b[0]}
	cVer=${b[1]}
	echo -e '\t<Component>' >> ${OUT}
	echo -e '\t\t<Name>'${l}'</Name>' >> ${OUT}
	echo -e '\t\t<Type>RPM</Type>' >> ${OUT}
	echo -e '\t\t<CompName>'${cName}'</CompName>' >> ${OUT}
	echo -e '\t\t<Version>'${cVer}'</Version>' >> ${OUT}
	echo -e "\t\t${ReleaseStr}" >> ${OUT}
	echo -e '\t</Component>' >> ${OUT}
done


# close out the XML file
#
echo -e "${xtail}" >> ${OUT}

echo "XML is in: ${OUT}"

