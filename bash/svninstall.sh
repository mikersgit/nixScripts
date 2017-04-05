#!/bin/bash +x
# WANdisco Subversion Installer V0.1
# opensource@wandisco.com
 
echo WANdisco Subversion Installer v0.1 for Redhat Enterprise Linux 5
echo Please report bugs or feature suggestions to opensource@wandisco.com
echo 
echo Gathering some information about your system...

MINVERSION='1'
SVNVER='1.6.11'
ARCH=`uname -m`
SVNSTATUS=`rpm -qa|grep ^subversion-[0-9]|awk 'BEGIN { FS = "-" } ; { print $1 }'`
NOW=$(date +"%b-%d-%y%s")

#functions
check_is_root ()
{
	if [[ $EUID -ne 0 ]]; then
   		echo "This script must be run as root" 1>&2
   		exit 1
	fi	
}
svn_remove_old ()
{
	if [ -f /etc/httpd/conf.d/subversion.conf ]; then
		echo Backing up /etc/httpd/conf.d/subversion.conf to /etc/httpd/conf.d/subversion.conf.backup-$NOW
		cp /etc/httpd/conf.d/subversion.conf /etc/httpd/subversion.conf.backup-$NOW
	fi
	echo Removing old packages...
	yum -y remove mod_dav_svn subversion subversion-devel subversion-perl subversion-python subversion-tools &>/dev/null
}
add_repo_config ()
{
        echo Adding repository configuration to /etc/yum.repos.d/
	if [ -f /etc/yum.repos.d/WANdisco-rhel5.repo ]; then
		echo "yum repo already installed. Skipping.."
	else
		echo " ------ Installing yum repo ------"
		wget http://opensource.wandisco.com/WANdisco-rhel5.repo -O /etc/yum.repos.d/WANdisco-rhel5.repo &>/dev/null
		echo "Importing GPG key"
		wget http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco -O /tmp/RPM-GPG-KEY-WANdisco &>/dev/null
		rpm --import /tmp/RPM-GPG-KEY-WANdisco
		rm -rf /tmp/RPM-GPG-KEY-WANdisco
		echo " ------ Installing yum repo: Done ------"
	fi
	
}
install_svn ()
{
        echo Checking to see if you already have Subversion installed via rpm...
        if [[ "$SVNSTATUS" =~ subversion ]]; then
		echo ------------------------------------------------------------------------------------------------
        	echo Subversion is already installed on the system.
        	echo Do you wish to replace the version of subversion currently installed with the WANdisco version? 
		echo This action will remove the previous version from your system 
		echo "[y/n]"
		read svn_install_confirm
		if [ "$svn_install_confirm" == "y" -o "$svn_install_confirm" == "Y" ]; then
			svn_remove_old
			add_repo_config
			echo		
			echo Installing Subversion $SVNVER-$MINVERSION
			echo
			yum -y install subversion.$ARCH subversion-perl.$ARCH subversion-python.$ARCH subversion-tools.$ARCH
 			echo Would you like to install apache and the apache SVN modules?
			echo "[y/n]"
			read dav_svn_confirm
			if [ "$dav_svn_confirm" == "y" -o "$dav_svn_confirm" == "Y" ]; then
				echo Installing apache and subversion modules
				yum -y install mod_dav_svn.$ARCH httpd
				echo Installation complete. Restart apache?
				echo "[y/n]"
				read apache_restart_confirm
				if [ $apache_restart_confirm == "y" -o $apache_restart_confirm == "Y" ]; then
					/etc/init.d/httpd restart	
				fi
				echo You can find the subversion configuration file for apache HTTPD at /etc/httpd/conf.d/subversion.conf
			fi
			
	       	else
			echo "Install Cancelled"
			exit 1
		fi

	else
		# Install SVN
		echo "Subversion is not currently installed"
		echo "Starting installation, are you sure you wish to continue?"
		echo "[y/n]"
		read svn_install_confirm
                if [ "$svn_install_confirm" == "y" -o "$svn_install_confirm" == "Y" ]; then
			add_repo_config
                        echo
                        echo Installing Subversion $SVNVER-$MINVERSION
                        echo
			yum -y install subversion.$ARCH subversion-perl.$ARCH subversion-python.$ARCH subversion-tools.$ARCH
                        echo Would you like to install apache HTTPD and the apache SVN modules?
			echo "[y/n]"
                        read dav_svn_confirm
                        if [ "$dav_svn_confirm" == "y" -o "$dav_svn_confirm" == "Y" ]; then
                                echo Installing apache and subversion modules
				yum -y install mod_dav_svn.$ARCH httpd
                                echo Installation complete. Restart apache? 
				echo "[y/n]"
                                read apache_restart_confirm
                                if [ $apache_restart_confirm == "y" -o $apache_restart_confirm == "Y" ]; then
                                        /etc/init.d/httpd restart
                                fi
				echo You can find the subversion configuration file for apache HTTPD at /etc/httpd/conf.d/subversion.conf
                        fi

                else
                        echo "Install Cancelled"
                        exit 1
                fi
		
        fi
	
}

install_32 ()
{
        echo Installing for $ARCH
	install_svn
}
install_64 ()
{
        echo Installing for $ARCH
	install_svn
}

#Main
check_is_root

echo Checking your system arch
if [ "$ARCH" == "i686" -o "$ARCH" == "i386" ]; then
        if [ "$ARCH" == "i686" ]; then
                ARCH="i386"
        fi;
	install_32
elif [ "$ARCH" == "x86_64" ];
then
	install_64
else 
	echo Unsupported platform: $ARCH
	exit 1
fi
