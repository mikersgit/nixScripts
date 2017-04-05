#!/bin/bash
#
# update source from git
# copy latest target milestone conf file
src="${HOME}/hp-smb-tools/"
bugs="${src}/hp-bugs/masterBug.conf"
here=${PWD}
cd ${src}
git pull
cd ${here}
set -x
\cp ${bugs} .
