#!/bin/bash
grep "rpm"| awk -F "<a" '{gsub("\""," ");split($2,a," ");if (length(a[2]>4) && a[2] ~ /rpm$/) print a[2]}'
