#!/bin/bash
yum -y --nogpgcheck install iscsi-initiator-utils.x86_64
service iscsi start
chkconfig iscsi on
iscsiadm -m discovery -t sendtargets -p 172.27.1.127
iscsiadm -m node -T iqn.2010-11.com.hp.vpi:0050563A0763 -p 172.27.1.127 --op update -n node.startup -v automatic
iscsiadm -m node -T iqn.2010-11.com.hp.vpi:0050563A0763 -p 172.27.1.127 --login

yum install -y fuse.x86_64 fuse-libs.x86_64

~/bin/agileUp.sh -n 2 \
                 -U eth1 -u 172.27.1.41 \
                 -N mwr1_cl \
                 -C eth0 -c 10.30.252.41 \
                 -I ibrix-pkgfull-FS_6.0.253+IAS_6.0.253-x86_64.iso -L 10.30.244.111:/var/iso
