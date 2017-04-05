#!/bin/bash

# replace vi with vim

mv /bin/vi /bin/vi_real ; ln -s /usr/bin/vim /bin/vi
