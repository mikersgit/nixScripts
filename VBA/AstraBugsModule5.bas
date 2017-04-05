Attribute VB_Name = "Module5"
Sub NonMasterBugs()
Attribute NonMasterBugs.VB_Description = "Remove bugs from listing that have [Master] in summary"
Attribute NonMasterBugs.VB_ProcData.VB_Invoke_Func = "m\n14"
'
' NonMasterBugs Macro
' Remove bugs from listing that have [Master] in summary
'
' Keyboard Shortcut: Ctrl+m
'
    ActiveSheet.Range("$I$1:$AC$800").AutoFilter Field:=6, Criteria1:= _
        "<>*[Master]*", Operator:=xlAnd
End Sub
