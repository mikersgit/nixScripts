echo off
rem batch file to download Manchester RZ bug report in CSV format
rem 25-Jan-2015 switch from Atlas to Aurora
rem 28-Mar-2016 removed running yellowZone and now run Aurora and Avitus RZ
rem 27-Apr-2016 Only run one rz report, for current aurora release
rem 06-Jul-2016 add 'status synopsis' to query
rem
set prog="c:\Program Files (x86)\Mozilla Firefox\firefox.exe"
rem set ieprog="C:\Program Files (x86)\Internet Explorer\iexplore.exe"
rem bugzilla AuroraProtRedZone query to CSV output
set rzbugUrl=http://link.osp.hpe.com/u/24wb
rem bugzilla AvitusProtRedZone query
rem set avitusRZurl=http://link.osp.hpe.com/u/1vxj
rem set AtlasMaintURL=http://link.osp.hpe.com/u/1w18
rem

start "rzreport" %prog% %rzbugUrl%
rem start "rzreport" %prog% %rzbugUrl%
rem start "AvitusReport" %prog% %avitusRZurl%
rem start "AtlasMaintURL" %prog% %AtlasMaintURL%
