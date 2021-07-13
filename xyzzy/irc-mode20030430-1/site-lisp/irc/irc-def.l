;;; -*- Mode: lisp; Package: irc -*-
;;;
;;; irc-def --- package definition

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

;;; description
;;;	�p�b�P�[�W

;;; changes
;;;	Mon, 13 May 2002 22:18:54 +0900
;;;		����

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "irc")
    (defpackage "irc"
      (:nicknames "irc")
      (:use "lisp" "editor"))))

(provide "irc/irc-def")