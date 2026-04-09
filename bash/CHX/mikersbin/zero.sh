#!/bin/bash
cd $1
echo 'dd if=/dev/zero of=zero bs=4K'
dd if=/dev/zero of=zero bs=4K 2>/dev/null
sync
ls -l zero
echo "removing zero"
rm zero

