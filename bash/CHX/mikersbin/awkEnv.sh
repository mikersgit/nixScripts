#!/bin/bash
export sfx=img
awk -v pfx=sdcard '{print "E: "ENVIRON["sfx"] "  V: "pfx }' /usr/bin/yes
