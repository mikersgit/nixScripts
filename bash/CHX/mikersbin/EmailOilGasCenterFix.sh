#!/bin/bash
##########################################
## process to re-enable smarten email service for Smarten controllers
## web page: https://www.thexyz.com/account/login

echo 'username: sergey.manucharian@championx.com'
echo 'password: ChampionX123!'
echo 'My Services -> Thexyz Custom Domain Email -> Managing Mailboxes'
echo 'Click "Enable" for "Smarten" mailbox, then click "Smarten" and reset password'
echo '23dbc7a40648b449e0eae2d6a7693158!'
explorer.exe https://www.thexyz.com/account/login

##
# To change settings or recover service navigate:
# 
# My Services -> Thexyz Custom Domain Email -> Managing Mailboxes
# 
# There are 2 mailboxes: "info" and "smarten". The first one never has issues, David Dennis knows how we use it in PCSF software and in the corresponding automated builds.
# 
# When the service stops working "smarten" mailbox gets disabled and its password gets reset. It can be re-enabled by clicking "Enable" button.
# Then you click the name "smarten" and set the password:
# 
# 23dbc7a40648b449e0eae2d6a7693158!
# 
# This is an MD5 hash of word "smarten" plus "!"
# Can be easily retrieved by running:
# echo -n smarten |md5sum| awk '{print $1"!"}' 

# To verify the box is working, get on gen4.oilgas.center and run mbsync -a -V. Should complete without errors
#echo "get to exodus.center, and then execute:"
#echo "ssh -p2730 michaelr@gen4.oilgas.center 'sudo su -l sergeym -c "/usr/bin/mbsync -a -V"'"
# Jump through exodus.center to gen4.oilgas.center and execute the mail box sync command
echo 'To verify that the mail box is working ssh to gen4 using the below "Jump" ssh to run the sync command'
echo 'which should complete without errors.'
echo 'michaelr:ChampionX123!'
echo 'ssh -p 2730 -J exodus@exodus.center:2730 michaelr@gen4.oilgas.center "./checkSmartenMailBox.sh"'
