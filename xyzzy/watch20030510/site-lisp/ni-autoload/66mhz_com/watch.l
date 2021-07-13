;;; -*- Mode: Lisp; Package: user -*-
;;;
;;; watch.l --- watchのni-autoload用モジュール

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

;;; description
;;;     watchのni-autoload用モジュール

; 任意の時点で実行するのでautoloadで読み込む
(export '(ed::toggle-watch-listview ed::toggle-watch-enable) "ed")
(autoload 'ed::toggle-watch-enable "watch" t)
(autoload 'ed::toggle-watch-listview "watch" t)
(autoload 'ed::watch-tool-bar "watch" t)
