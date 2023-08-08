Private Const CP_UTF8 = 65001
Private Declare Function WideCharToMultiByte Lib "Kernel32" ( _
    ByVal CodePage As Long, ByVal dwflags As Long, _
    ByVal lpWideCharStr As Long, ByVal cchWideChar As Long, _
    ByVal lpMultiByteStr As Long, ByVal cchMultiByte As Long, _
    ByVal lpDefaultChar As Long, ByVal lpUsedDefaultChar As Long) As Long
 
Public LastError As String
 
Public Function Post(url As String, data As String) As DOMDocument
    LastError = ""
    Dim objXML As New MSXML2.XMLHTTP
    Set objXML = CreateObject("msxml2.xmlhttp")
    With objXML
        .Open "POST", baseUrl & url, False
        .setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
        .send data
        If .Status = 200 Then
            Set Post = .responseXML
        Else
            LastError = .statusText
        End If
    End With
End Function

Public Function GetXML(url As String) As DOMDocument
    Dim objXML As New MSXML2.XMLHTTP
    Set objXML = CreateObject("msxml2.xmlhttp")
    objXML.Open "GET", baseUrl & url & "?rnd=" & Int(1000000000 * Rnd), False
    objXML.send
    Set GetXML = objXML.responseXML
End Function

Public Function UTF16To8(ByVal UTF16 As String) As String
Dim sBuffer As String
Dim lLength As Long
If UTF16 <> "" Then
    lLength = WideCharToMultiByte(CP_UTF8, 0, StrPtr(UTF16), -1, 0, 0, 0, 0)
    sBuffer = Space$(lLength)
    lLength = WideCharToMultiByte(CP_UTF8, 0, StrPtr(UTF16), -1, StrPtr(sBuffer), Len(sBuffer), 0, 0)
    sBuffer = StrConv(sBuffer, vbUnicode)
    UTF16To8 = Left$(sBuffer, lLength - 1)
Else
    UTF16To8 = ""
End If
End Function

Public Function UrlEncode( _
   StringVal As String, _
   Optional SpaceAsPlus As Boolean = False, _
   Optional UTF8Encode As Boolean = True _
) As String

Dim StringValCopy As String: StringValCopy = IIf(UTF8Encode, UTF16To8(StringVal), StringVal)
Dim StringLen As Long: StringLen = Len(StringValCopy)

If StringLen > 0 Then
    ReDim result(StringLen) As String
    Dim i As Long, CharCode As Integer
    Dim Char As String, Space As String

  If SpaceAsPlus Then Space = "+" Else Space = "%20"

  For i = 1 To StringLen
    Char = Mid$(StringValCopy, i, 1)
    CharCode = Asc(Char)
    Select Case CharCode
      Case 97 To 122, 65 To 90, 48 To 57, 45, 46, 95, 126
        result(i) = Char
      Case 32
        result(i) = Space
      Case 0 To 15
        result(i) = "%0" & Hex(CharCode)
      Case Else
        result(i) = "%" & Hex(CharCode)
    End Select
  Next i
  UrlEncode = Join(result, "")

End If
End Function



