;;; -*- Mode: lisp; Package: irc -*-
;;;
;;; irc-layout --- client side irc module : layout option

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

;;; description
;;;	レイアウト制御

;;; keybind
;;;	ログバッファ：
;;;		l	専用フレームに移動しレイアウト制御
;;;	ダイアログバッファ：
;;;		l	専用フレームに移動しレイアウト制御

;;; changes
;;;	Mon, 13 May 2002 22:18:54 +0900
;;;		初版

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "irc")
    (defpackage "irc"
      (:nicknames "irc")
      (:use "lisp" "editor")))
  (require "irc/irc")
  (require "irc/irc-dialog"))

(provide "irc/irc-struct")

(in-package "irc")

;;; ------------------------------------------------
;;; variable
;;; ------------------------------------------------

(defvar *irc-layout-head-ratio* 1/5)
(defvar *irc-layout-log-ratio* 1/5)
(defvar *irc-layout-frame* "irc")
(defvar *irc-layout-head-window* nil)
(defvar *irc-layout-body-window* nil)
(defvar *irc-layout-tail-window* nil)

;;; ------------------------------------------------
;;; keymap
;;; ------------------------------------------------

(define-key *irc-log-mode-map* '(#\C-c #\i #\l) 'irc-layout)
(define-key *irc-dialog-mode-map* '(#\C-c #\i #\l) 'irc-layout)

;;; ------------------------------------------------
;;; hook
;;; ------------------------------------------------

#|
irc-log-mode
　　*irc-log-mode-hook*
　　　　irc-layout

irc-filter
　　*irc-filter-hook*
　　　　irc-command-privmsg
　　　　　　*irc-command-privmsg-hook*
　　　　　　　　irc-dialog-privmsg
　　　　　　　　irc-layout-change-window
　　　　irc-command-join
　　　　　　*irc-command-join-hook*
　　　　　　　　irc-dialog-command
　　　　　　　　irc-layout-change-window

irc-cleanup
　　*irc-cleanup-hook*
　　　　irc-layout-delete-frame
|#

;;; change layout
(defun irc-layout ()
  "irc: フレームの作成及びレイアウト設定"
  (interactive)
  (select-pseudo-frame
   (or (find-pseudo-frame *irc-layout-frame*)
       (new-pseudo-frame *irc-layout-frame*)))
  (let (buf (*next-buffer-in-tab-order* nil))
    (delete-other-windows)
    (setq buf (selected-buffer))
    (loop
      (if (find buffer-mode *irc-mode*)
	  (return))
      (next-buffer)
      (if (eq buf (selected-buffer))
	  (return)))
    (split-window (truncate (* (screen-height) *irc-layout-head-ratio*)))
    (setq *irc-layout-head-window* (selected-window))
    (other-window)
    (split-window (- (truncate (* (screen-height) *irc-layout-log-ratio*))))
    (setq *irc-layout-tail-window* (selected-window))
    (set-buffer *irc-log-buffer*)
    (move-previous-window)
    (setq *irc-layout-body-window* (selected-window))))
(add-hook '*irc-log-mode-hook* 'irc-layout)

;;; change window
(defun irc-layout-change-window (&optional msg channel nick text)
  "irc: 新着メッセージに応じてバッファを変更"
  (when (eq (find-pseudo-frame *irc-layout-frame*)
	    (selected-pseudo-frame))
     (let (w n v)
       (setq w (selected-window))
       (setq c (irc-message-command msg))
       (setq v (cond ((find c '("PRIVMSG" "NOTICE") :test 'string-equal)
		      *irc-layout-head-window*)
		     ((and (string-equal c "JOIN")
			   (string= nick *irc-nick-registered*))
		      *irc-layout-body-window*)
		     (t
		      (return-from irc-layout-change-window nil))))
       (when (ignore-errors (set-window v))
	 (when (find buffer-mode *irc-mode*)
	   (set-buffer (irc-dialog-buffer (or channel nick))))
	 (set-window w)))))
(add-hook '*irc-command-privmsg-hook* 'irc-layout-change-window)
(add-hook '*irc-command-join-hook* 'irc-layout-change-window)

;;; delete frame
(defun irc-layout-delete-frame ()
  "irc: フレームの削除"
  (let ((frm (find-pseudo-frame *irc-layout-frame*)))
    (when frm
      (delete-pseudo-frame frm))))
(add-hook '*irc-cleanup-hook* 'irc-layout-delete-frame)
