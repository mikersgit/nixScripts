#!/bin/bash
#
# to show the socket that is being used over UDP to communicate between exodus and engine
# netstat -u -ep
#Active Internet connections (w/o servers)
#Proto Recv-Q Send-Q Local Address           Foreign Address         State       User       Inode      PID/Program name
#udp        0      0 localhost:52970         localhost:12001         ESTABLISHED root       18455      3420/dotnet
#udp        0      0 localhost:36355         localhost:12000         ESTABLISHED root       18839      3420/dotnet
# capture traffic on any interface with verbosity, and write pcap to hmiNet.pcap
tcpdump -i any -XX -vv -w hmiNet.pcap
