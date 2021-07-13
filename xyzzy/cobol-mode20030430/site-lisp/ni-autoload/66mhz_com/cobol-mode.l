;;; -*- Mode: Lisp; Package: user -*-
;;;
;;; cobol-mode.l --- cobol-modeのni-autoload用モジュール

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

;;; description
;;;     cobol-modeのni-autoload用モジュール

; 任意の時点で実行するのでautoloadで読み込む
(export 'ed::cobol-mode "ed")
(autoload 'cobol-mode "cobol-mode" t)
(pushnew '("\\.cob$" . cobol-mode) *auto-mode-alist* :test 'equal)
(pushnew '("\\.cbl$" . cobol-mode) *auto-mode-alist* :test 'equal)
(pushnew '("\\.cobol$" . cobol-mode) *auto-mode-alist* :test 'equal)
