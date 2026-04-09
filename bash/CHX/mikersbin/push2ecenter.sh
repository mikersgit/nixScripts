#!/bin/bash
set -x
strings libRIB2.so.1.0 |grep V5
rsync -e 'ssh -p 2730' libRIB2.so.1.0 exodus@50.116.29.158:/usr/local/www/files/misc/mwr/.
