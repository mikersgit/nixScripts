Attribute VB_Name = "Module1"
Sub smbFAA()
'
' smbFAA Macro
' SMB and FAA product filter
'
' Keyboard Shortcut: Ctrl+Shift+T
'
    ActiveSheet.Range(getFilterRegion).AutoFilter Field:=19, Criteria1:= _
        "=File Access Auditing", Operator:=xlOr, Criteria2:="=Protocols-SMB"
End Sub
Sub ClearFilters()
'
' ClearFilters Macro
' Clear column filters
'
' Keyboard Shortcut: Ctrl+Shift+K
'
    If ActiveSheet.FilterMode Then ActiveSheet.ShowAllData
    ' Go To cell D18 after processing
    Range("A1").Select
    UnHideColumns
End Sub
Sub UnHideColumns()
'
' UnHideColumns Macro
' Unhide columns
'
    Columns("A:AH").Select: Selection.EntireColumn.Hidden = False
    Range("E2").Select
End Sub
Sub Targeted()
'
' Targeted Macro
' Bugs with a 'Target Build' set
'
' Keyboard Shortcut: Ctrl+Shift+T
'
    ActiveWindow.LargeScroll ToRight:=1
    ActiveSheet.Range(getFilterRegion).AutoFilter Field:=26, Criteria1:="<>---" _
        , Operator:=xlAnd
    ' Go To cell D18 after processing
    Range("D18").Select
End Sub
Sub UntargRZ()
'
' UntargRZ Macro
' Filter for !targeted, !documentation, !waived
'
' Keyboard Shortcut: Ctrl+Shift+U
'
    Dim filterRegion As String: filterRegion = getFilterRegion
    ActiveSheet.Range(filterRegion).AutoFilter Field:=20, Criteria1:=Array( _
        "*Unknown (Triage)-AAUM", "*Unknown (Triage)-NFS", "*Unknown (Triage)-SMB", _
        "Authentication-AAUM", "Config Restore", "Install/Upgrade-AAUM", "Install/Upgrade-SMB", _
        "Manageability-AAUM", "Manageability-NFS", "Manageability-SMB", "Other-SMB", _
        "Server-NFS", "Server-SMB", "User Mapping-AAUM", "Server-AAUM", "Cross-Protocols-SMB", _
        "="), Operator:=xlFilterValues
    ActiveSheet.Range(filterRegion).AutoFilter Field:=26, Criteria1:="---"
    ActiveWindow.LargeScroll ToRight:=1
    ActiveSheet.Range(filterRegion).AutoFilter Field:=31, Criteria1:="---"
    
    ' Go To cell D18 after processing
    Range("D18").Select
End Sub
Sub Newest()
'
' Newest Macro
' The bugs less than one week old
'
' Keyboard Shortcut: Ctrl+Shift+N
'
    ActiveSheet.Range(getFilterRegion).AutoFilter Field:=2, Criteria1:=Array("0" _
        , "1", "2", "3", "4", "5", "6"), Operator:=xlFilterValues
    ' Go To cell D18 after processing
    Range("D18").Select
End Sub
Sub RedZoneAvitusSetup()
'
' RedZoneAvitusSetup Macro
' redzone setup
'
' Keyboard Shortcut: Ctrl+Shift+V
'
    Dim AvSht As String
    Dim AvBzRange As String
    Dim AvLow As String
    Dim AvHigh As String
    Dim AvUrlRow As String
    AvSht = "RedZoneAvitus"
    AvBzRange = "C18:c110"
    AvLow = "A115"
    AvHigh = "A137"
    AvUrlRow = "135"
    
    RzFormat AvSht, AvBzRange, AvLow, AvHigh, AvUrlRow

End Sub
Sub RedZoneStatusSetup()
'
' RedZoneStatusSetup Macro
' redzone setup
'
' Keyboard Shortcut: Ctrl+Shift+R
'
    Dim AuSht As String
    Dim AuBzRange As String
    Dim AuLow As String
    Dim AuHigh As String
    Dim AuUrlRow As String
    AuSht = "RedZone"
    AuBzRange = "C18:c98"
    AuLow = "A100"
    AuHigh = "A122"
    AuUrlRow = "120"
    
    RzFormat AuSht, AuBzRange, AuLow, AuHigh, AuUrlRow
End Sub
Sub RzFormat(shtName As String, BzRange As String, LowBzCell As String, HighBzCell As String, BzURLRow As String)
    Sheets(shtName).Select
    ' Copy full range of bug numbers column
    Range(BzRange).Select
    Selection.Copy
    ActiveWindow.SmallScroll Down:=3
    ' Go to cell that has hyperlink to the first cell that contains the lower set of bug numbers
'    Range(LowBzCell).Select
'    Selection.Hyperlinks(1).Follow NewWindow:=False, AddHistory:=True
'    ' Paste the copied list of new bug numbers into the lower list
'    ActiveSheet.Paste
'    Application.CutCopyMode = False
'    ' Go to cell that has hyperlink to the first cell that contains the upper set of bug numbers
'    Range(HighBzCell).Select
'    Selection.Hyperlinks(1).Follow NewWindow:=False, AddHistory:=True
    ' Insert formula to hyperlink to bugzilla, and copy to all cells
'    ActiveCell.FormulaR1C1 = _
'        "=HYPERLINK(CONCATENATE(R" & BzURLRow & "C1&INDIRECT(""c""&(ROW()+106))),INDIRECT(""c""&(ROW()+106)))"
'    Range("C18").Select
'    Selection.AutoFill Destination:=Range(BzRange), Type:=xlFillDefault
'    Range(BzRange).Select
'    With Selection.Font
'        .ThemeColor = xlThemeColorLight1
'        .TintAndShade = 0
'    End With

    LinkBugs getBZSheet & "!B3", shtName, BzRange
    ' Go To cell D18 after processing
    Range(BzRange).Select
    ' Change font to black
    With Selection.Font
        .ThemeColor = xlThemeColorLight1
        .TintAndShade = 0
    End With
    Range("D18").Select
End Sub
Sub LinkBugs(bzLnkLoc As String, shtName As String, lnkRange As String)
    Dim bugNums As Range
    Dim bug As Range
    ' BZ query screen pre-pended to bug number to create link to bug in bugzilla
    Dim bzStr As String: bzStr = bzLnkLoc
    Dim bugStr As String
    Dim strlen As Integer
    
    Set bugNums = Worksheets(shtName).Range(lnkRange)
    ' increase performance from 1 minute, to 2 seconds by turning off screen update and auto calculation
    pauseUpdates
    For Each bug In bugNums
        strlen = Len(bug.value)
        If strlen <= 6 And strlen > 0 And bug.value <> 0 Then
            bugStr = "=Hyperlink(" & bzStr
            bugStr = bugStr & " & " & bug.value & "," & bug.value & ")"
            bug.value = bugStr
        End If
    Next bug
    ' Turn screen update and calculation back on
    enableUpdates
    Range("A2").Select
End Sub
Sub OpenBug()
    ' Open single bug in bugzilla via firefox
    OpenBugCommon "B3", getBZSheet, "Bug number to open", "Bug Number"
End Sub
Sub OpenBugList()
    ' Open a summary list of bugs in bugzilla via firefox
    OpenBugCommon "B4", getBZSheet, "Bug numbers to open quote list and separate by space", "Bug Numbers"
End Sub
Sub OpenBugCommon(URLcell As String, DataSht As String, prompt As String, Title As String)
    ' msg box to get bug number
    Dim bugNum As String: bugNum = InputBox(prompt, Title)
    ' avoid getting error if no input from prompt
    If Len(bugNum) < 5 Then Exit Sub
    bzqueryFunc DataSht, URLcell, bugNum
End Sub
Sub rzbzquery()
    ' open firefox with Aurora bz query
    '
    Dim ThisSht As String: ThisSht = "RedZone"
    Dim URLcell As String: URLcell = "B1"
    
    ' bugzilla AuroraProtRedZone query to CSV output
    ' bzURL = "http://link.osp.hpe.com/u/24wb"
    Worksheets(ThisSht).Activate
    bzqueryFunc getBZSheet, URLcell
    rzimportInfo
    RedZoneStatusSetup
    
End Sub
Sub AVrzbzquery()
    ' open firefox with Avitus bz query
    '
    Dim ThisSht As String: ThisSht = "RedZoneAvitus"
    Dim URLcell As String: URLcell = "B2"
    
    ' bugzilla AvitusProtRedZone query to CSV output
    ' bzURL = "http://link.osp.hpe.com/u/268u"
    Worksheets(ThisSht).Activate
    bzqueryFunc getBZSheet, URLcell
    rzimportInfo
    RedZoneAvitusSetup
    
End Sub
Sub bzqueryFunc(DataSht As String, URLcell As String, Optional value As String)
    ' expect a cell range with cell that contains URL to be passed in
    Dim bzURL As String:  bzURL = Worksheets(DataSht).Range(URLcell).value
    '"C:\Program Files (x86)\Mozilla Firefox\firefox.exe "
    Dim browserPath As String: browserPath = Worksheets(getBZSheet).Range("B7").value & " "
    Shell (browserPath & bzURL & value)
End Sub

Sub rzimportInfo()
'
' importInfo Macro
' Get csv data from downloaded bz query
'
    ClearFilters
    '"C:\Users\mwroberts\AppData\Local\Temp\"
    'dwnldDirPath = Worksheets("BZurls").Range("B6").value
    Dim dwnldDirPath As String: dwnldDirPath = getTempFolder
    Dim csvFullPath As String
    
    Dim ScrubSheet As String: ScrubSheet = getWkBkName
    
    Dim Mo As String: Mo = Month(Date): If Len(Mo) = 1 Then Mo = "0" & Mo
    Dim Da As String: Da = Day(Date): If Len(Da) = 1 Then Da = "0" & Da
    Dim Yr As String: Yr = Year(Date)
    
    Dim ImportSht As String
    Dim prompt As String: prompt = _
        "Version of " & Mo & "-" & Da & _
        " CSV sheet from which to IMPORT [" & Chr(34) & "-1" & Chr(34) & " for example]" _
        & " CR (no input) for empty version"
    ImportSht = InputBox(prompt, "Input version")
    If InStr(ImportSht, "-") <> 1 And Len(ImportSht) > 0 Then ImportSht = "-" & ImportSht
    ImportSht = "bugs-" & Yr & "-" & Mo & "-" & Da & ImportSht & ".csv"

    ' wait 5 seconds
    'Application.Wait (Now + TimeValue("0:00:05"))

   ' open csv FILE and activate the worksheet, then copy the contents in two sections
   ' into the scrub worksheet
   '
   ' Skip the first row, do not want to overwrite calculations put in the column headings.
    csvFullPath = dwnldDirPath & ImportSht
    Workbooks.Open (csvFullPath)
    Windows(ImportSht).Activate
    ActiveWindow.Zoom = 42
    Range("A2:AF98").Select
    Selection.Copy
    
    ' switch to scrub worksheet and paste a-f
    Windows(ScrubSheet).Activate
    Range("c18").Select
    ActiveSheet.Paste
    Range("c18").Select
End Sub
Sub pauseUpdates()
    ' increase performance from 1 minute, to 2 seconds by turning off screen update and auto calculation
    Application.ScreenUpdating = False
    Application.Calculation = xlManual
End Sub
Sub enableUpdates()
   ' Turn screen update and calculation back on
    Application.Calculation = xlAutomatic
    Application.ScreenUpdating = True
End Sub
Function getBZSheet() As String
    getBZSheet = "BZurls"
End Function
Function getWkBkName() As String
    Set fso = CreateObject("Scripting.FileSystemObject")
    getWkBkName = fso.GetFileName(ThisWorkbook.FullName)
End Function
Function getTempFolder() As String
    getTempFolder = Environ("temp") & "\"
End Function
Function getFilterRegion() As String
    getFilterRegion = Worksheets(getBZSheet).Range("E6").value
End Function
