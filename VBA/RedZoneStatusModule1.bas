Attribute VB_Name = "Module1"
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
End Sub
Sub Targeted()
'
' Targeted Macro
' Bugs with a 'Target Build' set
'
' Keyboard Shortcut: Ctrl+Shift+T
'
    ActiveWindow.LargeScroll ToRight:=1
    ActiveSheet.Range("$A$17:$AH$98").AutoFilter Field:=26, Criteria1:="<>---" _
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
    ActiveSheet.Range("$A$17:$AH$98").AutoFilter Field:=20, Criteria1:=Array( _
        "*Unknown (Triage)-AAUM", "*Unknown (Triage)-NFS", "*Unknown (Triage)-SMB", _
        "Authentication-AAUM", "Config Restore", "Install/Upgrade-AAUM", "Install/Upgrade-SMB", _
        "Manageability-AAUM", "Manageability-NFS", "Manageability-SMB", "Other-SMB", _
        "Server-NFS", "Server-SMB", "User Mapping-AAUM", "Server-AAUM", "Cross-Protocols-SMB", _
        "="), Operator:=xlFilterValues
    ActiveSheet.Range("$A$17:$AH$98").AutoFilter Field:=26, Criteria1:="---"
    ActiveWindow.LargeScroll ToRight:=1
    ActiveSheet.Range("$A$17:$AH$98").AutoFilter Field:=31, Criteria1:="---"
    
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
    ActiveSheet.Range("$A$17:$AH$98").AutoFilter Field:=2, Criteria1:=Array("0" _
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
    Range(LowBzCell).Select
    Selection.Hyperlinks(1).Follow NewWindow:=False, AddHistory:=True
    ' Paste the copied list of new bug numbers into the lower list
    ActiveSheet.Paste
    Application.CutCopyMode = False
    ' Go to cell that has hyperlink to the first cell that contains the upper set of bug numbers
    Range(HighBzCell).Select
    Selection.Hyperlinks(1).Follow NewWindow:=False, AddHistory:=True
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

    LinkBugs "BZurls!B3", shtName, BzRange
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
Sub rzbzquery()
    ' open firefox with Aurora bz query
    '
    Dim ThisSht As String
    ThisSht = "RedZone"
    Dim URLCell As String
    URLCell = "B1"
    
    ' bugzilla AuroraProtRedZone query to CSV output
    ' bzURL = "http://link.osp.hpe.com/u/24wb"
    Worksheets(ThisSht).Activate
    bzqueryFunc (URLCell)
    rzimportInfo
    RedZoneStatusSetup
    
End Sub
Sub AVrzbzquery()
    ' open firefox with Avitus bz query
    '
    Dim ThisSht As String: ThisSht = "RedZoneAvitus"
    Dim URLCell As String: URLCell = "B2"
    
    ' bugzilla AvitusProtRedZone query to CSV output
    ' bzURL = "http://link.osp.hpe.com/u/268u"
    Worksheets(ThisSht).Activate
    bzqueryFunc (URLCell)
    rzimportInfo
    RedZoneAvitusSetup
    
End Sub
Sub bzqueryFunc(URLCell As String)
    ' expect a cell range with cell that contains URL to be passed in
    Dim bzURL As String
    bzURL = Worksheets("BZurls").Range(URLCell).Value
    Dim browserPath As String
    browserPath = "C:\Program Files (x86)\Mozilla Firefox\firefox.exe "
    Shell (browserPath & bzURL)
End Sub

Sub rzimportInfo()
'
' importInfo Macro
' Get csv data from downloaded bz query
'
    ClearFilters
    Dim dwnldDirPath As String
    dwnldDirPath = "C:\Users\mwroberts\AppData\Local\Temp\"
    Dim csvFullPath As String
    
    Dim ScrubSheet As String
    ScrubSheet = "RedZoneStatus.xlsm"
    
    Dim ImportSht As String
    ImportSht = InputBox("M-D of CSV sheet to IMPORT from:", "Input sheet name")
    ImportSht = "bugs-2017-" & ImportSht & ".csv"

    ' wait 5 seconds
    'Application.Wait (Now + TimeValue("0:00:05"))

   ' open csv FILE and activate the worksheet, then copy the contents in two sections
   ' into the scrub worksheet
   '
    csvFullPath = dwnldDirPath & ImportSht
    Workbooks.Open (csvFullPath)
    Windows(ImportSht).Activate
    ActiveWindow.Zoom = 42
    Range("A1:AF98").Select
    Selection.Copy
    
    ' switch to scrub worksheet and paste a-f
    Windows(ScrubSheet).Activate
    Range("c17").Select
    ActiveSheet.Paste
    Range("c17").Select
End Sub
