
rem delayed expansion fixes the problem of not getting cummulative string
rem built for bug summary list in for loop
rem
setlocal EnableDelayedExpansion
echo off
rem batch file to open webtabs for each bug in a file

set src=c:\Users\mwroberts\Desktop\users
set prog="c:\Program Files (x86)\Mozilla Firefox\firefox.exe"
rem URL for bug detail tab per bug
rem set ldapUrlA=https://g4t0029.houston.hp.com/dilbert/dilbert.cgi?base=o%3Dhp.com&advanced_search=off&search_value=
rem set ldapUrlB=michael.roberts%40hpe.com&ads_search=&search_choice=E-mail&port=636&host=hpe-pro-ods-ed-master.infra.hpecorp.net&column0=ntUserDomainId&custom_display=ntUserDomainId&scope=sub
rem set name=michael.roberts
rem URL for bug summary page with all bugs listed
for /F %%n in (%src%) do (
	
	set qURL="https://g4t0029.houston.hp.com/dilbert/dilbert.cgi?base=o%%3dhp.com&advanced_search=off&search_value="%%n"%%40hpe.com&ads_search=&search_choice=E-mail&port=636&host=hpe-pro-ods-ed-master.infra.hpecorp.net&column0=ntUserDomainId&custom_display=ntUserDomainId&scope=sub"
	start "title" %prog% !qUrl!
	timeout 2
	rem start "title" %prog% %bugUrl%%%i
	rem set TmpSumBugUrl=!SumBugUrl!%%i" "
	rem set SumBugUrl=!TmpSumBugUrl!
)
rem launch summary tab
rem start "title" %prog% !SumBugUrl!
rem pause
rem for /F %%i in (%src%) do start "title" %ieprog% %bugUrl%%%i
