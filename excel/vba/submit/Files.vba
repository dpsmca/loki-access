Private fso As Scripting.FileSystemObject

Public Function FileExists(path As String) As Boolean
    If fso Is Nothing Then
        Set fso = CreateObject("Scripting.FileSystemObject")
    End If
    FileExists = fso.FileExists(path)
End Function
