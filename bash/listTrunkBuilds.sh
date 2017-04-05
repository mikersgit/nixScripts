tday=$(date '+%m_%d_%Y')
yday=$(date --date yesterday '+%m_%d_%Y')
twodays=$(date --date "2 days ago" '+%m_%d_%Y')
host='flog.vpi.hp.com'
bpath='IBRIX-Store/daily_builds'
brel='TRUNK'

customUrl=0

if [[ $1 = "-u" ]]
then
  BaseURL=${2}
  customUrl=1
else
  BaseURL="http://${host}/${bpath}/${brel}/"
fi

echo -e "\n\t${BaseURL}"
sleep 3

function list() {
	local day=${1}
	echo -e "\n\t==================\n\tbuild_${day}\n\t==================\n"
	curl --silent -l http://${host}/${bpath}/${brel}/build_${day}/release/ |
	sed -e 's/</ /g' -e 's/>/ /g' |
	awk '{c=split($0,ary)
		for (i=1;i<=c;i++) {
			if (ary[i] ~ /href/ && ary[i] ~ /ibrix/) printf("%s\t%s\n",ary[i+1],ary[i+11])
		}
	}'
}

if (( customUrl ))
then
	curl --silent -l ${BaseURL} |
        sed -e 's/</ /g' -e 's/>/ /g' |
        awk '{c=split($0,ary)
                for (i=1;i<=c;i++) {
                        if (ary[i] ~ /href/ && ary[i] ~ /ibrix/) printf("%s\t%s\n",ary[i+1],ary[i+11])
                }
        }'
else
	for d in ${tday} ${yday} ${twodays}; { list ${d};}
fi
