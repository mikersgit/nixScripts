#!/bin/bash
echo "
	genperm run
	dogtag
	boot_tasks executable
	monitrc 0700
	crontabs
	fstab
	udev #comment out on tbone and leave in on bbb 70-persistent
	hosts
	libRIB2
	disable_cellmodem
	dir.info
	/autorun
	/mnt/ (777)
	/home/exodus/.ssh (700)
	deliver Keepalive, and remove SchneiderKeepAlive (deb package)
	uenv.txt change (see sergey team thread)
"

echo "[9/18 12:06 PM] Manucharian, Sergey

Hi Michael,

I just discovered, that we use a wrong /boot/uEnv.txt file for TBone. It comes from BBB's SD card. In the case of BBB we flash the EMMC from that rootfs, in TBone we copy the same rootfs. We have unattended keyword which tells /etc/pcsf/boot_tasks that it has to start the update process. I'm not sure it's really harmful, but I'd fix it at least for consistemcy.

[9/18 12:07 PM] Manucharian, Sergey

/boot/uEnv.txt should be replaced with /etc/default/uenv.emmc"
