#!/bin/bash
 #"CompanyLease": "Permian Resources",
    #"Name": "Walker 28 2H",
    #"Address": "166.166.40.100:8080",
    #"CompanyLeaseSlashName": "Permian Resources/Walker 28 2H"
CompanyLease="Odessa Lab"
#read -p"CompanyLease: " CompanyLease
MORE=1
while ((MORE))
do
read -p"Name: " Name
read -p"Address: " Address
echo '   {' >> WellJson
echo "     \"CompanyLease\": \"${CompanyLease}\"," >> WellJson
echo "     \"Name\": \"${Name}\"," >> WellJson
echo "     \"Address\": \"${Address}\"," >> WellJson
echo "     \"CompanyLeaseSlashName\": \"${CompanyLease}/${Name}\"" >> WellJson
echo '   },' >> WellJson
read -p"More? " ans
[[ ${ans} = 'n' ]] && MORE=0
done
