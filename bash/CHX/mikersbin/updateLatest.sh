#!/bin/bash
echo "cd to latest"
cd latest || exit 1
Files=(emmc_appsboot*.mbn kernel-*img rootfs-2*img splash*.img)
Part=(aboot boot system splash)
i=0
echo "list device attached"
fastboot devices
for f in $(ls -1 ${Files[@]})
do
	echo "===================================="
	echo "=== flash ${f} to ${Part[$i]} ======"
	echo "===================================="
	fastboot flash ${Part[$i]} ${f}
	((i+=1))
done
echo "reboot device attached"
fastboot reboot
