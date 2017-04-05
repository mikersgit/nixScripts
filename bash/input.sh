#!/bin/bash

echo "type comments then ctrl-D when done"

cat - > someFile 

echo -e "\n\tyou typed:\n"
cat someFile
echo -e "\n\tmade it!"

read -p"need bug: " bug

echo $bug
