;;; -*- Mode: Lisp; Package: editor -*-
;;;
;;; cobol-mode --- COBOL�ҏW�p���[�h

;;; author
;;;	YAMAMOTO Taizo

;;; date
;;;	Last updated: "2003-04-29"

;;; description
;;;	COBOL�ҏW�p���[�h�ł��B

;;; install
;;;	1.�𓀂��ďo�����t�@�C�����ȉ��̃f�B���N�g���ɃR�s�[���܂��B
;;;
;;;		--------------------------------
;;;		etc/COBOL              -> $XYZZY/etc/COBOL
;;;		site-lisp/cobol-mode.l -> $XYZZY/site-lisp/cobol-mode.l
;;;		--------------------------------
;;;
;;;     2.~/.xyzzy��������$XYZZY/site-lisp/siteini.l�ɋL�q��ǉ����܂��B
;;;	  
;;;		--------------------------------
;;;		(export 'ed::cobol-mode "ed")
;;;		(autoload 'cobol-mode "cobol-mode" t)
;;;		(pushnew '("\\.cob$" . cobol-mode) *auto-mode-alist* :test 'string=)
;;;		(pushnew '("\\.cbl$" . cobol-mode) *auto-mode-alist* :test 'string=)
;;;		(pushnew '("\\.cobol$" . cobol-mode) *auto-mode-alist* :test 'string=)
;;;		--------------------------------
;;;	  
;;;     3.��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy���ċN�����܂��B
;;;	  ��siteinit.l�ɋL�q�����ꍇ�ɂ͍ă_���v�����ĉ������B

;;; keybind
;;;	TAB	�C���f���g
;;;	C-.	�^�O�W�����v
;;;	C-,	�o�b�N�^�O�W�����v
;;;	C-x *	�s�̃R�����g��
;;;	C-x :	���[�W�����̃R�����g��

;;; changes
;;;	Sun, 27 Apr 2003 23:32:44 +0900
;;;		���������C��
;;;	Thu, 20 Jan 2000 20:31:43 +0900
;;;		�c�����񂩂����������̂�ǉ�
;;;	Sat, 08 Jan 2000 09:44:33 +0900
;;;		���ɕύX�͂Ȃ����ǌ��J�p�ɏC��
;;;	Thu, 17 Dec 1998 09:20:07 JST-9
;;;		�v���g�^�C�v

(provide "cobol-mode")

(in-package "editor")

(export '(*cobol-mode-hook*
	  *cobol-keyword-file*
	  cobol-mode))

(pushnew '(cobol-maketags "*.cob" "*.cbl") *maketags-list* :key #'car)

(pushnew '("\\.cob" . cobol-mode) *auto-mode-alist* :test 'equal)
(pushnew '("\\.cbl" . cobol-mode) *auto-mode-alist* :test 'equal)

(defvar *cobol-mode-hook* nil)

(defvar *cobol-keyword-hash-table* nil)
(defvar *cobol-keyword-file* "COBOL")

(defvar *cobol-mode-syntax-table* nil)
(unless *cobol-mode-syntax-table*
  (setq *cobol-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x)))((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alphanumericp c)
	(set-syntax-punctuation *cobol-mode-syntax-table* c))))
  (set-syntax-word *cobol-mode-syntax-table* #\-)
  (set-syntax-string *cobol-mode-syntax-table* #\")
  (set-syntax-string *cobol-mode-syntax-table* #\')
  (set-syntax-match *cobol-mode-syntax-table* #\( #\))
  (set-syntax-symbol *cobol-mode-syntax-table* #\/)
  (set-syntax-start-comment *cobol-mode-syntax-table* #\; t)
  (set-syntax-comment-column *cobol-mode-syntax-table* 6)  
  (set-syntax-end-comment *cobol-mode-syntax-table* #\LFD nil t))

(defvar *cobol-mode-map* nil)
(unless *cobol-mode-map*
  (setq *cobol-mode-map* (make-sparse-keymap))
  (define-key *cobol-mode-map* #\TAB 'cobol-tab)
  (define-key *cobol-mode-map* #\C-. 'cobol-jump-tag)
  (define-key *cobol-mode-map* #\C-\, 'cobol-back-tag-jump)
  ; �c�����񂩂���炤
  (define-key *cobol-mode-map* '(#\C-x #\*) 'cobol-comment-line)
  (define-key *cobol-mode-map* '(#\C-x #\:) 'cobol-comment-region))

(defvar *cobol-mode-abbrev-table* nil)
(unless *cobol-mode-abbrev-table*
  (define-abbrev-table '*cobol-mode-abbrev-table*))

; ----------
; �^�O�̒��o
(defun cobol-maketags (file count)
  "cobol-mode: �^�O�t�@�C���̍쐬"
  (goto-char (point-min))
  (while (scan-buffer "^...... \\([^ \t\n]+\\)\\([ \t]+SECTION\\)?\.$" :regexp t :tail t)
    (do-events)
    (format t "~A~A~D" (match-string 1) file (match-beginning 1))
    (incf count))
  count)

; ------------------------------
; �I�����ꂽ�s�̃W�����v��̒��o
(defun tags-find-cobol-target ()
  "cobol-mode: �W�����v��̒��o"
  (values nil
	  (save-excursion
	    (goto-bol)
	    (or (and (scan-buffer "^...... [ \t]*\\(EXIT\\|\\(GO[ \t]+TO\\|PERFORM\\)[ \t]+\\([^ \t\n.]+\\)\\)" :regexp t :tail t)
		     (match-string 3))
		"�^�O"))))

; --------------------
; �W�����v��̈ʒu����
(defun tags-find-cobol-point (class name functionp point)
  "cobol-mode: �W�����v��̈ʒu�̌���"
  (goto-bol)
  (and (scan-buffer (concat "^...... "
			    (regexp-quote name)
			    "\\([ \t]+SECTION\\)?\.$")
		    :regexp t :tail t :limit (+ point *jump-tag-limit*))
       (match-beginning 1)))

; -----------------
; COBOL�p��jump-tag
(defun cobol-jump-tag ()
  (interactive)
  "cobol-mode: �^�O�W�����v"
  (if (looking-at "^...... [ \t]*\\(EXIT\\|\\(GO[ \t]+TO\\|PERFORM\\)[ \t]+\\([^ \t\n.]+\\)\\)")
      (unless (jump-tag)
	(goto-eol))
    (scan-buffer "^...... [ \t]*\\(EXIT\\|\\(GO[ \t]+TO\\|PERFORM\\)[ \t]+\\([^ \t\n.]+\\)\\)" :regexp t :tail nil)))

; ----------------------
; COBOL�p��back-tag-jump
(defun cobol-back-tag-jump ()
  "cobol-mode: �o�b�N�^�O�W�����v"
  (interactive)
  (if (back-tag-jump)
      (goto-eol)))

; --------------------------
; �C���f���g�͂��Ȃ��^�u�ړ�
(defun cobol-tab ()
  (interactive)
  "cobol-mode: �^�u�̈ړ�"
  (let ((col (current-column)))
    (cond ; �s��
	  ((<= col 5)
	   (if (not (eq (goto-column 6) 6))
	       (indent-to 6)))
	  ; �R�����g�̗�
	  ((eq col 6)
	   (if (not (eq (goto-column 7) 7))
	       (indent-to 7)))
	  ; 4�̔{���̗�
	  (t
	   (let ((cnt 0))
	     (while (or (eq cnt 0)
			(not (eq (mod (current-column) 4) 3)))
	       (incf cnt)
	       (cond ((eolp)
		      (insert " "))
		     (t
		      (forward-char)))))))))

; ----------
; cobol-mode
(defun cobol-mode ()
  (interactive)
  "COBOL�p���[�h"
  (kill-all-local-variables)
  (setq mode-name "COBOL")
  (setq buffer-mode 'cobol-mode)
  (use-syntax-table *cobol-mode-syntax-table*)
  (use-keymap *cobol-mode-map*)
  (make-local-variable 'tags-find-target)
  (setq tags-find-target #'tags-find-cobol-target)
  (make-local-variable 'tags-find-point)
  (setq tags-find-point #'tags-find-cobol-point)  
  (and *cobol-keyword-file*
       (null *cobol-keyword-hash-table*)
       (setq *cobol-keyword-hash-table*
	     (load-keyword-file *cobol-keyword-file* t)))
  (when *cobol-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *cobol-keyword-hash-table*))
  (setq *local-abbrev-table* *cobol-mode-abbrev-table*)
  (run-hooks '*cobol-mode-hook*))


; �c�����񂩂炪�߂� ------------------------------------------
; Thu, 20 Jan 2000 20:28:59 +0900

; -------------------------------
; �R�����g�s�ɂ���
; Thu, 20 Jan 2000 20:27:50 +0900
(defun set-comment ()
  "cobol-mode: �R�����g�ɂ���"
  (goto-column 6)
  (delete-region (point) (+ (point) 1))
  (insert "*"))

(defun cobol-comment-line ()
  (interactive)
  "cobol-mode: ���Y�s���R�����g�ɂ���"
  (set-comment))

; -------------------------------
; �w��̈���R�����g�s�ɂ���
; Thu, 20 Jan 2000 20:28:32 +0900
(defun comment-region ()
  (goto-char (region-end))
  (setq end-cnt (current-line-number))
  (goto-char (region-beginning))
  (let ((cnt (current-line-number)))
    (while (< cnt end-cnt)
      (incf cnt)
      (set-comment)
      (forward-line))))

; ---------------------------------
; �w��̈���R�����g�s�ɂ���i�{�́j
; Thu, 20 Jan 2000 20:29:51 +0900
(defun cobol-comment-region ()
  (interactive)
  "cobol-mode: �w��͈͂��R�����g�s�ɂ���"
  (comment-region))
