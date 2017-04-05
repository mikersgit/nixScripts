echo off
rem batch file to download all >= Normal protocol bugs in CSV format
set prog="c:\Program Files (x86)\Mozilla Firefox\firefox.exe"
rem set ieprog="C:\Program Files (x86)\Internet Explorer\iexplore.exe"
rem set bugUrl=http://link.hp.com/u/1cxr w/o CRB/Waiver
rem AllResolvedOneYear updated 10-June-2016
set bugUrl=http://link.osp.hpe.com/u/24we
start "report" %prog% %bugUrl%
