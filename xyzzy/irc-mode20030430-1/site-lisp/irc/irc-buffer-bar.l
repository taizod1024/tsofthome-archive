;;; -*- Mode: lisp; Package: irc -*-
;;;
;;; irc-bufferl-bar --- client side irc module : buffer bar option

;;; Author: YAMAMOTO Taizo
;;; Last updated: "2002/07/07 17:52:56 +0900"

;;; description
;;;	irc専用のバッファバーを追加します。
;;;	（作業中）

;;; changes
;;;	Sun, 07 Jul 2002 09:18:24 +0900
;;;		初版

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "irc")
    (defpackage "irc"
      (:nicknames "irc")
      (:use "lisp" "editor")))
  (require "irc/irc"))

(provide "irc/irc-buffer-bar")

(in-package "irc")

;;; ------------------------------------------------
;;; function
;;; ------------------------------------------------

;;; ------------------------------------------------
;;; tool bar
;;; ------------------------------------------------

(defun irc-buffer-bar ()
  (create-tab-bar 'irc-buffer-bar #'(lambda (frame) (msgbox "~S" frame))))
(define-command-bar 'irc-buffer-bar "ircﾊﾞｯﾌｧ(&C)")

(defun irc-buffer-bar-add-item ()
  (tab-bar-add-item 'irc-buffer-bar
		    (buffer-name (selected-buffer))
		    (buffer-name (selected-buffer))))
(add-hook '*irc-log-mode-hook* 'irc-buffer-bar-add-item)
(add-hook '*irc-dialog-mode-hook* 'irc-buffer-bar-add-item)

(defun irc-buffer-bar-delete-item (buf)
  (tab-bar-delete-item 'irc-buffer-bar (buffer-name buf))
  t)
(add-hook '*delete-buffer-hook* 'irc-buffer-bar-delete-item)
;;(delete-command-bar 'irc::irc-buffer-bar)



