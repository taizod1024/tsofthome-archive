;;; -*- Mode: Lisp; Package: user -*-
;;;
;;; addref.l --- addrefのni-autoload用モジュール

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

;;; description
;;;     addrefのni-autoload用モジュール

; 任意の時点で実行するのでautoloadで読み込む
(autoload 'addref "addref" t)
(autoload 'addref-function "addref" t)
(autoload 'addref-variable "addref" t)
(autoload 'addref-any "addref" t)
(autoload 'addref-title-list-to-temp-buffer "addref" t)
