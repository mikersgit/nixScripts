VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThisWorkbook"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True

Option Explicit

Private Sub Workbook_BeforeClose(Cancel As Boolean)
   With Application.CommandBars("Worksheet Menu Bar")
      On Error Resume Next
      .Controls("&ScrubFuncs").Delete
      .Controls("&ViewFuncs").Delete
      On Error GoTo 0
   End With
End Sub
'
' Add In menu
'
Private Sub Workbook_Open()
   Dim objPopUp As CommandBarPopup
   Dim objBtn As CommandBarButton
   With Application.CommandBars("Worksheet Menu Bar")
      On Error Resume Next
      .Controls("ScrubFuncs").Delete
      On Error GoTo 0
      Set objPopUp = .Controls.Add( _
         Type:=msoControlPopup, _
         before:=.Controls.Count, _
         temporary:=True)
   End With
   '
   ' Filter macros
   '
   objPopUp.Caption = "&ScrubFuncs"
   Set objBtn = objPopUp.Controls.Add
   With objBtn
      .Caption = "For Review"
      .OnAction = "ForReview"
      .Style = msoButtonCaption
   End With
   Set objBtn = objPopUp.Controls.Add
   With objBtn
      .Caption = "Priority Zero"
      .OnAction = "P0bugs"
      .Style = msoButtonCaption
   End With
   Set objBtn = objPopUp.Controls.Add
   With objBtn
      .Caption = "Waivers"
      .OnAction = "Waivers"
      .Style = msoButtonCaption
   End With
   Set objBtn = objPopUp.Controls.Add
   With objBtn
      .Caption = "Targeted"
      .OnAction = "TargettedBuilds"
      .Style = msoButtonCaption
   End With
   Set objBtn = objPopUp.Controls.Add
   With objBtn
      .Caption = "Clone, no Target"
      .OnAction = "InPlay"
      .Style = msoButtonCaption
   End With
    Set objBtn = objPopUp.Controls.Add
   With objBtn
      .Caption = "Regress, forward"
      .OnAction = "regressionFilter"
      .Style = msoButtonCaption
   End With
    Set objBtn = objPopUp.Controls.Add
   With objBtn
      .Caption = "No Priority"
      .OnAction = "noPriority"
      .Style = msoButtonCaption
   End With
    Set objBtn = objPopUp.Controls.Add
   With objBtn
      .Caption = "Blocked"
      .OnAction = "blocked"
      .Style = msoButtonCaption
   End With
   Set objBtn = objPopUp.Controls.Add
   With objBtn
      .Caption = "No Disposition"
      .OnAction = "NoDisposition"
      .Style = msoButtonCaption
   End With
   '
   ' view macros
   '
   With Application.CommandBars("Worksheet Menu Bar")
      On Error Resume Next
      .Controls("ViewFuncs").Delete
      On Error GoTo 0
      Set objPopUp = .Controls.Add( _
         Type:=msoControlPopup, _
         before:=.Controls.Count, _
         temporary:=True)
   End With
   objPopUp.Caption = "&ViewFuncs"
   Set objBtn = objPopUp.Controls.Add
   With objBtn
      .Caption = "Clear Filters"
      .OnAction = "ClearFilters"
      .Style = msoButtonCaption
   End With
   Set objBtn = objPopUp.Controls.Add
   With objBtn
      .Caption = "UnHide"
      .OnAction = "UnHideColumns"
      .Style = msoButtonCaption
   End With
End Sub

