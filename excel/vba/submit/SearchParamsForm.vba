Option Explicit

Const SubmitColumn = 7
Const ErrorColumn = 8

Private raw As Worksheet
Private root As String
Private badTitleCharacter As RegExp
Private chosenEngines As New Dictionary
Private disableEngineChange As Boolean

Public Sub ShowSubmitForm(sheet As Worksheet, rootDir As String)
    Set raw = sheet
    root = rootDir
    Set badTitleCharacter = New RegExp
    With badTitleCharacter
        .IgnoreCase = True
        .Global = True
        .Pattern = "[^a-zA0Z0-9-+._()\[\]\{\}=# ]" 'See ServiceImpl.BAD_TITLE_CHARACTER
    End With
    
    If ValidateData() Then
        Show
    End If
End Sub

Private Sub Submit()
    Dim postStrings As New Dictionary
    Dim numErrors As Integer
    numErrors = 0
    Dim wasError As Boolean
    If ValidateData(postStrings) Then
        Dim Answer As String
        Answer = MsgBox("I am about to submit " & Str(postStrings.count) & " search(es) to Swift. Is this ok?", vbQuestion + vbYesNo, "Submitting to Swift")
        If Answer = vbNo Then
            Exit Sub
        End If
        Dim key As Variant
        For Each key In postStrings.Keys
            wasError = False
            Dim row As Integer
            row = Int(key)
            Dim postText As String
            postText = postStrings(row)
            
            On Error GoTo postFail
            Dim result As DOMDocument
            Set result = Web.Post("/searches.xml", postText)
            raw.Cells(row, ErrorColumn).Clear
            raw.Cells(row, SubmitColumn).Clear
            If result.SelectSingleNode("/list/search/id") Is Nothing Then
                wasError = True
                If result.SelectSingleNode("/list/error/message") Is Nothing Then
                    raw.Cells(row, ErrorColumn).value = "Undefined error"
                Else
                    raw.Cells(row, ErrorColumn).value = result.SelectSingleNode("/list/error/message").Text
                End If
            Else
                raw.Cells(row, SubmitColumn).value = "=HYPERLINK(""" & _
                    Submitter.searchUrl & result.SelectSingleNode("/list/search/id").Text & """, """ & _
                    result.SelectSingleNode("/list/search/title").Text & """)"
            End If
            
            On Error GoTo 0
            GoTo nextItem
postFail:
            wasError = True
            raw.Cells(row, ErrorColumn).value = "Error " + Web.LastError
nextItem:
            numErrors = HighlightErrors(wasError, row, numErrors)
        Next key
    End If
    
    If numErrors > 0 Then
        MsgBox "" & CStr(numErrors) & " out of " & CStr(postStrings.count) & " searches failed to submit. Delete the successful ones, fix the errors and try again."
    End If
    
    Unload Me
End Sub

Private Function ValidateData(Optional ByRef posts As Variant) As Boolean
    Dim row As Integer
    row = 2
    
    Dim numSkipped As Integer
    numSkipped = 0
    Dim wasError As Boolean
    
    'Strings to be submitted to the Swift's web service
    Dim titles As New Collection
    Dim common As String
    common = ""
    If Not IsMissing(posts) Then
        common = common & "userEmail=" & Web.UrlEncode(UsersListBox.value)
        common = common & "&paramSetId=" & Web.UrlEncode(ParameterSetsListBox.value)
        common = common & "&peptideReport=" & IIf(PeptideReportCB.value, "true", "false")
        common = common & "&fromScratch=" & IIf(FromScratchCB.value, "true", "false")
        common = common & "&lowPriority=" & IIf(LowPriorityCB.value, "true", "false")
        common = common & "&publicMgfFiles=" & IIf(PublicMgfFiles.value, "true", "false")
        common = common & "&publicSearchFiles=" & IIf(PublicIntermediateCB.value, "true", "false")
        If QuaMeterListBox.ListIndex <> -1 Then
            common = common & "&user.quameter.category=" & Web.UrlEncode(QuaMeterListBox.List(QuaMeterListBox.ListIndex, 0))
        End If
        Dim i As Integer
        For i = 0 To EnginesListBox.ListCount - 1
            If EnginesListBox.Selected(i) Then
                common = common & "&enabledEngines=" & Web.UrlEncode(EnginesListBox.List(i, 0))
            End If
        Next i
    End If
    
    Dim searchData As String
    searchData = ""
    Dim prevTitle As String
    prevTitle = ""
    Dim numErrors As Integer
    numErrors = 0
    Dim prevSearchStart As Integer
    prevSearchStart = 0
    While numSkipped < 100
        wasError = False
        'Search Title    Output Folder   File    Column  Experiment  Category    Search link Error
        Dim title As String
        Dim outputFolder As String
        Dim file As String
        Dim column As String
        Dim experiment As String
        Dim category As String
        
        title = Trim(raw.Cells(row, 1).value)
        outputFolder = Trim(raw.Cells(row, 2).value)
        outputFolder = Replace(outputFolder, "\", "/")
        file = Trim(raw.Cells(row, 3).value)
        column = Trim(raw.Cells(row, 4).value)
        experiment = Trim(raw.Cells(row, 5).value)
        category = Trim(raw.Cells(row, 6).value)
        
        If title = "" Then
            numSkipped = numSkipped + 1
        Else
            ValidateRow raw, row, ErrorColumn, title, outputFolder, file, column, experiment, category, wasError
            
            If (title <> prevTitle) Then
                If prevSearchStart > 0 And Not IsMissing(posts) Then
                    posts.Add Item:=common & searchData, key:=prevSearchStart
                End If
                searchData = ""
                searchData = searchData & "&title=" & Web.UrlEncode(title)
                searchData = searchData & "&outputFolderName=" & Web.UrlEncode(outputFolder)
                prevSearchStart = row
            End If
            
            file = Replace(file, "\", "/")
            searchData = searchData & "&inputFilePaths=" & Web.UrlEncode(file)
            searchData = searchData & "&biologicalSamples=" & Web.UrlEncode(column)
            searchData = searchData & "&categoryNames=" & Web.UrlEncode(category)
            searchData = searchData & "&experiments=" & Web.UrlEncode(experiment)
        End If
                
        numErrors = HighlightErrors(wasError, row, numErrors)
        row = row + 1
        prevTitle = title
    Wend
    
    If prevSearchStart > 0 And Not IsMissing(posts) Then
        posts.Add Item:=common & searchData, key:=prevSearchStart
    End If
    
    If numErrors > 0 Then
        MsgBox "There " & IIf(numErrors = 1, "was 1 error", "were " & numErrors & " errors") & "! Please review the Error column!", vbOKOnly, "Errors in input"
        ValidateData = False
    Else
        ValidateData = True
    End If
        
End Function

Private Function HighlightErrors(wasError As Boolean, row As Integer, numErrors As Integer) As Integer
        If wasError Then
            numErrors = numErrors + 1
            raw.Range("A" & row, "H" & row).Interior.Color = RGB(255, 200, 200)
        Else
            raw.Range("A" & row, "H" & row).Interior.ColorIndex = 0
            raw.Cells(row, ErrorColumn).value = ""
        End If
        HighlightErrors = numErrors
End Function

Private Sub ValidateRow(s As Worksheet, row As Integer, ErrorColumn As Integer, ByRef title As String, ByRef outputFolder As String, ByRef file As String, ByRef column As String, ByRef experiment As String, ByRef category As String, ByRef wasError As Boolean)
    title = Trim(title)
    outputFolder = Trim(outputFolder)
    file = Trim(file)
    column = Trim(column)
    experiment = Trim(experiment)
    category = Trim(category)
    
    If outputFolder = "" Then
        s.Cells(row, ErrorColumn).value = "Missing output folder"
        wasError = True
        Exit Sub
    End If
    If file = "" Then
        s.Cells(row, ErrorColumn).value = "Missing input file"
        wasError = True
        Exit Sub
    End If
    If column = "" Then
        s.Cells(row, ErrorColumn).value = "Missing column name"
        wasError = True
        Exit Sub
    End If
    If experiment = "" Then
        s.Cells(row, ErrorColumn).value = "Missing experiment name"
        wasError = True
        Exit Sub
    End If
    If category = "" Then
        s.Cells(row, ErrorColumn).value = "Missing category name"
        wasError = True
        Exit Sub
    End If
    If Not Files.FileExists(root & "\" & file) Then
        s.Cells(row, ErrorColumn).value = "File does not exist"
        wasError = True
        Exit Sub
    End If
    If Len(title) > 100 Then
        s.Cells(row, ErrorColumn).value = "Title too long, maximum 100 characters"
        wasError = True
        Exit Sub
    End If
    Dim matches As MatchCollection
    Set matches = badTitleCharacter.Execute(title)
    If matches.count > 0 Then
        Dim badChars As New Collection
        Dim myMatch As Match
        For Each myMatch In matches
            If Not InCollection(badChars, myMatch.value) Then
                badChars.Add myMatch.value, myMatch.value
            End If
        Next myMatch
        
        Dim chars As String
        chars = ""
        Dim badChar As Variant
        For Each badChar In badChars
            chars = chars & badChar
        Next badChar
        s.Cells(row, ErrorColumn).value = "Title must not contain " & chars
        wasError = True
        Exit Sub
    End If
End Sub

Private Sub CancelButton_Click()
    Hide
End Sub

Private Sub Validate()
    Dim valid As Boolean
    Dim i As Integer
    Dim numEngines As Integer
    numEngines = 0
    For i = 0 To EnginesListBox.ListCount - 1
        If EnginesListBox.Selected(i) Then
            numEngines = numEngines + 1
        End If
    Next i
    
    Dim quameterValid As Boolean
    quameterValid = True
    If Not IsEmpty(chosenEngines.Item("QUAMETER")) And chosenEngines.Item("QUAMETER") >= 0 Then
        ' Quameter is enabled
        If QuaMeterListBox.ListIndex = -1 Then
            quameterValid = False
        End If
    End If
    
    valid = Not IsNull(UsersListBox.value) And Not IsNull(ParameterSetsListBox.value) And numEngines >= 1 And quameterValid
    SubmitButton.Enabled = valid
End Sub

Private Sub EnginesListBox_Change()
    If disableEngineChange Then
        Exit Sub
    End If
    
    disableEngineChange = True
    ' We look at what engines we had selected before
    ' We look at what is selected now
    ' We make sure that for each engine code, only one version is selected at once
    ' The diff between before/now is done to figure out which engine is supposed to be the new one
       
    Dim code As String
    Dim i As Integer
    ' Collect information about engines the user changed
    Dim enginesToChange As New Dictionary
    Dim enginesNotSelected As New Dictionary
    For i = 0 To EnginesListBox.ListCount - 1
        code = EnginesListBox.List(i, 1)
        If Not EnginesListBox.Selected(i) Then
            enginesNotSelected.Item(code) = i
        End If
    Next i
    
    For i = 0 To EnginesListBox.ListCount - 1
        If EnginesListBox.Selected(i) Then
            code = EnginesListBox.List(i, 1)
            If enginesNotSelected.Exists(code) Then
                enginesNotSelected.Remove (code)
            End If
            If chosenEngines.Exists(code) Then
                ' This engine was previously selected
                If chosenEngines.Item(code) = i Then
                    ' no change here
                Else
                    ' this engine was not previously selected and now it is
                    ' We make a note that this is the new version the user wants
                    enginesToChange.Item(code) = i
                End If
            End If
        End If
    Next i
    
    ' Update the list of 'chosen' engines
    Dim key As Variant
    For Each key In enginesToChange.Keys
        chosenEngines.Item(key) = enginesToChange.Item(key)
    Next key
    For Each key In enginesNotSelected.Keys
        chosenEngines.Item(key) = -1
    Next key
    
    ' Change selection so each engine so it matches the chosen ones
    For i = 0 To EnginesListBox.ListCount - 1
        code = EnginesListBox.List(i, 1)
        Dim sel As Boolean
        sel = (chosenEngines.Exists(code) And chosenEngines.Item(code) = i)
        If EnginesListBox.Selected(i) <> sel Then
            EnginesListBox.Selected(i) = sel
        End If
    Next i
                                
    disableEngineChange = False
                
    Validate
End Sub

Private Sub ParameterSetsListBox_Change()
    Validate
End Sub

Private Sub QuaMeterListBox_Change()
    Validate
End Sub

Private Sub SubmitButton_Click()
    Submit
End Sub

Private Sub UsersListBox_Change()
    Validate
End Sub

Private Sub UserForm_Initialize()
    Application.EnableEvents = False
    On Error GoTo evts:
    UsersListBox.Clear
    
    Dim nodes As IXMLDOMSelection
    Set nodes = GetXML("/users.xml").SelectNodes("/list/user")
        
    Dim node As IXMLDOMNode
    Dim i As Integer
    
    For i = 0 To nodes.Length - 1
        Set node = nodes.Item(i)
        
        Dim firstName As String
        Dim lastName As String
        Dim email As String
        firstName = node.SelectSingleNode("firstName").Text
        lastName = node.SelectSingleNode("lastName").Text
        email = node.SelectSingleNode("email").Text
        With UsersListBox
            .AddItem
            .List(i, 0) = email
            .List(i, 1) = firstName
            .List(i, 2) = lastName
        End With
    Next i
    
    ' List engines
    Set nodes = GetXML("/engines.xml").SelectNodes("/list/engine")
    Dim allEngines() As String
        
    Dim code As String
    Dim redimmed As Boolean
    redimmed = False
    For i = 0 To nodes.Length - 1
        Set node = nodes.Item(i)
        Dim version As String
        
        code = node.SelectSingleNode("code").Text
        version = node.SelectSingleNode("version").Text
        If redimmed Then
            ReDim Preserve allEngines(LBound(allEngines) To UBound(allEngines) + 1) As String
        Else
            ReDim allEngines(0 To 0) As String
            redimmed = True
        End If
        allEngines(UBound(allEngines)) = code & " " & version
    Next i
    
    QuickSort allEngines, LBound(allEngines), UBound(allEngines)
    
    disableEngineChange = True
    EnginesListBox.Clear
    Dim prevCode As String
    For i = LBound(allEngines) To UBound(allEngines)
        With EnginesListBox
            .AddItem
            Dim parts() As String
            parts = Split(allEngines(i), " ", 2, vbTextCompare)
            prevCode = code
            code = parts(0)
            version = parts(1)
            .List(i, 0) = code & "-" & version
            .List(i, 1) = code
            .List(i, 2) = version
            If AutoSelectEngine(code) Then
                ' We build a dictionary of all chosen engines
                chosenEngines.Item(code) = i
                .Selected(i) = True
                If AutoSelectEngine(prevCode) And prevCode = code Then
                    .Selected(i - 1) = False
                End If
            End If
        End With
    Next i
    disableEngineChange = False

    ' List parameter sets
    Set nodes = GetXML("/parameter-sets.xml").SelectNodes("/list/parameter-set")
        
    ParameterSetsListBox.Clear
    For i = 0 To nodes.Length - 1
        Set node = nodes.Item(i)
        
        Dim id As String
        Dim name As String
        Dim initials As String
        id = node.SelectSingleNode("id").Text
        name = node.SelectSingleNode("name").Text
        initials = node.SelectSingleNode("initials").Text
        With ParameterSetsListBox
            .AddItem
            .List(i, 0) = id
            .List(i, 1) = name
            .List(i, 2) = initials
        End With
    Next i
    
    ' List quameter categories
    Set nodes = GetXML("/quameter-categories.xml").SelectNodes("/list/quameter-category")
        
    QuaMeterListBox.Clear
    For i = 0 To nodes.Length - 1
        Set node = nodes.Item(i)
        
        Dim catCode As String
        Dim catName As String
        catCode = node.SelectSingleNode("code").Text
        catName = node.SelectSingleNode("name").Text
        With QuaMeterListBox
            .AddItem
            .List(i, 0) = catCode
            .List(i, 1) = catName
        End With
    Next i
    
evts:
    Application.EnableEvents = True
    
    Validate

End Sub

Public Sub QuickSort(vArray As Variant, inLow As Long, inHi As Long)

  Dim pivot   As Variant
  Dim tmpSwap As Variant
  Dim tmpLow  As Long
  Dim tmpHi   As Long

  tmpLow = inLow
  tmpHi = inHi

  pivot = vArray((inLow + inHi) \ 2)

  While (tmpLow <= tmpHi)

     While (vArray(tmpLow) < pivot And tmpLow < inHi)
        tmpLow = tmpLow + 1
     Wend

     While (pivot < vArray(tmpHi) And tmpHi > inLow)
        tmpHi = tmpHi - 1
     Wend

     If (tmpLow <= tmpHi) Then
        tmpSwap = vArray(tmpLow)
        vArray(tmpLow) = vArray(tmpHi)
        vArray(tmpHi) = tmpSwap
        tmpLow = tmpLow + 1
        tmpHi = tmpHi - 1
     End If

  Wend

  If (inLow < tmpHi) Then QuickSort vArray, inLow, tmpHi
  If (tmpLow < inHi) Then QuickSort vArray, tmpLow, inHi

End Sub

Public Function AutoSelectEngine(code As String)
    AutoSelectEngine = code = "MASCOT" Or code = "SEQUEST" Or code = "TANDEM" Or code = "SCAFFOLD"
End Function
