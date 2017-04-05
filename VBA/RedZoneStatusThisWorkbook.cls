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

'
' Set up to remove menu items when sheet closed
'
Private Sub Workbook_BeforeClose(Cancel As Boolean)
   With Application.CommandBars("Worksheet Menu Bar")
      On Error Resume Next
      .Controls("&RZfilter").Delete
      .Controls("&RZViewFuncs").Delete
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
      .Controls("RZfilter").Delete
      On Error GoTo 0
      Set objPopUp = .Controls.Add( _
         Type:=msoControlPopup, _
         before:=.Controls.Count, _
         temporary:=True)
   End With
   '
   ' Filter macros
   '
   objPopUp.Caption = "&RZfilter"
   Set objBtn = objPopUp.Controls.Add
   With objBtn
      .Caption = "Newest"
      .OnAction = "Newest"
      .Style = msoButtonCaption
   End With
   Set objBtn = objPopUp.Controls.Add
   With objBtn
      .Caption = "Targeted"
      .OnAction = "Targeted"
      .Style = msoButtonCaption
   End With
   Set objBtn = objPopUp.Controls.Add
   With objBtn
      .Caption = "NoTarget"
      .OnAction = "UntargRZ"
      .Style = msoButtonCaption
   End With
   '
   ' view macros
   '
   With Application.CommandBars("Worksheet Menu Bar")
      On Error Resume Next
      .Controls("RZViewFuncs").Delete
      On Error GoTo 0
      Set objPopUp = .Controls.Add( _
         Type:=msoControlPopup, _
         before:=.Controls.Count, _
         temporary:=True)
   End With
   objPopUp.Caption = "&RZViewFuncs"
   Set objBtn = objPopUp.Controls.Add
   With objBtn
      .Caption = "Clear Filters"
      .OnAction = "ClearFilters"
      .Style = msoButtonCaption
   End With
   Set objBtn = objPopUp.Controls.Add
   With objBtn
      .Caption = "Aurora BZ Query"
      .OnAction = "rzbzquery"
      .Style = msoButtonCaption
   End With
   Set objBtn = objPopUp.Controls.Add
   With objBtn
      .Caption = "Avitus BZ Query"
      .OnAction = "AVrzbzquery"
      .Style = msoButtonCaption
   End With
   Set objBtn = objPopUp.Controls.Add
   With objBtn
      .Caption = "Import csv"
      .OnAction = "rzimportInfo"
      .Style = msoButtonCaption
   End With
End Sub


