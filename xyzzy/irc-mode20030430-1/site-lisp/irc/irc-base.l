;;; -*- Mode: lisp; Package: irc -*-
;;;
;;; irc-base --- client side irc module

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

;;; description
;;;	クライアント側のIRCのモジュールです。
;;;	最低限の接続制御・チャネル管理・ユーザ管理を行います。

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "irc")
    (defpackage "irc"
      (:nicknames "irc")
      (:use "lisp" "editor")))
  (require "irc/irc-struct"))

(provide "irc/irc")

;;; ------------------------------------------------
;;; interactive command
;;; ------------------------------------------------

; autoloadする場合には、editorの様に標準であるパッケージでは
; exportすればよいが、そうでないパッケージでは面倒くさいので、
; userに作ってしまうことにする。

(defun irc-mode ()
  (interactive)
  (irc::irc-setup))

(defun irc-connect ()
  (interactive)
  (irc::irc-setup)
  (irc::irc-connect))

;;; ------------------------------------------------
;;; variables
;;; ------------------------------------------------

(in-package "irc")

(defvar *irc-config-file*
  (merge-pathnames ".irc" (user-homedir-pathname)))
(when (file-exist-p *irc-config-file*)
  (load *irc-config-file*))

;;; user
(defvar *irc-server* "irc.tokyo.wide.ad.jp"
  "irc: サーバ名")
(defvar *irc-port* 6667
  "irc: ポート番号")
(defvar *irc-pass* "irc"
  "irc: 接続時のパスワード")
(defvar *irc-nick* "irc"
  "irc: ニック")
(defvar *irc-nick-away* (string-upcase *irc-nick*)
  "irc: AWAY時のニック")
(defvar *irc-user* "irc"
  "irc: ユーザ名")
(defvar *irc-user-mode* 8
  "irc: モード？何だっけか？")
(defvar *irc-realname* "irc irc"
  "irc: 実名")
(defvar *irc-channel* nil
  "irc: JOINしているチャネルのリスト")
(defvar *irc-quit-message* "bye"
  "irc: QUIT時のメッセージ")
(defvar *irc-away-message* "away"
  "irc: AWAY時のメッセージ")
(defvar *irc-send-interval* 0.10
  "irc: フラッドを起こさないための送信のインターバル")
(defvar *irc-minibuf-size* 10
  "irc: ミニバッファ編集時の最大行数")

(defvar *irc-incode* *encoding-jis*
  "irc: 入力文字コード")
(defvar *irc-outcode* *encoding-jis*
  "irc: 出力文字コード")
(defvar *irc-eol-code* *eol-cr*
  "irc: 出力改行コード")

(defvar *irc-log-max-size* nil
  "irc: ログバッファの最大行数")
(defvar *irc-log-step-size* nil
  "irc: ログバッファの削除行数")

(defvar *irc-log-no-pingpong* t
  "irc: 送受信したPING/PONGコマンドを表示しない")
(defvar *irc-log-no-inout* t
  "irc: 受信したコマンドを表示しない")
(defvar *irc-log-no-privmsg* t
  "irc: 受信したPRIVMSGコマンドを表示しない")

(defvar *irc-log-buffer* "[IRC:Log]"
  "irc: ログバッファ名")
(defvar *irc-log-mode-name* "IRC:Log"
  "irc: モード名")

(defvar *irc-log-title-bar-format* "%b %#f"
  "irc: ログバッファのタイトルバーの形式")
(defvar *irc-log-mode-line-format* "--%*- %b (%M) [%k:%l] %P %#F"
  "irc: ログバッファのモードラインの形式")

(defvar *irc-software*
  (concat (software-type) (ed::software-version) "+irc-mode20030430")
  "irc: CTCP-VERSIONに応答するためのソフトウェア名称")

;;; regexp
(defvar *irc-log-regexp-keyword-list*
  '(("^[0-9][0-9]:[0-9][0-9]" t (:color 12))
    ("[^]*" t (:color 3))
    (" msg \\(.*\\)$" t (:color 14) nil 1)
    (" out \\(.*\\)$" t (:color 4) nil 1)
    (" in_ \\(.*\\)$" t (:color 9) nil 1)
    (" rpl \\(.*\\)$" t (:color 10) nil 1)
    (" err \\(.*\\)$" t (:color 13) nil 1))
  "irc: ログバッファの正規表現キーワード")

(defvar *irc-log-compiled-regexp-keyword-list*
  (compile-regexp-keyword-list
   *irc-log-regexp-keyword-list*)
  "irc: ログバッファのコンパイル済み正規表現キーワード")

(defvar *irc-regexp-msg*
  (compile-regexp
   (concat
    "^\\(:\\([^ ]*\\) +\\)?"            ; (match-string 2) -> prefix
    "\\([a-zA-Z]+\\|[0-9][0-9][0-9]\\)" ; (match-string 3) -> command
    "\\(\\( +[^: ][^ ]*\\)*\\)"         ; (split-string (match-string 4) #\SPC) -> param
    "\\( +:\\(.*\\)\\)? *$"             ; (match-string 7) -> trailing
    ) nil)
  "irc: IRCコマンドの分解用正規表現")

(defvar *irc-regexp-prefix*
  (compile-regexp
   (concat
    "^\\([^ !@]+\\)"		; (match-string 1) -> server or nick
    "\\(!\\([^ @]+\\)\\)?"	; (match-string 3) -> user
    "\\(@\\([^ ]+\\)\\)? *$"	; (match-string 5) -> host
    ) nil)
  "irc: IRCコマンドのプリフィックス部分解用正規表現")

;;; keymap
(defvar *irc-prefix* '(#\C-c #\i)
  "irc: キーのプリフィクス")

(defvar *irc-log-mode-map* nil
  "irc: ログバッファ用キーマップ")
(unless *irc-log-mode-map*
  (setq *irc-log-mode-map* (make-sparse-keymap))
  (define-key *irc-log-mode-map* `(,@*irc-prefix* #\c) 'irc-connect)
  (define-key *irc-log-mode-map* `(,@*irc-prefix* #\q) 'irc-send-quit)
  (define-key *irc-log-mode-map* `(,@*irc-prefix* #\z) 'irc-exit)
  (define-key *irc-log-mode-map* `(,@*irc-prefix* #\n) 'irc-send-nick)
  (define-key *irc-log-mode-map* `(,@*irc-prefix* #\j) 'irc-send-join)
  (define-key *irc-log-mode-map* `(,@*irc-prefix* #\i) 'irc-info)
  (define-key *irc-log-mode-map* `(,@*irc-prefix* #\p) 'irc-send-part)
  (define-key *irc-log-mode-map* `(,@*irc-prefix* #\M) 'irc-send-privmsg)
  (define-key *irc-log-mode-map* `(,@*irc-prefix* #\C) 'irc-send-message)
  (define-key *irc-log-mode-map* `(,@*irc-prefix* #\a) 'irc-send-away)
  (define-key *irc-log-mode-map* `(,@*irc-prefix* #\A) 'irc-send-away-and-nick)
  (define-key *irc-log-mode-map* `(,@*irc-prefix* #\w) 'irc-send-whois)
  (define-key *irc-log-mode-map* `(,@*irc-prefix* #\h) 'irc-hold-buffer)
  (define-key *irc-log-mode-map* `(,@*irc-prefix* #\u) 'irc-previous-buffer)
  (define-key *irc-log-mode-map* `(,@*irc-prefix* #\v) 'irc-next-buffer)
  (define-key *irc-log-mode-map* #\SPC 'next-line)
  (define-key *irc-log-mode-map* #\RET 'end-of-buffer)
  (define-key *irc-log-mode-map* #\TAB 'end-of-buffer)
  (define-key *irc-log-mode-map* #\C-g 'irc-cancel-buffered-msg))

;;; hook for control					; ARGUMENT
(defvar *irc-setup-hook* nil)				; nil
(defvar *irc-cleanup-hook* nil)				; nil
(defvar *irc-open-hook* nil)				; nil
(defvar *irc-close-hook* '(irc-command-close))		; nil
(defvar *irc-log-mode-hook* nil)			; nil

;;; hook for log					; ARGUMENT
(defvar *irc-log-hook* '(irc-log-no-pingpong
			 irc-log-no-privmsg
			 irc-log-no-inout))		; type text

;;; hook for message					; ARGUMENT
(defvar *irc-before-filter-hook* nil)			; message
(defvar *irc-filter-hook* '(irc-command-ping
			    irc-command-privmsg
			    irc-command-join
			    irc-command-kick
			    irc-command-part
			    irc-command-quit
			    irc-command-nick
			    irc-command-mode
			    irc-command-topic
			    irc-command-001
			    irc-command-332
			    irc-command-353
			    irc-command-366
			    irc-command-433
			    irc-command-numeric
			    irc-command-other-numeric))

(defvar *irc-after-filter-hook* nil)			; message

;;; hook for ...                         	        ; ARGUMENT
(defvar *irc-command-privmsg-hook* nil)			; message channel nick text
(defvar *irc-command-join-hook* '(irc-command))		; message channel nick
(defvar *irc-command-nick-hook* '(irc-command2))	; message channel nick-new nick-old
(defvar *irc-command-quit-hook* '(irc-command2))	; message channel nick text
(defvar *irc-command-part-hook* '(irc-command))		; message channel nick
(defvar *irc-command-kick-hook* '(irc-command))		; message channel nick nick2
(defvar *irc-command-mode-hook* '(irc-command))		; message channel nick nick2 mode
(defvar *irc-command-topic-hook* '(irc-command))	; message channel channel-or-nick text
(defvar *irc-command-353-hook* nil)			; message channel

;;; system
(defvar *irc-numeric-message*
  '("002" "003" "004"
    "251" "252" "253" "254" "255"
    "372" "376"
    "422"))
(defvar *irc-mode* '(irc-log-mode))
(defvar *irc-process* nil)
(defvar *irc-away* nil)
(defvar *irc-nick-registered* nil)
(defvar *irc-channel-startup* nil)

(defvar *irc-rest-message* nil)
(defvar *irc-nick-repeat-count* 0)
(defvar *irc-namereply-channel* nil)
(defvar *irc-namereply* nil)

(defvar *irc-history* nil)

(setq-default irc-buffered-msg nil)
(setq-default irc-buffer-hold nil)

;;; ------------------------------------------------
;;; macro
;;; ------------------------------------------------

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmacro irc-read-string (prompt &rest args)
    `(let (*minibuffer-default-history* c)
       (setq *minibuffer-default-history* *irc-history*)
       (unwind-protect
	   (read-string ,prompt ,@args)
	 (setq *irc-history* *minibuffer-default-history*))))
  (defmacro irc-completing-read (prompt completions &rest args)
    `(let (*minibuffer-default-history* c)
       (setq *minibuffer-default-history* *irc-history*)
       (unwind-protect
	   (completing-read ,prompt ,completions ,@args)
	 (setq *irc-history* *minibuffer-default-history*))))
  (defmacro irc-escape-window-buffer (&rest body)
    `(let (#1=#:minibufp #2=#:buf)
       (setq #1# (selected-window))
       (setq #2# (selected-buffer))
       ,@body
       (set-buffer #2#)
       (set-window #1#))))

;;; ------------------------------------------------
;;; log
;;; ------------------------------------------------

(defun irc-log-mode ()
  (kill-all-local-variables)
  (setq buffer-mode 'irc-log-mode)
  (setq mode-name *irc-log-mode-name*)
  (use-keymap *irc-log-mode-map*)
  (make-local-variable 'kept-undo-information)
  (setq kept-undo-information nil)
  (make-local-variable 'need-not-save)
  (setq need-not-save t)
  (make-local-variable 'auto-save)
  (setq auto-save nil)
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *irc-log-compiled-regexp-keyword-list*)
  (make-local-variable 'title-bar-format)
  (setq title-bar-format *irc-log-title-bar-format*)
  (make-local-variable 'mode-line-format)
  (setq mode-line-format *irc-log-mode-line-format*)
  (make-local-variable 'irc-buffered-msg)
  (make-local-variable 'irc-buffer-hold)
  (setq buffer-read-only t)
  (run-hooks '*irc-log-mode-hook*))

(defun irc-log (type fmt &rest args)
  ; log
  (let ((m (if args (apply #'format nil fmt args) fmt))
	(buf (selected-buffer))
	pnt)
    ; message
    (message "~A" m)
    ; hook
    (and (run-hook-with-args-until-success '*irc-log-hook* type m)
	 (return-from irc-log nil))
    ; output to log buffer
    (set-buffer *irc-log-buffer*)
    (setq pnt (point))
    (goto-char (point-max))
    (setq buffer-read-only nil)
    (insert (format nil "~A ~A ~A~%" (format-date-string "%H:%M") type m))
    (and (integerp *irc-log-max-size*)
	 (integerp *irc-log-step-size*)
	 (< (1+ *irc-log-max-size*) (current-line-number))
	 (delete-region (point-min)
			(progn (goto-line (1+ *irc-log-step-size*)) (point))))
    (setq buffer-read-only t)
    ; restore buffer
    (when irc-buffer-hold
      (goto-char pnt))
    (set-buffer buf)))

;;; ------------------------------------------------
;;; interactive command
;;; ------------------------------------------------

;;; - irc exit
(defun irc-exit ()
  (interactive)
  (irc-cleanup))

;;; - next buffer
(defun irc-next-buffer ()
  (interactive)
  (let ((sbuf (selected-buffer))
	(*next-buffer-in-tab-order* nil))
    (while (and (next-buffer)
		(not (eq sbuf (selected-buffer)))
		(not (find buffer-mode *irc-mode*))))))

;;; - previous buffer
(defun irc-previous-buffer ()
  (interactive)
  (let ((sbuf (selected-buffer))
	(*next-buffer-in-tab-order* nil))
    (while (and (previous-buffer)
		(not (eq sbuf (selected-buffer)))
		(not (find buffer-mode *irc-mode*))))))

;;; - info
(defun irc-info ()
  (interactive)
  (irc-log :msg "irc-info {")
  (irc-log :msg "  server: ~A:~D" *irc-server* *irc-port*)
  (irc-log :msg "  nick: ~A" *irc-nick-registered*)
  (dolist (c *irc-channel*)
    (irc-log :msg "  channel:")
    (irc-log :msg "    name   - ~A" (irc-channel-name c))
    (irc-log :msg "    topic  - ~A" (irc-channel-topic c))
    (irc-log :msg "    user   -~:{ ~A~^~@{:~A~}~}" (irc-channel-user c))
    (irc-log :msg "    joined - ~A" (irc-channel-joined c)))
  (irc-log :msg "}"))

;;; - open connection / close connection
(defun irc-connect (&optional (mode :toggle))
  (interactive)
  (when (eq mode :toggle)
    (setq mode (not (irc-is-connected))))
  (cond (mode
	 (when (irc-is-connected)
	   (irc-log :msg "already connected")
	   (return-from irc-connect t))
	 (irc-open))
	(t
	 (unless (irc-is-connected)
	   (irc-log :msg "not connected")
	   (return-from irc-connect t))
	 (when (yes-or-no-p "DISCONNECT ~A:~D ?" *irc-server* *irc-port*)
	   (irc-close)))))

;;; - send QUIT
(defun irc-send-quit ()
  (interactive)
  (irc-check-connection)
  (when (yes-or-no-p "QUIT ~A:~D ?" *irc-server* *irc-port*)
    (irc-send "QUIT :~A" *irc-quit-message*)))

;;; - send WHOIS
(defun irc-send-whois (&optional nick)
  (interactive)
  (irc-check-connection)
  (unless nick
    (setq nick (irc-completing-read "WHOIS - nick: "
				    (irc-user-list))))
  (irc-send "WHOIS ~A" nick))

;;; - send NICK
(defun irc-send-nick (&optional nick)
  (interactive)
  (irc-check-connection)
  (unless nick
    (setq nick (irc-read-string "NICK - new nick: ")))
  (setq *irc-nick* nick)
  (irc-send "NICK ~A" nick))

;;; - send JOIN
(defun irc-send-join (&optional channel)
  (interactive)
  (irc-check-connection)
  (unless channel
    (setq channel (irc-read-string "JOIN - channel: ")))
  (irc-send "JOIN ~A" channel))

;;; - send PART
(defun irc-send-part (&optional channel)
  (interactive)
  (irc-check-connection)
  (unless channel
    (setq channel (irc-completing-read "PART - channel: "
				       (irc-channel-list)
				       :must-match t)))
  (when (yes-or-no-p "PART ~A ?" channel)
    (irc-send "PART ~A" channel)))

;;; - send PRIVMSG
(defun irc-send-privmsg (&optional nick msg)
  (interactive)
  (irc-check-connection)
  (unless nick
    (setq nick (irc-completing-read "PRIVMSG - nick: " (irc-user-list))))
  (unless msg
    (setq msg (irc-read-string "PRIVMSG - msg: ")))
  (unless (listp msg)
    (setq msg (split-string msg "\n")))
  (dolist (line msg)
    (irc-post-buffered-privmsg nick line)))

;;; - send message based on irc
(defun irc-send-message (&optional msg)
  (interactive)
  (irc-check-connection)
  (unless msg
    (setq msg (irc-read-string "message: ")))
  (irc-send msg))

;;; - send AWAY
(defun irc-send-away (&optional (mode :toggle) msg)
  (interactive)
  (irc-check-connection)
  (cond ((eq mode :toggle)
	 (setq mode (not *irc-away*)))
	((eq *irc-away* mode)
	 (return-from irc-send-away nil)))
  (cond (mode
	 (setq *irc-away-message*
	       (or msg
		   (irc-read-string "AWAY - msg: " :default *irc-away-message*)))
	 (irc-log :msg "registering away message (~A)" *irc-away-message*)
	 (irc-send "AWAY :~A" *irc-away-message*))
	(t
	 (irc-log :msg "unregistering away message")
	 (irc-send "AWAY")))
  (setq *irc-away* mode)
  t)

;;; - send AWAY and NICK
(defun irc-send-away-and-nick (&optional (mode :toggle) msg)
  (interactive)
  (irc-check-connection)
  (when (and (irc-send-away mode msg)
	     (irc-next-nick nil))
    (irc-log :msg "changing nick with un/registering away message")
    (irc-send "NICK ~A" (irc-next-nick nil))))

;;; ------------------------------------------------
;;; internal
;;; ------------------------------------------------

(defun irc-setup ()
  (if (irc-is-exist)
      (switch-to-buffer *irc-log-buffer*)
    (progn
      (switch-to-buffer *irc-log-buffer*)
      ; setup buffer
      (irc-log-mode)
      (set-buffer-alternate-file-name "SERVER: " *irc-log-buffer*)
      ; timer
      (stop-timer 'irc-send-buffered-msg)
      (start-timer *irc-send-interval* 'irc-send-buffered-msg)
      ; hook
      (run-hooks '*irc-setup-hook*)
      ; ※ kill-xyzzyによりサブプロセスが終了させられる際に、、
      ; irc-sentinelにサブプロセスの終了が通知される前に
      ; *kill-xyzzy-hook*のirc-cleanupが実行されるのを防ぐため、
      ; プロセスの終了を待ち合わせる。これをしないと
      ; 無意味なDISCONNECTの確認ダイアログが表示される。
      ; log
      (irc-log :msg "irc setup")
      (irc-log :msg "version is ~A" *irc-software*))))

(add-hook '*kill-xyzzy-hook* 'irc-cleanup)
(add-hook '*kill-xyzzy-hook* 'irc-wait-disconnect)
(defun irc-cleanup ()
  (when (and (irc-is-exist)
	     (irc-connect nil))
    ; timer
    (stop-timer 'irc-send-buffered-msg)
    ; hook
    (run-hooks '*irc-cleanup-hook*)
    ; log
    (irc-log :msg "irc cleaned up")
    ; cleanup buffer
    (dolist (buf (buffer-list))
      (set-buffer buf)
      (when (find buffer-mode *irc-mode*)
	(delete-buffer buf)))))

(defun irc-open ()
  (unless (irc-next-nick nil)
    (irc-log :msg "first nick must be non nil")
    (return-from irc-open nil))
  (irc-log :msg "connecting ~A:~A" *irc-server* *irc-port*)
  ; init
  (setq *irc-away* nil)
  (setq *irc-nick-registered* (irc-next-nick nil))
  (setq *irc-channel* nil)
  (setq *irc-rest-message* nil)
  (setq *irc-nick-repeat-count* 0)
  (setq *irc-namereply* nil)
  (handler-case
      (setq *irc-process*
	    (open-network-stream *irc-log-buffer* *irc-server* *irc-port*
				 :incode *irc-incode*
				 :outcode *irc-outcode*
				 :eol-code *irc-eol-code*))
    (condition (c)
      (irc-log :err (si:*condition-string c))
      (error c)))
  (irc-log :msg "connected ~A:~A" *irc-server* *irc-port*)
  (set-process-filter *irc-process* 'irc-filter)
  (set-process-sentinel *irc-process* 'irc-sentinel)
  ; connected
  (set-buffer-alternate-file-name
   (format nil "SERVER: ~A:~D" *irc-server* *irc-port*)
   *irc-log-buffer*)
  ; hook
  (run-hooks '*irc-open-hook*)
  ; initial dialog
  (irc-send "PASS ~A" *irc-pass*)
  (sit-for *irc-send-interval*)
  (irc-send "NICK ~A" *irc-nick-registered*)
  (sit-for *irc-send-interval*)
  (irc-send "USER ~A ~A * :~A" *irc-user* *irc-user-mode* *irc-realname*)
  t)

(defun irc-close ()
  (irc-send "QUIT :~A" *irc-quit-message*)
  (set-buffer *irc-log-buffer*)
  (kill-subprocess)
  ; ※ irc-closeは終了処理のきっかけになるだけで、
  ; 実際にはirc-sentinelが全て行う。
  (irc-wait-disconnect))

(defun irc-filter (process line)
  (let (l m w)
    ; buffering
    (setq l (concat *irc-rest-message* line))
    (setq m (split-string l "\n"))
    (setq *irc-rest-message* "")
    (unless (string= "\n" (substring l (1- (length l))))
      (setq *irc-rest-message* (car (last m)))
      (setq m (nbutlast m)))
    (setq w (selected-window))
    ; escape minibuffer
    (when (minibuffer-window-p w)
      (other-window))
    ; process every line
    (dolist (i m)
      (handler-case
	  (block oneline
	    (irc-log :in_ i)
	    (let (prefix command param trailing nick user host msg)
	      ; check format
	      (when (string-matchp *irc-regexp-msg* i)
		(setq prefix (match-string 2))
		(setq command (match-string 3))
		(setq param (split-string (match-string 4) #\SPC))
		(setq trailing (match-string 7)))
	      (when (and (stringp prefix)
			 (string-matchp *irc-regexp-prefix* prefix))
		(setq nick (match-string 1))
		(setq user (match-string 3))
		(setq host (match-string 5)))
	      (setq msg (make-irc-message :nick-or-server nick
					  :user user
					  :host host
					  :command command
					  :param param
					  :trailing trailing))
	      ; hook
	      (when (run-hook-with-args-until-success '*irc-before-filter-hook* msg)
		(return-from oneline nil))
	      (run-hook-with-args-until-success '*irc-filter-hook* msg)
	      (run-hook-with-args-until-success '*irc-after-filter-hook* msg))
	    ;; - check logic begin
	    (dolist (c *irc-channel*)
	      (unless (irc-channel-p c)
		(irc-log :err "<please send latest information on *Trace Output*>")
		(msgbox "<please send latest information on *Trace Output*>")
		(toggle-trace-on-error t)
		(error 'simple-condition)))
	    ;; - check logic end
	    )
	; error handling
	(error (c)
	  (irc-log :err (si:*condition-string c)))))
    ; restore minibuffer
    (when (minibuffer-window-p w)
      (set-window w)))
  ; refresh
  (irc-end-of-buffer)
  (refresh-screen)
  (refresh-title-bar)
  (refresh-tool-bars))

(defun irc-sentinel (process)
  (let (w)
    (setq w (selected-window))
    ; escape minibuffer
    (when (minibuffer-window-p w)
      (other-window))
    ; close ...
    (irc-log :msg "closed ~A:~A" *irc-server* *irc-port*)
    (handler-case
	(run-hooks '*irc-close-hook*)
      (error (c)
	(irc-log :err (si:*condition-string c))))
    ; restore minibuffer
    (when (minibuffer-window-p w)
      (set-window w)))
  ; clear
  (setq *irc-process* nil)
  (set-buffer-alternate-file-name "SERVER: " *irc-log-buffer*)
  (setq *irc-away* nil)
  (setq *irc-nick-registered* nil)
  (setq *irc-channel* nil)
  (setq *irc-rest-message* nil)
  (setq *irc-nick-repeat-count* 0)
  (setq *irc-namereply* nil)
  ; refresh
  (irc-end-of-buffer)
  (refresh-screen)
  (refresh-title-bar)
  (refresh-tool-bars))

(defun irc-send (fmt &rest args)
  (let ((m (apply #'format nil fmt args)))
    (cond ((irc-is-connected)
	   (process-send-string *irc-process* (format nil "~A~%" m))
	   (irc-log :out m)
	   t)
	  (t
	   (irc-log :err m)
	   nil))))

;;; ------------------------------------------------
;;; hook for log
;;; ------------------------------------------------

;;; log no pingpong
(defun irc-log-no-pingpong (type text)
  (and *irc-log-no-pingpong*
       (or (eq type :in_) (eq type :out))
       (string-matchp "\\(PING\\|PONG\\)" text)))

;;; log no privmsg
(defun irc-log-no-privmsg (type text)
  (and *irc-log-no-privmsg*
       (or (eq type :in_) (eq type :out))
       (string-matchp "PRIVMSG" text)))

;;; log no in/out
(defun irc-log-no-inout (type text)
  (and *irc-log-no-inout*
       (or (eq type :in_) (eq type :out))))

;;; ------------------------------------------------
;;; hook for message
;;; ------------------------------------------------

;;; default hook
#|
irc-setup
　　*irc-setup-hook*

irc-cleanup
　　*irc-cleanup-hook*

irc-open
　　*irc-open-hook*

irc-sentinel
　　*irc-close-hook*
　　　　irc-command-close
　　　　　　*irc-closed-hook*

irc-log-mode
　　*irc-log-mode-hook*

irc-filter
　　*irc-before-filter-hook*
　　*irc-filter-hook*
　　　　irc-command-ping
　　　　irc-command-privmsg
　　　　　　*irc-command-privmsg-hook*
　　　　irc-command-join
　　　　　　*irc-command-join-hook*
　　　　　　　　irc-command
　　　　irc-command-kick
　　　　　　*irc-command-nick-hook*
　　　　　　　　irc-command
　　　　irc-command-part
　　　　　　*irc-command-part-hook*
　　　　　　　　irc-command
　　　　irc-command-quit
　　　　　　*irc-command-quit-hook*
　　　　　　　　irc-command2
　　　　irc-command-nick
　　　　　　*irc-command-nick-hook*
　　　　　　　　irc-command2
　　　　irc-command-mode
　　　　　　*irc-command-mode-hook*
　　　　　　　　irc-command
　　　　irc-command-topic
　　　　　　*irc-command-topic-hook*
　　　　　　　　irc-command
　　　　irc-command-001
　　　　irc-command-numeric
　　　　irc-command-332
　　　　irc-command-353
　　　　　　*irc-command-353-hook*
　　　　irc-command-366
　　　　　　*irc-command-353-hook*
　　　　irc-command-433
　　　　irc-command-other-numeric
　　*irc-after-filter-hook*

*post-command-hook*
　　irc-not-modified
　　irc-minibuf-resize

start-timer
　　irc-send-bufferd-privmsg
|#

;;; PING/PONG
(defun irc-command-ping (msg)
  (when (string-equal (irc-message-command msg) "PING")
    (gc)
    (irc-send "PONG :~A" (irc-message-trailing msg))
    t))

;;; PRIVMSG/NOTICE
(defun irc-command-privmsg (msg)
  (when (and (find (irc-message-command msg) '("PRIVMSG" "NOTICE")
		   :test 'string-equal)
	     (not (find #\ (irc-message-trailing msg))))
    (let (chname
	  channel
	  (nick-or-server (irc-message-nick-or-server msg))
	  (user (irc-message-user msg))
	  (host (irc-message-host msg))
	  (command (irc-message-command msg))
	  (param (irc-message-param msg))
	  (trailing (irc-message-trailing msg))
	  (text (irc-message-text msg)))
      ; - init
      (setq channel (find (nth 0 param) *irc-channel*
			  :test 'string-equal
			  :key 'irc-channel-name))
      ; - text
      (unless (irc-message-text msg)
	(cond (channel
	       (setf (irc-message-text msg)
		     (format nil "~A@~A privmsg ~A"
			     nick-or-server (irc-channel-name channel) trailing)))
	      (t
	       (setf (irc-message-text msg)
		     (format nil "~A privmsg ~A"
			     nick-or-server trailing)))))
      ; - hook
      (run-hook-with-args '*irc-command-privmsg-hook*
			  msg channel nick-or-server trailing))
    t))

;;; JOIN
(defun irc-command-join (msg)
  (when (string-equal (irc-message-command msg) "JOIN")
    (let (chname
	  channel
	  (nick-or-server (irc-message-nick-or-server msg))
	  (user (irc-message-user msg))
	  (host (irc-message-host msg))
	  (command (irc-message-command msg))
	  (param (irc-message-param msg))
	  (trailing (irc-message-trailing msg))
	  (text (irc-message-text msg)))
      ; - init
      (setq chname (or (nth 0 param) trailing))
      ; - text
      (unless (irc-message-text msg)
	(setf (irc-message-text msg)
	      (format nil "~A@~A joined" nick-or-server chname)))
      ; - join
      (cond ((string-equal nick-or-server *irc-nick-registered*)
	     (setq channel (make-irc-channel :name chname :joined t))
	     (pushnew channel *irc-channel*))
	    (t
	     (setq channel (find chname *irc-channel*
				 :test 'string-equal
				 :key 'irc-channel-name))
	     (pushnew (cons nick-or-server nil) (irc-channel-user channel))))
      ; - hook
      (run-hook-with-args '*irc-command-join-hook*
			  msg channel nick-or-server))
    t))

;;; KICK
(defun irc-command-kick (msg)
  (when (string-equal (irc-message-command msg) "KICK")
    (let (chname
	  channel
	  (nick-or-server (irc-message-nick-or-server msg))
	  (user (irc-message-user msg))
	  (host (irc-message-host msg))
	  (command (irc-message-command msg))
	  (param (irc-message-param msg))
	  (trailing (irc-message-trailing msg))
	  (text (irc-message-text msg)))
      ; - init
      (setq channel (find (nth 0 param) *irc-channel*
			  :test 'string-equal
			  :key 'irc-channel-name))
      ; - text
      (unless (irc-message-text msg)
	(setf (irc-message-text msg)
	      (format nil "~A@~A was kicked off by ~A (~A)"
		      (nth 1 param) (nth 0 param) nick-or-server trailing)))
      ; - kick
      (delete (nth 1 param) (irc-channel-user channel)
	      :test 'string-equal
	      :key 'car)
      (when (string-equal (nth 1 param) *irc-nick-registered*)
	(setf (irc-channel-joined channel) nil)
	(delete (nth 0 param) *irc-channel*
		:test 'string-equal
		:key 'irc-channel-name))
      ; - hook
      (run-hook-with-args '*irc-command-kick-hook*
			  msg channel nick-or-server (nth 1 param)))
    t))

;;; PART
(defun irc-command-part (msg)
  (when (string-equal (irc-message-command msg) "PART")
    (let (chname
	  channel
	  (nick-or-server (irc-message-nick-or-server msg))
	  (user (irc-message-user msg))
	  (host (irc-message-host msg))
	  (command (irc-message-command msg))
	  (param (irc-message-param msg))
	  (trailing (irc-message-trailing msg))
	  (text (irc-message-text msg)))
      ; - init
      (setq channel (find (nth 0 param) *irc-channel*
			  :test 'string-equal
			  :key 'irc-channel-name))
      ; - text
      (unless (irc-message-text msg)
	(setf (irc-message-text msg)
	      (format nil "~A@~A parted" nick-or-server (nth 0 param))))
      ; - part
      (delete nick-or-server (irc-channel-user channel)
	      :test 'string-equal
	      :key 'car)
      (when (string-equal nick-or-server *irc-nick-registered*)
	(setf (irc-channel-joined channel) nil)
	(delete (nth 0 param) *irc-channel*
		:test 'string-equal
		:key 'irc-channel-name))
      ; - hook
      (run-hook-with-args '*irc-command-part-hook*
			  msg channel nick-or-server))
    t))

;;; QUIT
(defun irc-command-quit (msg)
  (when (string-equal (irc-message-command msg) "QUIT")
    (let (chname
	  channel
	  (nick-or-server (irc-message-nick-or-server msg))
	  (user (irc-message-user msg))
	  (host (irc-message-host msg))
	  (command (irc-message-command msg))
	  (param (irc-message-param msg))
	  (trailing (irc-message-trailing msg))
	  (text (irc-message-text msg)))
      ; - text
      (unless (irc-message-text msg)
	(setf (irc-message-text msg)
	      (format nil "~A quitted (~A)" nick-or-server trailing)))
      ; - quit
      (dolist (channel *irc-channel*)
	(let ((n (find nick-or-server (irc-channel-user channel)
		       :test 'string-equal
		       :key 'car)))
	  (when n
	    (delete nick-or-server (irc-channel-user channel)
		    :test 'string-equal
		    :key 'car)
	    (when (string-equal nick-or-server *irc-nick-registered*)
	      (setf (irc-channel-joined channel) nil))
	    ; - hook
	    (run-hook-with-args '*irc-command-quit-hook*
				msg channel nick-or-server trailing))))
      (run-hook-with-args '*irc-command-quit-hook*
			  msg nil nick-or-server trailing))
    t))

;;; NICK
(defun irc-command-nick (msg)
  (when (string-equal (irc-message-command msg) "NICK")
    (let (chname
	  channel
	  (nick-or-server (irc-message-nick-or-server msg))
	  (user (irc-message-user msg))
	  (host (irc-message-host msg))
	  (command (irc-message-command msg))
	  (param (irc-message-param msg))
	  (trailing (irc-message-trailing msg))
	  (text (irc-message-text msg)))
      ; - text
      (unless (irc-message-text msg)
	(setf (irc-message-text msg)
	      (format nil "~A changed nick to ~A" nick-or-server trailing)))
      ; - nick
      (when (string-equal nick-or-server *irc-nick-registered*)
	(setq *irc-nick-registered* trailing))
      (dolist (channel *irc-channel*)
	(let ((n (find nick-or-server (irc-channel-user channel)
		       :test 'string-equal
		       :key 'car)))
	  (when n
	    (setf (car n) trailing)
	    ; - hook
	    (run-hook-with-args '*irc-command-nick-hook*
				msg channel trailing nick-or-server))))
      (run-hook-with-args '*irc-command-nick-hook*
			  msg nil trailing nick-or-server))
    t))

;;; MODE
(defun irc-command-mode (msg)
  (when (string-equal (irc-message-command msg) "MODE")
    (let (chname
	  channel
	  (nick-or-server (irc-message-nick-or-server msg))
	  (user (irc-message-user msg))
	  (host (irc-message-host msg))
	  (command (irc-message-command msg))
	  (param (irc-message-param msg))
	  (trailing (irc-message-trailing msg))
	  (text (irc-message-text msg)))
      (when (nth 2 param)
	(cond ((string-match "\+.*o" (nth 1 param))
	       (let (channel)
		 ; - init
		 (setq channel (find (nth 0 param) *irc-channel*
				     :test 'string-equal
				     :key 'irc-channel-name))
		 ; - text
		 (unless (irc-message-text msg)
		   (setf (irc-message-text msg)
			 (format nil "~A@~A mode +o by ~A"
				 (nth 2 param) (nth 0 param) nick-or-server)))
		 ; - mode +o
		 (pushnew #\o (cdr (find (nth 2 param) (irc-channel-user channel)
					 :test 'string-equal
					 :key 'car)))
		 ; - hook
		 (run-hook-with-args '*irc-command-mode-hook*
				     msg channel (nth 2 param) (nth 0 param) "+o")))
	      ((string-match "-.*o" (nth 1 param))
	       (let (channel)
		 ; - init
		 (setq channel (find (nth 0 param) *irc-channel*
				     :test 'string-equal
				     :key 'irc-channel-name))
		 ; - text
		 (unless (irc-message-text msg)
		   (setf (irc-message-text msg)
			 (format nil "~A@~A mode -o by ~A"
				 (nth 2 param) (nth 0 param) nick-or-server)))
		 ; - mode -o
		 (delete #\o (find (nth 2 param) (irc-channel-user channel)
				   :test 'string-equal
				   :key 'car))
		 ; - hook
		 (run-hook-with-args '*irc-command-mode-hook*
				     msg channel (nth 2 param) (nth 0 param) "-o"))))))
    t))

;;; TOPIC
; ※332 RPL_TOPICとほとんど同じ
(defun irc-command-topic (msg)
  (when (string-equal (irc-message-command msg) "TOPIC")
    (let (chname
	  channel
	  (nick-or-server (irc-message-nick-or-server msg))
	  (user (irc-message-user msg))
	  (host (irc-message-host msg))
	  (command (irc-message-command msg))
	  (param (irc-message-param msg))
	  (trailing (irc-message-trailing msg))
	  (text (irc-message-text msg)))
      ; - init
      (setq channel (find (nth 0 param) *irc-channel*
			  :test 'string-equal
			  :key 'irc-channel-name))
      ; - text
      (unless (irc-message-text msg)
	(setf (irc-message-text msg)
	      (format nil "~A@~A changed topic (~A)"
		      nick-or-server (nth 0 param) trailing)))
      ; - topic
      (setf (irc-channel-topic channel) trailing)
      ; - hook
      (run-hook-with-args '*irc-command-topic-hook*
			  msg channel nick-or-server trailing))
    t))

;;; 001 RPL_WELCOME
(defun irc-command-001 (msg)
  (when (string-equal (irc-message-command msg) "001")
    (let (chname
	  channel
	  (nick-or-server (irc-message-nick-or-server msg))
	  (user (irc-message-user msg))
	  (host (irc-message-host msg))
	  (command (irc-message-command msg))
	  (param (irc-message-param msg))
	  (trailing (irc-message-trailing msg))
	  (text (irc-message-text msg)))
      (setq *irc-nick-registered* (car param))
      (when *irc-channel-startup*
	(irc-send "JOIN ~A~{,~A~}" (car *irc-channel-startup*) (cdr *irc-channel-startup*)))
      (irc-log :rpl "%%% ~A" trailing))
    t))

;;; numeric message
(defun irc-command-numeric (msg)
  (when (find (irc-message-command msg)
	      *irc-numeric-message*
	      :test 'string-equal)
    (let (chname
	  channel
	  (nick-or-server (irc-message-nick-or-server msg))
	  (user (irc-message-user msg))
	  (host (irc-message-host msg))
	  (command (irc-message-command msg))
	  (param (irc-message-param msg))
	  (trailing (irc-message-trailing msg))
	  (text (irc-message-text msg)))
      (irc-log :rpl "%%% ~{~A ~}~A" (cdr param) trailing))
    t))

;;; other numeric message
; ※本来は必要なものだけをirc-command-numericで受け取るようにする。
; 　ここを残しているのはデバグのため
(defun irc-command-other-numeric (msg)
  (when (string-match "^[0-9][0-9][0-9]$" (irc-message-command msg))
    (let (chname
	  channel
	  (nick-or-server (irc-message-nick-or-server msg))
	  (user (irc-message-user msg))
	  (host (irc-message-host msg))
	  (command (irc-message-command msg))
	  (param (irc-message-param msg))
	  (trailing (irc-message-trailing msg))
	  (text (irc-message-text msg)))
      (irc-log :rpl "%%% ~{~A ~}~A" (cdr param) trailing))
    t))

;;; 332 RPL_TOPIC
; ※TOPICとほとんど同じ
(defun irc-command-332 (msg)
  (when (string-equal (irc-message-command msg) "332")
    (let (chname
	  channel
	  (nick-or-server (irc-message-nick-or-server msg))
	  (user (irc-message-user msg))
	  (host (irc-message-host msg))
	  (command (irc-message-command msg))
	  (param (irc-message-param msg))
	  (trailing (irc-message-trailing msg))
	  (text (irc-message-text msg)))
      ; - init
      (setq channel (find (nth 1 param) *irc-channel*
			  :test 'string-equal
			  :key 'irc-channel-name))
      ; - text
      (unless (irc-message-text msg)
	(setf (irc-message-text msg)
	      (format nil "~A@~A set topic (~A)"
		      nick-or-server (nth 1 param) trailing)))
      ; - topic
      (setf (irc-channel-topic channel) trailing)
      ; - hook
      (run-hook-with-args '*irc-command-topic-hook*
			  msg channel nick-or-server trailing))
    t))

;;; 353 RPL_NAMREPLY
(defun irc-command-353 (msg)
  (when (string-equal (irc-message-command msg) "353")
    (let (chname
	  channel
	  (nick-or-server (irc-message-nick-or-server msg))
	  (user (irc-message-user msg))
	  (host (irc-message-host msg))
	  (command (irc-message-command msg))
	  (param (irc-message-param msg))
	  (trailing (irc-message-trailing msg))
	  (text (irc-message-text msg)))
      ; - next channel
      (cond ((not *irc-namereply-channel*)
	     ; - init
	     (setq *irc-namereply-channel* (nth 2 param))
	     (setq *irc-namereply* nil))
	    ((string/= *irc-namereply-channel* (nth 2 param))
	     ; - hook
	     (setq chname (find *irc-namereply-channel* *irc-channel*
				:test 'string-equal
				:key 'irc-channel-name))
	     (setf (irc-channel-user chname) *irc-namereply*)
	     (run-hook-with-args '*irc-command-353-hook* msg chname)
	     ; - init
	     (setq *irc-namereply-channel* (nth 2 param))
	     (setq *irc-namereply* nil)))
      ; - nick
      (dolist (i (split-string trailing #\SPC))
	(cond ((char= (char i 0) #\@)
	       (pushnew (cons (substring i 1) (list #\o)) *irc-namereply*))
	      ((char= (char i 0) #\+)
	       (pushnew (cons (substring i 1) nil) *irc-namereply*))
	      (t
	       (pushnew (cons i nil) *irc-namereply*)))))
    t))

;;; 366 RPL_ENDOFNAMES
(defun irc-command-366 (msg)
  (when (string-equal (irc-message-command msg) "366")
    (let (chname
	  channel
	  (nick-or-server (irc-message-nick-or-server msg))
	  (user (irc-message-user msg))
	  (host (irc-message-host msg))
	  (command (irc-message-command msg))
	  (param (irc-message-param msg))
	  (trailing (irc-message-trailing msg))
	  (text (irc-message-text msg)))
      ; - hook
      (setq chname (find *irc-namereply-channel* *irc-channel*
			 :test 'string-equal
			 :key 'irc-channel-name))
      (setf (irc-channel-user chname) *irc-namereply*)
      (run-hook-with-args '*irc-command-353-hook* msg chname)
      ; - init
      (setq *irc-namereply-channel* nil)
      (setq *irc-namereply* nil))
    t))

;;; 433 ERR_NICKNAMEINUSE
(defun irc-command-433 (msg)
  (when (string-equal (irc-message-command msg) "433")
    (let (chname
	  channel
	  (nick-or-server (irc-message-nick-or-server msg))
	  (user (irc-message-user msg))
	  (host (irc-message-host msg))
	  (command (irc-message-command msg))
	  (param (irc-message-param msg))
	  (trailing (irc-message-trailing msg))
	  (text (irc-message-text msg)))
      (let ((n (irc-next-nick t)))
	(cond (n
	       (irc-log :msg "retrying nick with ~A" n)
	       (irc-send "NICK ~A" n))
	      (t
	       (irc-log :msg "there are no nicks")
	       (irc-connect nil)))))
    t))

;;; close
(defun irc-command-close ()
  (let ((text (format nil  "closed ~A:~A" *irc-server* *irc-port*)))
    ; - quit
    (dolist (channel *irc-channel*)
      (setf (irc-channel-joined channel) nil)
      ; - hook
      (run-hook-with-args '*irc-closed-hook* text channel))
    (run-hook-with-args '*irc-closed-hook* text nil)
    t))

;;; ------------------------------------------------
;;; hook for ...
;;; ------------------------------------------------

(defun irc-command (msg &rest dummy)
  (irc-log :msg (irc-message-text msg)))

(defun irc-command2 (msg channel &rest dummy)
  (unless channel
    (irc-log :msg (irc-message-text msg))))

(add-hook '*post-command-hook* 'irc-not-modified)
(defun irc-not-modified ()
  (and (find buffer-mode *irc-mode*)
       (set-buffer-modified-p nil)))

(add-hook '*post-command-hook* 'irc-minibuf-resize)
(defun irc-minibuf-resize ()
  (and *irc-minibuf-size*
       (minibuffer-window-p (selected-window))
       (let ((l (save-excursion
		  (goto-char (point-max))
		  (current-line-number)))
	     (h (window-height)))
	 (when (< *irc-minibuf-size* l)
	   (setq l *irc-minibuf-size*))
	 (unless (= l h)
	   (enlarge-window (- l h))))))

;;; ------------------------------------------------
;;; support section
;;; ------------------------------------------------

;;; check
(defun irc-is-exist ()
  (find-buffer *irc-log-buffer*))

(defun irc-is-connected ()
  (and *irc-process*
       (eq (process-status *irc-process*) ':run)))

(defun irc-wait-disconnect ()
  (while (irc-is-connected)
    (sit-for 0.1))
  t)

;;; nick
(defun irc-next-nick (&optional next)
  (cond (next
	 (incf *irc-nick-repeat-count*)
	 (format nil "~A~D"
		 (if *irc-away* *irc-nick-away* *irc-nick*)
		 *irc-nick-repeat-count*))
	(t
	 (setq *irc-nick-repeat-count* 0)
	 (if *irc-away* *irc-nick-away* *irc-nick*))))

;;; buffered message (common)
(defun irc-cancel-buffered-msg ()
  (interactive)
  (when irc-buffered-msg
    (irc-log :msg "canceled ~D buffered messages" (length irc-buffered-msg))
    (setq irc-buffered-msg nil))
  (quit))

(defun irc-send-buffered-msg ()
  (let (c m w b)
    (setq w (selected-window))
    ; escape minibuffer
    (when (minibuffer-window-p w)
      (other-window))
    (setq b (selected-buffer))
    ; every buffer
    (dolist (buf (buffer-list))
      (set-buffer buf)
      (when (and (find buffer-mode *irc-mode*)
		 irc-buffered-msg)
	(setq m (pop irc-buffered-msg))
	(funcall m)
	(setq c t)))
    ; restore minibuffer
    (set-buffer b)
    (when (minibuffer-window-p w)
      (set-window w))
    ; refresh
    (when c
      (irc-end-of-buffer)
      (refresh-screen))))

;;; hold buffer
(defun irc-hold-buffer (&optional (mode :toggle))
  (interactive)
  (cond ((eq mode :toggle)
	 (setq mode (not irc-buffer-hold)))
	((eq irc-buffer-hold mode)
	 (return-from irc-hold-buffer nil)))
  (cond (mode
	 (irc-log :msg "buffer held"))
	(t
	 (irc-log :msg "never buffer held")))
  (setq irc-buffer-hold mode))

;;; end of buffer
(defun irc-end-of-buffer ()
  (let (w)
    (setq w (selected-window))
    (loop
      (and (find buffer-mode *irc-mode*)
	   (not irc-buffer-hold)
	   (goto-char (point-max)))
      (other-window)
      (when (eq w (selected-window))
	(return)))))

;;; buffered message
(defun irc-post-buffered-privmsg (nick-or-channel fmt &rest args)
  (let ((m (if args (apply #'format nil fmt args) fmt)))
    (setq irc-buffered-msg
	  (append irc-buffered-msg
		  (list #'(lambda ()
			    (irc-send "PRIVMSG ~A :~A" nick-or-channel m)))))))

(defun irc-post-buffered-notice (nick-or-channel fmt &rest args)
  (let ((m (if args (apply #'format nil fmt args) fmt)))
    (setq irc-buffered-msg
	  (append irc-buffered-msg
		  (list #'(lambda ()
			    (irc-send "NOTICE ~A :~A" nick-or-channel m)))))))

;;; channel list
(defun irc-channel-list ()
  (mapcar 'irc-channel-name *irc-channel*))

;;; userl list
(defun irc-user-list ()
  (remove-duplicates
   (apply 'append (mapcar #'(lambda (c) (mapcar 'car (irc-channel-user c))) *irc-channel*))
   :test 'string-equal))

;;; check connection
(defun irc-check-connection ()
  (unless (irc-is-connected)
    (msgbox "not connected")
    (quit)))
