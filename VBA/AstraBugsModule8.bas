Attribute VB_Name = "Module8"
Sub BetaBlocker()
Attribute BetaBlocker.VB_Description = "Beta bugs in the RedZone"
Attribute BetaBlocker.VB_ProcData.VB_Invoke_Func = "b\n14"
'
' BetaBlocker Macro
' Beta bugs in the RedZone
'
' Keyboard Shortcut: Ctrl+b
'
    Application.Run "AstraBugs.xlsm!RedZone"
    ActiveSheet.Range("$J$1:$AC$800").AutoFilter Field:=10, Criteria1:= _
        "=*buc1*", Operator:=xlAnd
End Sub
