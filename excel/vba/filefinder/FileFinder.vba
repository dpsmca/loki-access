Option Explicit

Sub FindFolders()
    Dim atlasDisk As String
    atlasDisk = "\\mfad\rchapp\odin\prod"

    Dim lookInto() As Variant
    'lookInto = Array("Clinical\Amyloid", "Clinical\Amyliod_LTQ\Archive", "ResearchandDevelopment\")
    lookInto = Array("Clinical\Amyloid\2015", "Clinical\Amyloid\2016", "Clinical\Amyloid\Archive", "ResearchandDevelopment\PID", "ResearchandDevelopment\Projects", "\ResearchandDevelopment\Projects\", "\ResearchandDevelopment\QE_Clinical_Support")
    'lookInto = Array("ResearchandDevelopment\PID")

    ' List all the folders we are to deal with
    Dim existingFolders As New Collection
    Dim folder As Variant
    Dim Path As Variant
    For Each Path In lookInto
        folder = Dir(atlasDisk & "\" & Path & "\", vbDirectory)
        While folder <> ""
            If Left(folder, 1) <> "." Then
                existingFolders.Add (Path & "\" & basename(folder))
            End If
            folder = Dir
        Wend
    Next Path
          
    Dim s As Worksheet
    Set s = ActiveSheet
    
    Dim row As Integer
    row = 2
    Dim numSkipped As Integer
    numSkipped = 0
    While numSkipped < 100
        Dim copath As String
        copath = s.Cells(row, 1).Value
        If copath = "" Then
            numSkipped = numSkipped + 1
        Else
            numSkipped = 0
            Dim column As Integer
            column = 2
            Dim folderName As Variant
            For Each folderName In existingFolders
                If UCase(Left(basename(folderName), Len(copath))) = UCase(copath) Then
                    s.Cells(row, column) = folderName
                    column = column + 1
                End If
            Next folderName
            ' Clear all 20 columns wide
            While column < 20
                s.Cells(row, column) = ""
                column = column + 1
            Wend
        End If
        row = row + 1
    Wend
End Sub

Private Function basename(ByVal inVal As String, Optional directorySeparator As String = "\") As String
    Dim index As Integer
    
    index = InStrRev(inVal, directorySeparator)
    If index > 0 Then
        basename = Mid(inVal, index + 1)
    Else
        basename = Mid(inVal, index + 1)
    End If
End Function

