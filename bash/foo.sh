#!/bin/bash

# less common, but works
# to get stdout and stderr going to a file
#
echo "un-common redirection" >> logit 2<&1
ls Nothing >> logit 2<&1

echo "common redirection" >> logit 2>&1
ls Nothing >> logit 2>&1
