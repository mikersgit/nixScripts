#!/bin/bash
# SRV-APP101 (172.28.0.12):
# user: PCS.ASPEN 
# workgroup=NPSDOVER
# password=Apergy2018
# net help use
net use  \DELETE \\172.28.0.12
net use n: \\172.28.0.12\Automation /user:PCS.ASPEN Apergy2018
