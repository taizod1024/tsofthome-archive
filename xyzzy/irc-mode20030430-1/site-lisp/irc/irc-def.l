;;; -*- Mode: lisp; Package: irc -*-
;;;
;;; irc-def --- package definition

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

;;; description
;;;	パッケージ

;;; changes
;;;	Mon, 13 May 2002 22:18:54 +0900
;;;		初版

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "irc")
    (defpackage "irc"
      (:nicknames "irc")
      (:use "lisp" "editor"))))

(provide "irc/irc-def")
