;--------------------------------
; Modern UIのインクルード

    !include "MUI2.nsh"
    !include "FileFunc.nsh"
    !include "InstallOptions.nsh"
    !include "WinMessages.nsh"

    ;;; MoveFileFolder.nsh
    !insertmacro Locate
    Var /GLOBAL switch_overwrite
    !include "MoveFileFolder.nsh"

;--------------------------------
; 一般的な設定

    ;;; 定数
    !undef PRODUCT_NAME
    !define PRODUCT_NAME "Dropboxリンクユーティリティ"

    !define PRODUCT_GROUP "tsoft"
    !define PRODUCT_AUTHOR "YAMAMOTO TAIZO"

    !define MUI_PRODUCT "${PRODUCT_NAME} ${PRODUCT_VERSION}"
    !define MUI_ABORTWARNING

    !define MESSAGE_ABORT                 "処理を中断しました。"
    !define ERROR_MESSAGE_NODROPBOXDB     "処理を中断しました。$\r$\n$\r$\nDropboxデータベースが見つかりません。$\r$\nDropboxがインストールされていることを確認してください。$\r$\nDropboxインストール後に設定が行われていることを確認してください。"
    !define ERROR_MESSAGE_NODROPBOXPATH   "処理を中断しました。$\r$\n$\r$\nDropboxフォルダが存在しません。$\r$\n環境を確認してください。"
    !define ERROR_MESSAGE_EXECJUNC        "処理を中断しました。$\r$\n$\r$\njunction.exeの実行に失敗しました。$\r$\n環境を確認してください"
    !define ERROR_MESSAGE_NOLINKPATH      "処理を中断しました。$\r$\n$\r$\nDropboxフォルダのリンク先が存在しません。$\r$\nリンク先フォルダが削除された可能性があります。$\r$\n環境を確認してください。"
    !define ERROR_MESSAGE_DROPBOXKILL     "処理を中断しました。$\r$\n$\r$\nDropboxを停止できません。$\r$\nDropboxの実行状態を確認してください。"
    !define ERROR_MESSAGE_BACKUPFAILED    "処理を中断しました。$\r$\n$\r$\nバックアップを作成できません。$\r$\nバックアップフォルダを確認してください。"
    !define ERROR_MESSAGE_MOVEFAILED      "処理を中断しました。$\r$\n$\r$\nフォルダを移動できません。$\r$\nバックアップフォルダを元に戻してください。"
    !define ERROR_MESSAGE_LINKFAILED      "処理を中断しました。$\r$\n$\r$\nリンクを設定できません。$\r$\nバックアップフォルダを元に戻してください。"
    !define ERROR_MESSAGE_UNLINKFAILED    "処理を中断しました。$\r$\n$\r$\nリンクを解除できません。$\r$\nリンク先フォルダを確認してください。"
    !define ERROR_MESSAGE_ATTRFAILED      "処理を中断しました。$\r$\n$\r$\nシステム属性を変更できません。$\r$\nリンク先フォルダを確認してください。"
	
    ;;; アイコン
    !define MUI_ICON "dropbox.ico"

    ;;; アプリケーション名
    Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"

    ;;; インストーラファイル名
    OutFile "${PRODUCT}"

    ;;; 要求実行レベル
    RequestExecutionLevel user

    ;;; ブランド
    BrandingText "${PRODUCT_NAME} ${PRODUCT_VERSION}"

;--------------------------------
; ページ

    !define MUI_WELCOMEFINISHPAGE_BITMAP "finish.bmp"
    !define MUI_WELCOMEFINISHPAGE_BITMAP_NOSTRETCH

    !define MUI_FINISHPAGE_NOAUTOCLOSE
    !define MUI_FINISHPAGE_TITLE "${PRODUCT_NAME}が完了しました。"
    !define MUI_FINISHPAGE_TEXT "Dropboxフォルダおよびリンク先フォルダを確認して、$\r$\n処理が正常に行われていることを確認してください。$\r$\n確認してから[バックアップを削除する]をチェックをしてください。"
    !define MUI_FINISHPAGE_RUN
    !define MUI_FINISHPAGE_RUN_TEXT "バックアップを削除する ..."
    !define MUI_FINISHPAGE_RUN_FUNCTION FinishPageOut

    Page custom CustomPageIn1 CustomPageOut1
    Page custom CustomPageIn2 CustomPageOut2
    !insertmacro MUI_PAGE_INSTFILES
    !insertmacro MUI_PAGE_FINISH

    ReserveFile "dropboxlink_register1.ini"
    ReserveFile "dropboxlink_register2.ini"
    ReserveFile "dropboxlink_unregister1.ini"
    ReserveFile "dropboxlink_unregister2.ini"

;--------------------------------
; 日本語

    !insertmacro MUI_LANGUAGE "Japanese_dropboxlink"

    VIAddVersionKey /LANG=${LANG_JAPANESE_DROPBOXLINK} "ProductName" "${PRODUCT_GROUP} ${PRODUCT_NAME}"
    VIAddVersionKey /LANG=${LANG_JAPANESE_DROPBOXLINK} "Comments" ""
    VIAddVersionKey /LANG=${LANG_JAPANESE_DROPBOXLINK} "CompanyName" ""
    VIAddVersionKey /LANG=${LANG_JAPANESE_DROPBOXLINK} "LegalTrademarks" ""
    VIAddVersionKey /LANG=${LANG_JAPANESE_DROPBOXLINK} "LegalCopyright" "${PRODUCT_AUTHOR}"
    VIAddVersionKey /LANG=${LANG_JAPANESE_DROPBOXLINK} "FileDescription" "${PRODUCT_GROUP} ${PRODUCT_NAME}"
    VIAddVersionKey /LANG=${LANG_JAPANESE_DROPBOXLINK} "FileVersion" "${PRODUCT_VERSION}"
    VIProductVersion "${PRODUCT_VERSION}"

;--------------------------------
; 変数

    !define BAK_SUFFIX ".bak"

    Var DropboxDBPath
    Var DropboxPath
    Var LinkPath
    Var BackupPath
    Var ModeAction

;--------------------------------
; ページセクション

Function .onInit

    ;;; MoveFileFolder.nsh
    StrCpy $switch_overwrite 0

    ;;; カスタムページの展開
    InitPluginsDir
    File /oname=$PLUGINSDIR\dropboxlink_register1.ini "dropboxlink_register1.ini"
    File /oname=$PLUGINSDIR\dropboxlink_register2.ini "dropboxlink_register2.ini"
    File /oname=$PLUGINSDIR\dropboxlink_unregister1.ini "dropboxlink_unregister1.ini"
    File /oname=$PLUGINSDIR\dropboxlink_unregister2.ini "dropboxlink_unregister2.ini"

    ;;; Dropboxデータベースの読み込み
    StrCpy $DropboxDBPath "$APPDATA\Dropbox\host.db"
    IfFileExists "$DropboxDBPath" DROPBOXDB_OK DROPBOXDB_NG
      DROPBOXDB_NG:
        MessageBox MB_ICONEXCLAMATION "${ERROR_MESSAGE_NODROPBOXDB}$\r$\nDropboxデータベース： $DropboxDBPath"
        Abort "${MESSAGE_ABORT}"
      DROPBOXDB_OK:

    FileOpen $0 "$DropboxDBPath" r
    FileRead $0 $1
    FileRead $0 $1
    FileClose $0

    ;;; Dropboxフォルダのデコード
    FileOpen $0 "$TEMP\dropboxlink.decb64.txt" w
    FileWrite $0 $1
    FileClose $0
    nsExec::Exec 'decb64.exe $TEMP\dropboxlink.decb64.txt'
    pop $R0
    FileOpen $0 "$TEMP\dropboxlink.decb64.txt.out" r
    FileRead $0 $2
    FileClose $0

    ; RELEASE StrCpy $DropboxPath "$2"
    ; DEBUG StrCpy $DropboxPath "$Documents\dropboxz"
    StrCpy $DropboxPath "$2"

    ;;; Dropboxフォルダの存在チェック
    IfFileExists "$DropboxPath\*.*" DROPBOXPATH_OK DROPBOXPATH_NG
      DROPBOXPATH_NG:
        MessageBox MB_ICONSTOP "${ERROR_MESSAGE_NODROPBOXPATH}$\r$\nDropboxフォルダ： $DropboxPath"
        Abort "${MESSAGE_ABORT}"
      DROPBOXPATH_OK:

    ;;; Dropboxフォルダのリンクの有無チェック
    nsExec::Exec 'cmd.exe /c if 1==1 junction\junction.exe "$DropboxPath" > $TEMP\dropboxlink.junction.txt'
    Pop $R0
    StrCmp $R0 "0" EXECJUNC_OK EXECJUNC_NG
      EXECJUNC_NG:
        MessageBox MB_ICONSTOP "${ERROR_MESSAGE_EXECJUNC}$\r$\n戻り値=$R0"
        Abort "${MESSAGE_ABORT}"
      EXECJUNC_OK:

    ;;; NOTE 何故か、findstrは出来ているのにリダイレクトが空になる!!!
    ;;;      諦めて自分で全部読んで判断する。
    ;;; NOTE findstrはコマンドなのでcmd.exeを使わずに直接起動する。

    StrCpy $LinkPath ""
    FileOpen $0 "$TEMP\dropboxlink.junction.txt" r

      FINDLINK_LOOP:
        FileRead $0 $1
        IfErrors FINDLINK_DONE

        StrCpy $2 $1 20
        StrCmp $2 "   Substitute Name: " FINDLINK_MATCH FINDLINK_NEXT

      FINDLINK_MATCH:
        StrCpy $2 $1 "" 20 
        StrCpy $LinkPath $2 -2

      FINDLINK_NEXT:
        Goto FINDLINK_LOOP

      FINDLINK_DONE:

    ;;; Dropboxフォルダのリンクの存在チェック
    IfFileExists "$LinkPath\*.*" LINKPATH_OK LINKPATH_NG
      LINKPATH_NG:
        MessageBox MB_ICONSTOP "${ERROR_MESSAGE_NOLINKPATH}$\r$\nリンク先フォルダ： $LinkPath"
        Abort "${MESSAGE_ABORT}"
      LINKPATH_OK:

    ;;; リンクの存在に応じてモードを変更
    StrCmp $LinkPath "" LINKPATH_NOTEXIST LINKPATH_EXIST

      LINKPATH_NOTEXIST:
        StrCpy $ModeAction "リンクの設定"
        StrCpy $LinkPath "$DropboxPath"
        Goto LINKPATH_DONE

      LINKPATH_EXIST:
        StrCpy $ModeAction "リンクの解除"
        Goto LINKPATH_DONE

      LINKPATH_DONE:

FunctionEnd

Function CustomPageIn1

    ;;; モードによって読み込むページを変更
    StrCmp $ModeAction "リンクの設定" PAGE_REG PAGE_UNREG

      PAGE_REG:
        !insertmacro MUI_HEADER_TEXT "リンクの設定" "リンク先フォルダのパスを指定します。"
        !insertmacro INSTALLOPTIONS_WRITE "dropboxlink_register1.ini" "Field 3" "State" $LinkPath
        InstallOptions::initDialog /NOUNLOAD "$PLUGINSDIR\dropboxlink_register1.ini"
        Goto PAGE_DONE

      PAGE_UNREG:
        !insertmacro MUI_HEADER_TEXT "リンクの解除" "Dropboxフォルダとリンク先フォルダのパスを確認します。"
        !insertmacro INSTALLOPTIONS_WRITE "dropboxlink_unregister1.ini" "Field 2" "Text" "Dropboxフォルダ： $DropboxPath\nリンク先フォルダ： $LinkPath"
        InstallOptions::initDialog /NOUNLOAD "$PLUGINSDIR\dropboxlink_unregister1.ini"
        Goto PAGE_DONE

      PAGE_DONE:

    ;;; カスタムページの表示
    InstallOptions::show

FunctionEnd

Function CustomPageOut1

    ;;; モードによって処理を変更
    StrCmp $ModeAction "リンクの設定" PAGE_REG PAGE_UNREG

      PAGE_REG:
        !insertmacro INSTALLOPTIONS_READ $0 "dropboxlink_register1.ini" "Field 3" "State"
  
        ;;; リンク先フォルダの空チェック
        StrCmp "$0" "" 0 +3
            MessageBox MB_ICONEXCLAMATION "リンク先フォルダを入力してください。"
            Abort

        ;;; リンク先フォルダの入力チェック
        StrCmp "$0" "$DropboxPath" 0 +3
            MessageBox MB_ICONEXCLAMATION "リンク先フォルダにはDropboxフォルダとは別のフォルダを入力してください。"
            Abort

        ;;; リンク先フォルダがDropboxPathの子フォルダでないことのチェック
        StrLen $1 "$DropboxPath\"
        StrCpy $2 "$0\" $1
        StrCmp "$2" "$DropboxPath\" 0 +3
            MessageBox MB_ICONEXCLAMATION "リンク先フォルダにはDropboxフォルダの子フォルダ以外を入力してください。"
            Abort

        ;;; リンク先フォルダがDropboxPathの親フォルダでないことのチェック
        StrLen $1 "$0\"
        StrCpy $2 "$DropboxPath\" $1
        StrCmp "$2" "$0\" 0 +3
            MessageBox MB_ICONEXCLAMATION "リンク先フォルダにはDropboxフォルダの親フォルダ以外を入力してください。"
            Abort

        ;;; リンク先フォルダの存在チェック
        ${DirState} $0 $1
        StrCmp "$1" "-1" LINK_NG LINK_OK
          LINK_NG:
            MessageBox MB_ICONQUESTION|MB_OKCANCEL "入力されたリンク先フォルダが存在しません。$\r$\nリンク先フォルダを作成しますか？" IDOK LINK_IDOK IDCANCEL LINK_IDCANCEL
              LINK_IDOK:
                CreateDirectory $0
                IfErrors LINK_CREATE_NG LINK_CREATE_OK
                  LINK_CREATE_NG:
                    MessageBox MB_ICONEXCLAMATION "リンク先フォルダの作成に失敗しました。$\r$\nリンク先フォルダ： $0"
                    Abort
                  LINK_CREATE_OK:
                Goto LINK_OK
              LINK_IDCANCEL:
                Abort
          LINK_OK:
  
        ;;; リンク先フォルダの空チェック
        StrCmp "$1" "1" 0 +3
            MessageBox MB_ICONEXCLAMATION "リンク先フォルダが空ではありません。$\r$\nリンク先フォルダ： $0"
            Abort

        ;;; リンク先フォルダ確定
        StrCpy $LinkPath $0  

        Goto PAGE_DONE

      PAGE_UNREG:

        Goto PAGE_DONE

      PAGE_DONE:

        ;;; Dropboxフォルダのバックアップの存在チェック
        StrCpy $BackupPath $DropboxPath${BAK_SUFFIX}
        IfFileExists "$BackupPath\*.*" DROPBOX_BACKUP_EXIST DROPBOX_BACKUP_DONE
          DROPBOX_BACKUP_EXIST:
            MessageBox MB_ICONQUESTION|MB_OKCANCEL "Dropboxフォルダのバックアップが存在します。$\r$\nバックアップを削除しますか？$\r$\nバックアップフォルダ： $BackupPath" IDOK DROPBOX_BACKUP_IDOK IDCANCEL DROPBOX_BACKUP_IDCANCEL
              DROPBOX_BACKUP_IDOK:
                nsExec::Exec 'cmd.exe /c if 1==1 rmdir /s /q "$BackupPath"'
                Pop $R0
                Goto LINK_OK
              DROPBOX_BACKUP_IDCANCEL:
                Abort
          DROPBOX_BACKUP_DONE:
    
        ;;; リンク先フォルダのバックアップの存在チェック
        StrCpy $BackupPath $LinkPath${BAK_SUFFIX}
        IfFileExists "$BackupPath\*.*" LINK_BACKUP_EXIST LINK_BACKUP_DONE
          LINK_BACKUP_EXIST:
            MessageBox MB_ICONQUESTION|MB_OKCANCEL "リンク先フォルダのバックアップが存在します。$\r$\nバックアップを削除しますか？$\r$\nバックアップフォルダ： $BackupPath" IDOK LINK_BACKUP_IDOK IDCANCEL LINK_BACKUP_IDCANCEL
              LINK_BACKUP_IDOK:
                nsExec::Exec 'cmd.exe /c if 1==1 rmdir /s /q "$BackupPath"'
                Pop $R0
                Goto LINK_OK
              LINK_BACKUP_IDCANCEL:
                Abort
          LINK_BACKUP_DONE:

        ;;; Dropboxフォルダのロックチェック
        StrCpy $BackupPath $DropboxPath${BAK_SUFFIX}
        Rename $DropboxPath $BackupPath
        IfErrors DROPBOX_LOCK_NG DROPBOX_LOCK_OK
          DROPBOX_LOCK_NG:
            MessageBox MB_ICONEXCLAMATION "Dropboxフォルダがロックされている可能性があります。$\r$\nDropboxを含む実行中の他のプロセスを終了させてください。"
            Rename $BackupPath $DropboxPath
            Abort
          DROPBOX_LOCK_OK:
            Rename $BackupPath $DropboxPath
    
        ;;; リンク先フォルダのロックチェック
        StrCpy $BackupPath $LinkPath${BAK_SUFFIX}
        Rename $LinkPath $BackupPath
        IfErrors LINK_LOCK_NG LINK_LOCK_OK
          LINK_LOCK_NG:
            MessageBox MB_ICONEXCLAMATION "リンク先フォルダがロックされている可能性があります。$\r$\nDropboxを含む実行中の他のプロセスを終了させてください。"
            Rename $BackupPath $LinkPath
            Abort
          LINK_LOCK_OK:
            Rename $BackupPath $LinkPath

FunctionEnd

Function CustomPageIn2

    ;;; モードによって読み込むページを変更
    StrCmp $ModeAction "リンクの設定" PAGE_REG PAGE_UNREG

      PAGE_REG:
        !insertmacro MUI_HEADER_TEXT "リンクの設定" "Dropboxフォルダの実体を移動します。"
        InstallOptions::initDialog /NOUNLOAD "$PLUGINSDIR\dropboxlink_register2.ini"
        Goto PAGE_DONE

      PAGE_UNREG:
        !insertmacro MUI_HEADER_TEXT "リンクの解除" "Dropboxフォルダの実体を元に戻します。"
        InstallOptions::initDialog /NOUNLOAD "$PLUGINSDIR\dropboxlink_unregister2.ini"
        Goto PAGE_DONE

      PAGE_DONE:

    ;;; カスタムページの表示    
    InstallOptions::show

FunctionEnd

Function CustomPageOut2
FunctionEnd

Section

    ;;; 情報表示
    DetailPrint "### 情報表示"
    DetailPrint "モード： $ModeAction"
    DetailPrint "Dropboxフォルダ： $DropboxPath"
    DetailPrint "リンク先フォルダ： $LinkPath"

    ;;; モードによって処理を変更
    StrCmp $ModeAction "リンクの設定" PAGE_REG PAGE_UNREG

      PAGE_REG:

        StrCpy $BackupPath $DropboxPath${BAK_SUFFIX}

        DetailPrint "### バックアップの作成"
        DetailPrint "バックアップフォルダ： $BackupPath"
        CopyFiles $DropboxPath $BackupPath
        IfErrors PAGE_REG_BACKUP_NG PAGE_REG_BACKUP_OK
          PAGE_REG_BACKUP_NG:
            MessageBox MB_ICONSTOP "${ERROR_MESSAGE_BACKUPFAILED}$\nバックアップフォルダ： $BackupPath"
            Abort "${MESSAGE_ABORT}"
          PAGE_REG_BACKUP_OK:

        DetailPrint "### システム属性の変更"
        StrCpy $0 'attrib +r "$BackupPath"'
        DetailPrint "コマンド： $0"
        nsExec::Exec '$0'
        Pop $R0

        DetailPrint "### フォルダの移動"
        !insertmacro MoveFolder $DropboxPath $LinkPath "*.*"
        IfErrors PAGE_REG_MOVE_NG PAGE_REG_MOVE_OK
          PAGE_REG_MOVE_NG:
            MessageBox MB_ICONSTOP "${ERROR_MESSAGE_MOVEFAILED}$\nバックアップフォルダ： $BackupPath"
            Abort "${MESSAGE_ABORT}"
          PAGE_REG_MOVE_OK:
    
        DetailPrint "### システム属性の変更"
        StrCpy $0 'attrib +r "$LinkPath"'
        DetailPrint "コマンド： $0"
        nsExec::Exec '$0'
        Pop $R0

        DetailPrint "### リンクの設定"
        StrCpy $0 'junction\junction.exe "$DropboxPath" "$LinkPath"'
        DetailPrint "コマンド： $0"
        nsExec::Exec 'cmd.exe /c if 1==1 $0 > $TEMP\dropboxlink.junction.register.txt'
        Pop $R0
        StrCmp $R0 "0" PAGE_REG_JUNC_OK PAGE_REG_JUNC_NG
          PAGE_REG_JUNC_NG:
            MessageBox MB_ICONSTOP "${ERROR_MESSAGE_LINKFAILED}$\r$\n戻り値=$R0"
            Abort "${MESSAGE_ABORT}"
          PAGE_REG_JUNC_OK:
    
        DetailPrint "### リンク設定の結果判定"
        StrCpy $0 'findstr /B Created $TEMP\dropboxlink.junction.register.txt'
        DetailPrint "コマンド： $0"
        nsExec::Exec '$0'
        Pop $R0
        StrCmp $R0 "0" PAGE_REG_JUNC_CREATE_OK PAGE_REG_JUNC_CREATE_NG
          PAGE_REG_JUNC_CREATE_NG:
            MessageBox MB_ICONSTOP "${ERROR_MESSAGE_LINKFAILED}$\r$\n戻り値=$R0"
            Abort "${MESSAGE_ABORT}"
          PAGE_REG_JUNC_CREATE_OK:

        DetailPrint "### システム属性の変更"
        StrCpy $0 'attrib +r "$DropboxPath"'
        DetailPrint "コマンド： $0"
        nsExec::Exec '$0'
        Pop $R0

        DetailPrint "### desktop.iniの更新"
        IfFileExists "$DropboxPath\desktop.ini" PAGE_REG_DESKTOPINI_EXIST PAGE_REG_DESKTOPINI_DONE
          PAGE_REG_DESKTOPINI_EXIST:
            ReadINIStr $0 "$DropboxPath\desktop.ini" ".ShellClassInfo" "InfoTip"
            WriteINIStr "$DropboxPath\desktop.ini" ".ShellClassInfo" "InfoTip0" "$0"
            WriteINIStr "$DropboxPath\desktop.ini" ".ShellClassInfo" "InfoTip"  "$0Dropboxフォルダの実体は$LinkPathにあります。"
            DetailPrint "desktop.ini： [.ShellClassInfo] InfoTip = $0 $LinkPath"
          PAGE_REG_DESKTOPINI_DONE:

        Goto PAGE_DONE

      PAGE_UNREG:

        DetailPrint "### システム属性の変更"
        StrCpy $0 'attrib -r +s "$DropboxPath"'
        DetailPrint "コマンド： $0"
        nsExec::Exec '$0'
        Pop $R0

        DetailPrint "### リンクの解除"
        StrCpy $0 'junction\junction.exe -d "$DropboxPath"'
        DetailPrint "コマンド： $0"
        nsExec::Exec 'cmd.exe /c if 1==1 $0 > $TEMP\dropboxlink.junction.unregister.txt'
        Pop $R0
        StrCmp $R0 "0" PAGE_UNREG_JUNC_OK PAGE_UNREG_JUNC_NG
          PAGE_UNREG_JUNC_NG:
            MessageBox MB_ICONSTOP "${ERROR_MESSAGE_UNLINKFAILED}$\r$\n戻り値=$R0"
            Abort "${MESSAGE_ABORT}"
          PAGE_UNREG_JUNC_OK:

        DetailPrint "### リンク解除の結果判定"
        StrCpy $0 'findstr Deleted /B $TEMP\dropboxlink.junction.unregister.txt'
        DetailPrint "コマンド： $0"
        nsExec::Exec '$0'
        Pop $R0
        StrCmp $R0 "0" PAGE_UNREG_JUNC_DELETE_OK PAGE_UNREG_JUNC_DELETE_NG
          PAGE_UNREG_JUNC_DELETE_NG:
            MessageBox MB_ICONSTOP "${ERROR_MESSAGE_UNLINKFAILED}$\r$\n戻り値=$R0"
            Abort "${MESSAGE_ABORT}"
          PAGE_UNREG_JUNC_DELETE_OK:

        StrCpy $BackupPath $LinkPath${BAK_SUFFIX}

        DetailPrint "### バックアップの作成"
        DetailPrint "バックアップフォルダ： $BackupPath"
        CopyFiles $LinkPath $BackupPath
        IfErrors PAGE_UNREG_BACKUP_NG PAGE_UNREG_BACKUP_OK
          PAGE_UNREG_BACKUP_NG:
            MessageBox MB_ICONSTOP "${ERROR_MESSAGE_BACKUPFAILED}$\nバックアップフォルダ： $BackupPath"
            Abort "${MESSAGE_ABORT}"
          PAGE_UNREG_BACKUP_OK:

        DetailPrint "### システム属性の変更"
        StrCpy $0 'attrib +r "$BackupPath"'
        DetailPrint "コマンド： $0"
        nsExec::Exec '$0'
        Pop $R0

        DetailPrint "### フォルダの移動"
        !insertmacro MoveFolder $LinkPath $DropboxPath "*.*"
        IfErrors PAGE_UNREG_MOVE_NG PAGE_UNREG_MOVE_OK
          PAGE_UNREG_MOVE_NG:
            MessageBox MB_ICONSTOP "${ERROR_MESSAGE_MOVEFAILED}$\nバックアップフォルダ： $BackupPath"
            Abort "${MESSAGE_ABORT}"
          PAGE_UNREG_MOVE_OK:
    
        DetailPrint "### システム属性の変更"
        StrCpy $0 'attrib +r "$DropboxPath"'
        DetailPrint "コマンド： $0"
        nsExec::Exec '$0'
        Pop $R0

        DetailPrint "### desktop.iniの更新"
        IfFileExists "$DropboxPath\desktop.ini" PAGE_UNREG_DESKTOPINI_EXIST PAGE_UNREG_DESKTOPINI_DONE
          PAGE_UNREG_DESKTOPINI_EXIST:
            ReadINIStr $0 "$DropboxPath\desktop.ini" ".ShellClassInfo" "InfoTip0"
            StrCmp "$0" "" PAGE_UNREG_DESKTOPINI_DONE PAGE_UNREG_DESKTOPINI_UPDATE
              PAGE_UNREG_DESKTOPINI_UPDATE:
                WriteINIStr "$DropboxPath\desktop.ini" ".ShellClassInfo" "InfoTip" "$0"
                DeleteINIStr "$DropboxPath\desktop.ini" ".ShellClassInfo" "InfoTip0"
                DetailPrint "desktop.ini： [.ShellClassInfo] InfoTip = $0"
          PAGE_UNREG_DESKTOPINI_DONE:

        Goto PAGE_DONE

      PAGE_DONE:

SectionEnd

Function FinishPageOut

    MessageBox MB_ICONQUESTION|MB_OKCANCEL "バックアップフォルダを削除しますか？$\r$\nバックアップフォルダ： $BackupPath" IDOK RMDIR_IDOK IDCANCEL RMDIR_IDCANCEL
      RMDIR_IDOK:
        nsExec::Exec 'cmd.exe /c if 1==1 rmdir /s /q "$BackupPath"'
        Pop $R0
        Goto RMDIR_DONE
      RMDIR_IDCANCEL:
        Abort
      RMDIR_DONE:

FunctionEnd

