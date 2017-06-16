Attribute VB_Name = "Module1"
Sub NoDisposition()
'
' NoDisposition Macro
' No Waiver, and no target, and not "For Review"
'
    Dim filterRegion As String: filterRegion = getFilterRegion
    pauseUpdates
    ActiveSheet.Range(filterRegion).AutoFilter Field:=12, Criteria1:="---"
    ActiveSheet.Range(filterRegion).AutoFilter Field:=13, Criteria1:="---"
    ActiveSheet.Range(filterRegion).AutoFilter Field:=17, Criteria1:= _
        "<>For Review", Operator:=xlAnd
    Columns("L:M").Select: Selection.EntireColumn.Hidden = True
    Range("a1").Select
    enableUpdates
End Sub

Sub Table2Range()
'
'
' Get the name of the table in current sheet, unlink from data source, and then convert to a range
'
Dim tbleName As String: tbleName = ActiveSheet.ListObjects(1).Name
    With ActiveSheet.ListObjects(tbleName)
        .Unlink
        .Unlist
    End With
    Range("A1").Select
End Sub
Sub ClearTable()
'
' ClearTable Macro
' Clear but do not delete
'
' Keyboard Shortcut: Ctrl+Shift+T
'
    Range("A2:Z100").Select
    Selection.ClearContents
    Range("Table_ExternalData_1[[#Headers],[BugId]]").Select
End Sub
Sub CopySQLdata()
'
' CopySQLdata Macro
' Copy data from SQL Query
'
    Dim NewSht As String: NewSht = NewSheetName()
    'NewSht = "bugs-2017-" & Mo & "-" & Da
    
    Dim ThisSht As String: ThisSht = ActiveSheet.Name
    Dim SQLdataSht As String: SQLdataSht = getSQLtarget
    Dim SQLConnectionQuery As String: SQLConnectionQuery = getSQLquery
    
    createCopy ThisSht, NewSht, getTriggerSheet
    
    Sheets(SQLdataSht).Select
    ClearTable
    ActiveWorkbook.Connections(SQLConnectionQuery).Refresh
    
    Range("A2:F100").Select
    Selection.Copy
    Sheets(NewSht).Select
    Range("D2").Select
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
    Sheets(SQLdataSht).Select
    Range("G2:X100").Select
    Selection.Copy
    Sheets(NewSht).Select
    Range("L2").Select
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
    Range("K1").Select
    enableUpdates
    ' Pass in copy FROM sheet as previous sheet
    FormatScrubSheet ThisSht
End Sub
Sub ForReview()
Attribute ForReview.VB_Description = "Sort on Target Milestone column for 'For Review'"
Attribute ForReview.VB_ProcData.VB_Invoke_Func = " \n14"
'
' ForReview Macro
' Sort on Target Milestone column for 'For Review'
'
    FilterOnValue getFilterRegion, "For Review", 17
    Columns("k:m").Select: Selection.EntireColumn.Hidden = True
End Sub
Sub TargettedBuilds()
Attribute TargettedBuilds.VB_Description = "Filter for Target Builds != '---'"
Attribute TargettedBuilds.VB_ProcData.VB_Invoke_Func = " \n14"
'
' TargettedBuilds Macro
' Filter for Target Builds != '---'
'
    FilterOnValue getFilterRegion, "<>---", 13
    Columns("i:l").Select: Selection.EntireColumn.Hidden = True
    Columns("i:l").Select: Selection.EntireColumn.Hidden = True
    Columns("q:y").Select: Selection.EntireColumn.Hidden = True
End Sub
Sub FilterOnValue(fltrRng As String, fltrStg As String, fltrField As Integer)
    ClearFilters
    ActiveSheet.Range(fltrRng).AutoFilter Field:=fltrField, Criteria1:=fltrStg
End Sub
Sub noPriority()
    FilterOnValue getFilterRegion, "unsp*", 8
End Sub
Sub blocked()
    FilterOnValue getFilterRegion, "block*", 20
End Sub
Sub InPlay()
Attribute InPlay.VB_Description = "Bugs, not waived, not doc, not targetted, not 'For Review'"
Attribute InPlay.VB_ProcData.VB_Invoke_Func = " \n14"
'
' InPlay Macro
' Bugs, not waived, not doc, not targetted, not 'For Review'
'
    Dim filterRegion As String: filterRegion = getFilterRegion
    ClearFilters
    ' 6 is F "Product" not equal to Documentation
    ActiveSheet.Range(filterRegion).AutoFilter Field:=6, Criteria1:= _
        "<>*Document*", Operator:=xlAnd
    ' 7 is G "Component" not equal to Documentation
    ActiveSheet.Range(filterRegion).AutoFilter Field:=7, Criteria1:= _
        "<>*Document*", Operator:=xlAnd
    ' 12 is L "Waivers" equal to dashes which means not set
    ActiveSheet.Range(filterRegion).AutoFilter Field:=12, Criteria1:="=---", _
        Operator:=xlOr, Criteria2:="="
    ' 13 is M "Target build" equal to dashes which means not set
    ActiveSheet.Range(filterRegion).AutoFilter Field:=13, Criteria1:="=---"
    ' 17 is Q "Target Milestone" equal to Avitus, also need to check for PPI*
    ActiveSheet.Range(filterRegion).AutoFilter Field:=17, Criteria1:=getRelName, _
        Operator:=xlOr, Criteria2:="PP*"
    Columns("k:m").Select: Selection.EntireColumn.Hidden = True
    Columns("g:g").Select: Selection.EntireColumn.Hidden = True
End Sub
Sub Waivers()
Attribute Waivers.VB_Description = "bugs with waivers requested"
Attribute Waivers.VB_ProcData.VB_Invoke_Func = " \n14"
'
' Waivers Macro
' bugs with waivers requested
'
    FilterOnValue getFilterRegion, "Waiver Requested", 12
    Columns("j:k").Select: Selection.EntireColumn.Hidden = True
    Columns("M:M").Select: Selection.EntireColumn.Hidden = True
    Columns("G:G").Select: Selection.EntireColumn.Hidden = True
End Sub
Sub ClearFilters()
Attribute ClearFilters.VB_ProcData.VB_Invoke_Func = " \n14"
'
' ClearFilters Macro
' Clear column filters
'
' The "If" prevents the error when clearning when no filters are set
'
    If ActiveSheet.FilterMode Then ActiveSheet.ShowAllData
    ' Go To cell D18 after processing
    UnHideColumns
    Columns("D:D").Select: Selection.EntireColumn.Hidden = True
    Range("A1").Select
End Sub
Sub P0bugs()
'
' P0bugs Macro
' Filter for 'P0' bugs
'
    ' 8 is H "priority"
    FilterOnValue getFilterRegion, "P0", 8
End Sub
Sub FormatScrubSheet(PrevSht As String)
'
' FormatScrubSheet Macro
' Do the sort, and setup the top/bottom links
'
    ClearFilters
    Dim ThisSht As String: ThisSht = ActiveSheet.Name
    
    ' simplified by passing the "copy from" sheet as the compare against sheet
'    Dim PrevSht As String
'    PrevSht = InputBox("M-D of sheet to compare against:", "Input sheet name")
'    PrevSht = "bugs-2017-" & PrevSht
    
    pauseUpdates
' insertText Macro
' insert text for previous sheet name
'
'
    Range("k103").Select
    ActiveCell.FormulaR1C1 = PrevSht
    
    ' sort the product column alphabetically
    AvProductSort ThisSht, "F2:F100"
    
' Hyperlinks Macro
' Insert top/bottom links
'
    Range("k1").Select
    ActiveSheet.Hyperlinks.Add Anchor:=Selection, Address:="", SubAddress:= _
        "'" & ThisSht & "'" & "!K118", TextToDisplay:="Prev Notes"
    Range("k1").Select
    Selection.Hyperlinks(1).Follow NewWindow:=False, AddHistory:=True
    Range("n111").Select
    ActiveSheet.Hyperlinks.Add Anchor:=Selection, Address:="", SubAddress:= _
        "'" & ThisSht & "'" & "!A2", TextToDisplay:="Top"
' date to compare age of bugs
'
' insertDate Macro
' insert today() excel function
' then the output of that is pasted as a value
'
    Range("K105").Select
    ActiveCell.FormulaR1C1 = "=TODAY()"
    Range("K105").Select
    Selection.Copy
    Range("K104").Select
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
    Application.CutCopyMode = False
    
    ' fill "notes" column with "."
    fillBlanks "J2", "J100"
    
    enableUpdates
    ' Fill I, O, P with "." if blank (Keyword, CFI, Status synopsis)
    DefValueForBlank "I2:I100", ThisSht
    DefValueForBlank "O2:O100", ThisSht
    DefValueForBlank "P2:P100", ThisSht
    
    ' hide column "D" that has non-linked bug ID
    Columns("D:D").Select: Selection.EntireColumn.Hidden = True
End Sub
Sub AvProductSort(Sheet As String, SrtRange As String)
    ActiveWorkbook.Worksheets(Sheet).AutoFilter.Sort.SortFields.Clear
    ActiveWorkbook.Worksheets(Sheet).AutoFilter.Sort.SortFields.Add _
        Key:=Range(SrtRange), SortOn:=xlSortOnValues, Order:=xlAscending, _
        DataOption:=xlSortTextAsNumbers
    With ActiveWorkbook.Worksheets(Sheet).AutoFilter.Sort
        .Header = xlYes
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With

End Sub
Sub fillBlanks(NotesStart As String, NotesEnd As String)
'
' fillBlanks Macro
' Fill empty cells with dot
'
    ' the current notes column
    Range(NotesStart).Select
    ActiveCell.FormulaR1C1 = "."
    Selection.AutoFill Destination:=Range(NotesStart & ":" & NotesEnd), Type:=xlFillDefault
    Range(NotesStart & ":" & NotesEnd).Select
    Range(NotesStart).Select
End Sub
Sub createCopy(fromSht As String, toSht As String, afterSht As String)
    pauseUpdates
    ' make sure the copy from sheet is the active sheet
    ClearFilters
    Sheets(fromSht).Select
    
    ' rename new sheet
    '
    Sheets(fromSht).Copy after:=Sheets(afterSht)
    Sheets(fromSht & " (2)").Select
    Sheets(fromSht & " (2)").Name = toSht
    ' make new sheet the active sheet so call to Format operates on the correct sheet
    ' NewSht = "bugs-2017-" & NewSht
    Sheets(toSht).Select
End Sub
Sub CopySheet()
'
' CopySheet Macro
' open firefox with BZ query
' Copy current sheet, rename it to new date,
'
'
    
    ' get name for new sheet
    '
    ' Dim NewSht As String
    ' NewSht = InputBox("M-D of NEW sheet to copy TO:", "Input sheet name")
    Dim NewSht As String: NewSht = NewSheetName()
    'NewSht = "bugs-2017-" & Mo & "-" & Da
    
    Dim ThisSht As String: ThisSht = ActiveSheet.Name
    ' Most of the time the "from" sheet has been the sheet where we select the copy button
    ' so simplifying by just putting the current sheet directly in the variable

    createCopy ThisSht, NewSht, getTriggerSheet
    
    ' open firefox with bz query
    '
    AvBzQuery
    
    ' import data from csv from bugzilla
    AvimportInfo
    
    enableUpdates
    ' format sheet
    FormatScrubSheet ThisSht
    
End Sub
Function NewSheetName() As String
    ' NewSht = InputBox("M-D of NEW sheet to copy TO:", "Input sheet name")
    Dim Mo As String: Mo = Month(Date): If Len(Mo) = 1 Then Mo = "0" & Mo
    Dim Da As String: Da = Day(Date): If Len(Da) = 1 Then Da = "0" & Da
    Dim Yr As String: Yr = Year(Date)
    Dim NewSht As String: NewSht = "bugs-" & Yr & "-" & Mo & "-" & Da
    NewSheetName = NewSht
End Function
Sub AvBzQuery()
    ' open firefox with bz query
    '
    ' Cell with direct CSV link
    Dim URLcell As String
    URLcell = "K3"
    
    bzqueryFunc getDataSheet, URLcell
End Sub
Sub AvRefreshData()
    Dim ThisSht As String: ThisSht = ActiveSheet.Name
    ' new data in the current sheet
    AvBzQuery
    AvimportInfo
    AvProductSort ThisSht, "F2:F100"
    
    ' Fill I, O, P with "." if blank (Keyword, CFI, Status synopsis)
    DefValueForBlank "I2:I100", ThisSht
    DefValueForBlank "O2:O100", ThisSht
    DefValueForBlank "P2:P100", ThisSht
    DefValueForBlank "J2:J100", ThisSht ' on refresh do not wipe out the notes column, just fill new blanks
End Sub
Sub AvimportInfo()
'
' importInfo Macro
' Get csv data from downloaded bz query
'
    ' "C:\Users\mwroberts\AppData\Local\Temp\"
    'dwnldDirPath = Worksheets(getBZSheet).Range("B5").value
    Dim dwnldDirPath As String: dwnldDirPath = getTempFolder
    Dim csvFullPath As String
    
    Dim ScrubSheet As String: ScrubSheet = getWkBkName
    
    Dim ImportSht As String: ImportSht = getMDstring & ".csv"

    ' wait 10 seconds
    ' Application.Wait (Now + TimeValue("0:00:10"))

   ' open csv FILE and activate the worksheet, then copy the contents in two sections
   ' into the scrub worksheet
   '
    csvFullPath = dwnldDirPath & ImportSht
    Workbooks.Open (csvFullPath)
    Windows(ImportSht).Activate
    Set CSVFile = ActiveWorkbook
    ActiveWindow.Zoom = 42
    Range("A2:F100").Select
    Selection.Copy
    
    ' switch to scrub worksheet and paste a-f
    Windows(ScrubSheet).Activate
    Range("D2").Select
    ActiveSheet.Paste
    
    ' back to csv for next section
    Windows(ImportSht).Activate
    Range("G2:Y100").Select
    Application.CutCopyMode = False
    Selection.Copy
    
    ' and copy to scrub worksheet
    Windows(ScrubSheet).Activate
    Range("L2").Select
    ActiveSheet.Paste
    ' this next "copy" is just to prevent the "large clipboard" warning pop-up when the csv file is closed.
    Range("D2").Select
    Application.CutCopyMode = False
    Selection.Copy
    
    CSVFile.Close SaveChanges:=False
End Sub
Sub HideColumns()
'
' HideColumns Macro
' Hide Columns to show previous values
'
    Columns("G:G").Select: Selection.EntireColumn.Hidden = True
    Columns("I:I").Select: Selection.EntireColumn.Hidden = True
    Columns("L:L").Select: Selection.EntireColumn.Hidden = True
    Columns("N:S").Select: Selection.EntireColumn.Hidden = True
    Columns("U:Z").Select: Selection.EntireColumn.Hidden = True
    ActiveWindow.ScrollColumn = 1
    Range("E2").Select
End Sub
Sub UnHideColumns()
'
' UnHideColumns Macro
' Unhide columns
'
    Columns("A:AH").Select: Selection.EntireColumn.Hidden = False
    Range("E2").Select
End Sub
Sub bzqueryFunc(DataSht As String, URLcell As String, Optional value As String)
    ' expect a cell range with cell that contains URL to be passed in
    Dim bzURL As String:  bzURL = Worksheets(DataSht).Range(URLcell).value
    'C:\Program Files (x86)\Mozilla Firefox\firefox.exe & " "
    Shell (getBrowserPath & bzURL & value)
End Sub
Sub DefValueForBlank(editRng As String, shtName As String)
    Dim Fields As Range
    Dim Field As Range
    Dim FieldStr As String: FieldStr = "."
    Dim strlen As Integer
    
    Set Fields = Worksheets(shtName).Range(editRng)
    ' increase performance from 1 minute, to 2 seconds by turning off screen update and auto calculation
    pauseUpdates
    For Each Field In Fields
        strlen = Len(Field.value)
        If strlen < 1 Then
            Field.value = FieldStr
        End If
    Next Field
    ' Turn screen update and calculation back on
    enableUpdates
    Range("A2").Select
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
Sub regressionFilter()
Attribute regressionFilter.VB_Description = "regress or forward port"
Attribute regressionFilter.VB_ProcData.VB_Invoke_Func = " \n14"
'
' regression Macro
' regress or forward port
'
    Dim filterRegion As String: filterRegion = getFilterRegion
    ClearFilters
    ActiveSheet.Range(filterRegion).AutoFilter Field:=9, Criteria1:= _
        "=*regress*", Operator:=xlOr, Criteria2:="=*forward*"
    
    ActiveSheet.Range(filterRegion).AutoFilter Field:=13, Criteria1:="---"
End Sub
Sub ProductChange()
'
' ProductChange Macro
' filter on color
'
    FilterOnColor getFilterRegion, 252, 228, 214, 6
End Sub
Sub PriorityChange()
'
' PriorityChange Macro
' filter on color
'
    FilterOnColor getFilterRegion, 204, 153, 255, 8
End Sub
Sub TargBuildChange()
'
' Target Build Change Macro
' filter on color
'
    FilterOnColor getFilterRegion, 226, 239, 218, 13
End Sub
Sub WaiverChange()
'
' WaiverChange Macro
' filter on color
'
    FilterOnColor getFilterRegion, 255, 229, 255, 12
End Sub
Sub FilterOnColor(fltrRng As String, R As Integer, G As Integer, B As Integer, fltrField As Integer)
    ClearFilters
    ActiveSheet.Range(fltrRng).AutoFilter Field:=fltrField, Criteria1:=RGB(R, G, B), Operator:=xlFilterCellColor
End Sub
Sub uniqueColumn()
'
' uniqueColumn Macro
' uniq
'
' Keyboard Shortcut: Ctrl+Shift+T
'
    Application.CutCopyMode = False
    ActiveSheet.Range("$A$1:$A$38").RemoveDuplicates Columns:=1, Header:=xlNo
End Sub
Sub OpenBug()
Attribute OpenBug.VB_Description = "Prompt for bug number to open in bugzilla via firefox"
Attribute OpenBug.VB_ProcData.VB_Invoke_Func = "B\n14"
    ' Open single bug in bugzilla via firefox
    OpenBugCommon "B3", getBZSheet, "Bug number to open", "Bug Number"
End Sub
Sub OpenBugList()
Attribute OpenBugList.VB_Description = "Prompt for quoted list of space separated bug numbers to open in summary."
Attribute OpenBugList.VB_ProcData.VB_Invoke_Func = "b\n14"
    ' Open a summary list of bugs in bugzilla via firefox
    OpenBugCommon "B2", getBZSheet, "Bug numbers to open quote list and separate by space", "Bug Numbers"
End Sub
Sub OpenBugCommon(URLcell As String, DataSht As String, prompt As String, Title As String)
    ' msg box to get bug number
    Dim bugNum As String: bugNum = InputBox(prompt, Title)
    ' avoid getting error if no input from prompt
    If Len(bugNum) < 5 Then Exit Sub
    bzqueryFunc DataSht, URLcell, bugNum
End Sub
Sub trBlocked()
    trHeadings "A1", "Blocked without target build"
End Sub
Sub trReview()
    trHeadings "A6", """For Review"" > 3 days"
End Sub
Sub trPriority()
    trHeadings "A11", "Priority and Keyword not set > 7days and not ""For Review"""
End Sub
Sub trTBnoCRB()
    trHeadings "A17", "Targeted for current week, not yet in CRB review"
End Sub
Sub trTBpastDue()
    trHeadings "A20", "Past Due Target build"
End Sub
Sub trStaleP0()
    trHeadings "A36", "P0 without update > 14 days"
End Sub
Sub trStaleP1()
    trHeadings "A39", "P1 without update > 14 days"
End Sub
Sub trHeadings(Pos As String, Text As String)
    With Worksheets(getTriggerSheet).Range(Pos)
        .value = Text
        .Font.Bold = True
        .Interior.Color = vbYellow
    End With
End Sub
Sub trClearValueFormat()
    Worksheets(getTriggerSheet).Range("22:30").Clear
End Sub
Sub runReview()
    Worksheets(getTriggerSheet).Activate
    Set trigSht = ActiveSheet
    Worksheets(Range("e1").value).Activate
    ForReview
End Sub
Function getMDstring() As String
    Dim Mo As String: Mo = Month(Date): If Len(Mo) = 1 Then Mo = "0" & Mo
    Dim Da As String: Da = Day(Date): If Len(Da) = 1 Then Da = "0" & Da
    Dim Yr As String: Yr = Year(Date)
    
    Dim prompt As String: prompt = _
        "Version of " & Mo & "-" & Da & _
        " CSV sheet from which to IMPORT [" & Chr(34) & "-1" & Chr(34) & " for example]" _
        & " CR (no input) for empty version"
        
    Dim fromTab As String
    fromTab = InputBox(prompt, "Input version of sheet")
    If InStr(fromTab, "-") <> 1 And Len(fromTab) > 0 Then fromTab = "-" & fromTab
    fromTab = "bugs-" & Yr & "-" & Mo & "-" & Da & fromTab
    getMDstring = fromTab
End Function
Function getSQLtarget() As String
    getSQLtarget = Worksheets(getDataSheet).Range("K10").value
End Function
Function getSQLquery() As String
    getSQLquery = Worksheets(getDataSheet).Range("K9").value
End Function
Function getDataSheet() As String
    getDataSheet = "Data"
End Function
Function getBZSheet() As String
    getBZSheet = "BZurls"
End Function
Function getTriggerSheet() As String
    getTriggerSheet = "Triggered"
End Function
Function getRelName() As String
    getRelName = Worksheets(getDataSheet).Range("K12").value
End Function
Function getWkBkName() As String
    Set fso = CreateObject("Scripting.FileSystemObject")
    getWkBkName = fso.GetFileName(ThisWorkbook.FullName)
End Function
Function getTempFolder() As String
    getTempFolder = Environ("temp") & "\"
End Function
Function getFilterRegion() As String
    getFilterRegion = Worksheets(getDataSheet).Range("K13").value
End Function
Function getBrowserPath() As String
    getBrowserPath = Worksheets(getBZSheet).Range("B6").value & " "
End Function
