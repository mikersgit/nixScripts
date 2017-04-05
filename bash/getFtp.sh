#!/bin/bash

# script to batch ftp gets
# assumes a .netrc that looks like
# machine ftp.usa.hp.com login globecas password R7tj^JN4
#
for N in 1 2 3 4
{
ftp -i ftp.usa.hp.com << eof
cd 18082011
cd Node${N}
cd log
! mkdir Node${N}
lcd Node${N}
mget I* f* i* e*
cd daily
! mkdir daily
lcd daily
mget I* f* i* e*
bye
eof
}
