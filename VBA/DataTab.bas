Attribute VB_Name = "DataTab"
'
' Setup common values in a data tab to drive "getValue..." functions in GeneralBugzilla and GeneralUtilities VBA collections
'
Sub CreateDataTab(shtName As String)

    Dim crow As Integer: crow = 1
    Dim colOneValue As String
    Dim colTwoValue As String
    
    '
    ' bugzilla common URL strings
    '
    Dim FPbzURL As String: FPbzURL = "https://bugzilla.houston.hpecorp.net:1181/bugzilla"
    Dim ThreePARbzURL As String: ThreePARbzURL = "https://bugs.storage.hpecorp.net"
    
    '
    ' bugzilla common REST command strings
    '
    Dim showBug As String: showBug = "/show_bug.cgi?id="
    Dim csvCmd As String: csvCmd = "&ctype=csv&human=1"
    Dim bgLstCmd As String: bgLstCmd = "/buglist.cgi?cmdtype="
    
    ' create new tab
    ' make that the active tab
    Sheets.Add.Name = shtName
    Sheets(shtName).Select
    
'
' ========== Template ===========
'    colOneValue = "":     colTwoValue = ""
'    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
' ==========

    pauseUpdates
    
    'Bugzilla query
    colOneValue = "FP Included"
    colTwoValue = FPbzURL & bgLstCmd & "dorem&list_id=2100035&namedcmd=FP%201.5.6%20Inclusion&remaction=run&sharer_id=1442" & csvCmd
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    'Bugzilla query
    colOneValue = "3PAR included"
    colTwoValue = ThreePARbzURL & bgLstCmd & "runnamed&list_id=8114909&namedcmd=Axion156-Inclusion" & csvCmd
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1

    ' Separate bz querries from other values with some space by incrementing the row
    crow = crow + 5
       
    'tab name into which to import bug info from CSV
    colOneValue = "FP-CurNominate":    colTwoValue = "<== FP nominate bug import tab"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    'base name of CSV to import
    colOneValue = "FP_1.5.6_Maint_Nom":    colTwoValue = "<== FP nominate bug file name from bugzilla"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    'base name of CSV to import
    colOneValue = "FP_1.5.6_Inclusion":    colTwoValue = "<== FP include bug file name from bugzilla"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
        
    'base name of CSV to import
    colOneValue = "Axion156-Inclusion":    colTwoValue = "<== 3PAR bug file name from bugzilla"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    'Download directory path
    colOneValue = "c:\Users\mwroberts\Downloads":    colTwoValue = "<== Download directory used by browser"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    'Workbook name
    colOneValue = ThisWorkbook.Name:    colTwoValue = "<== This Workbook's name"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    'Link to individual bug record in bugzilla
    colOneValue = FPbzURL & showBug:    colTwoValue = "<== FP bugzilla URL prefix for bug link"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
     '????????? should this be a formula ?????????????
    colOneValue = "A1:W5000":    colTwoValue = "<== bug sheet selection range =CONCATENATE(A19," & Chr(34) & "1:" & Chr(34) & ",A24,A22)"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
       
    'tab name into which to import bug info from CSV
    colOneValue = "FP-CurInclude":    colTwoValue = "<== FP include bug import tab name"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
       
    'tab name into which to import bug info from CSV
    colOneValue = "3PARCurInclude":    colTwoValue = "<== 3PAR bug import tab name"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    'Link to individual CFI record in CFIdb
    colOneValue = "http://vasa0097.cxo.storage.hpecorp.net/Cfi/CFIIssues/Details?CFINumber=":    colTwoValue = "<== CFI link"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    colOneValue = "A":    colTwoValue = "<== Bug column on bug import tab"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    colOneValue = "K":    colTwoValue = "<== CFI column on bug import tab"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1

    colOneValue = "S":    colTwoValue = "<== Owner column on bug import tab"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    colOneValue = "5000":    colTwoValue = "<== Max Row"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    colOneValue = "P":    colTwoValue = "<== Target Build Column"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    colOneValue = "W":    colTwoValue = "<== Max Column"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    'Link to individual bug record in bugzilla
    colOneValue = ThreePARbzURL & showBug:    colTwoValue = "<== 3PAR bugzilla URL prefix for bug link"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    colOneValue = "U":    colTwoValue = "<== 3PAR bug sheet CFI column"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    'tab name into which to import bug info from CSV
    colOneValue = "3PARbugs":    colTwoValue = "<== 3PAR bug import tab name"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    'base name of CSV to import
    colOneValue = "FP_RZ_Active":    colTwoValue = "<== 3PAR bug file name from bugzilla"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    ' Browser path
    colOneValue = "C:\Program Files\Mozilla Firefox\firefox.exe":    colTwoValue = "<<=== this is used to know which browser to open"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    ' Columns to link to webaddresses
    colOneValue = "A,B,M": colTwoValue = "<== columns to link to websites"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    ' Columns to fill blanks with default value
    colOneValue = "C,D,L": colTwoValue = "<== columns with empty values to fill with default"
    writeDataTab colOneValue, colTwoValue, crow:    crow = crow + 1
    
    ' size columns to fit content
    Resizecol "A", "B"
    
    'protect data sheet
    writePassWd "E1", "bzq"
    
    enableUpdates
End Sub 'CreateDataTab
'
' Given two values, write them on the same row in adjacent columns
'
Sub writeDataTab(val1 As String, val2 As String, crow As Integer)
    Dim ccol As Integer: ccol = 1
    Cells(crow, ccol).Value = val1
    Cells(crow, ccol + 1).Value = val2
End Sub 'writeDataTab

Sub writePassWd(passWdCell As String, passwd As String)
'
' writePassWd Macro
' Write password used to protect tab
' Raise message dialog to instruct how to use the protection
'

    Range(passWdCell).Select
    ActiveCell.FormulaR1C1 = "pass=" & passwd
    With Selection.Interior
        .Pattern = xlSolid
        .PatternColorIndex = xlAutomatic
        .Color = 65535
        .TintAndShade = 0
        .PatternTintAndShade = 0
    End With
    
    ActiveSheet.Protect DrawingObjects:=True, Contents:=True, Scenarios:=True
    
    MsgBox ActiveSheet.Name & " is protected with a NULL password." & vbCr & "Right click the tab," & _
        vbCr & "unprotect," & vbCr & "and then re-protect with the value in " & passWdCell & ".", _
        vbInformation, "Tab protection information"

End Sub

