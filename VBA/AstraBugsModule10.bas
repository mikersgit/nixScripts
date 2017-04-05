Attribute VB_Name = "Module10"
Sub FilterYellowZones()
Attribute FilterYellowZones.VB_Description = "Filter the list of bugs to yellow zones"
Attribute FilterYellowZones.VB_ProcData.VB_Invoke_Func = "Y\n14"
'
' FilterYellowZones Macro
' Filter the list of bugs to yellow zones
'
' Keyboard Shortcut: Ctrl+Shift+Y
'
    ActiveSheet.Range("$I$1:$AJ$800").AutoFilter Field:=2, Criteria1:="1"
    ActiveWindow.ScrollColumn = 2
    ActiveWindow.ScrollColumn = 3
    ActiveWindow.ScrollColumn = 4
    ActiveWindow.ScrollColumn = 5
    ActiveWindow.ScrollColumn = 6
    ActiveWindow.ScrollColumn = 7
    ActiveWindow.ScrollColumn = 8
    ActiveWindow.ScrollColumn = 9
    ActiveWindow.ScrollColumn = 10
    ActiveWindow.ScrollColumn = 11
    ActiveWindow.ScrollColumn = 12
    ActiveWindow.ScrollColumn = 13
    ActiveWindow.ScrollColumn = 14
    ActiveSheet.Range("$I$1:$AJ$800").AutoFilter Field:=10, Criteria1:= _
        "=*astra*", Operator:=xlAnd
    ActiveWindow.ScrollColumn = 16
    ActiveWindow.ScrollColumn = 17
    ActiveWindow.ScrollColumn = 18
    ActiveWindow.ScrollColumn = 19
    ActiveSheet.Range("$I$1:$AJ$800").AutoFilter Field:=21, Criteria1:=Array( _
        "---", "Defect", "Defect (same as --)", "Usability Bug"), Operator:= _
        xlFilterValues
End Sub
