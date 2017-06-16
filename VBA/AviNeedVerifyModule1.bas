Attribute VB_Name = "Module1"
Sub copyToTabs(ThisSht As String)
Attribute copyToTabs.VB_Description = "copy new bug data to filtered sheets"
Attribute copyToTabs.VB_ProcData.VB_Invoke_Func = " \n14"
'
' copyToTabs Macro
' copy new bug data to filtered sheets
'

' copy from csv sheet to "Latest"
' Then sort Latest by product a-z
'
'    Dim ThisSht As String
'    ThisSht = InputBox("M-D of sheet to copy from:", "Input sheet name")
'    ThisSht = "bugs-2017-" & ThisSht
    
    Sheets("Latest").Select
    ClearFilters
    pauseUpdates
    
    Sheets(ThisSht).Select
    Range("A2:AA600").Select
    Selection.Copy
    Sheets("Latest").Select
    Range("A2").Select
    ActiveSheet.Paste
    Range("B10").Select
    ActiveSheet.AutoFilter.Sort.SortFields.Clear
    ActiveSheet.AutoFilter.Sort.SortFields.Add _
        Key:=Range("C1:C600"), SortOn:=xlSortOnValues, Order:=xlAscending, _
        DataOption:=xlSortTextAsNumbers
    With ActiveSheet.AutoFilter.Sort
        .Header = xlYes
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With
    
    ' Copy data from "Latest" and filter according to tab name criteria
    '
    enableUpdates
    ClearFilters
    Sheets("!fix!wontFix").Select
    ClearFilters
    Sheets("FixedWontFix").Select
    ClearFilters
    Sheets("Latest").Select
    pauseUpdates
    
    Range("A2:AE600").Select
    Selection.Copy
    Sheets("FixedWontFix").Select
    Range("B2").Select
    ActiveSheet.Paste
    Range("B10").Select
    Sheets("!fix!wontFix").Select
    Range("B2").Select
    ActiveSheet.Paste
    Range("B10").Select
    ActiveSheet.Range("$A$1:$AB$600").AutoFilter Field:=6, Criteria1:=Array( _
        "CANTREPRODUCE", "DUPLICATE", "INVALID", "MOVED to 3Par", "MOVED to Rally"), _
        Operator:=xlFilterValues
    Sheets("FixedWontFix").Select
    ActiveSheet.Range("$A$1:$AB$600").AutoFilter Field:=6, Criteria1:="=FIXED" _
        , Operator:=xlOr, Criteria2:="=WONTFIX"
    enableUpdates
    LinkBugs getDataSheet & "!B4", "FixedWontFix", "B2:B300"
    LinkBugs getDataSheet & "!B4", "!fix!wontFix", "B2:B300"
End Sub
Sub ClearFilters()
'
' ClearFilters Macro
' Clear column filters
'
' The "If" prevents the error when clearning when no filters are set
'
' Keyboard Shortcut: Ctrl+Shift+K
'
    If ActiveSheet.FilterMode Then ActiveSheet.ShowAllData
    ' Go To cell D18 after processing
    Range("A1").Select
End Sub
Sub AVverifyBzQuery()
'
' open firefox with bz query
    '
    pauseUpdates
    Dim bzURL As String
    ' bzURL = "https://bugzilla.houston.hpecorp.net:1181/bugzilla/buglist.cgi?cmdtype=runnamed&namedcmd=AuroraAllResolved"
    ' bzURL = "https://bugzilla.houston.hpecorp.net:1181/bugzilla/buglist.cgi?bug_status=RESOLVED&chfield=bug_status&chfieldto=Now&classification=StoreAll%20Classic&classification=Avatar%20based%20FileSystem%2BData%20Services&classification=Protocols&classification=Platform&classification=External&columnlist=bug_id%2Cassigned_to%2Cproduct%2Cresolution%2Ccf_bedrock%2Ccf_foundby%2Cshort_desc%2Cbug_severity%2Ctarget_milestone%2Creporter%2Cstatus_whiteboard%2Cchangeddate%2Cbug_status%2Cversion%2Copendate%2Ccf_alsoseenby%2Ckeywords%2Ccf_probability%2Ccf_defecttype%2Ccomponent%2Cdeadline%2Ccf_redzonereviewflag%2Cpriority%2Ccf_releasenote%2Ccf_odc_opener%2Ccf_odcclosure%2Ccf_required%2Ccf_targetbuild%2Ccf_crb%2Ccf_waivers%2Ccf_cfi_number_text&query_format=advanced&target_milestone=Aurora&ctype=csv&human=1"
    bzURL = Worksheets(getDataSheet).Range("A2").Value
    '"C:\Program Files (x86)\Mozilla Firefox\firefox.exe "
    Shell (getBrowserPath & bzURL)
    Copytabfromsheet "Latest", getWkBkName
    enableUpdates
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
Sub LinkBugs(bzLnkLoc As String, shtName As String, lnkRange As String)
    Dim bugNums As Range
    Dim bug As Range
    ' BZ query screen pre-pended to bug number to create link to bug in bugzilla
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
End Sub
Sub Copytabfromsheet(TabToUse As String, wkBookToUse As String)
'
' Copytabfromsheet Macro
' copy
'
    '"C:\Users\mwroberts\AppData\Local\Temp\"
    Dim dwnldDirPath As String: dwnldDirPath = getTempFolder
    Dim fromTab As String: fromTab = getMDstring
    Dim fromSht As String: fromSht = fromTab & ".csv"
    
    Workbooks.Open (dwnldDirPath & fromSht)
    Windows(fromSht).Activate
    Sheets(fromTab).Select
    Sheets(fromTab).Move After:=Workbooks(wkBookToUse). _
        Sheets(TabToUse)
    Sheets(TabToUse).Select
    copyToTabs fromTab
End Sub
Function getMDstring() As String
    Dim Mo As String: Mo = Month(Date): If Len(Mo) = 1 Then Mo = "0" & Mo
    Dim Da As String: Da = Day(Date): If Len(Da) = 1 Then Da = "0" & Da
    Dim Yr As String: Yr = Year(Date)
    
    Dim prompt As String: prompt = _
        "Version of " & Mo & "-" & Da & _
        " CSV FILE from which to COPY [" & Chr(34) & "-1" & Chr(34) & " for example]" _
        & " CR (no input) for empty version"
        
    Dim fromTab As String
    fromTab = InputBox(prompt, "Input version of file")
    If InStr(fromTab, "-") <> 1 And Len(fromTab) > 0 Then fromTab = "-" & fromTab
    fromTab = "bugs-" & Yr & "-" & Mo & "-" & Da & fromTab
    getMDstring = fromTab
End Function
Function getDataSheet() As String
    getDataSheet = "MacroData"
End Function
Function getTempFolder() As String
    getTempFolder = Environ("temp") & "\"
End Function
Function getBrowserPath() As String
    getBrowserPath = Worksheets(getDataSheet).Range("B10").Value & " "
End Function
Function getWkBkName() As String
    Set fso = CreateObject("Scripting.FileSystemObject")
    getWkBkName = fso.GetFileName(ThisWorkbook.FullName)
End Function

