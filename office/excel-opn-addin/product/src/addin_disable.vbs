Option Explicit

' ------------------------------------------------------------------------
' アドインの無効化
' ------------------------------------------------------------------------

Const MSGSUCCESS = "アドインを無効化しました。"
Const MSGFAILURE = "アドインの無効化に失敗しました。"

Dim oExcel
Dim oAddin
Dim oBook
Dim sArgAppName
Dim sArgMode

On Error Resume Next

sArgAppName = Wscript.Arguments.Item(0)
sArgMode = Wscript.Arguments.Item(1)

Set oExcel = nothing
Set oBook = nothing
Set oAddin = nothing

' Excelオブジェクトの生成
Set oExcel = CreateObject("Excel.Application")
If Err.Number <> 0 Then ErrorHandler

' ワークブックの生成
Set oBook = oExcel.Workbooks.Add
If Err.Number <> 0 Then ErrorHandler

' アドインの選択
Set oAddin = oExcel.AddIns(sArgAppName)
If Err.Number <> 0 Then ErrorHandler

' アドインの解除
oAddin.Installed = False
If Err.Number <> 0 Then ErrorHandler

' オブジェクトの解放
oBook.Close
Set oBook = nothing

oExcel.Quit
Set oExcel = nothing

' 正常終了
If sArgMode <> "/i" Then
  MsgBox MSGSUCCESS, vbInformation, sArgAppName
End If
WScript.Quit 0

' ------------------------------------------------------------------------
' 異常終了
Sub ErrorHandler()
  MsgBox MSGFAILURE & vbcrlf & _
	"詳細: " & CStr(Err.Number) & ":" & Err.Description, _
	vbExclamation, sArgAppName
  If Not oBook Is Nothing Then oBook.Close
  Set oBook = nothing
  If Not oExcel Is Nothing Then oExcel.Quit
  Set oExcel = nothing
  WScript.Quit 1
End Sub
