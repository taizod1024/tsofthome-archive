;;; -*- Mode: lisp; Package: irc -*-
;;;
;;; irc-tool-bar --- client side irc module : tool bar option

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

;;; description
;;;	ツールバーを追加します。
;;;	状態を表示することを目的としています。

;;; changes
;;;	Sun, 07 Jul 2002 09:18:24 +0900
;;;		初版

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "irc")
    (defpackage "irc"
      (:nicknames "irc")
      (:use "lisp" "editor")))
  (require "irc/irc")
  (require "irc/irc-dialog"))

(provide "irc/irc-tool-bar")

(in-package "irc")

;;; ------------------------------------------------
;;; function
;;; ------------------------------------------------

(defun irc-tool-bar-send-away ()
  "irc: ツールバーからSEND及びAWAYを実行"
  (interactive)
  (irc-send-away-and-nick :toggle *irc-away-message*))

(defun irc-tool-bar-hold-buffer ()
  "irc: ツールバーから表示位置の固定を実行"
  (interactive)
  (cond ((eq buffer-mode 'irc-log-mode)
	 (irc-hold-buffer))
	((eq buffer-mode 'irc-dialog-mode)
	 (irc-dialog-hold-buffer))))

(defun irc-tool-bar-update-send-away ()
  "irc: ツールバーのAWAY状態の更新用"
  (cond ((not (find buffer-mode *irc-mode*)) :disable)
	((not (irc-is-connected)) :disable)
	(*irc-away* :check)))

(defun irc-tool-bar-update-hold-buffer ()
  "irc: ツールバーの表示位置状態の更新用"
  (cond ((not (find buffer-mode *irc-mode*)) :disable)
	((not (irc-is-connected)) :disable)
	(irc-buffer-hold :check)))

;;; ------------------------------------------------
;;; tool bar
;;; ------------------------------------------------

(defun irc-tool-bar ()
  "irc: ツールバーの作成"
  (create-tool-bar 'irc-tool-bar
		   (merge-pathnames "toolbar-irc.bmp" (etc-path))
		   '(("AWAY+NICK" 0 irc-tool-bar-send-away irc-tool-bar-update-send-away)
		     ("カーソル固定" 1 irc-tool-bar-hold-buffer irc-tool-bar-update-hold-buffer))))
(define-command-bar 'irc-tool-bar "irc-mode(&C)")
