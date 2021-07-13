;;; -*- Mode: lisp; Package: irc -*-
;;;
;;; irc-dialog --- client side irc module : dialog part

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

;;; description
;;;	チャネル用・個人用のバッファ管理を行います。

;;; note
;;;	・nickを変更した相手がプライベート中に相手が落ちると、バッファが残る
;;;	　そのまま次の会話を行うと相手がnickを変更したときに不整合が起こる。

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "irc")
    (defpackage "irc"
      (:nicknames "irc")
      (:use "lisp" "editor")))
  (require "irc/irc"))

(provide "irc/irc-dialog")

(in-package "irc")

;;; ------------------------------------------------
;;; variables
;;; ------------------------------------------------

;;; user
(defvar *irc-dialog-buffer* "[~A]")
(defvar *irc-dialog-mode-name* "IRC:Dialog")
(defvar *irc-dialog-title-bar-format* "%b %#f")
(defvar *irc-dialog-mode-line-format* "--%*- %b (%M) [%k:%l] %P %#f")
(defvar *irc-dialog-check-chop* t)

;;; regexp
(defvar *irc-dialog-regexp-keyword-list*
  '(("^[0-9][0-9]:[0-9][0-9]" t (:color 12))
    ("<[^\n>]*>" t (:color 9))
    ("=[^\n=]*=" t (:color 4))
    ("%%%[^\n]*" t (:color 10))))

(defvar *irc-dialog-compiled-regexp-keyword-list*
  (compile-regexp-keyword-list
   *irc-dialog-regexp-keyword-list*))

;;; Keymap
; ※ダイアログバッファでキーを打った時にミニバッファに移動する仕掛けがあるので、
;   RETだけは別の関数に変更してはダメです。
(defvar *irc-dialog-mode-map* nil)
(unless *irc-dialog-mode-map*
  (setq *irc-dialog-mode-map* (make-sparse-keymap))
  (do ((c #x20 (+ c 1)))
      ((> c #x7e))
    (define-key *irc-dialog-mode-map* (code-char c) 'irc-default-input-function))
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\c) 'irc-connect)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\q) 'irc-send-quit)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\z) 'irc-exit)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\n) 'irc-send-nick)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\j) 'irc-send-join)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\J) 'irc-dialog-send-join)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\p) 'irc-dialog-send-part)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\m) 'irc-dialog-send-privmsg)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\M) 'irc-send-privmsg)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\C) 'irc-send-message)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\a) 'irc-send-away)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\A) 'irc-send-away-and-nick)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\+) 'irc-dialog-send-mode-+o)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\-) 'irc-dialog-send-mode--o)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\t) 'irc-dialog-send-topic)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\k) 'irc-dialog-send-kick)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\i) 'irc-dialog-info)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\w) 'irc-send-whois)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\h) 'irc-dialog-hold-buffer)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\u) 'irc-previous-buffer)
  (define-key *irc-dialog-mode-map* `(,@*irc-prefix* #\v) 'irc-next-buffer)
  (define-key *irc-dialog-mode-map* #\C-g 'irc-dialog-cancel-buffered-msg)
  (define-key *irc-dialog-mode-map* #\SPC 'next-line)
  (define-key *irc-dialog-mode-map* #\TAB 'irc-dialog-end-of-buffer-or-send-privmsg)
  (define-key *irc-dialog-mode-map* #\RET 'irc-dialog-end-of-buffer-or-send-privmsg))

;;; for user function
(setq-default irc-dialog-channel nil)
(setq-default irc-dialog-private nil)

;;; hook for control
(defvar *irc-dialog-mode-hook* nil)

;;; system
(pushnew 'irc-dialog-mode *irc-mode*)

;;; ------------------------------------------------
;;; dialog
;;; ------------------------------------------------

;;; irc-dialog-mode
(defun irc-dialog-mode ()
  "irc: 対話用のモード"
  (kill-all-local-variables)
  (setq buffer-mode 'irc-dialog-mode)
  (setq mode-name *irc-dialog-mode-name*)
  (use-keymap *irc-dialog-mode-map*)
  (make-local-variable 'kept-undo-information)
  (setq kept-undo-information nil)
  (make-local-variable 'need-not-save)
  (setq need-not-save t)
  (make-local-variable 'auto-save)
  (setq auto-save nil)
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *irc-dialog-compiled-regexp-keyword-list*)
  (make-local-variable 'title-bar-format)
  (setq title-bar-format *irc-dialog-title-bar-format*)
  (make-local-variable 'mode-line-format)
  (setq mode-line-format *irc-dialog-mode-line-format*)
  (make-local-variable 'irc-buffered-msg)
  (make-local-variable 'irc-buffer-hold)
  (make-local-variable 'irc-dialog-channel)
  (make-local-variable 'irc-dialog-private)
  (make-local-variable 'default-input-function)
  (setq default-input-function 'irc-default-input-function)
  (setq buffer-read-only t)
  (run-hooks '*irc-dialog-mode-hook*))

;;;
(defun irc-default-input-function ()
  (interactive)
  (command-execute
   (format nil "~C" *last-command-char*)))

(defun irc-dialog (nick fmt &rest args)
  ; dialog
  (let ((text (if args (apply #'format nil fmt args) fmt))
	(f (cond ((null nick)
		  "~A %%% ~*~A~%")
		 ((string-equal nick *irc-nick-registered*)
		  "~A =~A= ~A~%")
		 (t
		  "~A <~A> ~A~%")))
	pnt)
    ; insert
    (setq pnt (point))
    (goto-char (point-max))
    (setq buffer-read-only nil)
    (insert (format nil f (format-date-string "%H:%M") nick text))
    (setq buffer-read-only t)
    (when irc-buffer-hold
      (goto-char pnt))))

;;; ------------------------------------------------
;;; hook for message
;;; ------------------------------------------------

; default hooks
#|
irc-dialog-mode
　　*irc-dialog-mode-hook*

irc-sentinel
　　*irc-close-hook*
　　　　irc-command-close
　　　　　　*irc-closed-hook*
　　　　　　　　irc-dialog-command2

irc-filter
　　*irc-filter-hook*
　　　　irc-command-privmsg
　　　　　　*irc-command-privmsg-hook*
　　　　　　　　irc-dialog-privmsg
　　　　irc-command-join
　　　　　　*irc-command-join-hook*
　　　　　　　　irc-dialog-command
　　　　irc-command-kick
　　　　　　*irc-command-nick-hook*
　　　　　　　　irc-dialog-command
　　　　irc-command-part
　　　　　　*irc-command-part-hook*
　　　　　　　　irc-dialog-command
　　　　irc-command-quit
　　　　　　*irc-command-quit-hook*
　　　　　　　　irc-dialog-command
　　　　irc-command-nick
　　　　　　*irc-command-nick-hook*
　　　　　　　　irc-dialog-command
　　　　　　　　irc-dialog-nick
　　　　irc-command-mode
　　　　　　*irc-command-mode-hook*
　　　　　　　　irc-dialog-command
　　　　irc-command-topic
　　　　　　*irc-command-topic-hook*
　　　　　　　　irc-dialog-command
　　　　　　　　irc-dialog-topic
　　　　irc-command-353
　　　　/irc-command-366
　　　　　　*irc-command-353-hook*
　　　　　　　　irc-dialog-353
|#

;;; - privmsg
(defun irc-dialog-privmsg (msg channel nick text)
  "irc: PRIVMSGをハンドラ"
  (irc-escape-window-buffer
   (set-buffer (irc-dialog-buffer (or channel nick)))
   (irc-dialog (irc-message-nick-or-server msg) text)))
(add-hook '*irc-command-privmsg-hook* 'irc-dialog-privmsg)

;;; - command
(defun irc-dialog-command (msg channel &rest dummy)  
  "irc: コマンドのハンドラ"
  (when channel
    (irc-escape-window-buffer
     (set-buffer (irc-dialog-buffer channel))
     (irc-dialog nil (irc-message-text msg)))))
(add-hook '*irc-command-join-hook* 'irc-dialog-command)
(add-hook '*irc-command-nick-hook* 'irc-dialog-command)
(add-hook '*irc-command-quit-hook* 'irc-dialog-command)
(add-hook '*irc-command-part-hook* 'irc-dialog-command)
(add-hook '*irc-command-kick-hook* 'irc-dialog-command)
(add-hook '*irc-command-mode-hook* 'irc-dialog-command)
(add-hook '*irc-command-topic-hook* 'irc-dialog-command)

;;; - command2
(defun irc-dialog-command2 (text channel &rest dummy)
  "irc: コマンドのハンドラ"
  (when channel
    (irc-escape-window-buffer
     (set-buffer (irc-dialog-buffer channel))
     (if irc-dialog-private
	 (set-buffer-alternate-file-name "PRIVATE: ")
       (set-buffer-alternate-file-name "TOPIC: "))
     (irc-dialog nil text))))
(add-hook '*irc-closed-hook* 'irc-dialog-command2)

;;; - 353 RPL_NAMREPLY
(defun irc-dialog-353 (msg channel)
  "irc: RPL_NAMREPLY用ハンドラ"
  (irc-escape-window-buffer
   (set-buffer (irc-dialog-buffer channel))
   (irc-dialog nil "namereply -~:{ ~A~^~@{:~A~}~}" (irc-channel-user channel))))
(add-hook '*irc-command-353-hook* 'irc-dialog-353)

;;; - nick
(defun irc-dialog-nick (msg channel nick-new nick-old)
  "irc: NICK用ハンドラ"
  (when channel
    (return-from irc-dialog-nick nil))
  (unless (find-buffer (irc-dialog-buffer-name nick-old))
    (return-from irc-dialog-nick nil))
  (irc-escape-window-buffer
   (set-buffer (irc-dialog-buffer nick-old))
   (irc-dialog nil (irc-message-text msg))
   (setq irc-dialog-private nick-new)
   (set-buffer-alternate-file-name (concat "PRIVATE: " nick-new))
   (rename-buffer (irc-dialog-buffer-name nick-new))))
(add-hook '*irc-command-nick-hook* 'irc-dialog-nick)

;;; - topic
(defun irc-dialog-topic (msg channel nick text)
  "irc: TOPIC用ハンドラ"
  (irc-escape-window-buffer
   (set-buffer (irc-dialog-buffer channel))
   (set-buffer-alternate-file-name (concat "TOPIC: " text))))
(add-hook '*irc-command-topic-hook* 'irc-dialog-topic)

;;; ------------------------------------------------
;;; command
;;; ------------------------------------------------

;;; - send PART
(defun irc-dialog-send-part ()
  "irc: PART送信"
  (interactive)
  (irc-check-connection)
  (irc-dialog-check-channel)
  (irc-dialog-check-joined)
  (when (yes-or-no-p "PART ~A ?" (irc-channel-name irc-dialog-channel))
    (irc-send "PART ~A" (irc-channel-name irc-dialog-channel))))

;;; - send JOIN
(defun irc-dialog-send-join ()
  "irc: JOIN送信"
  (interactive)
  (irc-check-connection)
  (irc-dialog-check-channel)
  (irc-dialog-check-not-joined)
  (irc-send "JOIN ~A" (irc-channel-name irc-dialog-channel)))

;;; - send KICK
(defun irc-dialog-send-kick (&optional nick)
  "irc: KICK送信"
  (interactive)
  (irc-check-connection)
  (irc-dialog-check-channel)
  (irc-dialog-check-joined)
  (irc-dialog-check-chop)
  (unless nick
    (setq nick (irc-completing-read (format nil "KICK - ~A: " (irc-channel-name irc-dialog-channel))
				    (irc-dialog-user-list)
				    :must-match t)))
  (irc-send "KICK ~A ~A" (irc-channel-name irc-dialog-channel) nick))

;;; - send MODE +o/-o
(defun irc-dialog-send-mode-+o (&optional nick)
  "irc: MODE +o送信"
  (interactive)
  (irc-check-connection)
  (irc-dialog-check-channel)
  (irc-dialog-check-joined)
  (irc-dialog-check-chop)
  (irc-dialog-send-mode nick "+o"))

(defun irc-dialog-send-mode--o (&optional nick)
  "irc: MODE -o送信"
  (interactive)
  (irc-check-connection)
  (irc-dialog-check-channel)
  (irc-dialog-check-joined)
  (irc-dialog-check-chop)
  (irc-dialog-send-mode nick "-o"))

(defun irc-dialog-send-mode (nick mode)
  "irc: MODE送信"
  (unless nick
    (setq nick (irc-completing-read (format nil "MODE ~A - ~A: " mode (irc-channel-name irc-dialog-channel))
				    (irc-dialog-user-list)
				    :must-match t)))
  (irc-send "MODE ~A ~A ~A" (irc-channel-name irc-dialog-channel) mode nick))

;;; - send TOPIC
(defun irc-dialog-send-topic (&optional topic)
  "irc: TOPIC送信"
  (interactive)
  (irc-check-connection)
  (irc-dialog-check-channel)
  (irc-dialog-check-joined)
  (let* ((prompt (format nil "TOPIC - ~A: " (irc-channel-name irc-dialog-channel)))
	 (fmt (concat prompt "~%~A")))
    (unless topic
      (setq topic (irc-read-string prompt)))
    (irc-send "TOPIC ~A :~A"
	      (irc-channel-name irc-dialog-channel)
	      topic)))

;;; - end-of-buffer or send PRIVMSG
(defun irc-dialog-end-of-buffer-or-send-privmsg (&optional lst)
  "irc: 最下行ならメッセージ送信"
  (interactive)
  (if (next-line)
      (end-of-buffer)
    (if (irc-is-connected)
	(irc-dialog-send-privmsg lst))))

;;; - send PRIVMSG
(defun irc-dialog-send-privmsg (&optional lst)
  "irc: メッセージ送信"
  (interactive)
  (irc-check-connection)
  (irc-dialog-check-joined)
  (unless lst
    (let (prompt)
      (setq prompt (format nil "PRIVMSG - ~A: "
			   (or irc-dialog-private
			       (irc-channel-name irc-dialog-channel))))
      (setq lst (split-string (irc-read-string prompt) "\n"))))
  (dolist (line lst)
    (irc-dialog-post-buffered-privmsg (or irc-dialog-private
					  (irc-channel-name irc-dialog-channel))
				      line)))

;;; - send PRIVMSG [overwrite irc-send-privmsg in irc.l]
(defun irc-send-privmsg (&optional nick msg)
  "irc: メッセージ送信"
  (interactive)
  (irc-check-connection)
  (unless nick
    (setq nick (irc-completing-read "PRIVMSG - nick: " (irc-user-list))))
  (unless msg
    (setq msg (irc-read-string "PRIVMSG - msg: ")))
  (unless (listp msg)
    (setq msg (split-string msg "\n")))
  (irc-escape-window-buffer
   (set-buffer (irc-dialog-buffer nick))
   (dolist (line msg)
     (irc-dialog-post-buffered-privmsg nick line))))

;;; - info
(defun irc-dialog-info ()
  "irc: チャネルの状態を表示"
  (interactive)
  (cond (irc-dialog-private
	 (irc-dialog nil "irc-dialog-info {")
	 (irc-dialog nil "  private:")
	 (irc-dialog nil "    name - ~A" irc-dialog-private)
	 (irc-dialog nil "}"))
	(irc-dialog-channel
	 (irc-dialog nil "irc-dialog-info {")
	 (irc-dialog nil "  channel:")
	 (irc-dialog nil "    name   - ~A" (irc-channel-name irc-dialog-channel))
	 (irc-dialog nil "    topic  - ~A" (irc-channel-topic irc-dialog-channel))
	 (irc-dialog nil "    user   -~:{ ~A~^~@{:~A~}~}" (irc-channel-user irc-dialog-channel))
	 (irc-dialog nil "    joined - ~A" (irc-channel-joined irc-dialog-channel))
	 (irc-dialog nil "}"))))

;;; ------------------------------------------------
;;; support section
;;; ------------------------------------------------

;;; buffer
(defun irc-dialog-buffer-name (channel-or-nick)
  "irc: チャネルやニックからバッファの名前を作成"
  (format nil *irc-dialog-buffer*
	  (cond ((stringp channel-or-nick)
		 channel-or-nick)
		((irc-channel-p channel-or-nick)
		 (irc-channel-name channel-or-nick)))))

(defun irc-dialog-buffer (channel-or-nick)
  "irc: チャネルやニックからバッファを返す"
  (let ((buf (irc-dialog-buffer-name channel-or-nick)))
    (save-excursion
      (cond ((find-buffer buf)
	     (set-buffer buf)
	     (when (irc-channel-p channel-or-nick)
	       (setq irc-dialog-channel channel-or-nick)))
	    (t
	     (set-buffer (create-new-buffer buf))
	     (irc-dialog-mode)
	     (irc-dialog nil "created")
	     (cond ((stringp channel-or-nick)
		    (setq irc-dialog-private channel-or-nick)
		    (set-buffer-alternate-file-name
		     (concat "PRIVATE: " channel-or-nick)))
		   ((irc-channel-p channel-or-nick)
		    (setq irc-dialog-channel channel-or-nick)
		    (set-buffer-alternate-file-name
		     (concat "TOPIC: " (irc-channel-topic channel-or-nick))))))))
    buf))

;;; hold buffer
(defun irc-dialog-hold-buffer (&optional (mode :toggle))
  "irc: バッファの表示位置固定"
  (interactive)
  (cond ((eq mode :toggle)
	 (setq mode (not irc-buffer-hold)))
	((eq irc-buffer-hold mode)
	 (return-from irc-dialog-hold-buffer nil)))
  (cond (mode
	 (irc-dialog nil "buffer held"))
	(t
	 (irc-dialog nil "never buffer held")))
  (setq irc-buffer-hold mode))

;;; buffered message
(defun irc-dialog-cancel-buffered-msg ()
  "irc: バッファリングされたメッセージの取消"
  (interactive)
  (when irc-buffered-msg
    (irc-dialog nil "canceled ~D buffered messages" (length irc-buffered-msg))
    (setq irc-buffered-msg nil))
  (quit))

;;; buffered message
(defun irc-dialog-post-buffered-privmsg (nick-or-channel fmt &rest args)
  "irc: バッファリングされたメッセージの送信"
  (let* ((m (if args (apply #'format nil fmt args) fmt)))
    (setq irc-buffered-msg
	  (append irc-buffered-msg
		  (list #'(lambda ()
			    (irc-dialog *irc-nick-registered* m)
			    (irc-send "PRIVMSG ~A :~A" nick-or-channel m)))))))

(defun irc-dialog-post-buffered-notice (nick-or-channel fmt &rest args)
  "irc: バッファリングされたNOTICEの送信"
  (let* ((m (if args (apply #'format nil fmt args) fmt)))
    (setq irc-buffered-msg
	  (append irc-buffered-msg
		  (list #'(lambda ()
			    (irc-dialog *irc-nick-registered* m)
			    (irc-send "NOTICE ~A :~A" nick-or-channel m)))))))

;;; chop
(defun irc-dialog-chop-p (&optional nick)
  "irc: ニックがチャネルのオペレータかどうかを返す"
  (find (or nick
	    *irc-nick-registered*)
	(irc-dialog-chop-list)
	:test 'string-equal))

(defun irc-dialog-user-list ()
  "irc: ユーザのリスト"
  (and irc-dialog-channel
       (mapcar #'car (irc-channel-user irc-dialog-channel))))

(defun irc-dialog-chop-list ()
  "irc: チャネルのオペレータのリスト"
  (and irc-dialog-channel
       (mapcar #'car (remove-if-not
		      #'(lambda (x) (find #\o (cdr x)))
		      (irc-channel-user irc-dialog-channel)))))

;;; check
(defun irc-dialog-check-channel ()
  "irc: バッファがチャネルかをチェック"
  (when irc-dialog-private
    (msgbox "this buffer is for private")
    (quit)))

(defun irc-dialog-check-joined ()
  "irc: チャネルにJOINしているかをチェック"
  (when (and (not irc-dialog-private)
	     (not (irc-channel-joined irc-dialog-channel)))
    (msgbox "not joined")
    (quit)))

(defun irc-dialog-check-not-joined ()
  "irc: チャネルにJOINしていないかをチェック"
  (when (and (not irc-dialog-private)
	     (irc-channel-joined irc-dialog-channel))
    (msgbox "already joined")
    (quit)))

(defun irc-dialog-check-chop ()
  "irc: チャネルのオペレータかをチェック"
  (unless (irc-dialog-chop-p)
    (msgbox "not channel operator")
    (quit)))

