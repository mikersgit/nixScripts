#!/bin/bash
PORT=$(ps -o args -p $(pgrep ibrcfrd)| awk -F "=" '$1 !~ /COMMAND/ {print $NF}')
ibrcfrctl  --op=udaemon --port=${PORT} --set-mask=1
