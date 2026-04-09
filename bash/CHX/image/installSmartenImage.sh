#!/bin/bash
#
# Install Smarten Image tools dependencies that are delivered in smarten-imagetools deb
cd /build/image
## perl and its dependencies
dpkg -i *perl*deb

## git and its dependencies
dpkg -i git*deb

## VIM and its dependencies
dpkg -i vim*deb
