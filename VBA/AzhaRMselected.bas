Attribute VB_Name = "AzhaRMselected"
'############# KeyBoard Macros ###############
'#############################################
Sub rmSelected()
Attribute rmSelected.VB_Description = "Remove the data for the bug on the current selected row."
Attribute rmSelected.VB_ProcData.VB_Invoke_Func = "R\n14"
'
' rmSelected Macro
'
' Keyboard Shortcut: Ctrl+Shift+R
'
    'unhide column "D"
    Range("C:E").EntireColumn.Hidden = False
    'get row number of selected cell
    Dim actRow As Integer: actRow = ActiveCell.Row
    'set first range to be cleared
    Dim rng As String: rng = getRngStr("d", "i", CStr(actRow), CStr(actRow))
    Range(rng).ClearContents
    'set second range to be cleared
    rng = getRngStr("l", "ad", CStr(actRow), CStr(actRow))
    Range(rng).ClearContents
    scrollTop
End Sub
