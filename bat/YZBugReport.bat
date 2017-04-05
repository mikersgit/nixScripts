echo off
rem batch file to download YZ bug report in CSV format
rem 28-Mar-2016 Run Yellow Zone report
rem
set prog="c:\Program Files (x86)\Mozilla Firefox\firefox.exe"
rem set ieprog="C:\Program Files (x86)\Internet Explorer\iexplore.exe"
rem bugzilla AuroraProtYelZone query
set yzbugUrl=http://link.osp.hpe.com/u/24wf
rem

start "yzreport" %prog% %yzbugUrl%
