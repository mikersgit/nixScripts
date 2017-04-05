Attribute VB_Name = "Module1"
Sub AllBugAnalysis()
Attribute AllBugAnalysis.VB_Description = "Copy all greater/equal normal severity bugs, sort by master bug."
Attribute AllBugAnalysis.VB_ProcData.VB_Invoke_Func = "A\n14"
'
' AllBugAnalysis Macro
' Copy all greater/equal normal severity bugs, sort by master bug.
'
' Keyboard Shortcut: Ctrl+Shift+A
'
    Dim fromSht As String
    fromSht = InputBox("M-D of sheet to copy from:", "Input sheet name")
    Application.Calculation = xlManual
    Range("E2:AJ981").Select
    Selection.ClearContents
    Range("E2").Select
    Sheets("bugs-2017-" & fromSht).Select
    Range("A2:AF981").Select
    Selection.Copy
    Sheets("Analysis").Select
    Range("E2").Select
    ActiveSheet.Paste
    Range("E2").Select
    Application.CutCopyMode = False
    Calculate
    Columns("C:C").Select
    ActiveWorkbook.Worksheets("Analysis").Sort.SortFields.Clear
    ActiveWorkbook.Worksheets("Analysis").Sort.SortFields.Add Key:=Range( _
        "C2:C1069"), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:= _
        xlSortNormal
    ActiveWorkbook.Worksheets("Analysis").Sort.SortFields.Add Key:=Range( _
        "D2:D1069"), SortOn:=xlSortOnValues, Order:=xlDescending, DataOption:= _
        xlSortNormal
    With ActiveWorkbook.Worksheets("Analysis").Sort
        .SetRange Range("A1:AJ1069")
        .Header = xlYes
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With
    Application.Calculation = xlAutomatic
    Range("G13").Select
    LinkBugs "Analysis", "e2:e900"
    LinkBugs "Analysis", "e2:e900"
End Sub ' AllBugAnalysis
Sub LinkBugs(shtName As String, lnkRange As String)
    Dim bugNums As Range
    Dim bug As Range
    Dim bzStr As String: bzStr = "MacroData!a2"
    Dim bugStr As String
    Dim strlen As Integer
    
    Set bugNums = Worksheets(shtName).Range(lnkRange)
    ' increase performance from 1 minute, to 2 seconds by turning off screen update and auto calculation
    Application.ScreenUpdating = False
    Application.Calculation = xlManual
    For Each bug In bugNums
        strlen = Len(bug.Value)
        If strlen <= 6 And strlen > 0 And bug.Value <> 0 Then
            bugStr = "=Hyperlink(" & bzStr
            bugStr = bugStr & " & " & bug.Value & "," & bug.Value & ")"
            bug.Value = bugStr
        End If
    Next bug
    ' Turn screen update and calculation back on
    Application.Calculation = xlAutomatic
    Application.ScreenUpdating = True
    Range("A2").Select
End Sub
Sub AgeNbzquery()
    '
    ' open firefox with AllOpenGENormal bz query
    '
    ' bugzilla AuroraProtRedZone query to CSV output
    Dim bzURL As String: bzURL = "http://link.osp.hpe.com/u/24wa"
    Worksheets("Analysis").Activate
    bzqueryFunc bzURL
    
End Sub
Sub AllResbzquery()
    '
    ' open firefox with AllResolvedOneYear bz query
    '
    ' bugzilla AllResolvedOneYear query to CSV output
    Dim bzURL As String: bzURL = "http://link.osp.hpe.com/u/24we"
    Worksheets("Resolved").Activate
    bzqueryFunc bzURL
End Sub
Sub ClearFilters()
'
' ClearFilters Macro
' Clear column filters
'
' The "If" prevents the error when clearning when no filters are set
'
' Keyboard Shortcut: Ctrl+Shift+K
'
    If ActiveSheet.FilterMode Then ActiveSheet.ShowAllData
    ' Go To cell D18 after processing
    UnHideColumns
    Range("A1").Select
End Sub
Sub UnHideColumns()
'
' UnHideColumns Macro
' Unhide columns
'
' Keyboard Shortcut: Ctrl+Shift+G
'
    Columns("A:AZ").Select
    Selection.EntireColumn.Hidden = False
    Range("E2").Select
End Sub
Sub bzqueryFunc(bzURL As String)
    ' expect a cell range with cell that contains URL to be passed in
    Dim browserPath As String
    browserPath = "C:\Program Files (x86)\Mozilla Firefox\firefox.exe "
    Shell (browserPath & bzURL)
End Sub
Sub ResolveBugAnalysis()
'
' ResolveBugAnalysis Macro
' Analysis of resolved bugs for ODC data
'
'
    Dim fromSht As String
    fromSht = InputBox("M-D of sheet to copy from:", "Input sheet name")
    Application.Calculation = xlManual
    Sheets("bugs-2017-" & fromSht).Select
    Range("A1:AD4000").Select
    Selection.Copy
    Sheets("Resolved").Select
    Range("E1").Select
    ActiveSheet.Paste
    Calculate
    Columns("C:C").Select
    Application.CutCopyMode = False
    ActiveWorkbook.Worksheets("Resolved").Sort.SortFields.Clear
    ActiveWorkbook.Worksheets("Resolved").Sort.SortFields.Add Key:=Range( _
        "C2:C4000"), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:= _
        xlSortNormal
    With ActiveWorkbook.Worksheets("Resolved").Sort
        .SetRange Range("C1:AH4000")
        .Header = xlYes
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With
    
    Application.Calculation = xlAutomatic
    Range("F2").Select
    'link bug column
    LinkBugs "Resolved", "e2:e4000"
    'link master column
    ' =IF(INDIRECT("d"&ROW())=0,IFERROR(VALUE(MID(INDIRECT("g"&ROW()),9,5)),0),INDIRECT("e"&ROW()))
    LinkBugs "Resolved", "c2:c4000"
End Sub ' ResolvedBugAnalysis
