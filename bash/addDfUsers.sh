#!/bin/bash

# the groups from the dogfood server were created
# smbldap-groupadd -g 2001 -p protocols
# smbldap-groupadd -g 2004 -p LabMan
# the 'Administrators' group already existed with gid '544'
# so for any of the DF users that had that group the '544' gid
# was used.

#smbldap-useradd -m -u 10101 -g sngrgp01 sngru01

#
# Users from the DF were gathered with:
# /opt/likewise/bin/lw-enum-users |
# awk '{  if( $2 ~ /^DEV|Administrator|Guest/) {
#              getline;getline;next
#       }
#       gsub("LOCAL","")
#       if($1 ~ /^Name/) printf("%s ",$2)
#       if($1 ~ /^Uid/) printf("%s ",$2)
#       if($1 ~ /^Gid/) printf("%s\n",$2)
#    }' |
# sed -e 's:\\::'

# list is in form of
# userName Uid Gid
##
echo "karl 2001 2001
mwroberts 2003 2001
sdouglas 2004 2001
admin 2005 544
dbeaver 9001 544
lswift 2008 2001
mberry 2009 544
evertson 2010 544
letmein 2012 2001
jsousa 2014 2001
dliptak 2015 2004
test 2016 2004
schaffer 2020 2001
ctc 2019 2001
ierickson 2017 544
mattd 2013 544
mtest1 2023 2001
mtest2 2022 2001
rbuser 2024 2001
lwoffshore 2025 2001
cassie 2026 2001
dpotts 2027 2001" | while read n u g
do
    #echo "name $n  uid $u gid $g"
    smbldap-useradd -m -u $u -g $g $n
done
