Attribute VB_Name = "Module1"
'*********** Sections **********
' 1. Globals
' 2. Initialize
' 3. Filter Bugs
' 4. format, sort
' 5. Begin To Be Verified (TBV) analysis
' 6. control general display
' 7. Pull data from external sources
' 8. trigger sheet
' 9. 3par (UDU) bug
' 10. Functions Section

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
    Public NextRow As Integer ' row index to use when populating Trigger sheet
    '******************* columns **************************
    Public colsSet As Boolean ' set this when all columns have been set.
    Public colsWrite As Boolean ' set this when the current column defs have been written to sheet
    Public waiveCol As Integer
    Public tarBldCol As Integer
    Public tarMilCol As Integer
    Public prodCol As Integer
    Public compCol As Integer
    Public severCol As Integer
    Public statusCol As Integer
    Public statusSynCol As Integer
    Public prioCol As Integer
    Public keywCol As Integer
    Public noteCol As Integer
    Public bugCol As Integer
    Public verCol As Integer
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
    NextRow = 0
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
Sub CallInitRountine()
    ' use this in debugging to get globals re-initialized
    Auto_Open
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
    ClearFilters
    pauseUpdates
    ActiveSheet.Range(filterRegion).AutoFilter Field:=waiveCol, Criteria1:="---"
    ActiveSheet.Range(filterRegion).AutoFilter Field:=tarBldCol, Criteria1:="---"
    ActiveSheet.Range(filterRegion).AutoFilter Field:=tarMilCol, Criteria1:= _
        "<>For Review", Operator:=xlAnd
    hideColumnRng ("L:M")
    scrollTop
    enableUpdates
End Sub ' end NoDisposition
Sub Reopened()
'
' Sort on Status column (30) for 'REOPENED'
'
    FilterOnValue filterRegion, "REOPENED", statusCol
    hideColumnRng ("o:ac")
    scrollTop
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

    uniqTargBld ' put unique list of target builds in the product column starting at row 152
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
    scrollTop
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
    scrollTop
End Sub ' end DefValueForBlank
Sub writeColumnsData()
    'colsWrite = False
    ' do not call try to write column data unless this is the first call (colsWrite = false), and sheet exists
    If colsWrite <> True Then
'If colsWrite <> True And WorksheetExists(getBugTabPfx) Then
    colsWrite = True

    Dim rowNu As Integer: rowNu = 200
    Dim c As Variant
    Dim v As Variant
    Dim l As String
    Dim n As String
    Dim col As String

'    colsSet = False
    UnHideColumns
'    setColNumbers
'    prodColLtr = getColLtr(prodCol) ' now that the column number of filter is known, determine the column letter for range calls
'    noteColLtr = getColLtr(noteCol)
'    bugColLtr = getColLtr(bugCol)
    

        pauseUpdates
        ' write the data range limits to the sheet
        Range("A197").Select: ActiveCell.FormulaR1C1 = rngSt
        Range("A198").Select: ActiveCell.FormulaR1C1 = rngEd
        Dim colNm() As Variant: colNm = Array("Bug ID," & bugColLtr & "," & bugCol, "Product," & prodColLtr & "," & prodCol, _
                    "Component," & "," & compCol, "Priority," & "," & prioCol, "Keywords," & "," & keywCol, _
                    "Notes," & noteColLtr & "," & noteCol, "Waivers," & "," & waiveCol, "Target Build," & "," & tarBldCol, _
                    "CFI," & "," & getColNu("CFI"), "Status Synopsis," & "," & statusSynCol, "Target Milestone," & "," & tarMilCol, _
                    "Severity," & "," & severCol, "Status," & "," & statusCol, "Version," & "," & verCol)

        For Each c In colNm
            pauseUpdates
            v = Split(CStr(c), ",")
            n = Replace(CStr(v(0)), " ", "")
            col = CStr(v(2))
            
            Range("A" & CStr(rowNu)).Select: ActiveCell.FormulaR1C1 = n
            l = CStr(v(1)): If Len(l) < 1 Then l = getColLtr(CInt(v(2)))
            Range("B" & CStr(rowNu)).Select: ActiveCell.FormulaR1C1 = l
            Range("E" & CStr(rowNu)).Select: ActiveCell.FormulaR1C1 = l & rngSt & ":" & l & rngEd
            Range("C" & CStr(rowNu)).Select: ActiveCell.FormulaR1C1 = col
            'R2C8:R100C8
            nmrng n, "R" & rngSt & "C" & col & ":" & "R" & rngEd & "C" & col, getBugTabPfx
            rowNu = rowNu + 1
        Next c
        
        enableUpdates
 End If
End Sub ' writeColumnsData
Sub uniqTargBld()
'
' unique values for target build in the target build column
' write the unique values into the summary area that is under the product column
'
    Dim targs As Range
    Dim targ As Range
    Dim targStr As String
    Dim dateStr As String
    Dim vStr As Variant
    Dim vStr2 As Variant
    Dim tarSumCol As String: tarSumCol = Range("B215").value
    Dim iter As Integer: iter = 0
    Dim idx1 As Integer
    Dim bsize As Integer
    Dim loc As Integer: loc = Range("C215").value ' the location in the spreadsheet where the target build start location vaue resides
    Dim tarBldColLtr As String: tarBldColLtr = getColLtr(tarBldCol)
    Dim builds(13) As Variant: builds(0) = ""
    
    pauseUpdates
    'clear the summary column of target releases
    Range(getRngStr(tarSumCol, tarSumCol, CStr(loc), CStr((loc + 13)))).Select
    Selection.ClearContents
    
    'get all the targets in the target milestone
    Set targs = Worksheets(getBugTabPfx).Range(getRngStr(tarBldColLtr, tarBldColLtr, rngSt, rngEd))
    
    ' build array of unique target builds from target build column
    For Each targ In targs
        If targ.value <> "---" Then ' ignore "not set" value
            targStr = targ.value
            If UBound(Filter(builds, targStr)) < 0 Then ' if < 0 then value not already in array
                builds(iter) = targStr
                iter = iter + 1
                'MsgBox targStr
            End If
        End If
    Next targ
    bsize = iter - 1
    
    ' sort array
    For iter = 0 To bsize
        vStr = Right(CStr(builds(iter)), 8)
        For idx1 = 0 To bsize
            vStr2 = Right(CStr(builds(idx1)), 8)
            If Len(vStr2) > 0 And CLng(vStr) < CLng(vStr2) Then
                dateStr = CStr(builds(idx1))
                builds(idx1) = builds(iter)
                builds(iter) = dateStr
            End If
        Next idx1
    Next iter
    
    'output target builds to sheet
    For Each vStr In builds
        If Len(vStr) > 0 Then
            Range(prodColLtr & CStr(loc)).Select
            ActiveCell.FormulaR1C1 = CStr(vStr)
            loc = loc + 1
        End If
    Next vStr
    enableUpdates
End Sub ' end uniqTargBld
Sub nmrng(rngName As String, rngStr As String, sht As String)
'
' nmrng Macro
' create a named range that is sheet specific
'
    ActiveWorkbook.Worksheets(sht).names.Add name:=rngName, _
        RefersToR1C1:="='" & sht & "'!" & rngStr
    'ActiveWorkbook.Worksheets("bugs-2017-06-23").names("priority").Comment = ""
End Sub

'******************** End of formating sorting routines ********************
'***************************************************************************

'******************** Begin To Be Verified (TBV) analysis ******************
'***************************************************************************
' Run sql query
' Generate unique list of owners
' Filter on each owner
' capture count owned by each owner
' write to summary area of scrub sheet
Sub TBVsqlQuery()
    Dim SQLdataSht As String: SQLdataSht = getTBVtarget
    Dim SQLConnectionQuery As String: SQLConnectionQuery = getTBVquery
    Sheets(SQLdataSht).Select
    Dim TableName As String: TableName = ActiveSheet.ListObjects(1).name

    ClearTable TableName
    ActiveWorkbook.Connections(SQLConnectionQuery).Refresh
    TBVowners
End Sub 'TBVsqlQuery
Sub TBVowners()
    Dim owners As Range
    Dim owner As Range
    Dim ownerStr As String
    Dim vStr As Variant
    Dim ownerTblCol As String
    Dim iter As Integer: iter = 0
    Dim rowCnt As Integer
    Dim loc As Integer
    Dim ownAry(13) As Variant: ownAry(0) = ""
     
    'get num rows in table
    Dim tbl As ListObject
    Set tbl = ActiveSheet.ListObjects(1)
    rowCnt = tbl.ListRows.Count + 1
    
    'get all the targets in the target milestone
    ownerTblCol = Sheets(getDataSheet).Range("k23").value
    Set owners = Worksheets(getTBVtarget).Range(getRngStr(ownerTblCol, ownerTblCol, 2, CStr(rowCnt)))
    
    ' build array of unique owners from owners column
    For Each owner In owners
        If owner.value = "" Then ' count empty value as "external partner"
            ownerStr = "External"
            owner.value = ownerStr '' need to limit this to the number of rows in table, else we count entire 99 rows
        Else
            ownerStr = owner.value
        End If
        If UBound(Filter(ownAry, ownerStr)) < 0 Then ' if < 0 then value not already in array
            ownAry(iter) = ownerStr
            iter = iter + 1
        End If
    Next owner
    
    'output owners to sheet
    'bugs-2017-07-13 K156
    pauseUpdates
    Sheets(getBugTabPfx).Activate
    loc = Range("C219").value
    Dim tbvColSt As String: tbvColSt = Range("c221").value
    Dim tbvColEnd As String: tbvColEnd = Range("c222").value
    'Sheets("bugs-2017-07-14").Activate
    iter = 0
    Range(Range("e218").value).Select
    Selection.ClearContents
    For Each vStr In ownAry
        If Len(vStr) > 0 Then
            Range(tbvColSt & CStr(loc)).Select
            ActiveCell.FormulaR1C1 = CStr(vStr)
            Range(tbvColEnd & CStr(loc)).Select
            ActiveCell.FormulaR1C1 = CStr(getNumMatches(owners(), CStr(vStr)))
            iter = iter + 1
            loc = loc + 1
        End If
    Next vStr
    enableUpdates
End Sub 'TBVowners
'******************** End of To Be Verified (TBV) analysis *****************
'***************************************************************************

'*******************************************
'** Subroutines that control general display
'*******************************************
Sub scrollTop()
'
' scroll to top
'
    ActiveWindow.ScrollRow = 2
    Range("A1").Select
End Sub
Sub hideColumnRng(rng As String)
    Columns(rng).Select: Selection.EntireColumn.Hidden = True
End Sub
Sub hideColumnName(colName As String)
    Dim cn As String: cn = getColLtr(getColNu(colName))
    hideColumnRng (getRngStr(cn, cn))
End Sub
Sub ClearTable(TableName As String)
'
' ClearTable Macro
' Clear but do not delete
'
' Keyboard Shortcut: Ctrl+Shift+T
'
    Range(getRngStr("A", "AB", rngSt, rngEd)).Select
    Selection.ClearContents
    'Range("Table_ExternalData_1[[#Headers],[BugId]]").Select
    Range(TableName & "[[#Headers],[BugId]]").Select
End Sub 'end ClearTable
Sub ClearFilters(Optional writeColumns As Boolean)
'
' ClearFilters Macro
' Clear column filters
'
' The "If" prevents the error when clearning when no filters are set
'
    If writeColumns = True Then
        writeColumnsData ' this gets called all the time, but set a boolean so it only does work once
    End If
    pauseUpdates
    If ActiveSheet.FilterMode Then ActiveSheet.ShowAllData
    ' Go To cell D18 after processing
    UnHideColumns
    hideColumnRng (getRngStr(bugColLtr, bugColLtr))
    scrollTop
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
Sub CopySummary()
'
' CopySummary Macro
' copy defect summary

    Sheets(getBugTabPfx).Select
    UnHideColumns
    Range("K145:N162").Select
    Selection.Copy
    Sheets(getTriggerSheet).Select
    Range("a34").Select
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
    Range("a31").Select
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
    ClearTable ActiveSheet.ListObjects(1).name
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
    Dim ShName As String
    pauseUpdates
    ' make sure the copy from sheet is the active sheet
    ClearFilters False ' send "False" so writingColumns not attempted until sheet is copied.

    ' check if TO already exists, then rename from to avoid collision if it does
    If WorksheetExists(toSht) Then
        ShName = fromSht & "-" & CStr(Hour(Now)) & CStr(Minute(Now))
        Sheets(fromSht).name = ShName
        fromSht = ShName
    End If
    
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
'*************** End Pull data from external sources and import section **************************
'*************************************************************************************************
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
    Dim nxtrw As Integer: nxtrw = getNextRow
    trHeadings "A1", "Blocked without target build"
End Sub
Sub trReview()
    trHeadings "A4", """For Review"" > 3 days"
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
Sub trNoDisp()
    trHeadings "a25", "No Disposition"
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
Sub runNoDisp()
    Worksheets(getTriggerSheet).Activate
    Set trigSht = ActiveSheet
    Worksheets(Range("e1").value).Activate
    NoDisposition
    copyFilterRange
    ' goto trigger sheet in calculated position
    ' call paste
End Sub
Sub runReview()
    Worksheets(getTriggerSheet).Activate
    Set trigSht = ActiveSheet
    Worksheets(Range("e1").value).Activate
    ForReview
    copyFilterRange
    ' goto trigger sheet in calculated position
    ' call paste
End Sub
Sub lastFilledCell()
    Dim c As Integer: c = Range("D2:d100").Cells.SpecialCells(xlCellTypeBlanks).Row
    MsgBox CStr(c)
End Sub
Sub copyFilterRange()
    Dim rows As Integer: rows = ActiveSheet.AutoFilter.Range.Columns(1).SpecialCells(xlCellTypeVisible).Cells.Count
    Range("a1:o100").Cells.SpecialCells(xlCellTypeVisible).Copy
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

    LinkBugs getBZSheet & "!B9", "3parRedZone", getRngStr("C", "C", urngSt, urngEd)
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
Function WorksheetExists(sName As String) As Boolean
    WorksheetExists = Evaluate("ISREF('" & sName & "'!A1)")
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
    fromTab = getBugTabPfx & fromTab
    getMDstring = fromTab
End Function ' end getMDstring
Function getBugTabPfx() As String
    getBugTabPfx = "bugs-" & YMDstr
End Function
Function getSQLtarget() As String
    getSQLtarget = Worksheets(getDataSheet).Range("K10").value
End Function
Function getSQLquery() As String
    getSQLquery = Worksheets(getDataSheet).Range("K9").value
End Function
Function getTBVtarget() As String
    getTBVtarget = Worksheets(getDataSheet).Range("K22").value
End Function
Function getTBVquery() As String
    getTBVquery = Worksheets(getDataSheet).Range("K21").value
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
Function getNextRow() As Integer
    If NextRow = 0 Then
        getNextRow = 1
    Else
        getNextRow = NextRow
    End If
End Function
Function getColNu(TextToFind As String) As Integer
    ' from column header, determine column number
    Dim rng1 As Range
    pauseUpdates
    rows("1:1").Select
    
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
     statusSynCol = getColNu("status synopsis")
     prioCol = getColNu("priority")
     keywCol = getColNu("keywords")
     noteCol = getColNu("*notes")
     verCol = getColNu("version")
     colsSet = True
    End If
    scrollTop
End Function
Function getNumMatches(ary As Variant, str As String) As Integer
    Dim elem As Variant
    Dim cnt As Integer: cnt = 0
    
    For Each elem In ary
        If str = CStr(elem) Then
            cnt = cnt + 1
        End If
    Next elem
    getNumMatches = cnt
End Function

