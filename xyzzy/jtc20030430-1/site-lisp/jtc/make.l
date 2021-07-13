;;; -*- Mode: Lisp; Package:user -*-
;;;
;;; make.l --- JavaTinyConsole
;;;

;;; author
;;;	YAMAMOTO Taizo

;;; date
;;;	Last updated: "2003-04-28"

;;; ヒストリ変数の変換

; Sun, 21 Oct 2001 14:19:08 +0900
(let ((s (find-symbol "*jtc-jdk-document-directory*" "user")))
  (and s (not (listp (eval s)))
       (set s (list (eval s)))))

;;; ヒストリ変数の廃止
(unregister-history-variable '*jtc-show-tool-bar*)

;;; パッケージの宣言
(require "jtc/jtc-def")
 
;;; バイトコンパイル

(byte-compile-file (merge-pathnames "site-lisp/jtc/jtc.l" (si:system-root)))
(byte-compile-file (merge-pathnames "site-lisp/jtc/jtc-def.l" (si:system-root)))
(byte-compile-file (merge-pathnames "site-lisp/jtc/jtc-shell.l" (si:system-root)))
(byte-compile-file (merge-pathnames "site-lisp/jtc/jtc-menu.l" (si:system-root)))
(byte-compile-file (merge-pathnames "site-lisp/jtc/jtc-complete.l" (si:system-root)))

