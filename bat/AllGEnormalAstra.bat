echo off
rem batch file to download all >= Normal protocol bugs in CSV format
set prog="c:\Program Files (x86)\Mozilla Firefox\firefox.exe"
rem set ieprog="C:\Program Files (x86)\Internet Explorer\iexplore.exe"
rem Lil'url for CSV link to AllOpenGENormal query
rem https://bugzilla.houston.hpecorp.net:1181/bugzilla/buglist.cgi?cmdtype=runnamed&namedcmd=AllOpenGENormal
set bugUrl=http://link.osp.hpe.com/u/24wa
start "report" %prog% %bugUrl%

rem the short URL is a shortening of the bugzilla search "AllOpenGENormal"
rem updated 26-Oct for the addition of 'Cross Protocol' component
rem 24-Jan bugzilla moved to https://bugzilla.houston.hpecorp.net:1181/bugzilla/
