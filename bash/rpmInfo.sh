 #!/bin/bash

# display the name, version, build host, build time, and install time of
# a package. If not package pattern given on command line, then search
# for default X9K rpms.

# to get a list of tags: rpm --querytags

fmtStr="%{N} %{V} %{R} \nBH %{BUILDHOST}\nBT %{BUILDTIME}\nIT %{INSTALLTIME}\n"
patrn=${1}

if (( $# < 1 ))
then
    # default package pattern
    patrn="-e Ibrix -e ibrix -e likewise"
fi

# get list of packages matching pattern
pkg=$(rpm -qa |grep ${patrn})

if (( ${#pkg} < 1 ))
then
        echo "No package matching pattern '${patrn}' found."
        exit 1
fi

echo -e "BH == Build Host : BT == Build Time : IT == Install Time\n"

rpm --qf "${fmtStr}"  -q  ${pkg} |
awk '{if ($1 ~ /[BI]T/) {
        printf("\t%s ",$1)
        system("date -d @"$2)
  }
  else {
  if ($1 ~ /BH/)
        printf("\t%s %s\n",$1,$2)
  else print
  }
}'
