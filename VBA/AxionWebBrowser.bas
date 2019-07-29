Attribute VB_Name = "AxionWebBrowser"
'#######################
'# WebBrowser utilities
'#######################
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
    Dim BrowserCell As String: BrowserCell = "A29"
    Dim dataSht As String: dataSht = getDataSheet
    getBrowserPath = Worksheets(dataSht).Range(BrowserCell).Value & " "
    If FileExists(getBrowserPath) = False Then
        MsgBox "Could not find:" & vbCr & getBrowserPath & vbCr & "Update default browser path on the 'data' tab in this spreadsheet: " & dataSht & "!" & BrowserCell _
        & vbCr & vbCr & "Attempting to find a browser to use.", vbInformation, "Browser not found"
        getBrowserPath = findBrowser
        MsgBox "Found & now using browser: " & vbCr & getBrowserPath
    End If
End Function
Function findBrowser() As String
    Dim bpth As String
    ' common paths for browsers
    Dim ffox As String: ffox = "C:\Program Files\Mozilla Firefox\firefox.exe"
    Dim chrome As String: chrome = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    Dim ie As String: ie = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
    '
    ' Hopefully we find one
    '
    If FileExists(ffox) = True Then
        bpth = ffox
    ElseIf FileExists(chrome) = True Then
        bpth = chrome
    ElseIf FileExists(ie) = True Then
        bpth = ie
    Else
        ' Bad news, cannot find a browser
        MsgBox "NO BROWSER FOUND", vbExclamation, "NO BROWSER"
        bpth = "No Browser"
    End If
    Debug.Print bpth
    findBrowser = bpth
End Function
Function FileExists(fullFileName As String) As Boolean
  If fullFileName = "" Then
    FileExists = False
  Else
    FileExists = VBA.Len(VBA.Dir(fullFileName)) > 0
  End If
End Function
