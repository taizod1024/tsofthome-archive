;;; -*- Mode: lisp; Package: irc -*-
;;;
;;; irc-struct --- client side irc module : structure definition

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

;;; description
;;;	ç\ë¢ëÃ

;;; changes
;;;	Mon, 13 May 2002 22:18:54 +0900
;;;		èâî≈

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "irc")
    (defpackage "irc"
      (:nicknames "irc")
      (:use "lisp" "editor"))))

(provide "irc/irc-struct")

(in-package "irc")

;;; ------------------------------------------------
;;; structure
;;; ------------------------------------------------

;;; channel
(defstruct irc-channel
  (name)			; name of channel
  (topic)			; topic of channel
  (user)			; mode for user
  (joined)			; is joinning ?
  )

;;; message
(defstruct irc-message
  (nick-or-server)		; nick or server
  (user)			; user
  (host)			; host
  (command)			; command
  (param)			; param [list]
  (trailing)			; trailing
  (text)			; abstract text of message
  )

