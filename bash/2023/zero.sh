#!/bin/bash
cd $1
dd if=/dev/zero of=zero bs=4K
sync
rm zero

