#!/bin/bash
Ecenter='http://exodus.center/files'
PreRel='genesis/V5.1.0%20pre-release'
WWWpath="${Ecenter}/${PreRel}/"
# get to "latest" dir first so file globbing doesn't expand wrong list
echo "Go to latest"
mkdir -p latest
cd latest
Files=(emmc_appsboot*.mbn splash*.img rootfs-2*img.xz kernel-*img)

rm ${Files[@]} rootfs* 2>/dev/null
for f in ${Files[@]}
do
	echo "===================================="
	echo "=== ${f} ======"
	echo "===================================="
	wget -qr --no-parent -nd -A ${f} ${WWWpath}/
done

for i in *xz
{
	echo "Decompressing $i"
	xz -dT0 ${i}
}
