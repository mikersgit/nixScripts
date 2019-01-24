echo OFF

set sys=15.250.145.150
set shar=home
set drv=G

set passw=hpinvent
set domain=local_cluster
set user=mwroberts

net use %drv%: \\%sys%\%shar% %passw% /user:%domain%\%user% /PERSISTENT:YES

