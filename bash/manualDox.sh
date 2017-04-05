#!/bin/bash

# OUTPUT_BASE=/root/bin/doxygen/1.8.0/hpcifs/SMB3PH
# INPUT_BASE=/root/source/git/branch/iter12/
read -p "Output directory " OUTPUT_BASE
read -p "Input directory " INPUT_BASE
export OUTPUT_BASE=$OUTPUT_BASE
export INPUT_BASE=$INPUT_BASE
