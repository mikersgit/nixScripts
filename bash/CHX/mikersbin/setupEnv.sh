function addVars() {
	if [[ ${ConfExists} -ne 1 ]] ;then
		baseDir="li=/localBuild/image"
		export ${baseDir}
		varArray=(${baseDir})
		idx=1
	else
		idx=0
	fi
	while :
	do
		read -p "env var and value var=value: " ans
		export ${ans}
		varArray[$idx]="${ans}"
		((idx+=1))
		read -p "more vars? " ans
		if [[ ${ans} == [nN] ]] ;then
			break
		fi
	done
	echo "Saving to Envsetup.conf"
	for v in ${varArray[*]}
	do
		echo "export ${v}" >> ${EnvFile}
	done
}

EnvFile=Envsetup.conf
if [[ -e ${EnvFile} ]] ;then
	ConfExists=1
	echo "currently configured env vars in ${EnvFile}"
	cat ${EnvFile}
	source ${EnvFile}
	read -p "Configure additional env vars? [Y]|N " ans
	[[ ${ans} != [nN] ]] && addVars
else
	ConfExists=0
	addVars
fi
