Attribute VB_Name = "GeneralUtilities"
'########################
'#  Utility subroutines
'########################

Sub pauseUpdates()
    ' increase performance from 1 minute, to 2 seconds by turning off screen update and auto calculation
    Application.ScreenUpdating = False
    Application.Calculation = xlManual
End Sub 'pauseUpdates()
Sub enableUpdates()
   ' Turn screen update and calculation back on
    Application.Calculation = xlAutomatic
    Application.ScreenUpdating = True
End Sub 'enableUpdates()
Sub Clear()
'
' Clear Macro
' Clear filters
'
    If ActiveSheet.FilterMode Then ActiveSheet.ShowAllData
    scrollTop
End Sub 'Clear()
Sub UnHideColumns()
'
' UnHideColumns Macro
' Unhide columns
'
    Columns("A:AH").Select: Selection.EntireColumn.Hidden = False
    Range("a2").Select
End Sub
Sub scrollTop()
'
' scroll to top
'
    ActiveWindow.ScrollRow = 2
    Range("A3").Select
End Sub 'scrollTop()
Sub multiDefaultFill(colStrs() As Variant, lastCell As Integer)
    Dim colRng As String
    Dim colStr As Variant
    For Each colStr In colStrs
        colRng = getRangeString(CStr(colStr), CStr(colStr), 2, lastCell)
        DefValueForBlank colRng
    Next colStr
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
Sub InsertCol(BeforeColLtr As String)
'
' InsertCol Macro
' Insert a column before referenced column
'
    Columns(BeforeColLtr & ":" & BeforeColLtr).Select
    Selection.Insert Shift:=xlToRight, CopyOrigin:=xlFormatFromLeftOrAbove
    Range("A1").Select
End Sub
Sub FmtNoWrap()
'
' FmtNoWrap Macro
' make sure format is no wrap
'
    Cells.Select
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
    Range("A1").Select
End Sub
Sub FreezeFirstRow()
'
' FreezeFirstRow Macro
' Freeze first row
'
'
    rows("1:1").Select
    With ActiveWindow
        .SplitColumn = 0
        .SplitRow = 1
    End With
    ActiveWindow.FreezePanes = True
    Range("a1").Select
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
Sub ClearContFormat(rng As String)
    Clear
    With Range(rng)
        .ClearContents
        .ClearFormats
    End With
End Sub
Sub hideColumnRng(rng As String)
    Columns(rng).Select: Selection.EntireColumn.Hidden = True
End Sub
Sub hideColumnName(colName As String)
    Dim cn As String: cn = getColLtr(getColNu(colName))
    hideColumnRng (getRngStr(cn, cn))
End Sub
Sub copyFilterRange()
    Dim rows As Integer: rows = ActiveSheet.AutoFilter.Range.Columns(1).SpecialCells(xlCellTypeVisible).Cells.Count
    Range("a1:o100").Cells.SpecialCells(xlCellTypeVisible).Copy
End Sub
''''''''''''''''''''''''''''''''''''''''''''
' common routine to filter a colomn by color
''''''''''''''''''''''''''''''''''''''''''''
Sub FilterOnColor(fltrRng As String, R As Integer, G As Integer, B As Integer, fltrField As Integer)
    ClearFilters
    ActiveSheet.Range(fltrRng).AutoFilter Field:=fltrField, Criteria1:=RGB(R, G, B), Operator:=xlFilterCellColor
End Sub
Sub Resizecol(begCol As String, endCol As String)
'
' Resizecol Macro
' Resize all columns
'
    Dim rangeStr As String: rangeStr = begCol & ":" & endCol
    Columns(rangeStr).Select
    Columns(rangeStr).EntireColumn.AutoFit
    Application.Goto Reference:="R1C2"
End Sub
Sub AddColFilter(begCol As String, endCol As String)
'
' AddColFilter Macro
' Add filtering to all columns
'
   If ActiveSheet.AutoFilterMode = False Then
        Dim rangeStr As String: rangeStr = begCol & ":" & endCol
        Columns(rangeStr).Select
        Selection.AutoFilter
    End If
    Application.Goto Reference:="R1C2"
End Sub

'#########
'# FUNCTIONS
'#########
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
Function getWkBkName() As String
    Set fso = CreateObject("Scripting.FileSystemObject")
    getWkBkName = fso.GetFileName(ThisWorkbook.FullName)
End Function
Function getTempFolder() As String
    getTempFolder = Environ("temp") & "\"
End Function
Function getYMDstr() As String
    Mo = Month(Date): If Len(Mo) = 1 Then Mo = "0" & Mo
    DA = Day(Date): If Len(DA) = 1 Then DA = "0" & DA
    Yr = Year(Date)
    YMDstr = Yr & "-" & Mo & "-" & DA
    getYMDstr = YMDstr
End Function 'getYMDstr()
Function getRangeString(begCol As String, endCol As String, Optional BegRow As Integer, Optional EndRow As Integer) As String
    If BegRow <= 0 Or EndRow <= 0 Then
        getRangeString = begCol & ":" & endCol
    Else
        getRangeString = begCol & BegRow & ":" & endCol & EndRow
    End If
End Function
'Given:
'   1. Letter of column in spreadsheet
'Do:
'   1. return integer row number of last filled cell
Function lastFilledCell(colStr As String) As Integer
    Dim c As Integer: c = 0
    Dim strtRow As Integer: strtRow = 2
    Dim strlen As Integer
    Dim Fields As Range
    Dim Field As Range
    Dim ThisSht As String: ThisSht = ActiveSheet.Name
    
    pauseUpdates
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
    enableUpdates
End Function 'lastFilledCell()
Function getDataSheet() As String
    getDataSheet = "Data"
End Function
Function getMaxRow() As Integer
    getMaxRow = Sheets(getDataSheet).Range("a22").Value
End Function
Function getWorkbookName() As String
    getWorkbookName = Sheets(getDataSheet).Range("a13").Value
End Function

