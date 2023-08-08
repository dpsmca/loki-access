Option Explicit

Public Const swiftUrl = "http://loki.mayo.edu"
Public Const baseUrl = swiftUrl & "/service" ' Web service access
Public Const searchUrl = swiftUrl & "/start/?load="

Public Const root = "\\mfad\rchapp\odin\prod"

Function TitlesWorksheet() As Worksheet
    Set TitlesWorksheet = Sheet1
End Function

Function RawWorksheet() As Worksheet
    Set RawWorksheet = Sheet2
End Function

Sub LookupInputFiles()
   
    Dim row As Integer
    row = 2
    Dim outrow As Integer
    outrow = 2
    Dim titles As Worksheet
    Set titles = TitlesWorksheet()
    
    Dim raw As Worksheet
    Set raw = RawWorksheet()
    
    Dim titleCount As New Collection
        
    CleanRawSheet raw
    
    Dim numSkipped As Integer
    numSkipped = 0
    Dim wasError As Boolean
    While numSkipped < 100
        If titles.Cells(row, 1).EntireRow.Hidden = True Then
            GoTo nextLoop
        End If
        
        wasError = False
        Dim title As String
        Dim inputFolder As String
        Dim outputFolder As String
        title = titles.Cells(row, 1).value
        inputFolder = titles.Cells(row, 2).value
        outputFolder = titles.Cells(row, 3).value
        titles.Cells(row, 4) = ""
        If Trim(outputFolder) = "" Then
                outputFolder = inputFolder & "\" & title
        End If
        
        If title = "" Then
            numSkipped = numSkipped + 1
        Else
            If IncrementCount(titleCount, title) > 1 Then
                If titles.Cells(row - 1, 1) <> title Then
                    titles.Cells(row, 4) = "Search [" + title + "] listed multiple times on non-consecutive rows!"
                    wasError = True
                ElseIf titles.Cells(row - 1, 3) <> outputFolder Then
                    titles.Cells(row, 4) = "Search [" + title + "] uses different output folder on previous line!"
                    wasError = True
                End If
            End If
            
            Dim inputFiles As Collection
            numSkipped = 0
            Set inputFiles = FindInputFiles(inputFolder)
            If inputFiles.count = 0 Then
                titles.Cells(row, 4) = "No files found!"
                wasError = True
            End If
            
            outrow = AddFiles(raw, title, outputFolder, inputFiles, outrow)
        End If
        If wasError Then
            titles.Range("A" & row, "D" & row).Interior.Color = RGB(255, 200, 200)
        Else
            titles.Range("A" & row, "D" & row).Interior.ColorIndex = 0
        End If
nextLoop:
        row = row + 1
    Wend
    If wasError Then
        MsgBox "There were errors! Please review the Error column!", vbOKOnly, "Errors in input"
    Else
        raw.Activate
    End If
End Sub

Sub SubmitSwiftSearches()
    Dim form As New SearchParamsForm
    form.ShowSubmitForm RawWorksheet(), root
End Sub

Private Function IncrementCount(ByRef count As Collection, key As String) As Integer
    If InCollection(count, key) Then
        Dim i As Integer
        i = count.Item(key)
        i = i + 1
        count.Remove key
        count.Add i, key
        IncrementCount = i
    Else
        count.Add 1, key
        IncrementCount = 1
    End If
End Function

Private Function AddFiles(sheet As Worksheet, title As String, outputFolder As String, inputFiles As Collection, outrow As Integer)
    Dim inputFile As Variant
    Dim prevTitle As String
    prevTitle = ""
    For Each inputFile In inputFiles
        Dim column As String
        column = Left(basename(inputFile), Len(basename(inputFile)) - 4)
            
        sheet.Cells(outrow, 1) = title
        sheet.Cells(outrow, 2) = outputFolder
        sheet.Cells(outrow, 3) = inputFile
        sheet.Cells(outrow, 4) = column
        sheet.Cells(outrow, 5) = title
        sheet.Cells(outrow, 6) = "none"
        
        If prevTitle <> title Then
            sheet.Cells(outrow, 7) = "Not submitted"
        Else
            sheet.Cells(outrow, 7) = ""
        End If
        sheet.Cells(outrow, 8) = ""
        outrow = outrow + 1
        prevTitle = title
    Next inputFile
    AddFiles = outrow
End Function

Private Sub CleanRawSheet(sheet As Worksheet)
    sheet.Cells.ClearContents
    sheet.Cells(1, 1) = "Search Title"
    sheet.Cells(1, 2) = "Output Folder"
    sheet.Cells(1, 3) = "File"
    sheet.Cells(1, 4) = "Column"
    sheet.Cells(1, 5) = "Experiment"
    sheet.Cells(1, 6) = "Category"
    sheet.Cells(1, 7) = "Search link"
    sheet.Cells(1, 8) = "Error"
    sheet.Range("A1..H1").Font.Bold = True
End Sub

Private Function FindInputFiles(inputFolder As String) As Collection
    Dim inputFiles As New Collection
    
    Dim folder As Variant
    folder = Dir(root & "\" & inputFolder & "\", vbDirectory)
    While folder <> ""
        If Left(folder, 1) <> "." Then
            If LCase(Right(folder, 4)) = ".raw" Or LCase(Right(folder, 4)) = ".mgf" Then
                inputFiles.Add (inputFolder & "\" & folder)
            End If
        End If
        folder = Dir
    Wend
    
    Sort inputFiles
    Set FindInputFiles = inputFiles
End Function

Private Sub Sort(ByRef col As Collection)
    Dim i As Long
    Dim j As Long
    Dim temp As Variant
    For i = 1 To col.count - 1
        For j = i + 1 To col.count
            If col(i) > col(j) Then
                temp = col(j)
                col.Remove j
                col.Add temp, , i
            End If
        Next j
    Next i
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

Public Function InCollection(col As Collection, key As String) As Boolean
  Dim var As Variant
  Dim errNumber As Long

  InCollection = False
  Set var = Nothing

  Err.Clear
  On Error Resume Next
    var = col.Item(key)
    errNumber = CLng(Err.Number)
  On Error GoTo 0

  '5 is not in, 0 and 438 represent incollection
  If errNumber = 5 Then ' it is 5 if not in collection
    InCollection = False
  Else
    InCollection = True
  End If

End Function
