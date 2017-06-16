Attribute VB_Name = "Module1"
Sub smbfilter()
'
' smbfilter Macro
' filter out NFS & AAUM
'
    ActiveSheet.Range("$A$1:$AJ$1000").AutoFilter Field:=21, Criteria1:= _
        "Protocols-SMB"
End Sub
Sub AllBugAnalysis(analysisSht As String, fromSht As String)
Attribute AllBugAnalysis.VB_Description = "Copy all greater/equal normal severity bugs, sort by master bug."
Attribute AllBugAnalysis.VB_ProcData.VB_Invoke_Func = "A\n14"
'
' AllBugAnalysis Macro
' Copy all greater/equal normal severity bugs, sort by master bug.
'
' Keyboard Shortcut: Ctrl+Shift+A
'
'    Dim fromSht As String
'    fromSht = InputBox("M-D of sheet to copy from:", "Input sheet name")
    pauseUpdates
    Range("E2:AJ981").Select
    Selection.ClearContents
    Range("E2").Select
    Sheets(fromSht).Select
    Range("A2:AF981").Select
    Selection.Copy
    Sheets(analysisSht).Select
    Range("E2").Select
    ActiveSheet.Paste
    Range("E2").Select
    Application.CutCopyMode = False
    Calculate
    Columns("C:C").Select
    ActiveWorkbook.Worksheets(analysisSht).Sort.SortFields.Clear
    ActiveWorkbook.Worksheets(analysisSht).Sort.SortFields.Add Key:=Range( _
        "C2:C1069"), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:= _
        xlSortNormal
    ActiveWorkbook.Worksheets(analysisSht).Sort.SortFields.Add Key:=Range( _
        "D2:D1069"), SortOn:=xlSortOnValues, Order:=xlDescending, DataOption:= _
        xlSortNormal
    With ActiveWorkbook.Worksheets(analysisSht).Sort
        .SetRange Range("A1:AJ1069")
        .Header = xlYes
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With
    enableUpdates
    Range("G13").Select
    LinkBugs analysisSht, "e2:e900"
    formatcolumn
    Range("a1").Select
End Sub ' AllBugAnalysis
Sub LinkBugs(shtName As String, lnkRange As String)
    Dim bugNums As Range
    Dim bug As Range
    Dim bzStr As String: bzStr = getDataSheet & "!a2"
    Dim bugStr As String
    Dim strlen As Integer
    
    Set bugNums = Worksheets(shtName).Range(lnkRange)
    ' increase performance from 1 minute, to 2 seconds by turning off screen update and auto calculation
    pauseUpdates
    For Each bug In bugNums
        strlen = Len(bug.Value)
        If strlen <= 6 And strlen > 0 And bug.Value <> 0 Then
            bugStr = "=Hyperlink(" & bzStr
            bugStr = bugStr & " & " & bug.Value & "," & bug.Value & ")"
            bug.Value = bugStr
        End If
    Next bug
    ' Turn screen update and calculation back on
    enableUpdates
    Range("A2").Select
End Sub
Sub AgeNbzquery()
    '
    Dim analysisSht As String: analysisSht = "Analysis"
    ' open firefox with AllOpenGENormal bz query
    '
    ' bugzilla AuroraProtRedZone query to CSV output
    bzQuery analysisSht, getOpenBgQuery
        
    Dim fromTab As String: fromTab = getMDstring
    Copytabfromsheet analysisSht, getWkBkName, fromTab
    AllBugAnalysis analysisSht, fromTab
End Sub
Sub AllResbzquery()
    '
    Dim analysisSht As String: analysisSht = "Resolved"
    ' open firefox with AllResolvedOneYear bz query
    '
    ' bugzilla AllResolvedOneYear query to CSV output
    bzQuery analysisSht, getResBgQuery
    
    Dim fromTab As String: fromTab = getMDstring
    Copytabfromsheet analysisSht, getWkBkName, fromTab
    ResolveBugAnalysis analysisSht, fromTab
End Sub
Sub bzQuery(analysisSht As String, bzQURL As String)
    Worksheets(analysisSht).Activate
    bzqueryFunc bzQURL
End Sub
Sub ClearFilters()
'
' ClearFilters Macro
' Clear column filters
'
' The "If" prevents the error when clearning when no filters are set
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
    Columns("A:AZ").Select
    Selection.EntireColumn.Hidden = False
    Range("E2").Select
End Sub
Sub bzqueryFunc(bzURL As String)
    ' expect a cell range with cell that contains URL to be passed in
    '"C:\Program Files (x86)\Mozilla Firefox\firefox.exe "
    Shell (getBrowserPath & bzURL)
End Sub
Sub ResolveBugAnalysis(analysisSht As String, fromSht As String)
'
' ResolveBugAnalysis Macro
' Analysis of resolved bugs for ODC data
'
'
'    Dim fromSht As String
'    fromSht = InputBox("M-D of sheet to copy from:", "Input sheet name")
    pauseUpdates
    Sheets(fromSht).Select
    Range("A1:AD4000").Select
    Selection.Copy
    Sheets(analysisSht).Select
    Range("E1").Select
    ActiveSheet.Paste
    Calculate
    Columns("C:C").Select
    Application.CutCopyMode = False
    ActiveWorkbook.Worksheets(analysisSht).Sort.SortFields.Clear
    ActiveWorkbook.Worksheets(analysisSht).Sort.SortFields.Add Key:=Range( _
        "C2:C4000"), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:= _
        xlSortNormal
    With ActiveWorkbook.Worksheets(analysisSht).Sort
        .SetRange Range("C1:AH4000")
        .Header = xlYes
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With
    
    enableUpdates
    Range("F2").Select
    'link bug column
    LinkBugs analysisSht, "e2:e4000"
    'link master column
    ' =IF(INDIRECT("d"&ROW())=0,IFERROR(VALUE(MID(INDIRECT("g"&ROW()),9,5)),0),INDIRECT("e"&ROW()))
    'LinkBugs analysisSht, "c2:c4000"
End Sub ' ResolvedBugAnalysis
Sub Copytabfromsheet(TabToUse As String, wkBookToUse As String, fromTab As String)
'
' Copytabfromsheet Macro
' copy
'
    ClearFilters
    '"C:\Users\mwroberts\AppData\Local\Temp\"
    'dwnldDirPath = Worksheets(getDataSheet).Range("B5").Value
    Dim dwnldDirPath As String: dwnldDirPath = getTempFolder
    'Dim fromTab As String: fromTab = getMDstring
'    fromTab = InputBox("M-D of FILE to copy from:", "Input file name")
'    fromTab = "bugs-2017-" & fromTab
    Dim fromSht As String: fromSht = fromTab & ".csv"
    
    Workbooks.Open (dwnldDirPath & fromSht)
    Windows(fromSht).Activate
    Sheets(fromTab).Select
    Sheets(fromTab).Move After:=Workbooks(wkBookToUse). _
        Sheets(TabToUse)
    Sheets(TabToUse).Select
End Sub
Function getMDstring() As String
    Dim fromTab As String
    Dim Mo As String: Mo = Month(Date): If Len(Mo) = 1 Then Mo = "0" & Mo
    Dim Da As String: Da = Day(Date): If Len(Da) = 1 Then Da = "0" & Da
    Dim Yr As String: Yr = Year(Date)
    
    Dim prompt As String: prompt = _
        "Version of " & Mo & "-" & Da & _
        " CSV sheet from which to IMPORT [" & Chr(34) & "-1" & Chr(34) & " for example]" _
        & " CR (no input) for empty version"
        
    fromTab = InputBox(prompt, "Input version of sheet")
    If InStr(fromTab, "-") <> 1 And Len(fromTab) > 0 Then fromTab = "-" & fromTab
    fromTab = "bugs-" & Yr & "-" & Mo & "-" & Da & fromTab
    getMDstring = fromTab
End Function
Sub enableUpdates()
   ' Turn screen update and calculation back on
    Application.Calculation = xlAutomatic
    Application.ScreenUpdating = True
End Sub
Sub pauseUpdates()
    ' increase performance from 1 minute, to 2 seconds by turning off screen update and auto calculation
    Application.ScreenUpdating = False
    Application.Calculation = xlManual
End Sub
Sub formatcolumn()
Attribute formatcolumn.VB_Description = "format for numbers"
Attribute formatcolumn.VB_ProcData.VB_Invoke_Func = "T\n14"
'
' formatcolumn Macro
' format for numbers
'
    Columns("E:E").Select
    Selection.NumberFormat = "0"
End Sub
Function getDataSheet() As String
    getDataSheet = "MacroData"
End Function
Function getWkBkName() As String
    Set fso = CreateObject("Scripting.FileSystemObject")
    getWkBkName = fso.GetFileName(ThisWorkbook.FullName)
End Function
Function getTempFolder() As String
    getTempFolder = Environ("temp") & "\"
End Function
Function getOpenBgQuery() As String
    getOpenBgQuery = Worksheets(getDataSheet).Range("B14").Value
End Function
Function getResBgQuery() As String
    getResBgQuery = Worksheets(getDataSheet).Range("B15").Value
End Function
Function getBrowserPath() As String
    getBrowserPath = Worksheets(getDataSheet).Range("B6").Value & " "
End Function
