;--------------------------------
; Modern UIのインクルード

  !include "MUI2.nsh"
  !include "EnvVarUpdate.nsh"

;--------------------------------
; 一般的な設定

  ; 定数
  ; - 全角の「チ」がmakeでエラーになるためシンボルを再定義している。
  !undef PRODUCT_NAME
  !define PRODUCT_NAME "バッチファイルユーティリティ"

  ; 定数
  !define PRODUCT_GROUP "tsoft"
  !define PRODUCT_AUTHOR "YAMAMOTO TAIZO"

  !define MUI_PRODUCT "${PRODUCT_NAME} ${PRODUCT_VERSION}"

  !define MUI_WELCOMEFINISHPAGE_BITMAP_NOSTRETCH
  !define MUI_UNWELCOMEFINISHPAGE_BITMAP_NOSTRETCH

  !define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\win-install.ico"
  !define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\win-uninstall.ico"

  !define MUI_UNINSTALLER
  !define MUI_UNCONFIRMPAGE

  !define MUI_ABORTWARNING

  ; アプリケーション名
  Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"

  ; インストーラファイル名
  OutFile "${PRODUCT}"

  ; インストールディレクトリ
  InstallDir "$LOCALAPPDATA\${PRODUCT_GROUP}\${PRODUCT_NAME}"

  ; 要求実行レベル
  RequestExecutionLevel user

  ; ブランド
  BrandingText "${PRODUCT_NAME} ${PRODUCT_VERSION}"

  ; スタートメニュー用の設定
  !define MUI_STARTMENUPAGE_DEFAULTFOLDER "${PRODUCT_GROUP}"

  ; スタートメニュー用の設定
  SetFont "MS UI Gothic" 9

;--------------------------------
; ページ

  !define MUI_WELCOMEPAGE_TEXT "$_CLICK"
  !define MUI_FINISHPAGE_TEXT "ウィザードを閉じるには[完了]を押してください。"
  !define MUI_FINISHPAGE_NOAUTOCLOSE

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !define MUI_WELCOMEPAGE_TEXT "$_CLICK"
  !define MUI_FINISHPAGE_TEXT "ウィザードを閉じるには[完了]を押してください。"
  !define MUI_UNFINISHPAGE_NOAUTOCLOSE

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

;--------------------------------
; 日本語

  !insertmacro MUI_LANGUAGE "Japanese"

  VIAddVersionKey /LANG=${LANG_JAPANESE} "ProductName" "${PRODUCT_GROUP} ${PRODUCT_NAME}"
  VIAddVersionKey /LANG=${LANG_JAPANESE} "Comments" ""
  VIAddVersionKey /LANG=${LANG_JAPANESE} "CompanyName" ""
  VIAddVersionKey /LANG=${LANG_JAPANESE} "LegalTrademarks" ""
  VIAddVersionKey /LANG=${LANG_JAPANESE} "LegalCopyright" "${PRODUCT_AUTHOR}"
  VIAddVersionKey /LANG=${LANG_JAPANESE} "FileDescription" "${PRODUCT_GROUP} ${PRODUCT_NAME}"
  VIAddVersionKey /LANG=${LANG_JAPANESE} "FileVersion" "${PRODUCT_VERSION}"
  VIProductVersion "${PRODUCT_VERSION}"

;--------------------------------
; 変数

;--------------------------------
; インストーラセクション

Section "Install"

  ; ファイルの展開
  DetailPrint "### ファイルの展開"
  SetOutPath "$INSTDIR"
  File /r /x .svn "..\doc\readme.txt"

  SetOutPath "$INSTDIR\sh"
  File /r /x .svn "..\src\t@sk.cmd"

  ; インストールディレクトリの短い名前を取得
  GetFullPathName /SHORT $0 $INSTDIR\sh

  ; エクスプローラの動作の登録
  DetailPrint "### エクスプローラの動作の登録"
  WriteRegStr HKCU "Software\Classes\.t@sk\shell\${PRODUCT_NAME}" "" "タスクを実行する(&T)"
  WriteRegStr HKCU "Software\Classes\.t@sk\shell\${PRODUCT_NAME}\command" "" 'cmd.exe /C $0\t@sk.cmd /p /f "%1" %*'

  ; 環境変数PATHへの登録
  DetailPrint "### 環境変数PATHへの追加"
  ${EnvVarUpdate} $1 "PATH" "A" "HKCU" $0

  ; アンインストーラの登録
  DetailPrint "### アンインストーラの登録"
  WriteUninstaller "$INSTDIR\uninstall.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayIcon" "$INSTDIR\uninstall.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayName" "${PRODUCT_GROUP} ${PRODUCT_NAME} ${PRODUCT_VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "Helplink" "$INSTDIR\readme.txt"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "NoModify" 1
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "NoRepair" 1
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "Publisher" "${PRODUCT_GROUP}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "UninstallString" "$INSTDIR\uninstall.exe"

  ; スタートメニューへの登録
  DetailPrint "### スタートメニューへの登録"
  CreateDirectory "$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}\インストールフォルダ.lnk" "$INSTDIR"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}\アンインストール.lnk" "$INSTDIR\uninstall.exe"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}\はじめにお読みください.lnk" "$INSTDIR\readme.txt" "" "$SYSDIR\shell32.dll" 70

SectionEnd

;--------------------------------
; アンインストーラセクション
; ・アンインストーラセクションでは$INSTDIRは、"WriteUninstaller"したディレクトリになることに注意。

Section "Uninstall"

  ; ファイルの削除
  DetailPrint "### ファイルの削除"
  Delete /REBOOTOK "$INSTDIR\readme.txt"
  Delete /REBOOTOK "$INSTDIR\sh\t@sk.cmd"

  ; エクスプローラの動作の削除
  DetailPrint "### エクスプローラの動作の削除"
  DeleteRegKey HKCU "Software\Classes\.t@sk\shell\${PRODUCT_NAME}"

  ; インストールディレクトリの短い名前を取得
  GetFullPathName /SHORT $0 $INSTDIR\sh

  ; 環境変数PATHからの削除
  DetailPrint "### 環境変数PATHからの削除"
  ${un.EnvVarUpdate} $1 "PATH" "R" "HKCU" $0

  ; アンインストーラの削除
  DetailPrint "### アンインストーラの削除"
  Delete /REBOOTOK "$INSTDIR\uninstall.exe"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"

  ; スタートメニューからの削除
  DetailPrint "### スタートメニューからの削除"
  RMDir /r "$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}"
  RMDir "$SMPROGRAMS\${PRODUCT_GROUP}"

  ; デスクトップからの削除
  DetailPrint "### デスクトップからの削除"
  Delete /REBOOTOK "$DESKTOP\${PRODUCT_NAME}.lnk"

  ; インストールフォルダの削除
  DetailPrint "### インストールフォルダの削除"
  RMDir /r /REBOOTOK "$INSTDIR"
  
SectionEnd
