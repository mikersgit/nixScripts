Attribute VB_Name = "WordMailMergePDF"
Sub GetXcel()
Attribute GetXcel.VB_Description = "select area and embed"
Attribute GetXcel.VB_ProcData.VB_Invoke_Func = "Project.NewMacros.GetXcel"
'
' GetXcel Macro
' select area and link
'
    Selection.PasteSpecial Link:=True, DataType:=wdPasteOLEObject, Placement _
        :=wdInLine, DisplayAsIcon:=False
End Sub
Sub ExportPDF()
'
' ExportPDF Macro
'
'
Dim dpath As String: dpath = "C:\Users\Michael\Documents\"
Dim pdfFile As String
Dim fullPath As String
pdfFile = InputBox("File name to save")
fullPath = dpath & pdfFile
    ActiveDocument.ExportAsFixedFormat OutputFileName:= _
        fullPath, ExportFormat:= _
        wdExportFormatPDF, OpenAfterExport:=True, OptimizeFor:= _
        wdExportOptimizeForPrint, Range:=wdExportAllDocument, From:=1, To:=1, _
        Item:=wdExportDocumentContent, IncludeDocProps:=True, KeepIRM:=True, _
        CreateBookmarks:=wdExportCreateNoBookmarks, DocStructureTags:=True, _
        BitmapMissingFonts:=True, UseISO19005_1:=False
End Sub
