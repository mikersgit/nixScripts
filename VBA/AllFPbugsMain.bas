Attribute VB_Name = "AllFPbugsMain"
Sub FPGuestIncoming()

    Dim BugCnt As String
    Dim FixIncomSht As String: FixIncomSht = "ClosedFPguestQuery"
    Dim ChartSht As String: ChartSht = "Chart"
    Dim CurCol As String: CurCol = Range("L159").Value
    
    webRequest Sheets(FixIncomSht).Range("a35").Value
     
    BugCnt = InputBox("How many bugs Incoming?", "One Week Incoming Count")

    Sheets(ChartSht).Range(CurCol & "183").Value = BugCnt
End Sub
Sub AZonlyfixed()
    Dim BugCnt As String
    Dim FixIncomSht As String: FixIncomSht = "ClosedFPguestQuery"
    Dim ChartSht As String: ChartSht = "Chart"
    Dim CurCol As String: CurCol = Range("L159").Value
    
    webRequest Sheets(FixIncomSht).Range("a24").Value
    
End Sub
Sub AZonlyfixedOneWeek()
    Dim BugCnt As String
    Dim FixIncomSht As String: FixIncomSht = "ClosedFPguestQuery"
    Dim ChartSht As String: ChartSht = "Chart"
    Dim CurCol As String: CurCol = Range("L159").Value
    
    webRequest Sheets(FixIncomSht).Range("a20").Value
    BugCnt = InputBox("How many bugs fixed?", "One Week fixed Count")
    'ae182
    Sheets(ChartSht).Range(CurCol & "182").Value = BugCnt
End Sub
Sub AllTMfixed()
    Dim BugCnt As String
    Dim FixIncomSht As String: FixIncomSht = "ClosedFPguestQuery"
    Dim ChartSht As String: ChartSht = "Chart"
    Dim CurCol As String: CurCol = Range("L159").Value
    
    webRequest Sheets(FixIncomSht).Range("a14").Value
    BugCnt = InputBox("How many bugs fixed from all TargetMilestones?", "One Week All TM fixed Count")
    'ae186
    Sheets(ChartSht).Range(CurCol & "186").Value = BugCnt
End Sub
Sub UpdateFixIncoming()
    Dim CurCol As String: CurCol = Sheets("Chart").Range("L159").Value
    
    Range("h77").Value = "Pending"
    AZonlyfixedOneWeek
    FPGuestIncoming
    AllTMfixed

    Range("m20").Select
    ActiveSheet.ChartObjects("Chart 5").Activate
    
    editTrendChart
    
    MsgBox "COMPLETED: Trend chart data series for fixed & incoming lines extended to column: " & vbCrLf & CurCol, vbInformation, _
            "Trend chart Updated"
    AddToKeywordChart
    Range("A20").Select
    Range("h77").Value = "Yes"
End Sub

Sub CopyAllChartData()
    
    Range("h75").Value = "Pending"
    MsgBox "The columns for K77 and K81 will be updated for you, and then the data from the recently run Bugzilla querries will be incorporated into the charts.", _
            vbOKOnly, "What this does"
    
    UpdateFPChartColumns
    UpdateFBOChartColumns
    pauseUpdates
    CopyChartData
    CopyFBOchartData
    enableUpdates
    Range("B77").Select
    Range("h75").Value = "Yes"
End Sub
Sub CopyChartData()
'
' CopyChartData Macro
' copy live File Persona current data to location for charting
'
    Dim CopyTMtoCell As String: CopyTMtoCell = Range("K83").Value
    Dim CopyKEYtoCell As String: CopyKEYtoCell = Range("L83").Value
    Dim NamedTMrange As String: NamedTMrange = Range("K78").Value
    Dim NamedKeyRange As String: NamedKeyRange = Range("L78").Value
    
    Range(NamedTMrange).Select
    Selection.Copy
    
    Range(CopyTMtoCell).Select
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
    
    Range(NamedKeyRange).Select
    Application.CutCopyMode = False
    Selection.Copy
    
    Range(CopyKEYtoCell).Select
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
    
    Range("G20").Select
    Application.CutCopyMode = False
    
    'Now extend the chart to the newly copied data
    AddToChartData
End Sub 'end CopyChartData()
Sub UpdateFPChartColumns()
    AdvanceOneColumn "K83", "K81"
End Sub 'UpdateFPChartColumns
Sub UpdateFBOChartColumns()
    AdvanceOneColumn "L77", "K77"
End Sub 'UpdateFBOChartColumns
Sub AdvanceOneColumn(RefCol As String, CellToUpdate As String)
    
    Dim addressAry() As String
    Dim NewColumn As String
    
    NewColumn = Range(Range(RefCol).Value).Offset(0, 1).Address
    addressAry() = Split(NewColumn, "$")
    Range(CellToUpdate).Value = addressAry(1)
    
End Sub
Sub CopyFBOchartData()
'
' CopyChartData Macro
' copy live File Persona current data to location for charting
'
    Dim CopyFBOToCell As String: CopyFBOToCell = Range("L77").Value
    Dim NamedFBOrange As String: NamedFBOrange = Range("K74").Value
    
    Range(NamedFBOrange).Select
    Selection.Copy
    
    Range(CopyFBOToCell).Select
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
    
    
    Range("H130").Select
    Application.CutCopyMode = False
    
    'Now extend the chart to the newly copied data
    FBOChartData
End Sub 'end CopyFBOchartData()

Sub MoveForcast()
'
' MoveForcast Macro
'
'Range(Cells(1,1).Address,Cells(5,5).Address).Address ' is:
'$A$1:$E$5

    'Dim PasteCell As String: PasteCell = split(Range(ForecastArea).Offset(0, 1).Address,":")
    Dim addressAry() As String
    Dim NextCol As String
    Dim CopyFromLiveDataBeg As String
    Dim CopyFromLiveDataEnd As String
    Dim CopyLiveDataRange As String
    Dim CopyToNewLiveData As String
    Dim NewDataColLtr As String
    Dim ForecastAreaName As String: ForecastAreaName = Range("P158").Value
    Dim LastLiveDataColumnName As String: LastLiveDataColumnName = Range("P157").Value
    
    Range("h73").Value = "Pending"
    
    'Get down one row and BACK one column address info from where ForecastArea currently is located.
    'This is used to set address for current last column of live data.
    addressAry() = Split(Range(ForecastAreaName).Offset(1, -1).Address, ":")
    CopyFromLiveDataBeg = addressAry(0)
    
    'Get the column letter for the current location for ForecastArea, this is the column where the new live data will be copied.
    'This letter is copied into L159 [LastLiveDataColumn] which feeds the formula in M159 [ForecastDateRange]
    'which defines the live data area from which the forecast is made
    addressAry() = Split(CopyFromLiveDataBeg, "$")
    NewDataColLtr = addressAry(1)
    'Write the Letter into the L159 [LastLiveDataColumn]
    Range(LastLiveDataColumnName).Value = NewDataColLtr
    
    'Get 25 row offset from Forecast data current location, this defines the last row in the live data column that will be copied.
    CopyFromLiveDataEnd = Range(CopyFromLiveDataBeg).Offset(25, 0).Address
    
    'Get 1 row offset of ForecastArea start location
    addressAry() = Split(Range(ForecastAreaName).Offset(1, 0).Address, ":")
    CopyToNewLiveData = addressAry(0)
    
    'Get 1 column offset to move ForecastArea TO
    addressAry() = Split(Range(ForecastAreaName).Offset(0, 1).Address, ":")
    NextCol = addressAry(0)
    
    'Create range to copy Live data from
    CopyLiveDataRange = CopyFromLiveDataBeg & ":" & CopyFromLiveDataEnd
    
    'Cut ForecastArea, then move over one column
    Range(ForecastAreaName).Select
    Selection.Cut
    Range(NextCol).Select
    ActiveSheet.Paste
    
    Range("M158").Select
    
    'With Forecast moved, now copy the previous live data column over one column to pickup the new live data in the series
    CopyForcastData CopyLiveDataRange, CopyToNewLiveData
    
    'Update the NOW current column for live forcast data
    addressAry() = Split(CopyToNewLiveData, "$")
    NewDataColLtr = addressAry(1)
    'Write the Letter into the L159 [LastLiveDataColumn]
    Range(LastLiveDataColumnName).Value = NewDataColLtr
    Range("B75").Select
    Range("h73").Value = "Yes"
End Sub 'MoveForcast
Sub CopyForcastData(copyRange As String, pasteCell As String)
'
' CopyForcastData Macro
'

    Range(copyRange).Select
    Selection.Copy
    Range(pasteCell).Select
    ActiveSheet.Paste
    Application.CutCopyMode = False
    Range("M157").Select
End Sub 'CopyForcastData
Sub SetName()
'
' SetName Macro
' Name a selected Cell
'
    Range("P10").Select
    ActiveWorkbook.Names.Add Name:="ResoB", RefersToR1C1:="=Chart!R10C16"
    Range("Q10").Select
    ActiveWorkbook.Names.Add Name:="ResoE", RefersToR1C1:="=Chart!R10C17"
    Range("R10").Select
End Sub
Sub goToBZquery()
    Sheets(getDataSheet).Activate
    Range("a28").Select
End Sub
Sub goTo3PARBZquery()
    Sheets("BZ_URL").Activate
    Range("a2").Select
End Sub
Sub filterOpenRZ()
Attribute filterOpenRZ.VB_Description = "Filter status and bedrock columns"
Attribute filterOpenRZ.VB_ProcData.VB_Invoke_Func = " \n14"
'
' filterOpenRZ Macro
' Filter status and bedrock columns
'
'
    Dim bzShtRange As String: bzShtRange = getBzShtRange
'   Make sure the bug import sheet is active
    Sheets(getBugFileTabName).Activate
    filterAllColumns
    ActiveSheet.Range(bzShtRange).AutoFilter Field:=5, Criteria1:=Array( _
        "ASSIGNED", "NEW", "REOPENED", "="), Operator:=xlFilterValues
    ActiveSheet.Range(bzShtRange).AutoFilter Field:=8, Criteria1:=Array( _
        "Blocker", "Red Zone", "="), Operator:=xlFilterValues
End Sub
Sub filterAllColumns()
'
' filterAllColumns Macro
' Enable filtering of all columns, A:S
'
    Columns(getRangeString(getBugCol, getOwnerCol)).Select
    Selection.AutoFilter
    Range("B2").Select
End Sub
Sub UniqueOwners()
'
' UniqueOwners Macro
' Unique list of owners
'
'
    Dim OwnerCol As String: OwnerCol = getOwnerCol
    Dim ownerRng As String: ownerRng = getRangeString(OwnerCol, OwnerCol)
' Need to execute where "data" is the active sheet and range to get unique values is column "S" on "AllBugs"
    pauseUpdates
    Application.Goto Reference:="AllBugs!R1C19"
    Columns("S:S").Select
    Selection.Copy
    Application.Goto Reference:="Sheet1!R1C2"
    ActiveSheet.Paste
    Columns("B:B").Select
    Application.CutCopyMode = False
    ActiveSheet.Range("$B$1:$B$4360").RemoveDuplicates Columns:=1, Header:= _
        xlYes
    Range("b1:b10").Select
    Selection.Copy
    Application.Goto Reference:="data!R1C2"
    ActiveSheet.Paste
    enableUpdates
    Range("B1").Select
    
    
'    Sheets("data").Select
'    Range("B1").Select
'    Sheets("AllBugs").Range("S1:S5000").AdvancedFilter Action:=xlFilterCopy, _
'        CopyToRange:=Range("B1:B10"), Unique:=True
'    Range("B8").Select
End Sub
Sub FilterOwnerOpenRZ(bgTabName As String, bugRange As String, dataSht As String)
Attribute FilterOwnerOpenRZ.VB_ProcData.VB_Invoke_Func = " \n14"
'
' FilterOwnerOpenRZ Macro
' filter by owner open, Azha targeted, RedZone or Blocker bugs
'
'
' Need to execute where "AllBugs" is the active sheet and filter range is pulled from sheet "data"
    Sheets(bgTabName).Activate
    Debug.Print bgTabName
    Debug.Print bugRange
    Debug.Print dataSht
    pauseUpdates
    ' OpenRZfilter is a named range on the "data" sheet
    Range(bugRange).AdvancedFilter Action:=xlFilterInPlace, CriteriaRange:= _
        Sheets(dataSht).Range("OpenRZfilter"), Unique:=True
    enableUpdates
    scrollTop
End Sub ' end FilterOwnerOpenRZ
Sub FilterOwnerFixedRZ(bgTabName As String, bugRange As String, dataSht As String)
'
' FilterOwnerFixedRZ Macro
' filter by owner closed/resolved/verified, fixed, Azha targeted, RedZone or Blocker bugs
'
'
' Need to execute where "AllBugs" is the active sheet and filter range is pulled from sheet "data"
    Sheets(bgTabName).Activate
    Debug.Print bgTabName
    Debug.Print bugRange
    Debug.Print dataSht
    pauseUpdates
    ' ClosedRZfilter is a named range on the "data" sheet
    Range(bugRange).AdvancedFilter Action:=xlFilterInPlace, CriteriaRange:= _
        Sheets(dataSht).Range("ClosedRZfilter"), Unique:=True
    enableUpdates
    scrollTop
End Sub ' FilterOwnerFixedRZ
Sub tbSort()
'WARNING
' Sometimes ".Apply" method crashes out Excel. not sure why
'
' tbSort Macro
' Sort on 'Target Build'
'
'
    Dim TBcol As String: TBcol = getTargetBuildCol
    Dim TBrng As String: TBrng = getRangeString(TBcol, TBcol, 2, getMaxRow)
    Dim AllRng As String: AllRng = getBzShtRange
    Dim BugImportSht As String: BugImportSht = getBugImportSht
    
    ActiveWorkbook.Worksheets(BugImportSht).Sort.SortFields.Clear
    ActiveWorkbook.Worksheets(BugImportSht).Sort.SortFields.Add Key:=Range( _
        TBrng), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:= _
        xlSortNormal
    With ActiveWorkbook.Worksheets(BugImportSht).Sort
        .SetRange Range(AllRng)
        .Header = xlYes
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply ' <== fails sometimes. have not figured out why
    End With
End Sub ' end tbSort
Sub SelectOwnerForFilter()
'
' SelectOwnerForFilter Macro
' put the selected owner in the filter for AllBugs
'
'
' Need to execute on "Analysis" sheet, selected value is copied to "data" sheet for filter, and then on "AllBugs" sheet the "FilterOwnerOpenRZ" macro is executed.
    Dim dataSht As String: dataSht = getDataSheet
    Dim bgTabName As String: bgTabName = getBugFileTabName
    Dim AnalysisDevOwnerCell As String: AnalysisDevOwnerCell = "H29"
    Dim DataDevOwnerCell As String: DataDevOwnerCell = "K1"
    
    Sheets(getAnalysisTabName).Activate
    Debug.Print getAnalysisTabName
    Range(AnalysisDevOwnerCell).Select
    Selection.Copy
    Sheets(dataSht).Select
    Range(DataDevOwnerCell).Select
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
    Sheets(bgTabName).Select
    FilterOwnerOpenRZ bgTabName, getRangeString(getBugCol, getOwnerCol, 1, getMaxRow), dataSht
    ' tbSort commented out because sometimes ".Apply" method crashes out Excel. not sure why
End Sub
Sub SelectOwnerForFixFilter()
'
' SelectOwnerForFixFilter Macro
' put the selected owner in the filter for AllBugs
'
'
' Need to execute on "Analysis" sheet, selected value is copied to "data" sheet for filter, and then on "AllBugs" sheet the "FilterOwnerFixedRZ" macro is executed.
    Dim dataSht As String: dataSht = getDataSheet
    Dim bgTabName As String: bgTabName = getBugFileTabName
    
    Sheets(getAnalysisTabName).Activate
    Debug.Print getAnalysisTabName
    Range("H29").Select
    Selection.Copy
    Sheets(dataSht).Select
    Range("K1").Select
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
    Sheets(bgTabName).Select
    FilterOwnerFixedRZ bgTabName, getRangeString(getBugCol, getOwnerCol, 1, getMaxRow), dataSht
End Sub
Sub DefValueForBlank(editRng As String)
    ' put a character in blank cells so that cut/paste into email doesn't get distorted when cells are empty
    Dim Fields As Range
    Dim Field As Range
    Dim FieldStr As String: FieldStr = "."
    Dim strlen As Integer
    Dim ThisSht As String: ThisSht = ActiveSheet.Name
    
    Set Fields = Worksheets(ThisSht).Range(editRng)
    ' increase performance from 1 minute, to 2 seconds by turning off screen update and auto calculation
    pauseUpdates
    For Each Field In Fields
        strlen = Len(Field.Value)
        If strlen < 1 Then
            Field.Value = FieldStr
        End If
    Next Field
    ' Turn screen update and calculation back on
    enableUpdates
    
End Sub ' end DefValueForBlank
Function lastFilledCell(colStr As String) As Integer
    Dim c As Integer: c = 0
    Dim strtRow As Integer: strtRow = 2
    Dim strlen As Integer
    Dim Fields As Range
    Dim Field As Range
    Dim ThisSht As String: ThisSht = ActiveSheet.Name
    
    Set Fields = Worksheets(ThisSht).Range(getRangeString(colStr, colStr, strtRow, getMaxRow))
    For Each Field In Fields
        strlen = Len(Field.Value)
        If strlen < 1 Then
            Exit For
        Else
            c = c + 1
        End If
    Next Field
    c = (c - 1) + strtRow
    'Debug.Print c
    lastFilledCell = c
End Function
Sub Refreshdata()
    setRunStatus
    MsgBox "The All FP Guest query can take up to 5 minutes!" & vbCrLf & "Be patient for it to complete, the Excel screen may go blank, do not worry.", vbInformation, "Be Patient"
    AllFPbugsQuery
    ThreeParbugsQuery

    ImportAllBugs
    Import3parBugs
    MsgBox "All FilePersona Guest, and InformFBO queries imported", vbInformation, "Guest & Host BZ downloads"
    Worksheets("Chart").Activate
    Range("h71").Value = "Yes"
    Sheets("Chart").Range("B73").Select
End Sub
Sub setRunStatus()
    pauseUpdates
    Range("h71").Value = "Pending"
    Range("h73").Value = "No"
    Range("h75").Value = "No"
    Range("h77").Value = "No"
    enableUpdates
End Sub
Sub ThreeParbugsQuery()
    webRequest getThreeParbugsQuery
End Sub 'end FPincludeQuery()
Sub Import3parBugs()
    Dim EndRow As Integer
    Dim colStr As Variant
    Dim colStrs() As Variant: colStrs = Array("F", "G", "I", "S", "T", "U")
    
    ImportBZquery get3PARBugFilename, get3PARBugFileTabName
    
    EndRow = lastFilledCell("d")
    
    For Each colStr In colStrs
        colRng = getRangeString(CStr(colStr), CStr(colStr), 2, EndRow)
        DefValueForBlank (colRng)
    Next colStr
    
    LinkBugs EndRow, getBugCol, get3PARBzURL
    LinkBugs EndRow, get3PARCfiCol, getCfiURL
    NoWrapText
    
End Sub
Sub AllFPbugsQuery()
    webRequest getAllFPbugsQuery
End Sub 'end FPincludeQuery()
Sub ImportAllBugs()
    Dim EndRow As Integer
    ImportBZquery getBugFilename, getBugFileTabName
    EndRow = lastFilledCell("d")
    Dim colStr As Variant
    Dim colStrs() As Variant: colStrs = Array("g", "k", "q")
    For Each colStr In colStrs
        colRng = getRangeString(CStr(colStr), CStr(colStr), 2, EndRow)
        DefValueForBlank (colRng)
    Next colStr
    LinkBugs EndRow, getBugCol, getBzURL
    LinkBugs EndRow, getCfiCol, getCfiURL
    UniqueOwners
    scrollTop
End Sub
Sub ImportBZquery(shtName As String, tabName As String)
    Dim dwnldPath As String: dwnldPath = getDwnLoadDir
    'ProtocolsSMB-Wipro-Closed-2019-01-11.csv
    'ProtocolsSMB-Wipro-NotRed-2019-01-11.csv
    shtName = shtName & "-" & getYMDstr
    Debug.Print shtName
    BZQimport dwnldPath, shtName, tabName
    TmpDwnldDelete dwnldPath, shtName
End Sub
Sub NoWrapText()
    Columns("A:X").Select
    With Selection
        .HorizontalAlignment = xlGeneral
        .VerticalAlignment = xlBottom
        .WrapText = False
        .Orientation = 0
        .AddIndent = False
        .IndentLevel = 0
        .ShrinkToFit = False
        .ReadingOrder = xlContext
        .MergeCells = False
    End With
    Range("A2").Select
End Sub
Function getYMDstr() As String
    Mo = Month(Date): If Len(Mo) = 1 Then Mo = "0" & Mo
    DA = Day(Date): If Len(DA) = 1 Then DA = "0" & DA
    Yr = Year(Date)
    YMDstr = Yr & "-" & Mo & "-" & DA
    getYMDstr = YMDstr
End Function
Sub BZQimport(dwnldPath As String, csvName As String, tabName As String)
    Dim csvFullpath As String
    Dim wrkBook As String: wrkBook = getWorkbookName
    Dim bzShtRange As String: bzShtRange = getBzShtRange
    
    csvFullpath = dwnldPath & "\" & csvName & ".csv"
    
    ' wait for file to exist
    DelayInSeconds 30
    While FileExists(csvFullpath) = False
        DelayInSeconds 10
        Debug.Print "try again"
    Wend
    
    pauseUpdates
    If Len(Dir(csvFullpath)) <> 0 Then
        Windows(wrkBook).Activate
        Sheets(tabName).Activate
        Clear
        Range(bzShtRange).ClearContents
        
        Workbooks.Open (csvFullpath)
        Windows(csvName & ".csv").Activate
        Range(bzShtRange).Select
        Selection.Copy
        
        ' switch to allbugs worksheet
        Windows(wrkBook).Activate
        Sheets(tabName).Activate
        Range("a2").Select
        ActiveSheet.Paste
        
        Application.DisplayAlerts = False
        Windows(csvName & ".csv").Activate
        Workbooks(csvName & ".csv").Close
        Application.DisplayAlerts = True
    End If
    enableUpdates
    scrollTop
End Sub

Sub LinkBugs(lastRow As Integer, linkCol As String, urlStr As String)
    ' example call LinkBugs getBZSheet & "!B3", "3parRedZone", "c2:c30"
    Dim bugNums As Range
    Dim bug As Range
    ' BZ query screen pre-pended to bug number to create link to bug in bugzilla
    
    Dim bugStr As String
    Dim strlen As Integer
    Dim lnkRng As String: lnkRng = getRangeString(linkCol, linkCol, 2, lastRow)
    
    Dim ThisSht As String: ThisSht = ActiveSheet.Name
    Set bugNums = Worksheets(ThisSht).Range(lnkRng)
    ' increase performance from 1 minute, to 2 seconds by turning off screen update and auto calculation
    pauseUpdates
    For Each bug In bugNums
        strlen = Len(bug.Value)
        If strlen <= 6 And strlen > 2 And bug.Value <> 0 Then
            bugStr = "=Hyperlink(" & Chr(34) & urlStr
            bugStr = bugStr & bug.Value & Chr(34) & "," & Chr(34) & bug.Value & Chr(34) & ")"
            bug.Value = bugStr
        End If
    Next bug
    ' Turn screen update and calculation back on
    enableUpdates
    scrollTop
End Sub ' end LinkBugs
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
Sub Clear()
'
' Clear Macro
' Clear filters
'
    If ActiveSheet.FilterMode Then ActiveSheet.ShowAllData
    scrollTop
End Sub
Sub scrollTop()
'
' scroll to top
'
    ActiveWindow.ScrollRow = 2
    Range("A3").Select
End Sub
Sub DelayInSeconds(delay As Integer)
    Dim time1, time2, start
    Dim delStr As String
    Dim minStr As String: minStr = "0:"
    
    If delay > 59 Then
        minStr = Str(Int((delay / 60))) & ":"
        delay = delay Mod 60
    End If
    
    If delay <= 9 Then
        delStr = "0" & Str(delay)
    Else
        delStr = Str(delay)
    End If
    delStr = minStr & delStr
    delStr = Replace(delStr, " ", "")
    time1 = Now
    'start = time1
    time2 = Now + TimeValue("0:0" & delStr)
    Do Until time1 >= time2
        ' timed pause
        time1 = Now()
    Loop
    'MsgBox (start & " now " & time1)
End Sub
Function getAllFPbugsQuery() As String
    getAllFPbugsQuery = Sheets(getDataSheet).Range("D28").Value
End Function
Function getThreeParbugsQuery() As String
    getThreeParbugsQuery = Sheets("BZ_URL").Range("A2").Value
End Function
Function getBugFilename() As String
    getBugFilename = Sheets(getDataSheet).Range("a46").Value
End Function
Function get3PARBugFilename() As String
    get3PARBugFilename = Sheets(getDataSheet).Range("a63").Value
End Function
Function getBugFileTabName() As String
    getBugFileTabName = Sheets(getDataSheet).Range("a51").Value
End Function
Function get3PARBugFileTabName() As String
    get3PARBugFileTabName = Sheets(getDataSheet).Range("a62").Value
End Function
Function getWorkbookName() As String
    getWorkbookName = Sheets(getDataSheet).Range("a48").Value
End Function
Function getDataSheet() As String
    getDataSheet = "data"
End Function
Function getBzURL() As String
    getBzURL = Sheets(getDataSheet).Range("a49").Value
End Function
Function get3PARBzURL() As String
    get3PARBzURL = Sheets(getDataSheet).Range("a60").Value
End Function
Function getCfiURL() As String
    getCfiURL = Sheets(getDataSheet).Range("a53").Value
End Function
Function getBzShtRange() As String
    getBzShtRange = Sheets(getDataSheet).Range("a50").Value
End Function
Function getAnalysisTabName() As String
    getAnalysisTabName = Sheets(getDataSheet).Range("a52").Value
End Function
Function getBugCol() As String
    getBugCol = Sheets(getDataSheet).Range("a54").Value
End Function
Function getCfiCol() As String
    getCfiCol = Sheets(getDataSheet).Range("a55").Value
End Function
Function get3PARCfiCol() As String
    get3PARCfiCol = Sheets(getDataSheet).Range("a61").Value
End Function
Function getOwnerCol() As String
    getOwnerCol = Sheets(getDataSheet).Range("a56").Value
End Function
Function getMaxRow() As Integer
    getMaxRow = Sheets(getDataSheet).Range("a57").Value
End Function
Function getTargetBuildCol() As String
    getTargetBuildCol = Sheets(getDataSheet).Range("a58").Value
End Function
Function getBugImportSht() As String
    getBugImportSht = Sheets(getDataSheet).Range("a51").Value
End Function
Function getRangeString(BegCol As String, EndCol As String, Optional BegRow As Integer, Optional EndRow As Integer) As String
    If BegRow <= 0 Or EndRow <= 0 Then
        getRangeString = BegCol & ":" & EndCol
    Else
        getRangeString = BegCol & BegRow & ":" & EndCol & EndRow
    End If
End Function



