#!/bin/bash
# on the controller execute as user 'exodus'
# this sets up a tunnel that forwards to port 2730 from 9970
ssh -R9970:localhost:2730 exodus.center
# Then on a remote machine you can just
ssh -p9970 exodus@exodus.center
