;;; -*- Mode: nsi; Package: editor -*-
;;;
;;; XyzzySetup.nsi --- xyzzy 配布パッケージ導入支援

;;; ヘッダ読込み
!include "MUI.nsh"
!include "XyzzySetup.nsh"
!include "XyzzyCustomA.nsh"

; 出力ファイル
OutFile "XyzzySetup.exe"

; デフォルトのインストールディレクトリ
InstallDir "$PROGRAMFILES\${MUI_PRODUCT}"

; インストールディレクトリの格納先レジストリ
InstallDirRegKey HKLM "Software\${MUI_SETUP}" ""

; 詳細表示
ShowInstDetails show			; 詳細を表示する
ShowUninstDetails show			; 詳細を表示する

; STARTMENU用レジストリ設定
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\${MUI_SETUP}" 
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"

; 使用するページを宣言する
!define MUI_CUSTOMPAGECOMMANDS		; CUSTOMページを使用する
!define MUI_WELCOMEPAGE			; WELCOMEページを使用する
!define MUI_DIRECTORYPAGE		; DIRECOTRYページを使用する
!define MUI_STARTMENUPAGE		; STARTMENUページを使用する
!define MUI_FINISHPAGE			; FINISHページを使用する

; MUI_CUSTOMPAGECOMMANDSを設定したので以下の順番でページを並べる
!insertmacro MUI_PAGECOMMAND_WELCOME	; WELCOMEページ
!insertmacro MUI_PAGECOMMAND_DIRECTORY	; DIRECOTRYページ
!insertmacro MUI_PAGECOMMAND_STARTMENU	; STARTMENUページ
Page custom SetCustomA			; CUSTOMページ
!insertmacro MUI_PAGECOMMAND_INSTFILES	; INSTFILESページ
!insertmacro MUI_PAGECOMMAND_FINISH	; FINISHページ

; 以下のオプションで作る
!define MUI_UNINSTALLER			; アンインストーラを作る
!define MUI_UNCONFIRMPAGE		; アンインストーラでは確認する
!define MUI_STARTMENUPAGE_NODISABLE	; ショートカットの作成は抑止できない
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\html\00README.html"
!define MUI_FINISHPAGE_NOAUTOCLOSE	; FINISHページに勝手に遷移しない
!define MUI_FINISHPAGE_RUN "$INSTDIR\XyzzySetup\XyzzyHome.exe"

; 以下のメッセージで作る
!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_WELCOME_INFO_TEXT "このウィザードは、${MUI_PRODUCT} のインストールをガイドしていきます。\r\n\r\n!!! 注意1 !!!\r\n${MUI_PRODUCT} は ${MUI_PRODUCT_AUTHOR} によって作成されたテキストエディタです。\r\n${MUI_SETUP} は ${MUI_PRODUCT} の導入の簡易化を目指して、${MUI_SETUP_AUTHOR} が作成したものです。従って ${MUI_SETUP} に関する質問及び要望は、下記メールアドレスから ${MUI_SETUP_AUTHOR} まで連絡してください。決して ${MUI_PRODUCT_AUTHOR} に連絡してはいけません。\r\n\r\n　　cbf95600@pop02.odn.ne.jp\r\n\r\n!!! 注意2 !!!\r\n${MUI_PRODUCT} 配布パッケージの展開のためにUNLHA32.DLLを使用しています。UNLHA32.DLLをインストールしてください。\r\n\r\n"
!insertmacro MUI_LANGUAGEFILE_STRING MUI_INNERTEXT_DIRECTORY_TOP "${MUI_PRODUCT} を以下のフォルダにインストールします。${MUI_SETUP} はサブフォルダにインストールされます。$\r$\n$\r$\n異なったフォルダにインストールするには、[参照]を押して、別のフォルダを選択してください。"
!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_FINISH_RUN "ユーザ環境変数 XYZZYHOME を設定する"
!insertmacro MUI_LANGUAGE "Japanese"	; 日本語で作る

; Reserveする
ReserveFile "XyzzyCustomA.ini"
!insertmacro MUI_RESERVEFILE_WELCOMEFINISHPAGE
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

;;; ------------------------------------------------
;;; インストーラ
;;; ------------------------------------------------

;;; 起動時処理
Function .onInit
  ReadRegStr $R0 HKLM "Software\${MUI_SETUP}" ""
  StrCmp $R0 "" +4
    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION "${MUI_PRODUCT} のインストール情報が存在します。$\r$\n${MUI_PRODUCT} 配布パッケージの更新の場合には、XyzzyUpdate で行ってください。$\r$\nそれでも続行しますか？" IDOK +3
      MessageBox MB_OK|MB_ICONSTOP "インストールを中止しました。"
      Quit
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "XyzzyCustomA.ini"
FunctionEnd

;;; インストーラ
Section "XyzzySetup.exe"

  ; このセクションのサイズ
  AddSize 8000

  ; 配布パッケージのインストール
  Call InstallPackage

  ; XyzzyUpdateの追加
  SetOutPath "$INSTDIR\XyzzySetup"
  File "XyzzyHome.exe"
  File "XyzzyUpdate.exe"

  ; 取り敢えずモジュールを落としたので書き込み
  WriteRegStr HKLM "Software\${MUI_SETUP}" "" $INSTDIR

  ; スタートメニュー追加
  SetOutPath "$INSTDIR"
  !insertmacro MUI_STARTMENU_WRITE_BEGIN
    CreateDirectory	"$SMPROGRAMS\${MUI_STARTMENUPAGE_VARIABLE}"
    CreateShortCut	"$SMPROGRAMS\${MUI_STARTMENUPAGE_VARIABLE}\README.lnk" "$INSTDIR\html\00README.html"
    CreateShortCut	"$SMPROGRAMS\${MUI_STARTMENUPAGE_VARIABLE}\xyzzy.lnk" "$INSTDIR\xyzzy.exe"
    CreateShortCut	"$SMPROGRAMS\${MUI_STARTMENUPAGE_VARIABLE}\xyzzycli.lnk" "$INSTDIR\xyzzycli.exe"
    CreateDirectory	"$SMPROGRAMS\${MUI_STARTMENUPAGE_VARIABLE}\XyzzySetup"
    CreateShortCut	"$SMPROGRAMS\${MUI_STARTMENUPAGE_VARIABLE}\xyzzySetup\xyzzy -q.lnk" "$INSTDIR\xyzzy.exe" "-q"
    CreateShortCut	"$SMPROGRAMS\${MUI_STARTMENUPAGE_VARIABLE}\XyzzySetup\XyzzyHome.lnk" "$INSTDIR\XyzzySetup\XyzzyHome.exe"
    CreateShortCut	"$SMPROGRAMS\${MUI_STARTMENUPAGE_VARIABLE}\XyzzySetup\XyzzyUpdate.lnk" "$INSTDIR\XyzzySetup\XyzzyUpdate.exe"
    CreateShortCut	"$SMPROGRAMS\${MUI_STARTMENUPAGE_VARIABLE}\XyzzySetup\XyzzyUninstall.lnk" "$INSTDIR\XyzzySetup\XyzzyUninstall.exe"
  !insertmacro MUI_STARTMENU_WRITE_END

  ; アンインストーラ追加
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_SETUP}" "DisplayName" "${MUI_SETUP}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_SETUP}" "UninstallString" '"$INSTDIR\XyzzySetup\XyzzyUninstall.exe"'
  CreateDirectory "$INSTDIR\XyzzySetup"
  WriteUninstaller "$INSTDIR\XyzzySetup\XyzzyUninstall.exe"

SectionEnd

;;; ------------------------------------------------
;;; アンインストーラ
;;; ------------------------------------------------

;;; 起動時処理
Function un.onInit
  ReadRegStr $INSTDIR HKLM "Software\${MUI_SETUP}" ""
  StrCmp $INSTDIR "" 0 +3
    MessageBox MB_OK|MB_ICONSTOP "${MUI_PRODUCT} のインストール情報が見つかりません。$\r$\n${MUI_PRODUCT} のアンインストールを中止します。"
    Quit
FunctionEnd

;;; アンインストーラ
Section "Uninstall"

  ; .xyzzy と siteinit.l の存在チェック
  IfFileExists "$INSTDIR\.xyzzy" confirm
  IfFileExists "$INSTDIR\site-lisp\siteinit.l" confirm
  Goto fileok
  confirm:
  MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION ".xyzzy または siteinit.l が存在します。削除してもよろしいですか？" IDOK fileok
    MessageBox MB_OK|MB_ICONSTOP "アンインストールを中止しました。"
    Quit
  fileok:

  ; アンインストーラ削除
  Delete "$INSTDIR\XyzzySetup\XyzzyUninstall.exe"
  Delete "$INSTDIR\XyzzySetup\XyzzyUpdate.exe"
  Delete "$INSTDIR\XyzzySetup\XyzzyHome.exe"

  ; スタートメニュー削除
  ReadRegStr $R0 "${MUI_STARTMENUPAGE_REGISTRY_ROOT}" "${MUI_STARTMENUPAGE_REGISTRY_KEY}" "${MUI_STARTMENUPAGE_REGISTRY_VALUENAME}"
  StrCmp $R0 "" noshortcuts
    Delete "$SMPROGRAMS\$R0\XyzzySetup\XyzzyUninstall.lnk"
    Delete "$SMPROGRAMS\$R0\XyzzySetup\XyzzyUpdate.lnk"
    Delete "$SMPROGRAMS\$R0\XyzzySetup\XyzzyHome.lnk"
    Delete "$SMPROGRAMS\$R0\xyzzySetup\xyzzy -q.lnk"
    Delete "$SMPROGRAMS\$R0\XyzzySetup"
    RMDir "$SMPROGRAMS\$R0\XyzzySetup"
    Delete "$SMPROGRAMS\$R0\xyzzycli.lnk"
    Delete "$SMPROGRAMS\$R0\xyzzy.lnk"
    Delete "$SMPROGRAMS\$R0\README.lnk"
    RMDir "$SMPROGRAMS\$R0"
  noshortcuts:

  ; インストールディレクトリ削除
  RMDir /r $INSTDIR

  ; レジストリ削除
  DeleteRegKey /ifempty HKLM "Software\${MUI_SETUP}"
  DeleteRegKey /ifempty HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_SETUP}"

  !insertmacro MUI_UNFINISHHEADER

SectionEnd

