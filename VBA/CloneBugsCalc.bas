Attribute VB_Name = "Module1"
Sub ClearFilters()
'
' ClearFilters Macro
' Clear column filters
'
    If ActiveSheet.FilterMode Then ActiveSheet.ShowAllData
    Range("A1").Select
End Sub
Sub LaunchBZ(URL As String)
    'C:\Program Files (x86)\Mozilla Firefox\firefox.exe & " "
    Shell (getBrowserPath & URL)
End Sub
Sub bzqueryFunc(URLcell As String, SheetWURL As String)
    ' expect a cell range with cell that contains URL to be passed in
    Dim bzURL As String: bzURL = Worksheets(SheetWURL).Range(URLcell).Value
    LaunchBZ bzURL
End Sub
Sub CloneCSVquery()
    ' open firefox with bz query
    '
    Dim URLcell As String: URLcell = "k28"
    Dim URLsheet As String: URLsheet = "CloneBugs"
    
    bzqueryFunc URLcell, URLsheet
    cbImport
End Sub
Sub cbImport()
    Dim CutRange As String: CutRange = "A2:N11"
    Dim PasteRange As String: PasteRange = "H2"
    
    CloneImportInfo getWkBkName, CutRange, PasteRange
End Sub
Sub SpecificBugsQuery()
    ' build URL for bug ID or comma separated list of IDS that is in the format to prepare for cloning
    '=HYPERLINK(CONCATENATE(G42, K31, G44), K31)
    Dim URL As String: URL = Range("G42") & Range("K31") & Range("g44")
    LaunchBZ URL
    cbImport
End Sub
Sub MasterFy()
    ' build url that sets the bugs (c17) Target milestone to 'Master', and prepends [Master] to summary (d17)
    ' g35,c17,g37,d17,g39
    Dim URL As String
    Dim bzSummary As String: bzSummary = urlsafe(Range("d17").Value)
    URL = Range("G35") & Range("c17") & Range("g37") & bzSummary & Range("g39")
    LaunchBZ URL
    'MsgBox URL
End Sub
Function urlsafe(line) As String
' see "man ascii" for octal and hex equivalents
'# 047   27    '’ # single quote
'# 052   2A    *
'# 054   2C    ,  # comma
'# 055   2D    -
'# 056   2E    .
'# 057   2F    /
'# 133   5B    [
'# 135   5D    ]
'
'echo ${ResText} | gawk '{gsub("[[:space:]]","%20")
'                gsub(",","%2C")
'                gsub("\047","%27")
'                gsub("\057","%2F")
'                gsub("\055","%2D")
'                gsub("\052","%2A")
'                gsub("\\[","%5B")
'                gsub("\\]","%5D")
'                gsub("\\.","%2E")
'                print}'
    Dim tmp As String
    tmp = Replace(line, " ", "%20")
    urlsafe = tmp

End Function
Sub CloneImportInfo(ScrubSheet As String, CutRange As String, PasteRange As String)
'
' importInfo Macro
' Get csv data from downloaded bz query
'
    Windows(ScrubSheet).Activate
    ClearFilters
    'Dim dwnldDirPath As String: dwnldDirPath = "C:\Users\mwroberts\AppData\Local\Temp\"
    Dim dwnldDirPath As String: dwnldDirPath = getTempFolder
    Dim csvFullPath As String
    
    Dim ImportSht As String: ImportSht = getMDstring & ".csv"
    
   ' open csv FILE and activate the worksheet, then copy the contents in two sections
   ' into the scrub worksheet
   '
    csvFullPath = dwnldDirPath & ImportSht
    Workbooks.Open (csvFullPath)
    Windows(ImportSht).Activate
    ActiveWindow.Zoom = 42
    Range(CutRange).Select
    Selection.Copy
    
    ' switch to scrub worksheet and paste a-f
    Windows(ScrubSheet).Activate
    Range(PasteRange).Select
    ActiveSheet.Paste
    Range(PasteRange).Select
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
Function getDataSheet() As String
    getDataSheet = "VBAdata"
End Function
Function getBrowserPath() As String
    getBrowserPath = Worksheets(getDataSheet).Range("B2").Value & " "
End Function
Function getTempFolder() As String
    getTempFolder = Environ("temp") & "\"
End Function
Function getWkBkName() As String
    Set fso = CreateObject("Scripting.FileSystemObject")
    getWkBkName = fso.GetFileName(ThisWorkbook.FullName)
End Function
Sub activeCellValue()
Attribute activeCellValue.VB_Description = "prepend letter m to bugs that have had master created"
Attribute activeCellValue.VB_ProcData.VB_Invoke_Func = "m\n14"
   Dim tmpstr As String: tmpstr = ActiveCell.Value
   ActiveCell.Value = "m" & tmpstr
End Sub
 
    
    
