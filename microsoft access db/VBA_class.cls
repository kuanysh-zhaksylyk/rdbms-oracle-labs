VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_Форма добавление или удаления полей"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Ctl_addbtn_Click()

    Dim dbs As Database, tdf As TableDef, fld As Field
    Set dbs = CurrentDb
    
    If ((Me.newname <> "") And (Me.newtype.Value <> "") And (Me.tables.Value <> "")) Then
    
        Set tdf = dbs.TableDefs(tables.Value)
        Select Case newtype.Value
            Case "Текстовый"
                Set fld = tdf.CreateField(Me.newname, dbText)
            Case "Числовой"
                Set fld = tdf.CreateField(Me.newname, dbLong)
            Case "Дата/время"
                Set fld = tdf.CreateField(Me.newname, dbDate)
            Case "Денежный"
                Set fld = tdf.CreateField(Me.newname, dbDecimal)
            Case "Логический"
                Set fld = tdf.CreateField(Me.newname, dbBoolean)
            Case "Поле MEMO"
                Set fld = tdf.CreateField(Me.newname, dbMemo)
        End Select
        
        On Error Resume Next
        tdf.Fields.Append fld
        If Err.Number = 3191 Then MsgBox "Поле с таким именем уже существует!"
        Err.Clear

        tdf.Fields.Refresh
        newname = ""
        newtype = "Текстовый"
        
        Dim StrTable As String
        StrTable = [tables]
        deletename.RowSourceType = "Field List"
        deletename.RowSource = StrTable
        
        If (check.Value) Then
            DoCmd.OpenTable tables.Value, acViewNormal
        End If
        
    Else: MsgBox "Поля не заполнены или не выбрана таблица!"
    End If
    
End Sub

Private Sub Ctl_deletebtn_Click()

    Dim Msg, Style, Title, Help, Ctxt, Response, MyString
    Dim dbs As Database, tdf As TableDef, fld As Field
    Set dbs = CurrentDb
    Set tdf = dbs.TableDefs(tables.Value)
     
    Msg = Вы действительно хотите удалить поле " + deletename.Value + "?"
    Style = vbYesNo + vbCritical + vbDefaultButton2
    Title = "Удаление поля"
    Help = "DEMO.HLP"
    Ctxt = 1000
    Response = MsgBox(Msg, Style, Title, Help, Ctxt)
    
    If Response = vbYes Then
        On Error Resume Next
        tdf.Fields.Delete (Me.deletename.Value)
        If Err.Number = 3280 Then MsgBox "Невозможно удалить ключевое поле!"
        tdf.Fields.Refresh
                
        Dim StrTable As String
        StrTable = [tables]
        deletename.RowSourceType = "Field List"
        deletename.RowSource = StrTable
             
        If (check.Value) Then
        DoCmd.OpenTable tables.Value, acViewNormal
        End If
    End If

End Sub

Private Sub tables_Click()
Dim StrTable As String
    StrTable = [tables]
    deletename.RowSourceType = "Field List"
    deletename.RowSource = StrTable
End Sub

Private Sub tables_DblClick(Cancel As Integer)
    DoCmd.OpenTable tables.Value, acViewNormal
End Sub

                  Private Sub button_25_Click()
                    On Error GoTo Err_buttion25_Click


    If Me.Dirty Then Me.Dirty = False
    DoCmd.Close

                      Exit_button25_Click:
    Exit Sub

                        Err_button25_Click:
    MsgBox Err.Description
                        Resume Exit_button25_Click
    
End Sub
                      Private Sub button26_Click()
                        On Error GoTo Err_button26_Click


    DoCmd.Close

                        Exit_button26_Click:
    Exit Sub

                          Err_button26_Click:
    MsgBox Err.Description
                          Resume Exit_button26_Click
    
End Sub
                        Private Sub button27_Click()
                          On Error GoTo Err_button27_Click


    DoCmd.Close

                          Exit_button27_Click:
    Exit Sub

                            Err_button27_Click:
    MsgBox Err.Description
                            Resume Exit_button27_Click
    
End Sub
                          Private Sub button28_Click()
                            On Error GoTo Err_button28_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = ChrW(53) & ChrW(53) & ChrW(32) & ChrW(1052) & ChrW(1069) & ChrW(1048) & ChrW(1053)
    DoCmd.OpenForm stDocName, , , stLinkCriteria

                            Exit_button28_Click:
    Exit Sub

                              Err_button28_Click:
    MsgBox Err.Description
                              Resume Exit_button28_Click
    
End Sub


