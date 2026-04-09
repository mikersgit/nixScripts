#!/bin/bash
par1=$1

function testVal() {
	local par=$1
	if test -n ${par} ;then
		echo "parameter set: ${par}"
	else
		echo "parameter NOT set"
	fi
}

testVal ${par1}
