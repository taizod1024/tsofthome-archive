;;; -*- Mode: nsi; Package: editor -*-
;;;
;;; XyzzySetup.nsh --- 共通ヘッダ

;;; ------------------------------------------------
;;; 共通設定
;;; ------------------------------------------------

;;; インストールするものの設定
; 基本的な設定
!define MUI_PRODUCT "xyzzy"
!define MUI_VERSION "- XyzzySetup verion 0.0.0 -"

; 内部用の名称
!define MUI_PRODUCT_AUTHOR "亀井氏"
!define MUI_SETUP "XyzzySetup"
!define MUI_SETUP_AUTHOR "山本"
!define MUI_SETUP_AUTHOR_ADDRESS "cbf95600@pop02.odn.ne.jp"

!define MUI_HEADERBITMAP "XyzzySetupHeader.bmp"
!define MUI_ABORTWARNING		; 中止しようとすると警告する
!define MUI_FONT "MS UI Gothic"		; フォントの設定は
!define MUI_FONTSIZE 9			; MUL_LANGUAGEの前に行う
!define MUI_FONT_HEADER "MS UI Gothic"
!define MUI_FONTSIZE_HEADER 9
!define MUI_FONT_TITLE "MS UI Gothic"
!define MUI_FONTSIZE_TITLE 12
