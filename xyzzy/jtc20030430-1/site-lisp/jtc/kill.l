;;; -*- Mode: Lisp; Package:user -*-
;;;
;;; kill.l --- JavaTinyConsole
;;;

;;; author
;;;	YAMAMOTO Taizo

;;; date
;;;	Last updated: "2003-04-28"

;;; 消す前に読み込み
(require "jtc/jtc")

; ヒストリ変数の削除
(unregister-history-variable '*jtc-jdk-directory*)
(unregister-history-variable '*jtc-jdk-document-directory*)
(unregister-history-variable '*jtc-member-completion*)
(unregister-history-variable '*jtc-show-api-ref*)
(unregister-history-variable '*jtc-javac-history*)
(unregister-history-variable '*jtc-java-history*)
(unregister-history-variable '*jtc-java-args-history*)
(unregister-history-variable '*jtc-jdb-history*)
(unregister-history-variable '*jtc-make-history*)
(unregister-history-variable '*jtc-javadoc-history*)

; バイトコンパイルファイルの削除
(dolist (f (list
	    (merge-pathnames "site-lisp/jtc/jtc.lc" (si:system-root))
	    (merge-pathnames "site-lisp/jtc/jtc-def.lc" (si:system-root))
	    (merge-pathnames "site-lisp/jtc/jtc-shell.lc" (si:system-root))
	    (merge-pathnames "site-lisp/jtc/jtc-menu.lc" (si:system-root))
	    (merge-pathnames "site-lisp/jtc/jtc-complete.lc" (si:system-root))))
  (delete-file f :if-does-not-exist :skip))

; 一時ファイルの削除
(delete-file jtc::*jtc-temp-completion-file* :if-does-not-exist :skip)

; ツールバーの削除
(delete-command-bar 'jtc::jtc-tool-bar)
