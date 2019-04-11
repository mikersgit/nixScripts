Attribute VB_Name = "GeneralSQL"
Sub CommonSQLQuery(targetTab As String, queryName As String)
    Dim TableName As String
    
    pauseUpdates
    Sheets(targetTab).Select
    TableName = ActiveSheet.ListObjects(1).Name

    'ClearTable TableName
    ActiveWorkbook.Connections(queryName).Refresh
    enableUpdates
End Sub
Sub ClearTable(TableName As String)
'
' ClearTable Macro
' Clear but do not delete
'
' Keyboard Shortcut: Ctrl+Shift+T
'
    Range(getRngStr("A", "P", 2, 200)).Select
    Selection.ClearContents
    'Range("Table_ExternalData_1[[#Headers],[BugId]]").Select
    'Range(TableName & "[[#Headers],[BugId]]").Select
End Sub 'end ClearTable
Function getTablRows() As Integer
    'get num rows in table
    Dim tbl As ListObject
    Set tbl = ActiveSheet.ListObjects(1)
    getTablRows = tbl.ListRows.Count + 1
End Function
