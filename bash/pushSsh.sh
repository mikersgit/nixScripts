#!/bin/bash
pckey='ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIB3vAcSYY2GwtyJcVcUIzHcq5Brjj2QLWoByIb1ywiWDKFB3MQ4tWnTjK5j8UGlzlFiV8MClUc3fiYiiMZUAX4JEiam7d40+FAptBJEve2ryAqPpvYGDW+ggSSYxEqS+9Go2Fn2Yo+BBkHojytdPiI18APZ1+QLkaA+NVMTKjjv+Q== rsa-key-20070207'

# could get this with
# pkey=$(< ~/.ssh/id_dsa.pub)
pkey='ssh-dss AAAAB3NzaC1kc3MAAACBAPJqxfS7Gnl4FFViYZyPze6MHxYh7jKNKr1VLtDN1RD2/t+kz4xPtgFDfDc+PUlOesHqnoJFg25/lljhVVpZZBsMBPNMKutX0FVJPF/LBICfHxqxBWNEP+GQ6i5ee1CPg1KCV+JWRxsHmvDTTXsMzqXqj9xi5G95PY8Pjw9HxkDzAAAAFQCnmJjhYbghJ7vpvxJ06x7yk05cXwAAAIBtBk3W/6J2Q9Lil8CRZpPdSV0H/DTxyinHizcvi8YQ8TjaH84twxN752DdBVHljfsWNqibbqW+OaKydCVKle41MVujg3I/R/Qve/9nq99d3yW707DbiR5G0vbZYBw7fmdCNYSB+W/Kp/s3oHMTwgrcOlGIh/Hoj2K9Iop2m4aOowAAAIEA75ru8710QJ7ddQX/EQz6VWIyqPYJX3kCyD8RKlWAJFxaMoMfAragu3pfkgfi4Smeh0PnurA4rnr0s93HsjxtIWQ+1AyhiKUn7phuHogY48BFyvy/hBqMnpErcurBxQ4323zbPHwF5nfli4+GIGIDkVzu6zQ2dv+7LKBCf+ppcsA= root@MY_HOST_NAME'
AuthFile='.ssh/authorized_keys'
AuthFile2='.ssh/authorized_keys2'

function usage() {
	echo "provide one IP address on command line."
	echo "second argument 'S' to also modify shell environment."
	exit 1
}

if (( ${#} < 1 ))
then
        usage
elif [[ $1 != [[:digit:]]* ]]
then
        usage
else
	IP=$1
fi

SETSHELL=0
USER=""
shift 1
case $1 in
    S) SETSHELL=1;shift 1;;
esac

if (( ${#} > 0 ))
then
    USER="${1}@"
fi

#
# add key
#
echo "set ssh keys on ${IP}"
for a in ${AuthFile} ${AuthFile2}
{
	echo ${pkey} | ssh -q ${USER}${IP} "cat - >> ${a}"
}

#
# set command line editor to emacs mode and add ibrix/bin and likewise 
# to path
#
if [[ $2 = [S] ]]
then
        echo "set emacs mode, ibrix path, aliases, nfs mounts on ${IP}"
        ssh -q ${USER}${IP} "echo 'set -o emacs' >> ~/.bash_profile"
        ssh -q ${USER}${IP} "echo 'export PATH=/usr/local/ibrix/bin:/opt/likewise/bin:${PATH}' >> ~/.bashrc"
	ssh -q ${USER}${IP} "echo -e 'alias bin=\0047cd ~/bin\0047' >> ~/.bashrc"
	ssh -q ${USER}${IP} "echo -e 'alias csi=\0047~/bin/csi.sh\0047' >> ~/.bashrc"
        ssh -q ${USER}${IP} "echo -e 'alias e=\0047echo\0047' >> ~/.bashrc"
        ssh -q ${USER}${IP} "echo -e 'alias g=\0047git\0047' >> ~/.bashrc"
	ssh -q ${USER}${IP} "echo -e 'alias gb=\0047git branch\0047' >> ~/.bashrc"
	ssh -q ${USER}${IP} "echo -e 'alias gc=\0047git commit\0047' >> ~/.bashrc"
	ssh -q ${USER}${IP} "echo -e 'alias gl=\0047git log\0047' >> ~/.bashrc"
        ssh -q ${USER}${IP} "echo -e 'alias gt=\0047git status\0047' >> ~/.bashrc"
	ssh -q ${USER}${IP} "echo -e 'alias gch=\0047git checkout\0047' >> ~/.bashrc"
	ssh -q ${USER}${IP} "echo -e 'alias gpl=\0047git pull\0047' >> ~/.bashrc"
        ssh -q ${USER}${IP} "echo -e 'alias h=\0047history\0047' >> ~/.bashrc"
	ssh -q ${USER}${IP} "echo -e 'alias hg=\0047history | grep \0047' >> ~/.bashrc"
        ssh -q ${USER}${IP} "echo -e 'alias r=\0047fc -s\0047' >> ~/.bashrc"
	ssh -q ${USER}${IP} "echo -e 'alias src=\0047. ~/bin/src.sh\0047' >> ~/.bashrc"
        ssh -q ${USER}${IP} "mkdir /root/bin"
        ssh -q ${USER}${IP} "mkdir /var/iso"
        ssh -q ${USER}${IP} "echo '10.30.38.206:/home_dirs/mwroberts/bin /root/bin   nfs     rw,vers=3,rsize=32768,wsize=32768,soft,proto=tcp,timeo=600,retrans=2,sec=sys 0 0' >> /etc/fstab"
        ssh -q ${USER}${IP} "mount /root/bin"
fi

###
## consider turning off un-needed daemons
###
#for d in bluetooth cups hidd avahi-daemon setroubleshoot rhnsd pcscd restorecond
#{
        #chkconfig ${d} off
        #/etc/init.d/${d}  stop
#}
