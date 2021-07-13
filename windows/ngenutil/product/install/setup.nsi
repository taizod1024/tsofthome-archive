;--------------------------------
; Modern UIのインクルード

  !include "MUI2.nsh"

;--------------------------------
; 一般的な設定

  ; 定数
  ; - 全角の「チ」がmakeでエラーになるためシンボルを再定義している。
  !undef PRODUCT_NAME
  !define PRODUCT_NAME "Ngenユーティリティ"

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

  !define ERROR_MESSAGE0 "セットアップを中断しました。"
  !define ERROR_MESSAGE1 "セットアップを中断しました。ファイルのコピーに失敗しました。インストーラの終了後、手動でエラーを解消してください。"

  ; アプリケーション名
  Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"

  ; インストーラファイル名
  OutFile "${PRODUCT}"

  ; インストールディレクトリ
  InstallDir "$LOCALAPPDATA\${PRODUCT_GROUP}\${PRODUCT_NAME}"

  ; 要求実行レベル
  RequestExecutionLevel admin

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
  !define MUI_FINISHPAGE_RUN "$INSTDIR\ngenutil.exe"
  !define MUI_FINISHPAGE_RUN_PARAMETERS "$\"$INSTDIR\ngenutil.exe$\""
  !define MUI_FINISHPAGE_RUN_TEXT "Ngenユーティリティのネイティブイメージを生成する。"

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

  ;;; Var ReturnCode

;--------------------------------
; インストーラセクション

Section "Install"

  ; ファイルの展開
  DetailPrint "### ファイルの展開"
  SetOutPath "$INSTDIR"
  File /r /x .svn "..\src\readme.txt"
  File /r /x .svn "..\src\ngenutil\ngenutil\bin\Release\ngenutil.exe"
  IfErrors FILECOPY1_NG FILECOPY1_OK
  FILECOPY1_NG:
    MessageBox MB_ICONSTOP ${ERROR_MESSAGE1}
    Abort ${ERROR_MESSAGE0}
  FILECOPY1_OK:

  ; エクスプローラの動作の登録
  WriteRegStr HKCU "Software\Classes\Directory\shell\${PRODUCT_NAME}" "" "${PRODUCT_NAME}(&G) ..."
  WriteRegStr HKCU "Software\Classes\Directory\shell\${PRODUCT_NAME}\command" "" "$INSTDIR\ngenutil.exe %1"
  WriteRegStr HKCU "Software\Classes\Directory\Background\shell\${PRODUCT_NAME}" "" "${PRODUCT_NAME}(&G) ..."
  WriteRegStr HKCU "Software\Classes\Directory\Background\shell\${PRODUCT_NAME}\command" "" "$INSTDIR\ngenutil.exe %V"

  ; エクスプローラの[送る]の登録
  CreateShortCut "$SENDTO\${PRODUCT_NAME}.lnk" "$INSTDIR\ngenutil.exe"
 
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
  Delete /REBOOTOK "$INSTDIR\ngenutil.exe"

  ; エクスプローラの動作の削除
  DeleteRegKey HKCU "Software\Classes\Directory\shell\${PRODUCT_NAME}"
  DeleteRegKey HKCU "Software\Classes\Directory\Background\shell\${PRODUCT_NAME}"

  ; エクスプローラの[送る]の削除
  Delete /REBOOTOK "$SENDTO\${PRODUCT_NAME}.lnk"
 
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
