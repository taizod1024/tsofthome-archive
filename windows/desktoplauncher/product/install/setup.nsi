;--------------------------------
; Modern UIのインクルード

  !include "MUI2.nsh"

;--------------------------------
; 一般的な設定

  ; 定数
  ; - 全角の「チ」がmakeでエラーになるためシンボルを再定義している。
  !undef PRODUCT_NAME
  !define PRODUCT_NAME "デスクトップランチャ"

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

;--------------------------------
; インストーラセクション

Section "Install"

  ; ファイルの展開
  DetailPrint "### ファイルの展開"
  SetOutPath "$INSTDIR"
  File /r /x .svn "..\src\readme.txt"
  File /r /x .svn "..\src\desktoplauncher\desktoplauncher\bin\Release\desktoplauncher.exe"
  IfErrors FILECOPY1_NG FILECOPY1_OK
  FILECOPY1_NG:
    MessageBox MB_ICONSTOP ${ERROR_MESSAGE1}
    Abort ${ERROR_MESSAGE0}
  FILECOPY1_OK:

  ; ネイティブイメージの作成
  ExecWait '"$WINDIR\Microsoft.NET\Framework\v4.0.30319\ngen.exe" install "$INSTDIR\desktoplauncher.exe" /silent' $ReturnCode
  StrCmp $ReturnCode "0" NGEN_OK NGEN_NG
  NGEN_NG:
    DetailPrint "結果: Ngen.exeの実行が異常終了しました。($ReturnCode)"
    DetailPrint "結果: ネイティブイメージは作成されませんでした。"
    goto NGEN_END
  NGEN_OK:
    DetailPrint "結果: Ngen.exeの実行が正常終了しました。($ReturnCode)"
    DetailPrint "結果: ネイティブイメージを作成しました。"
    goto NGEN_END
  NGEN_END:

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
  CreateShortCut	"$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}\デスクトップランチャ.lnk" "$INSTDIR\desktoplauncher.exe"
  CreateShortCut	"$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}\エクスプローラの再起動.lnk" "$INSTDIR\desktoplauncher.exe" "/explorer"
  CreateShortCut	"$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}\アンインストール.lnk" "$INSTDIR\uninstall.exe"
  CreateShortCut	"$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}\はじめにお読みください.lnk" "$INSTDIR\readme.txt" "" "$SYSDIR\shell32.dll" 70

  ; デスクトップへの登録
  DetailPrint "### デスクトップへの登録"
  CreateShortCut	"$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\desktoplauncher.exe"

SectionEnd

;--------------------------------
; アンインストーラセクション
; ・アンインストーラセクションでは$INSTDIRは、"WriteUninstaller"したディレクトリになることに注意。

Section "Uninstall"

  ; ファイルの削除
  DetailPrint "### ファイルの削除"
  Delete /REBOOTOK "$INSTDIR\readme.txt"
  Delete /REBOOTOK "$INSTDIR\desktoplauncher.exe"

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
