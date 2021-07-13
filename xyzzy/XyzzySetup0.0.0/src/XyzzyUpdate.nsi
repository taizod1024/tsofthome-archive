;;; -*- Mode: nsi; Package: editor -*-
;;;
;;; XyzzyUpdate.nsi --- xyzzy 配布パッケージ更新支援

;;; ヘッダ読込み
!include "MUI.nsh"
!include "XyzzySetup.nsh"
!include "XyzzyCustomA.nsh"

; 出力ファイル
OutFile "XyzzyUpdate.exe"

; 詳細表示
ShowInstDetails show			; 詳細を表示する

; 使用するページを宣言する
!define MUI_CUSTOMPAGECOMMANDS		; CUSTOMページを使用する
!define MUI_FINISHPAGE			; FINISHページを使用する

; MUI_CUSTOMPAGECOMMANDSを設定したので以下の順番でページを並べる
Page custom SetCustomA			; CUSTOMページ
!insertmacro MUI_PAGECOMMAND_INSTFILES	; INSTFILESページ
!insertmacro MUI_PAGECOMMAND_FINISH	; FINISHページ

; 以下のオプションで作る
!define MUI_FINISHPAGE_NOAUTOCLOSE	; FINISHページに勝手に遷移しない

; 以下のメッセージで作る
!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_INSTALLING_TITLE "更新"
!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_INSTALLING_SUBTITLE "${MUI_PRODUCT} を更新しています。しばらくお待ちください。"
!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_ABORTWARNING "${MUI_PRODUCT} の更新を中止しますか？"  
!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_FINISH_INFO_TEXT "${MUI_PRODUCT} は、更新されました。\r\n\r\nウィザードを閉じるには[完了]を押してください。"
!insertmacro MUI_LANGUAGE "Japanese"	; 日本語で作る

; 特定の情報をReserveする
ReserveFile "XyzzyCustomA.ini"
!insertmacro MUI_RESERVEFILE_WELCOMEFINISHPAGE
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

;;; 起動時処理
Function .onInit
  ReadRegStr $INSTDIR HKLM "Software\${MUI_SETUP}" ""
  StrCmp $INSTDIR "" 0 +3
    MessageBox MB_OK|MB_ICONSTOP "${MUI_PRODUCT} のインストール情報が見つかりません。$\r$\n${MUI_PRODUCT} の更新を中止します。"
    Quit
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "XyzzyCustomA.ini"
FunctionEnd

;;; インストーラ
Section "XyzzyUpdate.exe"

  Call InstallPackage

SectionEnd

