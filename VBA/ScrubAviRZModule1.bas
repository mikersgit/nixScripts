Attribute VB_Name = "Module1"
'**************
'** Globals definitions
'**************
    '*******
    '** constants
    '*******
'    Public Const rngSt As String = "2"    ' start row for vdu bug scrub sheet
'    Public Const rngEd As String = "100"  ' end row for vdu bug scrub sheet
'    Public Const urngSt As String = "2"   ' start row for udu bug scrub sheet
'    Public Const urngEd As String = "30"  ' end row for udu bug scrub sheet
    '*********
    '** variables
    '*********
    '******************* ranges *********************
    Public rngSt As String    ' start row for vdu bug scrub sheet
    Public rngEd As String    ' end row for vdu bug scrub sheet
    Public urngSt As String    ' start row for udu bug scrub sheet
    Public urngEd As String   ' end row for udu bug scrub sheet
    '******************* columns **************************
    Public colsSet As Boolean ' set this when all columns have been set.
    Public waiveCol As Integer
    Public tarBldCol As Integer
    Public tarMilCol As Integer
    Public prodCol As Integer
    Public compCol As Integer
    Public severCol As Integer
    Public statusCol As Integer
    Public prioCol As Integer
    Public keywCol As Integer
    Public noteCol As Integer
    Public bugCol As Integer
    Public bugColLtr As String
    Public prodColLtr As String
    Public noteColLtr As String
    '**************** filter
    Public filterRegion As String
    Public Mo As String
    Public DA As String
    Public Yr As String
    Public YMDstr As String
    '************ end of global definitions (not initialized yet) **************************
Private Sub Auto_Open()
    'automatically initialize the columns using the latest worksheet, when the workbook is opened
    Sheets(2).Activate ' use the second tab as the sheet from which to grab the column names and locations
    setColNumbers ' set the column numbers to be used in filters. Do it once at startup to improve performance
    filterRegion = getFilterRegion ' get the size of the full sheet size from the "Data" sheet in the workbook
    setDataRange ' get the size of the data region from the "Data" sheet
    setUDUDataRange ' get the size of the UDU sheets data region from the "Data" sheet
    setYMDstr       ' set the year-month-day string that is used several times
    prodColLtr = getColLtr(prodCol) ' now that the column number of filter is known, determine the column letter for range calls
    noteColLtr = getColLtr(noteCol)
    bugColLtr = getColLtr(bugCol)
    'MsgBox CStr(filterRegion)
End Sub
'*****************************************
'** Subroutines that initialize globals on open
'*****************************************
Sub setColNumbers()
    colsSet = False
    UnHideColumns
    Dim t As Variant: t = setColNum()
End Sub
Sub setDataRange()
    rngSt = Worksheets(getDataSheet).Range("k15").value
    rngEd = Worksheets(getDataSheet).Range("k16").value
End Sub
Sub setUDUDataRange()
    urngSt = Worksheets(getDataSheet).Range("k18").value
    urngEd = Worksheets(getDataSheet).Range("k19").value
End Sub
Sub setYMDstr()
    Mo = Month(Date): If Len(Mo) = 1 Then Mo = "0" & Mo
    DA = Day(Date): If Len(DA) = 1 Then DA = "0" & DA
    Yr = Year(Date)
    YMDstr = Yr & "-" & Mo & "-" & DA
End Sub
'**************************** End of initialization section ***********************
'*****************************************
'** Subroutines that filter bugs displayed
'*****************************************
Sub NoDisposition()
'
' NoDisposition Macro
' No Waiver, and no target, and not "For Review"
'
    'Dim filterRegion As String: filterRegion = getFilterRegion
    pauseUpdates
    ClearFilters
    ActiveSheet.Range(filterRegion).AutoFilter Field:=waiveCol, Criteria1:="---"
    ActiveSheet.Range(filterRegion).AutoFilter Field:=tarBldCol, Criteria1:="---"
    ActiveSheet.Range(filterRegion).AutoFilter Field:=tarMilCol, Criteria1:= _
        "<>For Review", Operator:=xlAnd
    hideColumnRng ("L:M")
    Range("a2").Select
    enableUpdates
End Sub ' end NoDisposition
Sub Reopened()
'
' Sort on Status column (30) for 'REOPENED'
'
    FilterOnValue filterRegion, "REOPENED", statusCol
    hideColumnRng ("o:ac")
    Range("a2").Select
End Sub
Sub ForReview()
'
' ForReview Macro
' Sort on Target Milestone column (17) for 'For Review'
'
    FilterOnValue filterRegion, "For Review", tarMilCol
    hideColumnRng ("k:m")
End Sub
Sub TargettedBuilds()
'
' TargettedBuilds Macro
' Filter for Target Builds(13) != '---'
'
    FilterOnValue filterRegion, "<>---", tarBldCol
    hideColumnRng ("i:l")
    hideColumnRng ("i:l")
    hideColumnRng ("q:y")
End Sub ' end TargettedBuilds
Sub noPriority()
    FilterOnValue filterRegion, "unsp*", prioCol
End Sub
Sub blocked()
    FilterOnValue filterRegion, "block*", severCol
End Sub
Sub InPlay()
'
' InPlay Macro
' Bugs, not waived, not doc, not targetted, not 'For Review'
'
    'Dim filterRegion As String: filterRegion = getFilterRegion
    ClearFilters
    ' 6 is F "Product" not equal to Documentation (use '*' because count is appended in column header)
    ActiveSheet.Range(filterRegion).AutoFilter Field:=prodCol, Criteria1:= _
        "<>*Document*", Operator:=xlAnd
    ' 7 is G "Component" not equal to Documentation
    ActiveSheet.Range(filterRegion).AutoFilter Field:=compCol, Criteria1:= _
        "<>*Document*", Operator:=xlAnd
    ' 12 is L "Waivers" equal to dashes which means not set
    ActiveSheet.Range(filterRegion).AutoFilter Field:=waiveCol, Criteria1:="=---", _
        Operator:=xlOr, Criteria2:="="
    ' 13 is M "Target build" equal to dashes which means not set
    ActiveSheet.Range(filterRegion).AutoFilter Field:=tarBldCol, Criteria1:="=---"
    ' 17 is Q "Target Milestone" equal to Avitus, also need to check for PPI*
    ActiveSheet.Range(filterRegion).AutoFilter Field:=tarMilCol, Criteria1:=getRelName, _
        Operator:=xlOr, Criteria2:="PP*"
    hideColumnRng ("k:m")
    hideColumnRng ("g:g")
End Sub ' end InPlay
Sub Waivers()
'
' Waivers Macro
' bugs with waivers requested
'
    ClearFilters
    ActiveSheet.Range(filterRegion).AutoFilter Field:=waiveCol, Criteria1:= _
        "=Waiver Requested", Operator:=xlOr, Criteria2:="=Director*"
    hideColumnRng ("j:k")
    hideColumnRng ("M:M")
    hideColumnRng ("G:G")
End Sub ' end Waivers
Sub P0bugs()
'
' P0bugs Macro
' Filter for 'P0' bugs
'
    ' 8 is H "priority"
    FilterOnValue filterRegion, "P0", prioCol
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Common filter routine that takes a range and filter value
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub FilterOnValue(fltrRng As String, fltrStg As String, fltrField As Integer)
    ClearFilters
    pauseUpdates
    ActiveSheet.Range(fltrRng).AutoFilter Field:=fltrField, Criteria1:=fltrStg
    enableUpdates
End Sub
Sub regressionFilter()
'
' regression Macro
' regress or forward port
'
    ClearFilters
    ActiveSheet.Range(filterRegion).AutoFilter Field:=keywCol, Criteria1:= _
        "=*regress*", Operator:=xlOr, Criteria2:="=*forward*"
    
    ActiveSheet.Range(filterRegion).AutoFilter Field:=tarBldCol, Criteria1:="---"
End Sub 'end regressionFilter
Sub ProductChange()
'
' ProductChange Macro
' filter on color
'
    FilterOnColor filterRegion, 252, 228, 214, prodCol
End Sub
Sub PriorityChange()
'
' PriorityChange Macro
' filter on color
'
    FilterOnColor filterRegion, 204, 153, 255, prioCol
End Sub
Sub TargBuildChange()
'
' Target Build Change Macro
' filter on color
'
    FilterOnColor filterRegion, 226, 239, 218, tarBldCol
End Sub
Sub WaiverChange()
'
' WaiverChange Macro
' filter on color
'
    FilterOnColor filterRegion, 255, 229, 255, waiveCol
End Sub
''''''''''''''''''''''''''''''''''''''''''''
' common routine to filter a colomn by color
''''''''''''''''''''''''''''''''''''''''''''
Sub FilterOnColor(fltrRng As String, R As Integer, G As Integer, B As Integer, fltrField As Integer)
    ClearFilters
    ActiveSheet.Range(fltrRng).AutoFilter Field:=fltrField, Criteria1:=RGB(R, G, B), Operator:=xlFilterCellColor
End Sub
'**************************** End of filter section ***********************
'**************************************************************************
'************************************************
'** Subroutines that format, sort the spreadsheet
'************************************************
Sub FormatScrubSheet(PrevSht As String)
'
' FormatScrubSheet Macro
' Do the sort, and setup the top/bottom links
'
    ClearFilters
    Dim ThisSht As String: ThisSht = ActiveSheet.name
    
    pauseUpdates
' insertText Macro
' insert text for previous sheet name
'
'
    Range("k103").Select
    ActiveCell.FormulaR1C1 = PrevSht
    
    ' sort the product column alphabetically
    AvProductSort ThisSht, getRngStr(prodColLtr, prodColLtr, rngSt, rngEd)
    
' Hyperlinks Macro
' Insert top/bottom links
'
    Range("k1").Select
    ActiveSheet.Hyperlinks.Add Anchor:=Selection, Address:="", SubAddress:= _
        "'" & ThisSht & "'" & "!K140", TextToDisplay:="Prev Notes"
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
    fillBlanks noteColLtr & rngSt, getRngStr(noteColLtr, noteColLtr, rngSt, rngEd)

    UnHideColumns ' Make columns visible before looking-up column letters
    Dim colNm() As Variant: colNm = Array("Keywords", "CFI", "status synop*", "whiteboard", "Affected Tar*")
    multiRangeBlank colNm(), rngSt, rngEd, ThisSht

    enableUpdates
    
    ' hide column "D" that has non-linked bug ID
    hideColumnRng (getRngStr(bugColLtr, bugColLtr))
End Sub ' end FormatScrubSheet
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

End Sub ' end AvProductSort
Sub fillBlanks(NotesStart As String, NotesRng As String)
'
' fillBlanks Macro
' Fill empty cells with dot
'
    ' the current notes column
    Range(NotesStart).Select
    ActiveCell.FormulaR1C1 = "."
    Selection.AutoFill Destination:=Range(NotesStart & ":" & NotesRng), Type:=xlFillDefault
    Range(NotesRng).Select
    Range(NotesStart).Select
End Sub ' end fillBlanks
Sub LinkBugs(bzLnkLoc As String, shtName As String, lnkRange As String)
    ' example call LinkBugs getBZSheet & "!B3", "3parRedZone", "c2:c30"
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
End Sub ' end LinkBugs
Sub multiRangeBlank(col As Variant, rstart As String, rend As String, sht As String)
    ' Call the DefValueForBlank routine in a loop over multiple columns
    Dim c As Variant
    Dim cn As String
    Dim rng As String
    For Each c In col
        cn = getColLtr(getColNu(CStr(c)))
        rng = getRngStr(cn, cn, rstart, rend)
        DefValueForBlank rng, sht
    Next c
End Sub
Sub DefValueForBlank(editRng As String, shtName As String)
    ' put a character in blank cells so that cut/paste into email doesn't get distorted when cells are empty
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
End Sub ' end DefValueForBlank
'******************** End of formating sorting routines ********************
'***************************************************************************

'*******************************************
'** Subroutines that control general display
'*******************************************
Sub hideColumnRng(rng As String)
    Columns(rng).Select: Selection.EntireColumn.Hidden = True
End Sub
Sub hideColumnName(colName As String)
    Dim cn As String: cn = getColLtr(getColNu(colName))
    hideColumnRng (getRngStr(cn, cn))
End Sub
Sub ClearTable()
'
' ClearTable Macro
' Clear but do not delete
'
' Keyboard Shortcut: Ctrl+Shift+T
'
    Range(getRngStr("A", "Z", rngSt, rngEd)).Select
    Selection.ClearContents
    Range("Table_ExternalData_1[[#Headers],[BugId]]").Select
End Sub 'end ClearTable
Sub ClearFilters()
'
' ClearFilters Macro
' Clear column filters
'
' The "If" prevents the error when clearning when no filters are set
'
    pauseUpdates
    If ActiveSheet.FilterMode Then ActiveSheet.ShowAllData
    ' Go To cell D18 after processing
    UnHideColumns
    hideColumnRng (getRngStr(bugColLtr, bugColLtr))
    Range("A1").Select
    enableUpdates
End Sub 'ClearFilters
Sub HideColumns()
'
' HideColumns Macro
' Hide Columns to show previous values
'
    'hideColumnRng ("G:G") ' component
    hideColumnName ("component")
    'hideColumnRng ("I:I") ' keywords
    hideColumnName ("keywords")
    'hideColumnRng ("L:L") ' waivers
    hideColumnName ("waivers")
    hideColumnRng ("N:S")
    hideColumnRng ("U:Z")
    ActiveWindow.ScrollColumn = 1
    Range("E2").Select
End Sub 'end HideColumns
Sub UnHideColumns()
'
' UnHideColumns Macro
' Unhide columns
'
    Columns("A:AI").Select: Selection.EntireColumn.Hidden = False
    Range("E2").Select
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
'************** End of general display section ****************************
'**************************************************************************
'*********************************************
'** Pull data from external sources and import
'*********************************************
Sub CopySQLdata()
'
' CopySQLdata Macro
' Copy data from SQL Query
'
    Dim NewSht As String: NewSht = NewSheetName()
    'NewSht = "bugs-2017-" & Mo & "-" & Da
    
    Dim ThisSht As String: ThisSht = ActiveSheet.name
    Dim SQLdataSht As String: SQLdataSht = getSQLtarget
    Dim SQLConnectionQuery As String: SQLConnectionQuery = getSQLquery
    
    createCopy ThisSht, NewSht, getTriggerSheet
    
    Sheets(SQLdataSht).Select
    ClearTable
    ActiveWorkbook.Connections(SQLConnectionQuery).Refresh
    
    Range(getRngStr("A", "F", rngSt, rngEd)).Select
    Selection.Copy
    Sheets(NewSht).Select
    Range("D2").Select
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
        
    Sheets(SQLdataSht).Select
    Range(getRngStr("G", "X", rngSt, rngEd)).Select
    Selection.Copy
    Sheets(NewSht).Select
    Range("L2").Select
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
        
    Sheets(SQLdataSht).Select
    Range(getRngStr("Z", "Z", rngSt, rngEd)).Select
    Selection.Copy
    Sheets(NewSht).Select
    Range("AD2").Select
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
    
    Range("K1").Select
    enableUpdates
    ' Pass in copy FROM sheet as previous sheet
    FormatScrubSheet ThisSht
End Sub ' end CopySQLdata
Sub createCopy(fromSht As String, toSht As String, afterSht As String)
    pauseUpdates
    ' make sure the copy from sheet is the active sheet
    ClearFilters
    Sheets(fromSht).Select
    
    ' rename new sheet
    '
    Sheets(fromSht).Copy after:=Sheets(afterSht)
    Sheets(fromSht & " (2)").Select
    Sheets(fromSht & " (2)").name = toSht
    ' make new sheet the active sheet so call to Format operates on the correct sheet
    ' NewSht = "bugs-2017-" & NewSht
    Sheets(toSht).Select
End Sub ' end createCopy
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
    
    Dim ThisSht As String: ThisSht = ActiveSheet.name
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
    
End Sub 'end CopySheet
Sub AvBzQuery()
    ' open firefox with bz query
    '
    ' Cell with direct CSV link
    Dim URLcell As String
    URLcell = "K3"
    
    bzqueryFunc getDataSheet, URLcell
End Sub
Sub AvRefreshData()
    Dim ThisSht As String: ThisSht = ActiveSheet.name

    ' new data in the current sheet
    AvBzQuery
    AvimportInfo
    AvProductSort ThisSht, getRngStr(prodColLtr, prodColLtr, rngSt, rngEd)
    UnHideColumns ' Make columns visible before looking-up column letters
    Dim colNm() As Variant: colNm = Array("Keywords", "CFI", "Status Syn*", "*notes", "whiteboard")
    multiRangeBlank colNm(), rngSt, rngEd, ThisSht

End Sub ' end AvRefreshData

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
    Range(getRngStr("A", "F", rngSt, rngEd)).Select
    Selection.Copy
    
    ' switch to scrub worksheet and paste a-f
    Windows(ScrubSheet).Activate
    Range("D2").Select
    ActiveSheet.Paste
    
    ' back to csv for next section
    Windows(ImportSht).Activate
    Range(getRngStr("G", "Y", rngSt, rngEd)).Select
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
End Sub ' end AvimportInfo
Sub bzqueryFunc(DataSht As String, URLcell As String, Optional value As String)
    ' expect a cell range with cell that contains URL to be passed in
    Dim bzURL As String:  bzURL = Worksheets(DataSht).Range(URLcell).value
    'C:\Program Files (x86)\Mozilla Firefox\firefox.exe & " "
    Shell (getBrowserPath & bzURL & value)
End Sub
'**************************************
'** trigger sheet routines
'**************************************
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
'************** end trigger sheet routines ****************
'**********************************************************
'*******************************************
'** 3par (UDU) bug query and format routines
'*******************************************
Sub UDUData()
    ' pull data from UDU instance of bugzilla
    ' make sure 3parRedZone is active sheet
    Worksheets("3parRedzone").Activate
    UDUBzQuery
    UDUimport
    UDUformat
End Sub
Sub UDUBzQuery()
    ' open firefox with bz query
    '
    ' Cell with direct CSV link
    Dim URLcell As String
    URLcell = "B8"
    
    bzqueryFunc getBZSheet, URLcell
End Sub
Sub UDUimport()
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

    pauseUpdates
   ' open csv FILE and activate the worksheet, then copy the contents
   ' into the scrub worksheet
   '
    csvFullPath = dwnldDirPath & ImportSht
    Workbooks.Open (csvFullPath)
    Windows(ImportSht).Activate
    Set CSVFile = ActiveWorkbook
    ActiveWindow.Zoom = 42
    Range("A2:F30").Select
    Selection.Copy
    
    ' switch to scrub worksheet and paste
    Windows(ScrubSheet).Activate
    Range("C2").Select
    ActiveSheet.Paste
    
    ' back to csv for next section
    Windows(ImportSht).Activate
    Range("G2:T30").Select
    Application.CutCopyMode = False
    Selection.Copy
    
    ' and copy to scrub worksheet
    Windows(ScrubSheet).Activate
    Range("J2").Select
    ActiveSheet.Paste
    
    ' this next "copy" is just to prevent the "large clipboard" warning pop-up when the csv file is closed.
    Range("D2").Select
    Application.CutCopyMode = False
    Selection.Copy
    
    CSVFile.Close SaveChanges:=False
    enableUpdates
End Sub ' end UDUimport
Sub UDUformat()
    ' make sure 3parRedZone is active sheet
    Worksheets("3parRedzone").Activate
    Dim ThisSht As String: ThisSht = ActiveSheet.name

    LinkBugs getBZSheet & "!B9", "3parRedZone", getRngStr(bugColLtr, bugColLtr, urngSt, urngEd)
    UnHideColumns ' Make columns visible before looking-up column letters
    Dim colNm() As Variant: colNm = Array("Keywords", "deadline", "gr8*", "*notes", "whiteboard", "developer*")
    multiRangeBlank colNm(), urngSt, urngEd, ThisSht
   
    pauseUpdates
    ' get today's date, then copy/paste into a cell, that way it doesn't change until data is refreshed
    Range("f38").Select
    ActiveSheet.Hyperlinks.Add Anchor:=Selection, Address:="", SubAddress:= _
        "'" & NewSheetName & "'" & "!A2", TextToDisplay:="VDU Bugs"
    Range("F39").Select
    ActiveCell.FormulaR1C1 = "=TODAY()"
    Range("F39").Select
    Selection.Copy
    Range("F40").Select
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
    Application.CutCopyMode = False
    enableUpdates
End Sub ' end UDUformat
'************** End 3par (UDU) bug query and format routines ***************
'***************************************************************************
'***********************
'** Future use routines
'***********************
Sub AskColumnNumber()
    Dim cname As String
    Dim cnumber As Integer
    Set wksht = ActiveSheet
    cname = InputBox("column name", "input cname")
    MsgBox (cnumber)
End Sub
Sub AskColumnLetter()
    Dim cname As String
    Dim cnumber As Integer
    cnumber = InputBox("column num", "input cnumber")
    cname = getColLtr(cnumber)
    MsgBox (cname)
End Sub
Sub AskMultipleNumber()
    Dim name As Variant
    Dim names() As Variant: names = Array("waivers", "assign*")
    For Each name In names
        If Len(CStr(name)) > 0 Then
            MsgBox (CStr(name))
            MsgBox (getColNu(CStr(name)))
        End If
    Next name
    
End Sub
Sub Table2Range()
'
'
' Get the name of the table in current sheet, unlink from data source, and then convert to a range
'
Dim tbleName As String: tbleName = ActiveSheet.ListObjects(1).name
    With ActiveSheet.ListObjects(tbleName)
        .Unlink
        .Unlist
    End With
    Range("A1").Select
End Sub ' end Table2Range
Sub uniqueColumn()
'
' uniqueColumn Macro
' uniq
'
' Keyboard Shortcut: Ctrl+Shift+T
'
    Application.CutCopyMode = False
    ActiveSheet.Range("$A$1:$A$38").RemoveDuplicates Columns:=1, Header:=xlNo
End Sub ' end uniqueColumn
Sub callGetRng()
    Dim str As String: str = getRngStr("a", "a")
    str = getRngStr("A", "b", "2", "100")
End Sub
Function setRng()
    If Len(rngSt) < 1 Then
        rngSt = "2"
        rngEd = "100"
    End If
End Function
'*********** end of future use routines ****************
'*******************************************************
'********************
'** Functions Section
'********************
Function NewSheetName() As String
    ' NewSht = InputBox("M-D of NEW sheet to copy TO:", "Input sheet name")
    Dim NewSht As String: NewSht = "bugs-" & YMDstr
    NewSheetName = NewSht
End Function ' end NewSheetName
Function getMDstring() As String

    Dim prompt As String: prompt = _
        "Version of " & Mo & "-" & DA & _
        " CSV sheet from which to IMPORT [" & Chr(34) & "-1" & Chr(34) & " for example]" _
        & " CR (no input) for empty version"
        
    Dim fromTab As String
    fromTab = InputBox(prompt, "Input version of sheet")
    If InStr(fromTab, "-") <> 1 And Len(fromTab) > 0 Then fromTab = "-" & fromTab
    fromTab = "bugs-" & YMDstr & fromTab
    getMDstring = fromTab
End Function ' end getMDstring
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
Function getColNu(TextToFind As String) As Integer
    ' from column header, determine column number
    Dim rng1 As Range
    pauseUpdates
    Rows("1:1").Select
    
    Set rng1 = ActiveSheet.UsedRange.Find(TextToFind, , xlValues, xlWhole)
    If Not rng1 Is Nothing Then
        getColNu = rng1.Column
    Else
        getColNu = -1
        Rem MsgBox "Not found", vbCritical
    End If
    enableUpdates
End Function ' end getColNu
Function getColLtr(lngCol As Integer) As String
    'From the column number determine the column letter
    Dim vArr
    vArr = Split(Cells(1, lngCol).Address(True, False), "$")
    getColLtr = vArr(0)
End Function
Function getRngStr(startLtr As String, endLtr As String, Optional startNu As String, Optional endNu As String) As String
    If Len(startNu) > 0 Then
        getRngStr = startLtr & startNu & ":" & endLtr & endNu
    Else
        getRngStr = startLtr & ":" & endLtr
    End If
End Function
Function setColNum()
    'set column numbers once per session
    If colsSet <> True Then
     bugCol = getColNu("Bug ID")
     waiveCol = getColNu("Waivers")
     tarBldCol = getColNu("target build")
     tarMilCol = getColNu("target milestone")
     prodCol = getColNu("product*")
     compCol = getColNu("component")
     severCol = getColNu("severity")
     statusCol = getColNu("status")
     prioCol = getColNu("priority")
     keywCol = getColNu("keywords")
     noteCol = getColNu("*notes")
     colsSet = True
    End If
    Range("a1").Select
End Function
