######## must execute in PowerShell
######## just here so I don't have to google again

$lptAndCom = '{4d36e978-e325-11ce-bfc1-08002be10318}'
get-wmiobject -Class win32_pnpentity | where ClassGuid -eq $lptAndCom | select name
