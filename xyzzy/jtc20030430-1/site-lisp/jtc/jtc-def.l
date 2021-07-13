;;; -*- Mode: Lisp; Package:jtc -*-
;;;
;;; jtc-def.l --- JavaTinyConsole
;;;

;;; author
;;;	YAMAMOTO Taizo

;;; date
;;;	Last updated: "2003-04-28"

(provide "jtc/jtc-def")

(unless (find-package "jtc")
  (defpackage "jtc" (:use "lisp" "editor"))
  (use-package "jtc" "user"))

(in-package "jtc")

(defmacro show-message (x &rest y)
  `(if si:*report-simple-errors-mildly*
     (message ,x ,@y)
     (msgbox ,x ,@y)))
