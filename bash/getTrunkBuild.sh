tday=$(date '+%m_%d_%Y')
yday=$(date --date yesterday '+%m_%d_%Y')
twodays=$(date --date "2 days ago" '+%m_%d_%Y')
host='flog.vpi.hp.com'
bpath='IBRIX-Store/daily_builds'
brel='TRUNK'
build=${1}

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

function getbuild() {
	local day=${2}
	echo -e "\n\t==================\n\tbuild_${day}/release/${build}\n\t==================\n"
	curl -o ${build}  http://${host}/${bpath}/${brel}/build_${day}/release/${build} 
}

if (( customUrl ))
then
	build=$(echo ${BaseURL} | awk -F "/" '{ print $NF}')	
	curl -o ${build}  ${BaseURL}
else
	getbuild ${build} ${tday}
fi
