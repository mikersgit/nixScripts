#!/bin/bash

# The RedHat page on crash setup:

# http://docs.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/6/html/\
#        Deployment_Guide/ch-kdump.html

kernelRev=$(uname -r)
# 2.6.18-194.el5
arch='x86_64'


#  curl -o kexec-tools-1.102pre-126.el5_6.6.${arch}.rpm \
#          http://ftp.sunet.se/pub/Linux/distributions/scientific/57/\
#                 ${arch}/SL/\
#                 kexec-tools-1.102pre-126.el5_6.6.${arch}.rpm
#  curl -o kernel-debuginfo-common-${kernelRev}.${arch}.rpm \
#          http://ftp.sunet.se/pub/Linux/distributions/scientific/5rolling/\
#                 archives/debuginfo/\
#                 kernel-debuginfo-common-${kernelRev}.${arch}.rpm
#  curl -o kernel-debuginfo-${kernelRev}.${arch}.rpm \
#          http://ftp.sunet.se/pub/Linux/distributions/scientific/5rolling/\
#                 archives/debuginfo/\
#                 kernel-debuginfo-${kernelRev}.${arch}.rpm

rpm -qa kexec\* kernel-debug\*
#kexec-tools-1.102pre-126.el5_6.6
#kernel-debuginfo-2.6.18-194.el5
#kernel-debuginfo-common-2.6.18-194.el5

# /boot/grub/grub.conf
# kernel /vmlinuz-${kernelRev} ro root=/dev/VolGroup00/LogVol00\
#        crashkernel=128M@16M

cd /usr/src
ln -s /usr/src/kernels/${kernelRev}-${arch} linux

cd /var/crash
ln -s /usr/lib/debug/lib/modules/${kernelRev}/vmlinux vmlinux 

echo 1 > /proc/sys/kernel/sysrq
service kdump status

#Kdump is operational
