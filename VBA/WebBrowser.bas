Attribute VB_Name = "WebBrowser"
Sub webRequest(URL As String)
    'Dim browserPath As String: browserPath = Worksheets(dataSheet).Range("b42").Value & " "
    Shell (getBrowserPath & URL)
End Sub 'end webRequest()
Public Function getDwnLoadDir() As String
    Dim currentUser As String: currentUser = Environ("Username")
    getDwnLoadDir = "c:\Users\" & currentUser & "\Downloads\"
    'getDwnLoadDir = Sheets(getDataSheet).Range("a47").Value
End Function
Function getBrowserPath() As String
    getBrowserPath = Worksheets(getDataSheet).Range("A29").Value & " "
End Function
