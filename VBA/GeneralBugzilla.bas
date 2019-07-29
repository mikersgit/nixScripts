Attribute VB_Name = "GeneralBugzilla"
'########################
'# Bugzilla Utility subroutines
'########################

' Given:
'   1. csv file basename
'   2. spreadsheet tab into which to import
' Do:
'   1. append current date to csv file name
'   2. call import subroutine to copy/paste from csv to tab
'   3. call delete subroutine to remove csv file from file system
Sub ImportBZquery(csvFileName As String, tabName As String)
    Dim dwnldPath As String: dwnldPath = getDwnLoadDir
    'ProtocolsSMB-Wipro-Closed-2019-01-11.csv
    'ProtocolsSMB-Wipro-NotRed-2019-01-11.csv
    csvFileName = csvFileName & "-" & getYMDstr
    Debug.Print csvFileName
    BZQimport dwnldPath, csvFileName, tabName
    TmpDwnldDelete dwnldPath, csvFileName
End Sub 'ImportBZquery()

' Given:
'   1. browser download path
'   2. file name for CSV file
'   3. tab name tab into which to import the csv
' Do:
'   1. copy/paste from the csv into the spreadsheet tab
Sub BZQimport(dwnldPath As String, csvName As String, tabName As String)
    Dim csvFullpath As String
    Dim wrkBook As String: wrkBook = getWorkbookName
    Dim bzShtRange As String: bzShtRange = getBzShtRange
    
    csvFullpath = dwnldPath & "\" & csvName & ".csv"
    
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
        Range("a1").Select
        ActiveSheet.Paste
        
        Application.DisplayAlerts = False
        Windows(csvName & ".csv").Activate
        Workbooks(csvName & ".csv").Close
        Application.DisplayAlerts = True
    End If
    enableUpdates
    scrollTop
End Sub 'BZQimport()
' Given:
'   1. path
'   2. file name
' Do:
'   1. Delete the csv from the download directory
Sub TmpDwnldDelete(dwnldDirPath As String, csvName As String)
    Dim csvFullpath As String
    csvFullpath = dwnldDirPath & "\" & csvName & ".csv"
    
    Application.DisplayAlerts = False
    pauseUpdates
    If Len(Dir(csvFullpath)) <> 0 Then
        Workbooks.Open (csvFullpath)
        Windows(csvName & ".csv").Activate
        Workbooks(csvName & ".csv").Saved = True

        Workbooks(csvName & ".csv").Close SaveChanges:=False

        SetAttr csvFullpath, vbNormal
        Kill csvFullpath
    End If
    Application.DisplayAlerts = True
    enableUpdates
End Sub 'TmpDwnldDelete()
'INPUT:
'   1. last active row numer
'   2. column with values to hyperlink
'   3. URL prefix for hyperlink
'DO:
'   Iterate over the rows, check there is a value (skip if no value), write hyperlink code to cell
'
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
    ' use Chr(34) for double quotes. Works more consistently than trying to escape, multi-quote to get quote string
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
'INPUT:
'   1. bug/cfi url prefix location on data sheet
'   2. Tab in spreadsheet where bug/cfi's are to be linked
'   3. Column range to link
'   4. [opt] bug/cfi url SUFFIX if needed
'   5. [opt] Boolean to use or not altQuery string (eg. FP bugzilla v. 3PAR bugzilla)
'DO:
'   Iterate over the bug/cfi ids in the specified column and write HYPERLINK code into cell to link to URL
'   If AltQuery is true, and a second query string was provided, and bug ID is > FP bz range, link to 3par bz url instead
'
' Example:
'   # link CFI with suffix in the second URL arg
'   LinkIds dataSht & "!B30", Sht, colRng, dataSht & "!B32", False
'   # link bugs, with 3par URL in the second URL arg, and boolean true
'   LinkIds dataSht & "!B36", Sht, colRng, dataSht & "!B37", True
'
Sub LinkIds(idLnkPrefx As String, shtName As String, lnkRange As String, Optional idLnkSufx As String, Optional altQuery As Boolean)
    ' example call LinkBugs getBZSheet & "!B3", "3parRedZone", "c2:c30"
    Dim idNums As Range
    Dim id As Range
    ' BZ query screen pre-pended to bug number to create link to bug in bugzilla
    Dim queryStr As String: queryStr = idLnkPrefx
    Dim idStr As String
    Dim idVal As String
    'Dim UDUbugIDthreshold As Integer: UDUbugIDthreshold = 180000
    Dim strlen As Integer
    Dim skipId As Boolean: skipId = False
    Sheets(shtName).Select
    Set idNums = Worksheets(shtName).Range(lnkRange)
        
    pauseUpdates
    For Each id In idNums
        ' some csv imports have multiple spaces in "blank" cells, strip out space chars
        If IsNumeric(id.Value) = False Then
            skipId = True
        Else
            idVal = Replace(id.Value, " ", "")
        End If
        strlen = Len(idVal)

        If (strlen <= 6 And strlen > 0 And id.Value <> 0) And skipId = False Then
            If id.Value > 140000 And altQuery = True Then
                queryStr = idLnkSufx
            End If
            idStr = "=Hyperlink(" & Chr(34) & queryStr
            idStr = idStr & id.Value
            ' if optional URL suffix supplied and not an alternate queryString, then append ampersand Chr(38), and then the URL suffix
            If Len(idLnkSufx) > 0 And altQuery = False Then
                idStr = idStr & Chr(38) & idLnkSufx
            End If
            idStr = idStr & Chr(34) & "," & Chr(34) & id.Value & Chr(34) & ")"
            id.Value = idStr
        End If
        skipId = False
        queryStr = idLnkPrefx
    Next id
    enableUpdates
End Sub ' end LinkIds
Function getBzURL() As String
    getBzURL = Sheets(getDataSheet).Range("a14").Value
End Function
Function get3PARBzURL() As String
    get3PARBzURL = Sheets(getDataSheet).Range("a25").Value
End Function
Function getCfiURL() As String
    getCfiURL = Sheets(getDataSheet).Range("A18").Value
End Function
Function getBzShtRange() As String
    'range in downloaded bug sheet to copy to main sheet
    getBzShtRange = Sheets(getDataSheet).Range("A15").Value
End Function
