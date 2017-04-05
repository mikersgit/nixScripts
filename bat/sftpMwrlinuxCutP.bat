echo off
rem batch file location is relative to where this bat file is called from
rem get/put location is controlled in the batch file 'cpBatch'
rem cd C:\"Documents and Settings"\mwroberts\Desktop\bats
echo on

"c:\Program Files\Putty\psftp" -v -b cpBatch mikers@mwrlinux.fc.hp.com
