Option Explicit

' 定数：OS関連
Const olFolderNotes = 12
Const olSave = 2
Const HWND_TOPMOST = -1
Const TemporaryFolder = 2
Const SWP_NOSIZE = &H1
Const SWP_NOMOVE = &H2
Const SWP_HIDEWINDOW = &H80
Const ForWriting = 2
Const TYPE_STRING = 8

' 定数：SFCmini
Dim FindWindowA
Dim SetWindowPos

' 定数：アプリ固有
Const cCaption = "outlook.exe"
Const cAppName = "Outlookメモで付箋紙"
Const cFsnTag = "付箋紙"
Const cFsxTag = "付箋紙/表示"
Const cNoname = "無題"
Const cPrefix = " - メモ"
Const cMagic = "  "

Const cArgNew = "/new"
Const cArgClip = "/clipboard"
Const cArgOutlook = "/outlook"
Const cArgDisplay = "/display"
Const cArgTag = "/tag:"

Dim cScrWidth
Dim cScrHeight

' 変数：アプリ引数
Dim bArgNew
Dim bArgClip
Dim bArgOutlook
Dim bArgDisplay
Dim sArgTag

' 変数：オブジェクト
Dim oShl
Dim oFso
Dim oOlk
Dim oNsp
Dim oFld

' 変数：表示状態
Dim bInit
Dim bDisplay
Dim sTagPath

' ------------------------------------------------------------------------
' 主処理
ArgCheck()      ' 引数のチェック
AppInit()       ' 初期化
AppMain()       ' 主処理

WScript.Quit 0

' ------------------------------------------------------------------------
' 主処理
Sub AppMain()

  If bArgOutlook Then
	ExecOutlook()
  Else
	DisplayNote()
  End If

End Sub

' ------------------------------------------------------------------------
' 引数チェック
Sub ArgCheck()

  Dim sArg

  bArgNew = False
  bArgClip = False
  bArgOutlook = False
  bArgDisplay = False
  sArgTag = ""

  For each sArg in WScript.arguments
	Select Case sArg
	Case cArgNew
	  bArgNew = True
	Case cArgClip
	  bArgClip = True
	Case cArgOutlook
	  bArgOutlook = True
	Case cArgDisplay
	  bArgDisplay = True
	Case Else
	  If Left(sArg,Len(cArgTag)) = cArgTag Then
		sArgTag = Mid(sArg,Len(cArgTag) + 1)
	  Else
		MsgBox "不明な引数が指定されています" & vbcrlf & _
		  "詳細: " & sArg & vbcrlf & _
		  "使い方：スクリプト名 引数なし | /new [ /clipboard ] [ /tag:タグ ] | /display [ /tag:タグ ] | /outlook", _
		  vbExclamation, cAppName
		WScript.Quit 1
	  End If
	End Select
  Next

End Sub

' ------------------------------------------------------------------------
' アプリ初期化
Sub AppInit()

  Dim oWmi
  Dim oCols
  Dim oCol
  Dim oLct
  Dim oSvc
  Dim oSet

  ' SFCminiの初期化
  Set FindWindowA = CreateObject("SfcMini.DynaCall")
  Set SetWindowPos = CreateObject("SfcMini.DynaCall")

  FindWindowA.Declare "user32","FindWindowA"
  SetWindowPos.Declare "user32","SetWindowPos"

  ' スクリーンサイズ
  Set oWmi = GetObject("Winmgmts:\\.\root\cimv2")
  Set oCols = oWmi.ExecQuery("Select * From Win32_DesktopMonitor where DeviceID = 'DesktopMonitor1'",,0)
  For Each oCol in oCols
	cScrWidth = oCol.ScreenWidth
	cScrHeight = oCol.ScreenHeight
  Next

  ' ファイルがなければ表示状態へ
  Set oLct = WScript.CreateObject("WbemScripting.SWbemLocator")
  Set oSvc = oLct.ConnectServer
  Set oSet = oSvc.ExecQuery("select * from win32_process where caption='" & cCaption & "'")
  bInit = oSet.count = 0

  ' オブジェクト接続
  Set oShl = WScript.CreateObject("Wscript.Shell")
  Set oFso = WScript.CreateObject("Scripting.FileSystemObject")
  Set oOlk = CreateObject("Outlook.Application")
  Set oNsp = oOlk.GetNamespace("MAPI")
  Set oFld = oNsp.GetDefaultFolder(olFolderNotes)
  sTagPath = oFso.GetSpecialFolder(TemporaryFolder).Path & "\" & cAppName & ".dat"

End Sub

' ------------------------------------------------------------------------
' 付箋紙の表示
Sub DisplayNote()

  Dim oNotes
  Dim oNote
  Dim lIdx
  Dim lNote
  Dim lDelete
  Dim sTitle
  Dim hWnd

  ' --------------------------------
  ' Outlook維持用の一枚を追加
  ' タグを予め登録しておくために、強制表示タグも追加
  Set oNotes = oFld.Items.Restrict("[分類項目] = '" & cFsnTag & "'")
  Set oNote = nothing
  For lIdx = 1 To oNotes.Count
	If oNotes(lIdx).subject = cAppName Then
	  Set oNote = oNotes(lIdx)
	  Exit For
	End If
  Next
  If oNote Is nothing Then
	Set oNote = oFld.Items.Add
	oNote.Categories = cFsnTag & "," & cFsxTag
	oNote.body = cAppName
	oNote.Left = cScrWidth / 2 - oNote.Width / 2
	oNote.Top = cScrHeight / 2 - oNote.Height / 2
	oNote.Close olSave
	If MsgBox("[" & cAppName & "]の初期設定を行いました。" & vbcrlf & "初期設定を反映させるには一度Outlookを終了する必要があります。" & vbcrlf & "Outlookを終了してもよろしいですか？", vbQuestion + vbYesNo, cAppName) = vbYes Then
	  oOlk.Quit
	  MsgBox "[新しい付箋紙]をクリックして付箋紙を追加してください。", vbInformation, cAppName
	Else
	  MsgBox "後でOutlookを終了してください。", vbInformation, cAppName
	End If
	WScript.Quit 3
  End If

  oNote.Display
  WScript.Sleep(500)
  sTitle = NoteTitle(oNote.subject)
  hWnd = FindWindowA(0, sTitle)
  SetWindowPos hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE Or SWP_NOMOVE Or SWP_HIDEWINDOW

  ' --------------------------------
  ' 全モード：空の付箋紙をすべて削除
  Set oNotes = oFld.Items.Restrict("[分類項目] = '" & cFsnTag & "'")
  oNotes.Sort "更新日時", False
  lNote = 0
  lDelete = 0
  For lIdx = oNotes.Count To 1 step -1
	Set oNote = oNotes(lIdx)
	If oNote.subject <> cAppName  Then
	  If "" = Trim(oNote.subject) Then
		oNote.Delete
		lDelete = lDelete + 1
	  Else
		lNote = lNote + 1
	  End If
	End If
  Next

  If Not bArgNew And Not bArgDisplay And lNote = 0 Then

	bDisplay = False

	' --------------------------------
	' 追加モード：追加するのでスルー
	' 表示モード：表示するのでスルー
	' 通常モード：付箋紙が一枚もなくなっていたら一件の登録を提案して終了
	MsgBox "[付箋紙の表示]がクリックされましたが付箋紙はありません。" & vbcrlf & "[新しい付箋紙]をクリックして付箋紙を追加してください。", vbInformation, cAppName
	WScript.Quit 2

  Else

	' --------------------------------
	' 全モード：現在状態の取得
	' Outlook未起動状態なら表示状態へ
	' 新しい付箋紙ならば表示状態へ
	' 強制表示ならば表示状態へ

	bDisplay = bInit _
	  Or bArgNew _
	  Or bArgDisplay _
	  Or Not oFso.FileExists(sTagPath)

	If bDisplay Then

	  ' --------------------------------
	  ' 全モード：表示する
	  For lIdx = 1 To oNotes.Count
		Set oNote = oNotes(lIdx)
		If oNote.subject <> cAppName _
			And (sArgTag = "" Or 0 < InStr(oNote.Categories, sArgTag)) Then
		  oNote.Display
		  sTitle = NoteTitle(oNote.subject)
		  oShl.AppActivate sTitle
		  hWnd = FindWindowA(0, sTitle)
		  If hWnd = 0 Then
			oNote.Close olSave
			oNote.Display
			hWnd = FindWindowA(0, sTitle)
		  End If
		  SetWindowPos hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE
		End If
	  Next

	Else

	  ' --------------------------------
	  ' 全モード：表示しない
	  For lIdx = 1 to oNotes.Count
		Set oNote = oNotes(lIdx)
		If oNote.subject <> cAppName _
			And InStr(oNote.Categories, cFsxTag) = 0 Then
		  oNote.Close olSave
		End If
	  Next
	End If

	' --------------------------------
	' 追加モード：付箋紙を追加
	If bArgNew Then
	  NewNote()
	End If

  End If

  ' --------------------------------
  ' 全モード：現在状態を更新
  UpdateStatus()

End Sub

' ------------------------------------------------------------------------
' 新しい付箋紙
Sub NewNote()

  Dim oNote
  Dim sFsnTag
  Dim hWnd
  Dim sBody
  Dim sTitle

  Set oNote = oFld.Items.Add
  sFsnTag = cFsnTag
  sBody = ""
  sTitle = cNoname
  If bArgClip Then
	sBody = Trim(CreateObject("htmlfile").parentwindow.clipboarddata.getdata("text"))
	If varType(sBody) <> TYPE_STRING Then
	  MsgBox "クリップボードの内容が文字列ではありません。", vbExclamation, cAppName
	  WScript.Quit 4
	End If
	If 0 < InStr(sBody, vbcrlf) Then
	  sTitle = Left(sBody, InStr(sBody, vbcrlf) - 1)
	Else
	  sTitle = sBody
	End If
  End If
  If sArgTag <> "" Then
	sFsnTag = sArgTag & "," & sFsnTag
  End If
  oNote.Categories = sFsnTag
  oNote.body = sBody
  oNote.Save
  oNote.Display
  oShl.AppActivate NoteTitle(sTitle)
  hWnd = FindWindowA(0, NoteTitle(sTitle))
  SetWindowPos hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE

End Sub


' ------------------------------------------------------------------------
' 新しい付箋紙
Sub ExecOutlook()

  oFld.Display

End Sub

' ------------------------------------------------------------------------
' 表示状態の更新
Sub UpdateStatus()

  If bDisplay Then
	oFso.CreateTextFile(sTagPath)
  Else
	If oFso.FileExists(sTagPath) Then
	  oFso.DeleteFile(sTagPath)
	End If
  End If

End Sub

' ------------------------------------------------------------------------
' タイトル名の生成
Function NoteTitle(note)
  NoteTitle = replace(note & cPrefix & cMagic, vbTab, " ")
End Function
