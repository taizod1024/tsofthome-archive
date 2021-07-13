;--------------------------------
; Modern UIのインクルード

  !include "MUI2.nsh"
  !include "Library.nsh"

;--------------------------------
; 一般的な設定

  ; 定数
  !define PRODUCT_GROUP "tsoft"

  !define MUI_PRODUCT "${PRODUCT_NAME} ${PRODUCT_VERSION}"
  
  !define MUI_WELCOMEFINISHPAGE_BITMAP_NOSTRETCH
  !define MUI_UNWELCOMEFINISHPAGE_BITMAP_NOSTRETCH

  !define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\win-install.ico"
  !define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\win-uninstall.ico"

  !define MUI_ABORTWARNING

  ; アプリケーション名
  Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"

  ; インストーラファイル名
  OutFile "${PRODUCT}"

  ; インストールディレクトリ
  InstallDir "$COMMONFILES\${PRODUCT_GROUP}\${PRODUCT_NAME}"

  ; 要求実行レベル
  RequestExecutionLevel admin

  ; ブランド
  BrandingText "${PRODUCT_NAME}"

  ; 各種定数
  !define SUB_KEY "SOFTWARE\Microsoft\Windows\CurrentVersion\SharedDlls"
  !define DLL_PATH "$COMMONFILES\${PRODUCT_GROUP}\${PRODUCT_NAME}\${PRODUCT_NAME}.dll"
  
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

;--------------------------------
; 変数

  Var RegCnt0
  Var RegCnt1
  
;--------------------------------
; インストーラセクション

Section "Install"

  SetOutPath "$INSTDIR"
  File "${PRODUCT_NAME}.dll"
  WriteUninstaller "uninstall.exe"

  ReadRegStr $RegCnt0 HKLM "${SUB_KEY}" "${DLL_PATH}"
  !insertmacro InstallLib REGDLL "" REBOOT_NOTPROTECTED "${PRODUCT_NAME}.dll" "${DLL_PATH}" $TEMP
  ReadRegStr $RegCnt1 HKLM "${SUB_KEY}" "${DLL_PATH}"
  
  DetailPrint "参照カウント: '$RegCnt0' -> '$RegCnt1'"
  
SectionEnd

;--------------------------------
; アンインストーラセクション

Section "Uninstall"

  ReadRegStr $RegCnt0 HKLM "${SUB_KEY}" "${DLL_PATH}"
  !insertmacro UninstallLib REGDLL SHARED REBOOT_NOTPROTECTED "${DLL_PATH}"
  ReadRegStr $RegCnt1 HKLM "${SUB_KEY}" "${DLL_PATH}"

  DetailPrint "参照カウント: '$RegCnt0' -> '$RegCnt1'"

  StrCmp "$RegCnt1" "" DLL_NONE DLL_EXISTS
  DLL_NONE:
    RMDir /r /REBOOTOK "$INSTDIR"
	RmDir "$COMMONFILES\${PRODUCT_GROUP}"
  DLL_EXISTS:

SectionEnd
