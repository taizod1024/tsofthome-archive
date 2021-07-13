;--------------------------------
; Modern UIのインクルード

  !include "MUI2.nsh"

;--------------------------------
; 一般的な設定

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
  !define ERROR_MESSAGE2 "セットアップを中断しました。インストールは成功しましたが、アドインの有効化に失敗しました。インストーラの終了後、手動でアドインを有効にしてください。"
  !define ERROR_MESSAGE3 "アドインの無効化に失敗しましたが、アンインストールは継続します。アンインストーラの終了後、手動でアドインを無効にしてください。"

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

  Var ReturnCode
  Var AppName

;--------------------------------
; インストーラセクション

Section "Install"

  ; アプリケーションの確認
  DetailPrint "### アプリケーションの確認"
  SetOutPath "$TEMP"
  File "..\src\check_object12.vbs"
  StrCpy $AppName "Excel.Application"
  ExecWait 'wscript.exe "$TEMP\check_object12.vbs" $AppName' $ReturnCode
  StrCmp $ReturnCode "0" CHKAPP_OK CHKAPP_NG
  CHKAPP_NG:
    DetailPrint "結果: アプリケーションの確認に失敗しました。"
    MessageBox MB_ICONSTOP "セットアップを中断しました。$\r$\nアプリケーションの確認に失敗しました。$\r$\n以下のアプリケーションがインストールされていることを確認してください。$\r$\n$\r$\nアプリケーション: $AppName"
    Abort ${ERROR_MESSAGE0}
  CHKAPP_OK:
  DetailPrint "結果: アプリケーションの確認に成功しました。"

  ; ファイルの展開
  DetailPrint "### ファイルの展開"
  SetOutPath "$INSTDIR"
  File /r /x .svn "..\src\*.*"
  IfErrors FILECOPY1_NG FILECOPY1_OK
  FILECOPY1_NG:
    MessageBox MB_ICONSTOP ${ERROR_MESSAGE1}
    Abort ${ERROR_MESSAGE0}
  FILECOPY1_OK:

  ; アドインファイルのコピー
  DetailPrint "### アドインファイルのコピー"
  CopyFiles "$INSTDIR\${PRODUCT_SYMBOL}.xlam" "$APPDATA\Microsoft\AddIns\"
  IfErrors FILECOPY2_NG FILECOPY2_OK
  FILECOPY2_NG:
    MessageBox MB_ICONSTOP ${ERROR_MESSAGE1}
    Abort ${ERROR_MESSAGE0}
  FILECOPY2_OK:

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
  CreateDirectory	"$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}"
  CreateShortCut	"$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}\アンインストール.lnk" "$INSTDIR\uninstall.exe"
  CreateShortCut	"$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}\はじめにお読みください.lnk" "$INSTDIR\readme.txt" "" "$SYSDIR\shell32.dll" 70

  ; アドインの有効化
  DetailPrint "### アドインの有効化"
  ExecWait 'wscript.exe "$INSTDIR\addin_enable12.vbs" ${PRODUCT_SYMBOL} /i' $ReturnCode
  strcmp $ReturnCode "0" ADDINENABLE_OK ADDINENABLE_NG
  ADDINENABLE_OK:
    DetailPrint "結果: アドインを有効化しました。"
    goto ADDINENABLE
  ADDINENABLE_NG:
    DetailPrint "結果: アドインの有効化に失敗しました。"
    MessageBox MB_ICONINFORMATION ${ERROR_MESSAGE2}
  ADDINENABLE:

SectionEnd

;--------------------------------
; アンインストーラセクション
; ・アンインストーラセクションでは$INSTDIRは、"WriteUninstaller"したディレクトリになることに注意。

Section "Uninstall"

  ; アドインの無効化
  DetailPrint "### アドインの無効化"
  ExecWait 'wscript.exe "$INSTDIR\addin_disable.vbs" ${PRODUCT_SYMBOL} /i' $ReturnCode
  strcmp $ReturnCode "0" ADDINDISABLE_OK ADDINDISABLE_NG
  ADDINDISABLE_OK:
    DetailPrint "結果: アドインを無効化しました。"
    goto ADDINDISABLE
  ADDINDISABLE_NG:
    DetailPrint "結果: アドインの無効化に失敗しました。"
    MessageBox MB_ICONINFORMATION ${ERROR_MESSAGE3}
    DetailPrint "注意: アンインストールを継続します。"
    goto ADDINDISABLE
  ADDINDISABLE:

  ; ファイルの削除
  DetailPrint "### ファイルの削除"
  Delete /REBOOTOK "$INSTDIR\readme.txt"
  Delete /REBOOTOK "$INSTDIR\addin_disable.vbs"
  Delete /REBOOTOK "$INSTDIR\addin_enable12.vbs"
  Delete /REBOOTOK "$INSTDIR\${PRODUCT_SYMBOL}.xlam"

  ; アドインファイルの削除
  DetailPrint "### アドインファイルの削除"
  Delete /REBOOTOK "$APPDATA\Microsoft\AddIns\${PRODUCT_SYMBOL}.xlam"
  
  ; アンインストーラの削除
  DetailPrint "### アンインストーラの削除"
  Delete /REBOOTOK "$INSTDIR\uninstall.exe"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"

  ; スタートメニューの削除
  DetailPrint "### スタートメニューの削除"
  RMDir /r "$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}"
  RMDir "$SMPROGRAMS\${PRODUCT_GROUP}"

  ; インストールフォルダの削除
  DetailPrint "### インストールフォルダの削除"
  RMDir /r /REBOOTOK "$INSTDIR"
  
SectionEnd
