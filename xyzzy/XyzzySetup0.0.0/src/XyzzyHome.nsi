;;; -*- Mode: nsi; Package: editor -*-
;;;
;;; XyzzyHome.nsi --- ユーザ環境変数 XYZZYHOME 設定

;;; ヘッダ読込み
!include "MUI.nsh"
!include "XyzzySetup.nsh"
!include "XyzzyCustomB.nsh"

; 出力ファイル
OutFile "XyzzyHome.exe"

; 詳細表示
ShowInstDetails show			; 詳細を表示する

; 使用するページを宣言する
!define MUI_CUSTOMPAGECOMMANDS		; CUSTOMページを使用する
!define MUI_FINISHPAGE			; FINISHページを使用する

; MUI_CUSTOMPAGECOMMANDSを設定したので以下の順番でページを並べる
Page custom SetCustomB			; CUSTOMページ
!insertmacro MUI_PAGECOMMAND_INSTFILES	; INSTFILESページ
!insertmacro MUI_PAGECOMMAND_FINISH	; FINISHページ
!define MUI_FINISHPAGE_NOAUTOCLOSE	; FINISHページに勝手に遷移しない

; 以下のメッセージで作る
!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_INSTALLING_TITLE "設定"
!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_INSTALLING_SUBTITLE "ユーザ環境変数 XYZZYHOME を設定しています。しばらくお待ちください。"
!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_ABORTWARNING "ユーザ環境変数 XYZZYHOME の設定を中止しますか？"  
!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_FINISH_INFO_TEXT "ユーザ環境変数 XYZZYHOME を設定しました。\r\n\r\nウィザードを閉じるには[完了]を押してください。"
!insertmacro MUI_LANGUAGE "Japanese"	; 日本語で作る

; 特定の情報をReserveする
ReserveFile "XyzzyCustomB.ini"
!insertmacro MUI_RESERVEFILE_WELCOMEFINISHPAGE
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

;;; 起動時処理
Function .onInit
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "XyzzyCustomB.ini"
FunctionEnd

;;; インストーラ
Section "XyzzyHome.exe"

  Call SetEnvironment

SectionEnd

