Option Explicit

' ------------------------------------------------------------------------
' オブジェクトのチェック
' ------------------------------------------------------------------------

Dim oApp

On Error Resume Next

' 引数のチェック
If 1 <> WScript.arguments.count Then
  WScript.Quit 1
End If

' オブジェクトのチェック
Set oApp = CreateObject(WScript.arguments(0))
If Err.Number <> 0 Then
  WScript.Quit 2
End If

' オブジェクトの解放
oApp.Quit
Set oApp = nothing

' チェック成功
WScript.Quit 0
