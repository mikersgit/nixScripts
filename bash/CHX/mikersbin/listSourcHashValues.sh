#!/bin/bash
# output the HEAD git ID for the repos used to make the image
#======== rootfs/ ==========
#839dd47352a57f7e8a47e051730c1da578fe4781
#======== Exodus/ ==========
#c0d4c4401bc9b0ac763001cab2cd0e974c603ba4
#======== OS/ ==========
#1c563ba9108247064558ddc285b944af6cb536bf
#
# output all the hashes regardless of platform
# commented out if/then/else
#if [[ $1 = "BBB" ]] ; then
        #commonName=(ExodusCmain RootFs HMI BBB_Kernel)
        #repos=(Exodus/ rootfs/ OS/ BBB_Kernel/)
#else
        #commonName=(ExodusCmain RootFs HMI TBone BBB_Kernel)
        #repos=(Exodus/ rootfs/ OS/ TBone/ BBB_Kernel/)
#fi

commonName=(ExodusCmain RootFs HMI TBone BBB)
repos=(Exodus/ rootfs/ OS/ TBone/ BBB_Kernel/)
echo "========= Sources ========="
echo -e "\tInitialInstall\tsrc: "
c=0
for d in ${repos[@]}
{
	if test -e ${d};
	then
		cd $d
		hash=$(git log -1 --date=short --pretty=format:'%cd %H')
		echo -e "\t${commonName[$c]}\tsrc: $hash"
		cd ..
	fi
	((c+=1))
}
