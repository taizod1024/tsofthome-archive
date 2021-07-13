;;; -*- Mode: nsi; Package: editor -*-
;;;
;;; XyzzyCustomA.nsh --- CustomA用ヘッダ

; CUSTOMAページ用テキスト
!insertmacro MUI_LANGUAGEFILE_STRING TEXT_CUSTOMA_TITLE "配布パッケージの取得方法を指定してください。"
!insertmacro MUI_LANGUAGEFILE_STRING TEXT_CUSTOMA_SUBTITLE "${MUI_PRODUCT} 配布パッケージをどのように取得するかを設定します。"

;;; CUSTOMページ用処理
Function SetCustomA
  ReadRegStr $R1 HKLM "Software\${MUI_SETUP}" "urlflag"
  ReadRegStr $R2 HKLM "Software\${MUI_SETUP}" "url"
  ReadRegStr $R3 HKLM "Software\${MUI_SETUP}" "localfileflag"
  ReadRegStr $R4 HKLM "Software\${MUI_SETUP}" "localfile"
  StrCmp $R2 "" 0 +2
    StrCpy $R2 "http://www.jsdlab.co.jp/~kamei/cgi-bin/download.cgi"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "XyzzyCustomA.ini" "Field 3" "State" $R1
  !insertmacro MUI_INSTALLOPTIONS_WRITE "XyzzyCustomA.ini" "Field 4" "State" $R2
  !insertmacro MUI_INSTALLOPTIONS_WRITE "XyzzyCustomA.ini" "Field 5" "State" $R3
  !insertmacro MUI_INSTALLOPTIONS_WRITE "XyzzyCustomA.ini" "Field 6" "State" $R4
  !insertmacro MUI_HEADER_TEXT "${TEXT_CUSTOMA_TITLE}" "${TEXT_CUSTOMA_SUBTITLE}"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "XyzzyCustomA.ini"
FunctionEnd

;;; 配布パッケージをインストール
Function InstallPackage

  ; 配布パッケージを取得
  !insertmacro MUI_INSTALLOPTIONS_READ $R1 "XyzzyCustomA.ini" "Field 3" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $R2 "XyzzyCustomA.ini" "Field 4" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $R3 "XyzzyCustomA.ini" "Field 5" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $R4 "XyzzyCustomA.ini" "Field 6" "State"
  WriteRegStr HKLM "Software\${MUI_SETUP}" "urlflag" $R1
  WriteRegStr HKLM "Software\${MUI_SETUP}" "url" $R2
  WriteRegStr HKLM "Software\${MUI_SETUP}" "localfileflag" $R3
  WriteRegStr HKLM "Software\${MUI_SETUP}" "localfile" $R4

  DetailPrint "ダウンロード及び展開用一時ファイル及びフォルダ作成開始"
  GetTempFileName $R5
  GetTempFileName $R6
  Delete $R6
  CreateDirectory $R6
  DetailPrint "ダウンロード及び展開用一時ファイル及びフォルダ作成完了"
  StrCmp $R1 1 download
  StrCmp $R3 1 localfile

  download:
  DetailPrint "ダウンロード開始：$R2"
  NSISdl::download /TIMEOUT=30000 $R2 $R5
  Pop $R0
  StrCmp $R0 "success" +6
    StrCmp $R0 "cancel" +3
      MessageBox MB_OK|MB_ICONSTOP "ダウンロードに失敗しました。$\r$\nエラー内容：$R0"
      Quit
      MessageBox MB_OK|MB_ICONSTOP "ダウンロードをキャンセルしました。"
      Quit
  DetailPrint "ダウンロード完了：$R2"
  Goto fileready

  localfile:
  IfFileExists $R4 +3
    MessageBox MB_OK|MB_ICONSTOP "ローカルファイルが見つかりません。"
    Quit
  CopyFiles $R4 $R5
  Goto fileready

  fileready:

  ; 配布パッケージを展開
  ; unlhaで$INSTDIRに直接展開する方法が分からなかったので、
  ; 一旦展開してから必要なものだけコピーしている…
  DetailPrint "展開開始：$R5"
  System::Call 'unlha32::Unlha(i, t, t, i) i (0, "x $R5 $R6\ ", "", 0) .r0'
  StrCmp $0 0 +3
    MessageBox MB_OK|MB_ICONSTOP "展開に失敗しました。$\r$\nユーザにより中断、UNLHA32.DLLが組み込まれていない、$\r$\nファイル形式が間違っている等の可能性があります。"
    Quit
  DetailPrint "展開完了：$R5"
  SetOutPath $INSTDIR  
  CopyFiles "$R6\xyzzy\*.*" $INSTDIR

  ; 配布パッケージ削除
  DetailPrint "ダウンロード及び展開用一時ファイル及びフォルダ削除開始"
  Delete $R5
  Delete "$R6\*.*"
  RMDir /r $R6
  DetailPrint "ダウンロード及び展開用一時ファイル及びフォルダ削除完了"

FunctionEnd
