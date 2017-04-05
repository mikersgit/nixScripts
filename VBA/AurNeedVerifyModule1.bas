Attribute VB_Name = "Module1"
Sub copyToTabs()
Attribute copyToTabs.VB_Description = "copy new bug data to filtered sheets"
Attribute copyToTabs.VB_ProcData.VB_Invoke_Func = "t\n14"
'
' copyToTabs Macro
' copy new bug data to filtered sheets
'
    Dim BugSht As String
    BugSht = InputBox("M-D of bug sheet:", "Input sheet name")
    BugSht = "bugs-2017-" & BugSht
    
    pauseUpdates
    
    ' copy data from bug csv to "Latest"
    '
    Sheets(BugSht).Select
    Range("A2:AE500").Select
    Selection.Copy
    Sheets("Latest").Select
    Range("A2").Select
    ActiveSheet.Paste
    ' sort the product column alphabetically
    ActiveSheet.AutoFilter.Sort.SortFields.Clear
    ActiveSheet.AutoFilter.Sort.SortFields.Add _
        Key:=Range("c1:c500"), SortOn:=xlSortOnValues, Order:=xlAscending, _
        DataOption:=xlSortTextAsNumbers
    With ActiveSheet.AutoFilter.Sort
        .Header = xlYes
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With
    
    enableUpdates
    ClearFilters
    pauseUpdates
    
    Sheets("!fix!wontFix").Select
    
    enableUpdates
    ClearFilters
    pauseUpdates
    
    Sheets("Latest").Select
    Range("A2:AE500").Select
    Selection.Copy
    Sheets("FixedWontFix").Select
    Range("B2").Select
    ActiveSheet.Paste
    Range("B10").Select
    Sheets("!fix!wontFix").Select
    Range("B2").Select
    ActiveSheet.Paste
    ActiveSheet.Range("$A$1:$AF$448").AutoFilter Field:=5, Criteria1:=Array( _
        "CANTREPRODUCE", "DUPLICATE", "INVALID", "MOVED to 3Par", "MOVED to Rally"), _
        Operator:=xlFilterValues
    Sheets("FixedWontFix").Select
    ActiveSheet.Range("$A$1:$AF$448").AutoFilter Field:=5, Criteria1:="=FIXED" _
        , Operator:=xlOr, Criteria2:="=WONTFIX"
    
    enableUpdates
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
Sub verifyBzQuery()
'
' open firefox with bz query
    '
    Dim bzURL As String
    ' bzURL = "https://bugzilla.houston.hpecorp.net:1181/bugzilla/buglist.cgi?cmdtype=runnamed&namedcmd=AuroraAllResolved"
    ' bzURL = "https://bugzilla.houston.hpecorp.net:1181/bugzilla/buglist.cgi?bug_status=RESOLVED&chfield=bug_status&chfieldto=Now&classification=StoreAll%20Classic&classification=Avatar%20based%20FileSystem%2BData%20Services&classification=Protocols&classification=Platform&classification=External&columnlist=bug_id%2Cassigned_to%2Cproduct%2Cresolution%2Ccf_bedrock%2Ccf_foundby%2Cshort_desc%2Cbug_severity%2Ctarget_milestone%2Creporter%2Cstatus_whiteboard%2Cchangeddate%2Cbug_status%2Cversion%2Copendate%2Ccf_alsoseenby%2Ckeywords%2Ccf_probability%2Ccf_defecttype%2Ccomponent%2Cdeadline%2Ccf_redzonereviewflag%2Cpriority%2Ccf_releasenote%2Ccf_odc_opener%2Ccf_odcclosure%2Ccf_required%2Ccf_targetbuild%2Ccf_crb%2Ccf_waivers%2Ccf_cfi_number_text&query_format=advanced&target_milestone=Aurora&ctype=csv&human=1"
    bzURL = Worksheets("MacroData").Range("A2").Value
    Dim browserPath As String
    browserPath = "C:\Program Files (x86)\Mozilla Firefox\firefox.exe "
    Shell (browserPath & bzURL)
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
