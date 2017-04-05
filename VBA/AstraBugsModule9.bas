Attribute VB_Name = "Module9"
Sub copyit()
Attribute copyit.VB_Description = "copy formula multiple time"
Attribute copyit.VB_ProcData.VB_Invoke_Func = "C\n14"
'
' copyit Macro
' copy formula multiple times
' in 'formula menu select 'manual calculate' this speeds up the paste of formulas
' select cell w/ formula
'   go to edit bar and select ctrl+c text
'   esc
'   issue macro shortcut
' re-enable auto calculate
'
' Keyboard Shortcut: Ctrl+Shift+C
'
    Application.Calculation = xlManual
    Dim i As Integer
    
    For i = 1 To 10
    ActiveCell.Offset(1, 0).Range("A1").Select
    ActiveSheet.Paste
    ActiveCell.Offset(1, 0).Range("A1").Select
    ActiveSheet.Paste
    ActiveCell.Offset(1, 0).Range("A1").Select
    ActiveSheet.Paste
    ActiveCell.Offset(1, 0).Range("A1").Select
    ActiveSheet.Paste
    ActiveCell.Offset(1, 0).Range("A1").Select
    ActiveSheet.Paste
    ActiveCell.Offset(1, 0).Range("A1").Select
    ActiveSheet.Paste
    ActiveCell.Offset(1, 0).Range("A1").Select
    ActiveSheet.Paste
    ActiveCell.Offset(1, 0).Range("A1").Select
    ActiveSheet.Paste
    ActiveCell.Offset(1, 0).Range("A1").Select
    ActiveSheet.Paste
    Next i
    Application.Calculation = xlAutomatic
End Sub
Sub RedZone()
Attribute RedZone.VB_Description = "Filter Red Zone"
Attribute RedZone.VB_ProcData.VB_Invoke_Func = "Z\n14"
'
' RedZone Macro
' Filter Red Zone
'
' Keyboard Shortcut: Ctrl+Shift+Z
'
    ActiveSheet.Range("$I$1:$AJ$800").AutoFilter Field:=1, Criteria1:="1"
    ActiveSheet.Range("$I$1:$AJ$800").AutoFilter Field:=10, Criteria1:= _
        "=*Astra**", Operator:=xlAnd
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
    ActiveWindow.ScrollColumn = 15
    ActiveWindow.ScrollColumn = 16
    ActiveSheet.Range("$I$1:$AJ$800").AutoFilter Field:=21, Criteria1:= _
        "<>*Task*", Operator:=xlAnd
End Sub
