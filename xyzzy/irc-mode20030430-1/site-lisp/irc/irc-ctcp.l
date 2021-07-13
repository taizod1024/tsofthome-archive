;;; -*- Mode: lisp; Package: irc -*-
;;;
;;; irc-ctcp --- client side irc module : CTCP option

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

;;; description
;;;	CTCPの機能を追加します。

;;; changes
;;;	Sun, 26 May 2002 17:36:41 +0900
;;;		初版

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "irc")
    (defpackage "irc"
      (:nicknames "irc")
      (:use "lisp" "editor")))
  (require "irc/irc"))

(provide "irc/irc-ctcp")

(in-package "irc")

;;; ------------------------------------------------
;;; variables
;;; ------------------------------------------------

;;; variable
(defvar *irc-ctcp* '("VERSION"
		     "CLIENTINFO"
		     "DCC")
  "irc: CTCPで対応しているコマンドリスト")

(defvar *irc-ctcp-dcc-regexp*
  (compile-regexp
   (concat
    "^DCC"
    " \\([^ ]*\\)"	; (match-string 1) -> command
    " \\([^ ]*\\)"	; (match-string 2) -> filename
    " \\([^ ]*\\)"	; (match-string 3) -> address
    " \\([^ ]*\\)"	; (match-string 4) -> port
    " \\([^ ]*\\)"	; (match-string 5) -> filesize
    ) nil)
  "irc: DCCコマンドの分解用正規表現")

(defvar *irc-ctcp-dcc-send-path*
  (get-special-folder-location :personal)
  "irc: DCC-SENDの送受信用パス")
(defvar *irc-ctcp-dcc-send-autosave* nil
  "irc: DCC-SENDを自動保存するか？")

;;; hook for ...                 			; ARGUMENT
(defvar *irc-ctcp-hook* '(irc-command
			  irc-ctcp-version
			  irc-ctcp-clientinfo
			  irc-ctcp-dcc-send))		; message ctcp-command

;;; ------------------------------------------------
;;; hook for message
;;; ------------------------------------------------

; default hook
#|
irc-filter
　　*irc-filter-hook*
　　　　irc-ctcp-privmsg
　　　　　　*irc-ctcp-hook*
irc-ctcp-notice
irc-ctcp-version
irc-ctcp-clientinfo
|#

;;; PRIVMSG/NOTICE
(add-hook '*irc-filter-hook* 'irc-ctcp-privmsg)
(defun irc-ctcp-privmsg (msg)
  "irc: CTCPのハンドラ"
  (when (and (find (irc-message-command msg) '("PRIVMSG" "NOTICE")
		   :test 'string-equal)
	     (string-matchp "\\(.*\\)$" (irc-message-trailing msg)))
    (let ((nick-or-server (irc-message-nick-or-server msg))
	  (user (irc-message-user msg))
	  (host (irc-message-host msg))
	  (command (irc-message-command msg))
	  (param (irc-message-param msg))
	  (trailing (irc-message-trailing msg))
	  (text (irc-message-text msg)))
      (setf (irc-message-text msg)
	    (format nil "CTCP ~A - ~A :~A"
		    command
		    nick-or-server
		    (match-string 1)))
      (run-hook-with-args '*irc-ctcp-hook* msg (match-string 1)))
    t))

;;; ------------------------------------------------
;;; hook for ...
;;; ------------------------------------------------

(defun irc-ctcp-version (msg ctcp-command)
  "irc: CTCP VERSIONのハンドラ"
  (when (string-equal ctcp-command "VERSION")
    (let ((nick-or-server (irc-message-nick-or-server msg))
	  (user (irc-message-user msg))
	  (host (irc-message-host msg))
	  (command (irc-message-command msg))
	  (param (irc-message-param msg))
	  (trailing (irc-message-trailing msg))
	  (text (irc-message-text msg)))
      (irc-post-buffered-notice nick-or-server
				"~A ~A"
				ctcp-command
				*irc-software*))))

(defun irc-ctcp-clientinfo (msg ctcp-command)
  "irc: CTCP CLIENTINFOのハンドラ"
  (when (string-equal ctcp-command "CLIENTINFO")
    (let ((nick-or-server (irc-message-nick-or-server msg))
	  (user (irc-message-user msg))
	  (host (irc-message-host msg))
	  (command (irc-message-command msg))
	  (param (irc-message-param msg))
	  (trailing (irc-message-trailing msg))
	  (text (irc-message-text msg)))
      (irc-post-buffered-notice nick-or-server
				"~A :~{~A ~}"
				ctcp-command
				*irc-ctcp*))))

(defun irc-ctcp-dcc-send (msg ctcp-command)
  "irc: DCC-SENDのハンドラ"
  (when (and (string-match *irc-ctcp-dcc-regexp* ctcp-command)
	     (string-equal (match-string 1) "SEND"))
    (let ((nick-or-server (irc-message-nick-or-server msg))
	  (user (irc-message-user msg))
	  (host (irc-message-host msg))
	  (command (irc-message-command msg))
	  (param (irc-message-param msg))
	  (trailing (irc-message-trailing msg))
	  (text (irc-message-text msg))
	  ; dcc
	  (filename (file-namestring (match-string 2)))
	  (address (irc-decode-address (read-from-string (match-string 3))))
	  (port (read-from-string (match-string 4)))
	  (filesize (read-from-string (match-string 5))))
      (start-timer *irc-send-interval*
		   #'(lambda ()
		       (irc-receive-file address
					 port
					 filename
					 filesize)) t))))

;;; ------------------------------------------------
;;; function
;;; ------------------------------------------------

(defun irc-receive-file (address port filename filesize)
  (let (path)
    (if *irc-ctcp-dcc-send-autosave*
	(setq path (merge-pathnames filename *irc-ctcp-dcc-send-path*))
      (setq path
	    (file-name-dialog
	     :title (format nil "受信ファイルの保存先 ~A (~:D bytes)" filename filesize)
	     :default (merge-pathnames filename
				       *irc-ctcp-dcc-send-path*))))
    (if (not path)
	(irc-cancel-write-to-file address port)
      (progn
	(irc-write-to-file address port path filesize)
	(or *irc-ctcp-dcc-send-autosave*
	    (msgbox "受信完了 ~A (~:D bytes)" filename filesize))))))

(defun irc-decode-address (val)
  (format nil "~D.~D.~D.~D"
	  (logand (ash val -24) 255)
	  (logand (ash val -16) 255)
	  (logand (ash val -8) 255)
	  (logand val 255)))

(defun irc-encode-dword (val)
  (format nil "~C~C~C~C"
	  (code-char (logand (ash val -24) 255))
	  (code-char (logand (ash val -16) 255))
	  (code-char (logand (ash val -8) 255))
	  (code-char (logand val 255))))

(defun irc-decode-dword (val)
  (+ (ash (char-code (schar val 0)) 24)
     (ash (char-code (schar val 1)) 16)
     (ash (char-code (schar val 2)) 8)
     (char-code (schar val 3))))

(defun irc-write-to-file (address port filename filesize)
  (let ((buf (make-vector 65536 :element-type 'character :fill-pointer 0))
	(bytes 0))
    (with-open-file (os filename :direction :output :encoding :binary)
      (with-open-stream (is (connect address port :encoding :binary))
	(while (read-into buf is nil nil (min 65536 (- filesize bytes)))
	  (princ buf os)
	  (incf bytes (length buf))
	  (princ (irc-encode-dword bytes) is)
	  (message "DCC SEND - receiving ... ~A (~:D/~:D bytes)" (file-namestring filename) bytes filesize)
	  (if (= bytes filesize) (return t)))
	(irc-log :msg "DCC SEND - received ~A (~:D bytes)" (file-namestring filename) bytes filesize)))))


(defun irc-cancel-write-to-file (address port)
  (with-open-stream (is (connect address port :encoding :binary))))
