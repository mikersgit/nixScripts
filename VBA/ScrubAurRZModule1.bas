Attribute VB_Name = "Module1"
Sub FormatScrubSheet()
Attribute FormatScrubSheet.VB_ProcData.VB_Invoke_Func = " \n14"
'
' FormatScrubSheet Macro
' Do the sort, and setup the top/bottom links
'
    Dim ThisSht As String: ThisSht = ActiveSheet.Name
    ' MsgBox ("Active sheet is " & ThisSht)
    
    Dim PrevSht As String
    PrevSht = InputBox("M-D of sheet to compare against:", "Input sheet name")
    PrevSht = "bugs-2017-" & PrevSht
    
    pauseUpdates
' insertText Macro
' insert text for previous sheet name
'
'
    Range("I84").Select
    ActiveCell.FormulaR1C1 = PrevSht
    
    ' sort the product column alphabetically
    AuProductSort ThisSht, "F1:F83"

    Range("I1").Select
    Range("L92").Select
' Hyperlinks Macro
' Insert top/bottom links
'
'
    Range("I1").Select
    ActiveSheet.Hyperlinks.Add Anchor:=Selection, Address:="", SubAddress:= _
        "'" & ThisSht & "'" & "!K98", TextToDisplay:="Prev Notes"
    Range("I1").Select
    Selection.Hyperlinks(1).Follow NewWindow:=False, AddHistory:=True
    Range("L92").Select
    ActiveSheet.Hyperlinks.Add Anchor:=Selection, Address:="", SubAddress:= _
        "'" & ThisSht & "'" & "!A2", TextToDisplay:="Top"
' date to compare age of bugs
'
' insertDate Macro
' insert today() excel function
' then the output of that is pasted as a value
'
    Range("I86").Select
    ActiveCell.FormulaR1C1 = "=TODAY()"
    Range("I86").Select
    Selection.Copy
    Range("I85").Select
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
    Application.CutCopyMode = False
    
    enableUpdates
    
    ' fill "notes" column with "."
    fillBlanks "H2", "H80"
    
    ' E, N, S (status synopsis, CFI, and Keyword respectively) fill with default "." string if empty
    DefValueForBlank "E2:E80", ThisSht
    DefValueForBlank "N2:N80", ThisSht
    DefValueForBlank "S2:S80", ThisSht
    
    ' make bug numbers BZ links
    LinkBugs "Data!H4", ThisSht, "C2:C80"
    
End Sub
Sub AuProductSort(CurrentSht As String, SortRange As String)
' sort the product column alphabetically
    ActiveWorkbook.Worksheets(CurrentSht).AutoFilter.Sort.SortFields.Clear
    ActiveWorkbook.Worksheets(CurrentSht).AutoFilter.Sort.SortFields.Add _
        key:=Range(SortRange), SortOn:=xlSortOnValues, Order:=xlAscending, _
        DataOption:=xlSortTextAsNumbers
    With ActiveWorkbook.Worksheets(CurrentSht).AutoFilter.Sort
        .Header = xlYes
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With
End Sub
Sub AuRefreshData()
    ' new data in the current sheet
    AubzQuery
    AuimportInfo
    AuProductSort ActiveSheet.Name, "F2:F80"

    ' make bug numbers BZ links
    LinkBugs "Data!H4", ActiveSheet.Name, "C2:C80"
    ' E, N, S (status synopsis, CFI, and Keyword respectively) fill with default "." string if empty
    DefValueForBlank "E2:E80", ThisSht
    DefValueForBlank "N2:N80", ThisSht
    DefValueForBlank "S2:S80", ThisSht
    DefValueForBlank "H2:H80", ThisSht ' since this is refresh, do not wipe out comments already entered, may have to relocate to match bug
End Sub
Sub CopySheet()
'
' CopySheet Macro
' Copy current sheet
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
    
    ' call the saved bz query
    AubzQuery
    
    ' import the csv
    AuimportInfo
    
    ' Format the new data
    FormatScrubSheet
    
End Sub
Sub AubzQuery()
    ' open firefox with bz query
    '
    ' this references the cell with the direct to CSV link in BZ, does not display the query
    Dim URLcell As String
    URLcell = "H3"
    
    bzqueryFunc (URLcell)
    
End Sub
Sub AuimportInfo()
'
' importInfo Macro
' Get csv data from downloaded bz query
'
    Dim dwnldDirPath As String: dwnldDirPath = "C:\Users\mwroberts\AppData\Local\Temp\"
    Dim csvFullPath As String
    
    Dim ScrubSheet As String: ScrubSheet = "Scrub_Aurora_RZ_bugs.xlsm"
    
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
    Range("A2:E80").Select
    Selection.Copy
    
    ' switch to scrub worksheet and paste a-e
    Windows(ScrubSheet).Activate
    Range("C2").Select
    ActiveSheet.Paste
    
    ' back to csv for next section f-v
    Windows(ImportSht).Activate
    Range("F2:V80").Select
    Application.CutCopyMode = False
    Selection.Copy
    
    ' and copy to scrub worksheet
    Windows(ScrubSheet).Activate
    Range("J2").Select
    ActiveSheet.Paste
    Range("D2").Select
End Sub
Sub bzqueryFunc(URLcell As String)
    ' expect a cell range with cell that contains URL to be passed in
    Dim bzURL As String
    bzURL = Worksheets("Data").Range(URLcell).Value
    Dim browserPath As String
    browserPath = "C:\Program Files (x86)\Mozilla Firefox\firefox.exe "
    Shell (browserPath & bzURL)
End Sub

Sub ForReview()
Attribute ForReview.VB_Description = "Sort on Target Milestone column for 'For Review'"
Attribute ForReview.VB_ProcData.VB_Invoke_Func = " \n14"
'
' ForReview Macro
' Sort on Target Milestone column for 'For Review'
'
    ClearFilters
    ActiveSheet.Range("$A$1:$Z$83").AutoFilter Field:=12, Criteria1:= _
        "For Review"
End Sub
Sub TargettedBuilds()
Attribute TargettedBuilds.VB_Description = "Filter for Target Builds != '---'"
Attribute TargettedBuilds.VB_ProcData.VB_Invoke_Func = " \n14"
'
' TargettedBuilds Macro
' Filter for Target Builds != '---'
'
    ClearFilters
    ActiveSheet.Range("$A$1:$Z$83").AutoFilter Field:=11, Criteria1:="<>---", _
        Operator:=xlAnd
End Sub
Sub InPlay()
Attribute InPlay.VB_Description = "Bugs, not waived, not doc, not targetted, not 'For Review'"
Attribute InPlay.VB_ProcData.VB_Invoke_Func = " \n14"
'
' InPlay Macro
' Bugs, not waived, not doc, not targetted, not 'For Review'
'
    ClearFilters
    ActiveSheet.Range("$A$1:$Z$83").AutoFilter Field:=6, Criteria1:= _
        "<>*Document*", Operator:=xlAnd
    ActiveSheet.Range("$A$1:$Z$83").AutoFilter Field:=7, Criteria1:= _
        "<>*Document*", Operator:=xlAnd
    ActiveSheet.Range("$A$1:$Z$83").AutoFilter Field:=10, Criteria1:="=---", _
        Operator:=xlOr, Criteria2:="="
    ActiveSheet.Range("$A$1:$Z$83").AutoFilter Field:=11, Criteria1:="---"
    ActiveSheet.Range("$A$1:$Z$83").AutoFilter Field:=12, Criteria1:="Aurora"
    
End Sub
Sub Waivers()
Attribute Waivers.VB_Description = "bugs with waivers requested"
Attribute Waivers.VB_ProcData.VB_Invoke_Func = " \n14"
'
' Waivers Macro
' bugs with waivers requested
'
    ClearFilters
    ActiveSheet.Range("$A$1:$Z$83").AutoFilter Field:=10, Criteria1:= _
        "Waiver Requested"
End Sub
Sub ClearFilters()
'
' ClearFilters Macro
' Clear column filters
'
    If ActiveSheet.FilterMode Then ActiveSheet.ShowAllData
    ' Go To cell D18 after processing
    Range("A1").Select
End Sub
Sub HideColumns()
'
' HideColumns Macro
' Hide Columns to show previous values
'
    Columns("G:G").Select
    Selection.EntireColumn.Hidden = True
    Columns("I:I").Select
    Selection.EntireColumn.Hidden = True
    Columns("L:L").Select
    Selection.EntireColumn.Hidden = True
    Columns("N:S").Select
    Selection.EntireColumn.Hidden = True
    Columns("U:Z").Select
    Selection.EntireColumn.Hidden = True
    ActiveWindow.ScrollColumn = 1
    Range("E2").Select
End Sub
Sub UnHideColumns()
'
' UnHideColumns Macro
' Unhide columns
'
    Columns("C:AA").Select
    Selection.EntireColumn.Hidden = False
    Range("E2").Select
End Sub
Sub P0bugs()
'
' P0bugs Macro
' Filter for 'P0' bugs
'
    ClearFilters
    ActiveSheet.Range("$A$1:$AD$81").AutoFilter Field:=20, Criteria1:="P0"
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
Sub iterateOverAge()
' if the target cell (column L)is "For Review", and the age cell (column A) is > value for trigger on "Data" sheet, color orange
    For Each c In Worksheets("bugs-2017-03-23").Range("A2:A80").Cells
        If c.Value > 5 Then c.Interior.Color = RGB(255, 100, 100)
    Next
End Sub
Sub Reviewtrigger()
Attribute Reviewtrigger.VB_Description = "age trigger"
Attribute Reviewtrigger.VB_ProcData.VB_Invoke_Func = " \n14"
'
' trigger Macro
' age trigger
'
'
    ClearFilters
    Dim age As String: age = Worksheets("Data").Range("H12").Value
    ActiveSheet.Range("$A$1:$AD$81").AutoFilter Field:=12, Criteria1:= _
        "For Review"
    ActiveSheet.Range("$A$1:$AD$81").AutoFilter Field:=1, Criteria1:=">=" & age, _
        Operator:=xlAnd
End Sub
Sub Prioritytrigger()
'
' trigger Macro
' age trigger
'
'
    ClearFilters
    
    ActiveSheet.Range("$A$1:$AD$81").AutoFilter Field:=20, Criteria1:= _
        "P0"
    ActiveSheet.Range("$A$1:$AD$81").AutoFilter Field:=19, Criteria1:="Regres*", _
        Operator:=xlOr, Criteria2:="="
End Sub
Sub LinkBugs(bzLnkLoc As String, shtName As String, lnkRange As String)
    Dim bugNums As Range
    Dim bug As Range
    ' BZ query string pre-pended to bug number to create link to bug in bugzilla
    Dim bzStr As String: bzStr = bzLnkLoc
    Dim bugStr As String
    Dim strlen As Integer
    
    Set bugNums = Worksheets(shtName).Range(lnkRange)
    pauseUpdates
    For Each bug In bugNums
        strlen = Len(bug.Value)
        If strlen <= 6 And strlen > 0 And bug.Value <> 0 Then
            bugStr = "=Hyperlink(" & bzStr
            bugStr = bugStr & " & " & bug.Value & "," & bug.Value & ")"
            bug.Value = bugStr
        End If
    Next bug
    enableUpdates
    Range("A2").Select
End Sub ' LinkBugs
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
