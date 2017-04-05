Attribute VB_Name = "Module1"
Sub insertColumns()
Attribute insertColumns.VB_Description = "insert colums through K"
Attribute insertColumns.VB_ProcData.VB_Invoke_Func = "y\n14"
'
' insertColumns Macro
' insert colums through K
'
' Keyboard Shortcut: Ctrl+y
'
    Dim fromSht As String
    fromSht = InputBox("M-D of sheet to copy from:", "Input sheet name")
    aws = ActiveSheet.Name
    Columns("A:m").Select
    Selection.Insert Shift:=xlToRight, CopyOrigin:=xlFormatFromLeftOrAbove
    Range("A1").Select
    Sheets("bugs-2015-" & fromSht).Select
    Range("A1:m800").Select
    Selection.Copy
    'Sheets("bugs-2015-03-27").Select
    Sheets(aws).Select
    Range("A1").Select
    ActiveSheet.Paste
    Range("A2").Select
    Columns("B:B").EntireColumn.AutoFit
    '
    ' HideL Macro
    '
    '
    Columns("n:n").Select
    Selection.EntireColumn.Hidden = True
    Columns("I:I").Select
    Selection.EntireColumn.Hidden = True
    Columns("j:j").Select
    Selection.EntireColumn.Hidden = True
    '
    ' FilterColumns Macro
    '
    ' Keyboard Shortcut: Ctrl+Shift+F
    '
    Columns("I:AK").Select
    Selection.AutoFilter
    Range("n1").Select
    ActiveWindow.LargeScroll ToRight:=-1
    Range("A1").Select
    Columns("p:x").Select
    Columns("p:x").EntireColumn.AutoFit
    Range("p1").Select
    Columns("p:p").ColumnWidth = 116.43
    Range("M1").Select
    Columns("k:l").ColumnWidth = 4
    Columns("m:m").EntireColumn.AutoFit
    Columns("o:o").ColumnWidth = 18
    Columns("D:D").ColumnWidth = 18
End Sub
