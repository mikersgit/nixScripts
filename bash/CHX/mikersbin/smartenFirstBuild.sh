#!/bin/bash
# after cloning a new source, or branch, need to populate npm pkgs and build node.
# VS will then be able to build and run in local browser

# robocopy the "packages" dir from a working build
# robocopy DevTip\packages\ <new branch>\. /MT /COPYALL
# mkdir <new branch>\packages
#  Robocopy.exe .\v610\packages .\<new branch>\packages /E /MT /COPYALL
cd SmartenServer
 npm install
cd ../GenesisMcpClient
 npm install
cd ../SmartenClient # for react code
 npm install
 npm run build:all
 npm start
				###### end

 node .\SmartenServer\app.js

