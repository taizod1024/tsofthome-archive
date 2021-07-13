;--------------------------------
; Modern UIのインクルード

  !include "MUI2.nsh"
  !include "Library.nsh"

;--------------------------------
; 一般的な設定

  ; 定数
  !define PRODUCT_GROUP "tsoft"
  !define PRODUCT_AUTHOR "YAMAMOTO TAIZO"

  !define PRODUCT_BASE_FILE "tsoft-sfcmini-${PRODUCT_VERSION}.exe"

  !define MUI_PRODUCT "${PRODUCT_NAME} ${PRODUCT_VERSION}"

  !define MUI_WELCOMEFINISHPAGE_BITMAP_NOSTRETCH
  !define MUI_UNWELCOMEFINISHPAGE_BITMAP_NOSTRETCH

  !define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\win-install.ico"
  !define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\win-uninstall.ico"

  !define MUI_ABORTWARNING

  !define ERROR_MESSAGE0 "セットアップを中断しました。"
  !define ERROR_MESSAGE1 "セットアップを中断しました。ファイルのコピーに失敗しました。インストーラの終了後、手動でエラーを解消してください。"

  !define DLL_UNINSTALLER "$COMMONFILES\${PRODUCT_GROUP}\sfcmini\uninstall.exe"
  
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
  Var AlreadyInstalled

;--------------------------------
; インストーラセクション

Section "Install"

  ; アプリケーションの確認
  DetailPrint "### アプリケーションの確認"
  SetOutPath "$TEMP"
  File "..\src\check_object.vbs"
  StrCpy $AppName "Outlook.Application"
  ExecWait 'wscript.exe "$TEMP\check_object.vbs" $AppName' $ReturnCode
  StrCmp $ReturnCode "0" CHKAPP_OK CHKAPP_NG
  CHKAPP_NG:
    DetailPrint "結果: アプリケーションの確認に失敗しました。"
    MessageBox MB_ICONSTOP "セットアップを中断しました。$\r$\nアプリケーションの確認に失敗しました。$\r$\n以下のアプリケーションがインストールされていることを確認してください。$\r$\n$\r$\nアプリケーション: $AppName"
    Abort ${ERROR_MESSAGE0}
  CHKAPP_OK:
  DetailPrint "結果: アプリケーションの確認に成功しました。"

  ; ファイルの展開
  ; ・先に共有ライブラリの登録をしてしまうとFileでエラーが発生
  DetailPrint "### ファイルの展開"
  SetOutPath "$INSTDIR"
  File /r /x .svn "..\src\*.*"
  IfErrors FILECOPY1_NG FILECOPY1_OK
  FILECOPY1_NG:
    MessageBox MB_ICONSTOP ${ERROR_MESSAGE1}
    Abort ${ERROR_MESSAGE0}
  FILECOPY1_OK:

  ; 共有ライブラリの登録
  DetailPrint "### sfcmini.dllの登録"
  ReadRegStr $AlreadyInstalled HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayIcon"
  StrCmp "$AlreadyInstalled" "" REGDLL_BGN0 REGDLL_BGN1
  REGDLL_BGN0:
    SetOutPath "$TEMP"
    File "${PRODUCT_BASE_FILE}"
    ExecWait 'cmd /c "$TEMP\${PRODUCT_BASE_FILE}" /S' $ReturnCode
    DetailPrint "戻り値: '$ReturnCode'"
    StrCmp $ReturnCode "0" REGDLL_OK REGDLL_NG
    REGDLL_NG:
      DetailPrint "結果: 共有ライブラリの登録に失敗しました。"
      MessageBox MB_ICONSTOP "セットアップを中断しました。$\r$\n共有ライブラリの登録に失敗しました。"
      Abort ${ERROR_MESSAGE0}
    REGDLL_OK:
    DetailPrint "結果: 共有ライブラリを登録しました。"
	GoTo REGDLL_END
  REGDLL_BGN1:
    DetailPrint "結果: 共有ライブラリの登録をスキップします。"
	GoTo REGDLL_END
  REGDLL_END:
 
  ; アンインストーラの登録
  DetailPrint "### アンインストーラの登録"
  WriteUninstaller "$INSTDIR\uninstall.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayIcon"	"$INSTDIR\uninstall.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayName"	"${PRODUCT_GROUP} ${PRODUCT_NAME} ${PRODUCT_VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayVersion"	"${PRODUCT_VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "Helplink" "$INSTDIR\readme.txt"
  WriteRegDWORD	HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "NoModify"		1
  WriteRegDWORD	HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "NoRepair"		1
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "Publisher"		"${PRODUCT_GROUP}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "UninstallString"	"$INSTDIR\uninstall.exe"

  ; スタートメニューへの登録
  DetailPrint "### スタートメニューへの登録"
  CreateDirectory       "$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}"
  CreateShortCut        "$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}\アンインストール.lnk"			"$INSTDIR\uninstall.exe"
  CreateShortCut        "$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}\新しい付箋紙.lnk"				"$INSTDIR\${PRODUCT_SYMBOL}.vbs" "/new" "$INSTDIR\image\note-ajouter-icone-6022.ico" 0
  CreateShortCut        "$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}\クリップボードから付箋紙.lnk"	"$INSTDIR\${PRODUCT_SYMBOL}.vbs" "/new /clipboard" "$INSTDIR\image\note-ajouter-icone-6022.ico" 0
  CreateShortCut        "$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}\付箋紙の表示.lnk"				"$INSTDIR\${PRODUCT_SYMBOL}.vbs" ""     "$INSTDIR\image\note-icone-7296.ico" 0
  CreateShortCut        "$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}\Outlookメモの管理.lnk"		"$INSTDIR\${PRODUCT_SYMBOL}.vbs" "/outlook" "$SYSDIR\shell32.dll" 127
  CreateShortCut	    "$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}\はじめにお読みください.lnk"	"$INSTDIR\readme.txt" "" "$SYSDIR\shell32.dll" 70

  ; スタートアップへの登録
  DetailPrint "### スタートアップへの登録"
  CreateShortCut        "$SMSTARTUP\${PRODUCT_NAME}.lnk"	"$INSTDIR\${PRODUCT_SYMBOL}.vbs" "/display"	"$INSTDIR\image\note-icone-7296.ico" 0

  ; デスクトップへの登録
  DetailPrint "### デスクトップへの登録"
  CreateShortCut        "$DESKTOP\新しい付箋紙.lnk"				"$INSTDIR\${PRODUCT_SYMBOL}.vbs" "/new"				"$INSTDIR\image\note-ajouter-icone-6022.ico" 0
  CreateShortCut        "$DESKTOP\クリップボードから付箋紙.lnk"	"$INSTDIR\${PRODUCT_SYMBOL}.vbs" "/new /clipboard"	"$INSTDIR\image\note-ajouter-icone-6022.ico" 0
  CreateShortCut        "$DESKTOP\付箋紙の表示.lnk"				"$INSTDIR\${PRODUCT_SYMBOL}.vbs" ""					"$INSTDIR\image\note-icone-7296.ico" 0

  ; クイック起動への登録
  DetailPrint "### クイック起動への登録"
  CreateShortCut        "$QUICKLAUNCH\新しい付箋紙.lnk"				"$INSTDIR\${PRODUCT_SYMBOL}.vbs" "/new"				"$INSTDIR\image\note-ajouter-icone-6022.ico" 0
  CreateShortCut        "$QUICKLAUNCH\クリップボードから付箋紙.lnk"	"$INSTDIR\${PRODUCT_SYMBOL}.vbs" "/new /clipboard"	"$INSTDIR\image\note-ajouter-icone-6022.ico" 0
  CreateShortCut        "$QUICKLAUNCH\付箋紙の表示.lnk"				"$INSTDIR\${PRODUCT_SYMBOL}.vbs" ""					"$INSTDIR\image\note-icone-7296.ico" 0

SectionEnd

;--------------------------------
; アンインストーラセクション
; ・アンインストーラセクションでは$INSTDIRは、"WriteUninstaller"したディレクトリになることに注意。

Section "Uninstall"

  ; アンインストーラの削除
  DetailPrint "### アンインストーラの削除"
  Delete /REBOOTOK "$INSTDIR\uninstall.exe"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"

  ; スタートメニューからの削除
  DetailPrint "### スタートメニューからの削除"
  RMDir /r "$SMPROGRAMS\${PRODUCT_GROUP}\${PRODUCT_NAME}"
  RMDir "$SMPROGRAMS\${PRODUCT_GROUP}"

  ; スタートアップからの削除
  DetailPrint "### スタートアップからの削除"
  Delete /REBOOTOK "$SMSTARTUP\${PRODUCT_NAME}.lnk"

  ; デスクトップからの削除
  DetailPrint "### デスクトップからの削除"
  Delete /REBOOTOK "$DESKTOP\新しい付箋紙.lnk"
  Delete /REBOOTOK "$DESKTOP\クリップボードから付箋紙.lnk"
  Delete /REBOOTOK "$DESKTOP\付箋紙の表示.lnk"

  ; クイック起動からの削除
  DetailPrint "### デスクトップからの削除"
  Delete /REBOOTOK "$QUICKLAUNCH\新しい付箋紙.lnk"
  Delete /REBOOTOK "$QUICKLAUNCH\クリップボードから付箋紙.lnk"
  Delete /REBOOTOK "$QUICKLAUNCH\付箋紙の表示.lnk"

  ; インストールフォルダの削除
  DetailPrint "### インストールフォルダの削除"
  RMDir /r /REBOOTOK "$INSTDIR"

  ; 共有ライブラリの登録解除
  DetailPrint "### sfcmini.dllの登録解除"
  ExecWait 'cmd /c "${DLL_UNINSTALLER}" /S' $ReturnCode
  DetailPrint "戻り値: '$ReturnCode'"
  StrCmp $ReturnCode "0" UNREG_OK UNREG_NG
  UNREG_NG:
    DetailPrint "結果: 共有ライブラリの登録解除に失敗しました。"
	GoTo UNREG_END
  UNREG_OK:
    DetailPrint "結果: 共有ライブラリを登録解除しました。"
	GoTo UNREG_END
  UNREG_END:

SectionEnd
