;;; -*- Mode: nsi; Package: editor -*-
;;;
;;; XyzzyCustomB.nsh --- CustomB用ヘッダ

;;; CUSTOMBページ用処理
!insertmacro MUI_LANGUAGEFILE_STRING TEXT_CUSTOMB_TITLE "XYZZYHOME を指定してください。"
!insertmacro MUI_LANGUAGEFILE_STRING TEXT_CUSTOMB_SUBTITLE "ユーザ環境変数 XYZZYHOME を、存在するディレクトリから選択します。"

Function SetCustomB
  ReadRegStr $R0 HKCU "Environment" "XYZZYHOME"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "XyzzyCustomB.ini" "Field 3" "State" $R0
  !insertmacro MUI_HEADER_TEXT "${TEXT_CUSTOMB_TITLE}" "${TEXT_CUSTOMB_SUBTITLE}"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "XyzzyCustomB.ini"
FunctionEnd

Function SetEnvironment
  !insertmacro MUI_INSTALLOPTIONS_READ $R0 "XyzzyCustomB.ini" "Field 3" "State"
  StrCmp $R0 "" +4
    WriteRegStr HKCU "Environment" "XYZZYHOME" $R0
    DetailPrint "ユーザ環境変数設定：XYZZYHOME"
    Goto +3
    DeleteRegValue HKCU "Environment" "XYZZYHOME"
    DetailPrint "ユーザ環境変数削除：XYZZYHOME"
FunctionEnd

