#!/bin/bash
tar -cvf mwrGen.tar Common.pdb Common.dll Common.deps.json GenesisMcp.* 
scp -P 2730 mwrGen.tar  exodus@192.168.0.62:~/.
