;;; -*- Mode: Lisp; Package: user -*-
;;;
;;; irc.l --- irc-modeのni-autoload用モジュール

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-30"

;;; description
;;;     irc-modeのni-autoload用モジュール

; パッケージだけ先に宣言する
(require "irc/irc-def")

; ツールバーは任意の時点で読込む
(autoload 'irc::irc-tool-bar "irc/irc-mode" t)
(autoload 'irc-mode "irc/irc-mode" t)
(autoload 'irc-connect "irc/irc-mode" t)
