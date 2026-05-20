#!/bin/bash
strings ${1} |grep V[456] |awk '{print $2}'
