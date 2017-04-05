Attribute VB_Name = "Module1"
Sub ForReview()
Attribute ForReview.VB_Description = "Sort on Target Milestone column for 'For Review'"
Attribute ForReview.VB_ProcData.VB_Invoke_Func = " \n14"
'
' ForReview Macro
' Sort on Target Milestone column for 'For Review'
'
    ClearFilters
    ActiveSheet.Range("$A$1:$AH$100").AutoFilter Field:=17, Criteria1:= _
        "For Review"
    Columns("k:m").Select: Selection.EntireColumn.Hidden = True
End Sub
Sub TargettedBuilds()
Attribute TargettedBuilds.VB_Description = "Filter for Target Builds != '---'"
Attribute TargettedBuilds.VB_ProcData.VB_Invoke_Func = " \n14"
'
' TargettedBuilds Macro
' Filter for Target Builds != '---'
'
    ClearFilters
    ActiveSheet.Range("$A$1:$AH$100").AutoFilter Field:=13, Criteria1:="<>---", _
        Operator:=xlAnd
    Columns("i:l").Select: Selection.EntireColumn.Hidden = True
    Columns("i:l").Select: Selection.EntireColumn.Hidden = True
    Columns("q:y").Select: Selection.EntireColumn.Hidden = True
End Sub
Sub FilterOnValue(fltrRng As String, fltrStg As String, fltrField As Integer)
    ClearFilters
    ActiveSheet.Range(fltrRng).AutoFilter Field:=fltrField, Criteria1:=fltrStg
End Sub
Sub noPriority()
    FilterOnValue "$A$1:$AH$100", "unsp*", 8
End Sub
Sub InPlay()
Attribute InPlay.VB_Description = "Bugs, not waived, not doc, not targetted, not 'For Review'"
Attribute InPlay.VB_ProcData.VB_Invoke_Func = " \n14"
'
' InPlay Macro
' Bugs, not waived, not doc, not targetted, not 'For Review'
'
    ClearFilters
    ' 6 is F "Product" not equal to Documentation
    ActiveSheet.Range("$A$1:$AH$100").AutoFilter Field:=6, Criteria1:= _
        "<>*Document*", Operator:=xlAnd
    ' 7 is G "Component" not equal to Documentation
    ActiveSheet.Range("$A$1:$AH$100").AutoFilter Field:=7, Criteria1:= _
        "<>*Document*", Operator:=xlAnd
    ' 12 is L "Waivers" equal to dashes which means not set
    ActiveSheet.Range("$A$1:$AH$100").AutoFilter Field:=12, Criteria1:="=---", _
        Operator:=xlOr, Criteria2:="="
    ' 13 is M "Target build" equal to dashes which means not set
    ActiveSheet.Range("$A$1:$AH$100").AutoFilter Field:=13, Criteria1:="=---"
    ' 17 is Q "Target Milestone" equal to Avitus, also need to check for PPI*
    ActiveSheet.Range("$A$1:$AH$100").AutoFilter Field:=17, Criteria1:="Avitus", _
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
    ClearFilters
    ActiveSheet.Range("$A$1:$AH$100").AutoFilter Field:=12, Criteria1:= _
        "Waiver Requested"
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
    ClearFilters
    ' 8 is H "priority"
    ActiveSheet.Range("$A$1:$AD$100").AutoFilter Field:=8, Criteria1:="P0"
End Sub
Sub FormatScrubSheet()
'
' FormatScrubSheet Macro
' Do the sort, and setup the top/bottom links
'
    ClearFilters
    Dim ThisSht As String: ThisSht = ActiveSheet.Name
    
    Dim PrevSht As String
    PrevSht = InputBox("M-D of sheet to compare against:", "Input sheet name")
    PrevSht = "bugs-2017-" & PrevSht
    
    pauseUpdates
' insertText Macro
' insert text for previous sheet name
'
'
    Range("k103").Select
    ActiveCell.FormulaR1C1 = PrevSht
    
    ' sort the product column alphabetically
    AvProductSort ThisSht, "F2:F100"
    
    Range("k1").Select
    Range("n111").Select
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
Sub CopySheet()
'
' CopySheet Macro
' open firefox with BZ query
' Copy current sheet, rename it to new date,
'
'
    
    ' get name for new sheet
    '
    Dim NewSht As String
    NewSht = InputBox("M-D of NEW sheet to copy TO:", "Input sheet name")
        
    Dim ThisSht As String
    ThisSht = InputBox("M-D of sheet to copy from:", "Input sheet name")
    ThisSht = "bugs-2017-" & ThisSht
    Sheets(ThisSht).Select
    
    ' rename new sheet
    '
    Sheets(ThisSht).Copy before:=Sheets(1)
    Sheets(ThisSht & " (2)").Select
    Sheets(ThisSht & " (2)").Name = "bugs-2017-" & NewSht
    Sheets("bugs-2017-" & NewSht).Select
    
    ' open firefox with bz query
    '
    AvBzQuery
    
    ' import data from csv from bugzilla
    AvimportInfo
    
    ' format sheet
    FormatScrubSheet
    
End Sub
Sub AvBzQuery()
    ' open firefox with bz query
    '
    ' Cell with direct CSV link
    Dim URLcell As String
    URLcell = "K3"
    
    bzqueryFunc (URLcell)
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
    Dim dwnldDirPath As String: dwnldDirPath = "C:\Users\mwroberts\AppData\Local\Temp\"
    Dim csvFullPath As String
    
    Dim ScrubSheet As String: ScrubSheet = "Scrub_Avitus_RZ_bugs.xlsm"
    
    Dim ImportSht As String
    ImportSht = InputBox("M-D of CSV sheet to IMPORT from:", "Input sheet name")
    ImportSht = "bugs-2017-" & ImportSht & ".csv"

    ' wait 10 seconds
    ' Application.Wait (Now + TimeValue("0:00:10"))

   ' open csv FILE and activate the worksheet, then copy the contents in two sections
   ' into the scrub worksheet
   '
    csvFullPath = dwnldDirPath & ImportSht
    Workbooks.Open (csvFullPath)
    Windows(ImportSht).Activate
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
    Range("D2").Select
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
Sub bzqueryFunc(URLcell As String)
    ' expect a cell range with cell that contains URL to be passed in
    Dim bzURL As String:  bzURL = Worksheets("Data").Range(URLcell).Value
    Dim browserPath As String: browserPath = "C:\Program Files (x86)\Mozilla Firefox\firefox.exe "
    Shell (browserPath & bzURL)
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
        strlen = Len(Field.Value)
        If strlen < 1 Then
            Field.Value = FieldStr
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
    ClearFilters
    ActiveSheet.Range("$A$1:$AH$101").AutoFilter Field:=9, Criteria1:= _
        "=*regress*", Operator:=xlOr, Criteria2:="=*forward*"
    ActiveSheet.Range("$A$1:$AH$101").AutoFilter Field:=13, Criteria1:="---"
End Sub
