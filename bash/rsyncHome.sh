#!/bin/bash

#rsync used to copy home directory to another machine, skipping any mounts

cd $HOME
rsync -axv . 10.30.238.157:.

