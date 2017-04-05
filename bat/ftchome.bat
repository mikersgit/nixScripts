echo OFF

set sys=ftchome.ibftc.vpi.hp.com
set shar=ftchome
set drv=F

set passw=hpinvent#1
set domain=ibftc
set user=mroberts

net use %drv%: \\%sys%\%shar% %passw% /user:%domain%\%user% /PERSISTENT:YES
