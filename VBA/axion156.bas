Attribute VB_Name = "axion156"
'Runs all of the queries, and then imports all of the resultant CSV files
'prompts for each download, and pops-up a dialog when all imports are completed
Sub AllBugDataRefresh()
    Dim BeginInfoMsg As String
    Dim answer As Integer
    
    BeginInfoMsg = "Verify browser is logged into both bugzilla instances." & vbCr & vbCr & _
    "4 queries will be run," & vbCr & vbTab & "FP guest included in 1.5.6" & vbCr & vbTab & "FP guest nominated" & vbCr & vbTab & "3PAR included" & vbCr & _
    vbTab & "3PAR nominated" & vbCr & _
    "Make sure to use 'Save File' for each browser prompt." & vbCr & "After Downloads, select the spreadsheet to confirm." & vbCr & _
    "After download confirmation, all files will be imported, and a completion message will be displayed."
    
    MsgBox BeginInfoMsg, vbInformation, "Begin"
    
    FPincludeQuery
    DelayInSeconds 3
    'MsgBox "FP include downloaded?", vbOKOnly, "FP Include download confirmation"
    FPnominateQuery
    DelayInSeconds 3
    'MsgBox "FP nominated downloaded?", vbOKOnly, "FP nominated download confirmation"
    ThreePARincludeQuery
    DelayInSeconds 3
    'MsgBox "3par include downloaded?", vbOKOnly, "3par include download confirmation"
    ThreePARnominateQuery
    DelayInSeconds 3
    'MsgBox "3par nominate downloaded?", vbOKOnly, "3par nominate download confirmation"
    answer = MsgBox("All 4 downloads complete?", vbYesNo, "Download confirmation")
    
    If answer = vbNo Then
        Debug.Print answer
        MsgBox "Import Aborted", vbExclamation, "Aborted"
        Exit Sub
    End If

    ' imports
    ImportFPincludeBugs
    ImportFPnominateBugs
    Import3PARincludeBugs
    Import3PARnominateBugs
    MsgBox "Import completed", vbInformation, "Completion"
End Sub
'#############
'# Inclusion and nominate bug query calls
'#############
Sub FPincludeQuery()
    webRequest getFPinclusionQuery
End Sub 'end FPincludeQuery()
Sub FPnominateQuery()
    webRequest getFPnominateQuery
End Sub 'end FPnominateQuery()
Sub ThreePARincludeQuery()
    webRequest get3PARinclusionQuery
End Sub 'end ThreePARincludeQuery()
Sub ThreePARnominateQuery()
    webRequest get3PARnominateQuery
End Sub 'end ThreePARnominateQuery()
'##### End of specific calls to queries

' ############
' # Import include and nominate query results
' # 1. File Persona included bugs
' # 2. File Persona nominated bugs
' # 3. 3PAR inclustion bugs
' ############
Sub ImportFPincludeBugs()
    Dim lastCell As Integer
    Dim colStrs() As Variant: colStrs = Array("H", "K", "R", "T")
    
    ImportBZquery getFPinclBugFilename, getFPinclusionTab
    lastCell = lastFilledCell("A")
    
    ' iterate over columns that may have blank cells and put a '.'. this helps preserve formating when copy/paste into email messages
    ' otherwise outlook tends to merge blank cells with adjacent cells and get garbled
    'multiDefaultFill buildVariantArray("A33"), lastCell
    multiDefaultFill colStrs(), lastCell
    
    LinkBugs lastCell, "A", getBzURL
    LinkBugs lastCell, "B", getBzURL
    LinkBugs lastCell, "K", getCfiURL
    
    'insert a blank column for notes
    InsertCol "A"
    'Autosize b->t columns for width, then add filters to those columns
    Resizecol "B", "T"
    AddColFilter "B", "T"
    FreezeFirstRow
'    LinkIds getBzURL, getFPinclusionTab, getRangeString("A", "A", 2, lastCell)
'    LinkIds getBzURL, getFPinclusionTab, getRangeString("B", "B", 2, lastCell)

' put 'summary xx' in summary column
Range("k1").Value = "=CONCATENATE(" & Chr(34) & "Summary " & Chr(34) & ", SUBTOTAL(3,B2:B80))"
    
End Sub 'ImportFPincludeBugs()
Sub ImportFPnominateBugs()
    Dim lastCell As Integer
    Dim colStrs() As Variant: colStrs = Array("E", "F", "C", "T")
    
    ImportBZquery getFPnomBugFilename, getFPnomTab
    lastCell = lastFilledCell("A")
    
    'multiDefaultFill buildVariantArray("A34"), lastCell
    multiDefaultFill colStrs(), lastCell
    
    LinkBugs lastCell, "A", getBzURL
    LinkBugs lastCell, "C", getCfiURL
    InsertCol "A"
    'Autosize b->t columns for width, then add filters to those columns
    Resizecol "B", "T"
    AddColFilter "B", "T"
    FreezeFirstRow
End Sub 'ImportFPincludeBugs()
Sub Import3PARincludeBugs()
    Dim lastCell As Integer
    Dim colStrs() As Variant: colStrs = Array("C", "E", "F", "G", "S")
    
    ImportBZquery get3PARinclusionBugFilename, get3PARinclusionTab
    ' format the 3par import as "no text wrap" because executive summary often is multi-line
    FmtNoWrap
    lastCell = lastFilledCell("A")
    
    ' list of cells to default fill, BEFORE insertion of column "A", in in cell A32 on Data sheet
    'multiDefaultFill buildVariantArray("A32"), lastCell
    multiDefaultFill colStrs(), lastCell

    
    LinkBugs lastCell, "A", get3PARBzURL
    LinkBugs lastCell, "C", getCfiURL
    InsertCol "A"
    'Autosize b->t columns for width, then add filters to those columns
    Resizecol "B", "T"
    AddColFilter "B", "T"
    FreezeFirstRow
    ' put 'summary xx' in summary column
    Range("m1").Value = "=CONCATENATE(" & Chr(34) & "Summary " & Chr(34) & ", SUBTOTAL(3,B2:B80))"
End Sub 'Import3PARincludeBugs()
Sub Import3PARnominateBugs()
    Dim lastCell As Integer
    Dim colStrs() As Variant: colStrs = Array("c", "d", "e", "f", "g", "s")
    
    ImportBZquery get3PARnominateBugFilename, get3PARnominateTab
    ' format the 3par import as "no text wrap" because executive summary often is multi-line
    FmtNoWrap
    lastCell = lastFilledCell("A")
    
    ' list of cells to default fill, BEFORE insertion of column "A", in in cell A32 on Data sheet
    'multiDefaultFill buildVariantArray("A32"), lastCell
    multiDefaultFill colStrs(), lastCell

    
    LinkBugs lastCell, "A", get3PARBzURL
    LinkBugs lastCell, "C", getCfiURL
    InsertCol "A"
    'Autosize b->t columns for width, then add filters to those columns
    Resizecol "B", "T"
    AddColFilter "B", "T"
    FreezeFirstRow
    ' put 'summary xx' in summary column
    Range("M1").Value = "=CONCATENATE(" & Chr(34) & "Summary " & Chr(34) & ", SUBTOTAL(3,B2:B80))"
End Sub 'Import3PARnominateBugs()
' ######## end of specific Import call
'

' ############################
' # File Persona INCLUDE functions:
' #    1. query url
' #    2. download csv file name
' #    3. spreadsheet tab into which to import
' ############################
Function getFPinclusionQuery() As String
    getFPinclusionQuery = Worksheets(getDataSheet).Range("B1").Value & " "
End Function
Function getFPinclBugFilename() As String
    getFPinclBugFilename = Sheets(getDataSheet).Range("a10").Value
End Function
Function getFPinclusionTab() As String
    getFPinclusionTab = Sheets(getDataSheet).Range("a16").Value
End Function
' ############################
' # File Persona NOMINATE functions: query url, download csv file name, spreadsheet tab into which to import
' ############################
Function getFPnominateQuery() As String
    getFPnominateQuery = Worksheets(getDataSheet).Range("B2").Value & " "
End Function
Function getFPnomBugFilename() As String
    getFPnomBugFilename = Sheets(getDataSheet).Range("a9").Value
End Function
Function getFPnomTab() As String
    getFPnomTab = Sheets(getDataSheet).Range("a8").Value
End Function
' ############################
' # 3PAR INCLUDE functions: query url, download csv file name, spreadsheet tab into which to import
' ############################
Function get3PARinclusionQuery() As String
    get3PARinclusionQuery = Worksheets(getDataSheet).Range("B3").Value & " "
End Function
Function get3PARinclusionBugFilename() As String
    get3PARinclusionBugFilename = Sheets(getDataSheet).Range("a11").Value
End Function
Function get3PARinclusionTab() As String
    get3PARinclusionTab = Sheets(getDataSheet).Range("a17").Value
End Function
' ############################
' # 3PAR NOMINATE functions: query url, download csv file name, spreadsheet tab into which to import
' ############################
Function get3PARnominateQuery() As String
    get3PARnominateQuery = Worksheets(getDataSheet).Range("B4").Value & " "
End Function
Function get3PARnominateBugFilename() As String
    get3PARnominateBugFilename = Sheets(getDataSheet).Range("A4").Value
End Function
Function get3PARnominateTab() As String
    get3PARnominateTab = Sheets(getDataSheet).Range("A7").Value
End Function
' # end of bug query, filename, tabname GET functions
'

' return string array from comma separated list in a cell
Function buildVariantArray(loc As String) As Variant
    Dim v As Variant: v = Split(Sheets(getDataSheet).Range(loc).Value, ",")
    
    buildVariantArray = v
    
End Function

'####################
'# General use GET functions
'####################










