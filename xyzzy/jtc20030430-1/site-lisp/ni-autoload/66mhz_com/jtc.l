;;; -*- Mode: Lisp; Package: user -*-
;;;
;;; jtc.l --- jtcのni-autoload用モジュール

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-05-02"

;;; description
;;;     jtcのni-autoload用モジュール

; フックの設定があるのでjavaを先に読み込む。
; ラムダ式を使わないのは*java-mode-hook*に、明示的に関数名を出したいから。
(require "java")

; パッケージだけ先に宣言する
(require "jtc/jtc-def")

; ツールバーは任意の時点で読込む
(autoload 'jtc::jtc-tool-bar "jtc/jtc" t)

; jtc本体はjava-mode初回の起動時に読み込む
(defun jtc-loadup-func () 
  (require "jtc/jtc"))
(add-hook '*java-mode-hook* 'jtc-loadup-func)
