;;; -*- Mode: Lisp; Package:jtc -*-
;;;
;;; jtc-shell.l --- JavaTinyConsole
;;;

;;; author
;;;	YAMAMOTO Taizo

;;; date
;;;	Last updated: "2003-04-28"

(provide "jtc/jtc-shell")

(require "shell")
(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "jtc/jtc-def"))

(in-package "jtc")

;;; 変数
(export '(*jtc-error-regexp*
	  *jtc-output-buffer-name*
	  *jtc-error-attr1*
	  *jtc-error-attr2*))

(defvar *jtc-error-regexp* (compile-regexp "^\\(.+\\)[:：][ \t]*\\([0-9]+\\)\\([:： \t]\\|$\\)\\|^[ \t]*at [^()\n]+(\\([^:)\n]+\\):\\([0-9]+\\))"))
(defvar *jtc-command-buffer-name* "*jtc:output*")
(defvar *jtc-output-buffer-name* "*jtc:output*")
(defvar *jtc-error-attr1* '(:bold t :foreground 1))
(defvar *jtc-error-attr2* '(:bold t))

(defvar *jtc-property-page-no* nil)
(defvar *jtc-build-last-command* "")

(pushnew (list (compile-regexp "^[ \t]*at [^()\n]+(\\([^:)\n]+\\):\\([0-9]+\\))$") 1 2)
	 *error-regexp-list*)
(pushnew (list (compile-regexp "^[ \t]*\[[0-9]+\][^(\n]+(\\([^:]+\\):\\([0-9]+\\))$") 1 2)
	 *error-regexp-list*)

;;; シェル
(export '(jtc-tool-bar
	  jtc-show-property
	  jtc-javac-buffer
	  jtc-javac-buffer1
	  jtc-javac-directory
	  jtc-javac-directory1
	  jtc-jdb-buffer
	  jtc-java-buffer
	  jtc-make-command
	  jtc-shell-send-interrupt
	  jtc-jdb-command
	  jtc-java-command
	  jtc-shell-command
	  jtc-build-command))

(defun jtc-show-property ()
  (interactive)
  (setq ed::*option-prop-page-no* *jtc-property-page-no*)
  (option-property-sheet))

(defun jtc-javac-buffer1 ()
  (interactive)
  (jtc-javac-buffer nil))

(defun jtc-shell-send-interrupt ()
  (interactive)
  (unless (is-process-running)
    (show-message "ﾌﾟﾛｾｽはなさそうです")
    (return-from jtc-shell-send-interrupt t))
  (when (find-buffer *jtc-output-buffer-name*)
    (pop-to-buffer
     (prog1 (selected-buffer)
       (pop-to-buffer *jtc-output-buffer-name*)
       (ed::shell-send-interrupt)
       (apply #'set-text-attribute
	      (point)
	      (progn (insert "[停止]") (point))
	      'jtc-err *jtc-error-attr1*)))))

(defun jtc-javac-buffer (&optional (check t))
  (interactive)
  (multiple-value-bind (f g)
      (check-buffer)
    (cond
     ((eq f :nofilename)
      (show-message "ﾌｧｲﾙ名がありません"))
     ((eq f :nojavafile)
      (show-message "javaﾌｧｲﾙではありません"))
     ((if check (eq f :compiled))
      (show-message "多分、ｺﾝﾊﾟｲﾙ済みです"))
     (t
      (jtc-build-command (format nil "~A \"~A\"" (car *jtc-javac-history*)
				 (file-namestring g)))))))

(defun jtc-java-buffer (&optional (check t))
  (interactive)
  (multiple-value-bind (f g h)
      (check-buffer)
    (cond
     ((eq f :nofilename)
      (show-message "ﾌｧｲﾙ名がありません"))
     ((eq f :nojavafile)
      (show-message "javaﾌｧｲﾙではありません"))
     ((if check (eq f :compiled))
      (jtc-java-command (file-namestring h)))
     (t
      (show-message "ｺﾝﾊﾟｲﾙされていません")))))

(defun jtc-jdb-buffer (&optional (check t))
  (interactive)
  (multiple-value-bind (f g h)
      (check-buffer)
    (cond
     ((eq f :nofilename)
      (show-message "ﾌｧｲﾙ名がありません"))
     ((eq f :nojavafile)
      (show-message "javaﾌｧｲﾙではありません"))
     ((if check (eq f :compiled))
      (jtc-jdb-command (file-namestring h)))
     (t
      (show-message "ｺﾝﾊﾟｲﾙされていません")))))

(defun jtc-javac-directory1 ()
  (interactive)
  (jtc-javac-directory nil))

(defun jtc-javac-directory (&optional (check t))
  (interactive)
  (multiple-value-bind (f g)
      (check-dir)
    (cond
     ((eq f :nojavafiles)
      (show-message "javaﾌｧｲﾙが見つかりません"))
     ((not check)
      (jtc-build-command (format nil "~A *.java" (car *jtc-javac-history*))))
     ((eq f :compiled)
      (show-message "多分、全てｺﾝﾊﾟｲﾙ済みです"))
     (t
      (jtc-build-command (format nil "~A~{ \"~A\"~}" (car *jtc-javac-history*) g))))))

(defun jtc-make-command ()
  (interactive)
  (jtc-build-command (car *jtc-make-history*)))

(defun jtc-java-command (f)
  (interactive "e(jtc:java) \np")
  (jtc-shell-command (format nil "~A \"~A\" ~A"
			     (car *jtc-java-history*)
			     f
			     (car *jtc-java-args-history*))))

(defun jtc-jdb-command (f)
  (interactive "e(jtc:jdb) \np")
  (jtc-shell-command (format nil "~A \"~A\"" (car *jtc-jdb-history*) f)))

(defun jtc-shell-command (f)
  (interactive "e(jtc:shell) \np")
  (pop-to-buffer (get-buffer-create *jtc-output-buffer-name*)
		 (truncate (screen-height) 3))
  (when (is-process-running)
    (show-message "別ﾌﾟﾛｾｽ実行中です")
    (return-from jtc-shell-command t))
  (delete-region (point-min) (point-max))
  (let ((*eshell* ""))
    (declare (special *eshell*))
    (ed::shell-mode))
  (make-process f :output (selected-buffer)))

(defun jtc-build-command (cmd)
  (interactive "e(jtc:build) \np"
    :default0 *jtc-build-last-command* :history0 'execute)
  ; jtc-update-temp-completion-listとは違い、エラーが
  ; あるときはジャンプするためsave-window-excursionしない
  (cond
   ; 実行中
   ((is-process-running)
    (show-message "別ﾌﾟﾛｾｽが実行中なので、ﾋﾞﾙﾄﾞしません"))
   ; コマンドのチェック
   ((string= cmd "")
    (show-message "ﾋﾞﾙﾄﾞｺﾏﾝﾄﾞが見つかりません"))
   ; 実行
   (t
    (setq *jtc-build-last-command* cmd)
    (let ((buf (selected-buffer))
	  (dir (default-directory)))
      (long-operation
	(with-output-to-temp-buffer (*jtc-command-buffer-name*)
	  (format t "対象ﾃﾞｨﾚｸﾄﾘ\n\t~A\nﾋﾞﾙﾄﾞ中 ...\n\t~A" dir cmd))
	(message "ﾋﾞﾙﾄﾞ中 ...")
	(execute-shell-command cmd t *jtc-output-buffer-name* t dir))
      (colorize-output-buffer)
      (set-scanner)
      (unless (first-error)
	(pop-to-buffer buf))))))

;;; ローカル用
(defun colorize-output-buffer ()
  (save-window-excursion
    (set-buffer *jtc-output-buffer-name*)
    ; 色づけ
    (goto-char (point-min))
    (while (scan-buffer *jtc-error-regexp* :regexp t :tail t)
      (let ((p (match-beginning 0)) (q (match-end 0)))
	(apply #'set-text-attribute
	       p q 'jtc-err *jtc-error-attr1*)
	(apply #'set-text-attribute
	       q (progn (goto-eol) (point)) 'jtc-err *jtc-error-attr2*)))))

;;; スキャナを設定
(defun set-scanner ()
  (make-local-variable 'ed::*find-error-scanner*)
  (setq ed::*find-error-scanner*
	#'(lambda (&optional l)
	    (let (s)
	      (move-previous-window)
	      (save-excursion
		(save-restriction
		  (narrow-to-region (point)
				    (progn
				      (while (and (next-line) (not (find-text-attribute-point(point)))))
				      (point)))
		  (when (and (scan-buffer "^" :reverse t) (previous-line))
		    (setq s (buffer-substring (point) (progn (goto-eol) (point)))))))
	      (other-window)
	      (when s
		(goto-eol)
		(scan-buffer s :reverse t :limit (- l)))))))

(defun is-process-running ()
  (let ((proc (buffer-process (find-buffer *jtc-output-buffer-name*))))
    (and proc (eq (process-status proc) ':run))))

(defun check-buffer ()
  (let (f g h)
    (setq f (get-buffer-file-name))
    (if (not f)
	:nofilename
      (if (not (string-matchp "^\\(.*\\)\.java$" f))
	  :nojavafile
	(if (not (file-exist-p (setq g (format nil "~A.class" (setq h (substring f (match-beginning 1) (match-end 1)))))))
	    (values :noclassfile f)
	  (if (< (file-write-time f) (file-write-time g))
	      (values :compiled f h)
	    (values :modified f)))))))

(defun check-dir ()
  (let ((f (directory (default-directory) :absolute nil :wild "*.java" :file-only t)))
    (if (null f)
	:nojavafiles
      (progn
	(setq f (remove-if #'(lambda (x)
			       (let (y)
				 (string-matchp "^\\(.*\\)\.java$" x)
				 (setq y (format nil "~A.class" (substring x (match-beginning 1) (match-end 1))))
				 (and (file-exist-p y)
				      (< (file-write-time x)
					 (file-write-time y)))))
			   f))
	(if (null f)
	    :compiled
	  (values :modified f))))))
