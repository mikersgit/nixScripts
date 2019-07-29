Attribute VB_Name = "Chart"
Sub SaveChartAsPNG(ChartName As String, SaveName As String)
    Dim fname As String
    ActiveSheet.ChartObjects(ChartName).Activate
    If ActiveChart Is Nothing Then Exit Sub
    'Dim SaveName As String: SaveName = InputBox("Save chart as name: ", "Chart name")
    fname = ThisWorkbook.Path & "\" & SaveName & ".png"
    ActiveChart.Export Filename:=fname, FilterName:="PNG"
End Sub
Sub SaveAllCharts()
    Dim StackChart As String: StackChart = "Chart 3"
    Dim StackChartFile As String: StackChartFile = "FPstackChart"
    Dim TrendChart As String: TrendChart = "Chart 5"
    Dim TrendChartFile As String: TrendChartFile = "FPtrendChart"
    Dim InformFBOChart As String: InformFBOChart = "Chart 4"
    Dim InformFBOChartFile As String: InformFBOChartFile = "InformFBOchart"
    
    SaveChartAsPNG StackChart, StackChartFile
    SaveChartAsPNG TrendChart, TrendChartFile
    SaveChartAsPNG InformFBOChart, InformFBOChartFile
    MsgBox "Charts: " & vbCr & StackChartFile & vbCr & TrendChartFile & vbCr & InformFBOChartFile & vbCr & "Saved in: " & ThisWorkbook.Path, vbInformation, "Saved charts"
    Range("a67").Select
    
End Sub
Sub editTrendChart()
'
' editTrendChart
'
'
    Dim FixLine As Integer: FixLine = 4
    Dim IncomLine As Integer: IncomLine = 5
    Dim TrendChart As String: TrendChart = "Chart 5"
    Dim CurCol As String: CurCol = Sheets("Chart").Range("L159").Value

    MsgBox "IN PROGRESS: Extending Fixed & Incoming data selection to column: " & CurCol, vbInformation, "Extending trend chart"

    ActiveSheet.ChartObjects(TrendChart).Activate
    ' update "incoming" series
    ActiveChart.SeriesCollection(IncomLine).Values = Range("$C$183:$" & CurCol & "$183")
    ' update "Fixes" series
    ActiveChart.SeriesCollection(FixLine).Values = Range("$C$182:$" & CurCol & "$182")
    
End Sub 'editTrendChart
Sub AddToChartData()
'
' AddToChartData Macro
' Extend the File Persona charted data
'
    Dim chartStart As String: chartStart = Range("K79").Value
    Dim chartEnd As String: chartEnd = Range("L79").Value
    Dim chartRange As String: chartRange = chartStart & ":" & chartEnd
    
    ActiveSheet.ChartObjects("Chart 3").Activate
    ActiveChart.PlotArea.Select
    ActiveChart.SetSourceData Source:=Range(chartRange)
    Range("I80").Select
End Sub 'end AddToChartData()
Sub AddToKeywordChart()
    Dim chartRange As String: chartRange = "B170:" & Range("K81").Value & "174"
    
    ActiveSheet.ChartObjects("Chart 1").Activate
    ActiveChart.PlotArea.Select
    ActiveChart.SetSourceData Source:=Range(chartRange)
    Range("M153").Select
End Sub 'AddToKeywordChart
Sub FBOChartData()
'
' FBOChartData Macro
' Extend data for chart
'
    Dim chartStart As String: chartStart = Range("K75").Value
    Dim chartEnd As String: chartEnd = Range("L75").Value
    Dim chartRange As String: chartRange = chartStart & ":" & chartEnd
    
    ActiveSheet.ChartObjects("Chart 4").Activate
    ActiveChart.PlotArea.Select
    ActiveChart.SetSourceData Source:=Range(chartRange)
    Range("H130").Select
End Sub
