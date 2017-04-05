echo off
rem batch file to download Manchester RZ bug report in CSV format
rem 25-Jan-2015 switch from Atlas to Aurora
rem 28-Mar-2016 removed running yellowZone and now run Aurora and Avitus RZ
rem 06-Jul-2016 add 'status synopsis' to query
rem
set prog="c:\Program Files (x86)\Mozilla Firefox\firefox.exe"
rem set ieprog="C:\Program Files (x86)\Internet Explorer\iexplore.exe"
rem bugzilla AuroraProtRedZone query to CSV output
set rzbugUrl=http://link.osp.hpe.com/u/24wb
rem bugzilla AvitusProtRedZone query (3-mar-2017 added 'for review')
set avitusRZurl=http://link.osp.hpe.com/u/268u
rem bugzilla AtlasMaintProtRedZone query
set AtlasMaintURL=http://link.osp.hpe.com/u/24wd
rem

start "rzreport" %prog% %rzbugUrl%
start "AvitusReport" %prog% %avitusRZurl%
start "AtlasMaintURL" %prog% %AtlasMaintURL%
