;;; -*- Mode: Lisp; Package: editor -*-
;;;
;;; watch.l --- �V���{���̃E�H�b�`�@�\

;;; author
;;;	YAMAMOTO Taizo

;;; date
;;;	Last updated: "2003-05-10"

;;; description
;;;	�V���{���̃E�H�b�`���s���܂��B�f�o�O���Ɏg�p�������B
;;;	�펞�A�V���{����\������̂�ListView.dll���g�p���Ă��܂��B

;;; install
;;;	1.ListView.dll�𓱓����܂��B
;;;
;;;		--------------------------------
;;;		http://www003.upp.so-net.ne.jp/rex/
;;;		--------------------------------
;;;
;;;	2.�𓀂��ďo�����t�@�C�����ȉ��̃f�B���N�g���ɃR�s�[���܂��B
;;;
;;;		--------------------------------
;;;		site-lisp/watch.l     -> $XYZZY/site-lisp/watch.l
;;;		etc/watch-bound.ico   -> $XYZZY/etc/watch-bound.ico
;;;		etc/watch-unbound.ico -> $XYZZY/etc/watch-unbound.ico
;;;		etc/watch-error.ico   -> $XYZZY/etc/watch-error.ico
;;;		etc/watch-toolbar.bmp -> $XYZZY/etc/watch-toolbar.bmp
;;;		--------------------------------
;;;
;;;     3.~/.xyzzy��������$XYZZY/site-lisp/siteini.l�ɋL�q��ǉ����܂��B
;;;
;;;		--------------------------------
;;;		(require "listview")
;;;		(require "watch")
;;;		--------------------------------
;;;
;;;     4.��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy���ċN�����܂��B
;;;	  ��siteinit.l�ɋL�q�����ꍇ�ɂ͍ă_���v�����ĉ������B

;;; uninstall
;;; 	1.install�ŃR�s�[�����t�@�C�����폜���܂��B
;;;	2.ESC ESC (delete-command-bar 'editor::watch-tool-bar)
;;;	  �ƃ^�C�v���܂��B
;;;     3.��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy���ċN�����܂��B
;;;	  ��siteinit.l�ɋL�q�����ꍇ�ɂ͍ă_���v�����ĉ������B

;;; keybind
;;;	ListView.dll��ł̃L�[�o�C���h�͈ȉ��̂Ƃ���ł��B
;;;
;;;		--------------------------------
;;; 		DEL BS 	�A�C�e���̍폜
;;;		ESC TAB	xyzzy�փt�H�[�J�X��J��
;;;		F2	�A�C�e���̕ҏW
;;;		--------------------------------

;;; note
;;;	editor::*this-command*���E�H�b�`����Ə����̏d����������܂��B
;;;	���܂�ɏd���ꍇ�ɂ͎g�p���T����悤�ɂ��ĉ������B
;;;	Win98SE+Duron700MHz+256MB���炢�ł������d���C�����܂��B
;;;	�ǋL�j���낢��ƃ`���[�j���O�������ʁA�������������C�����܂�

;;; changes
;;;	Sat, 10 May 2003 22:01:14 +0900
;;;		�V���{�����ϐ�����Ȃ��ꍇ�̑Ή���ǉ�
;;;	Sun, 27 Apr 2003 22:43:02 +0900
;;;		���������C��
;;;	Wed, 20 Mar 2002 07:43:06 +0900
;;;		F2���������Ƃ���watch-edit-label���ĂԂ悤�ɏC��
;;;	Fri, 08 Mar 2002 21:56:07 +0900
;;;		�T�䂳��̃A�h�o�C�X�{��v�ۂ����measure-watch-cost���g���ă`���[�j���O
;;;		���S��callback����lisp�Ń��X�g���Ǘ�����悤�ɕύX
;;;		user��use-package����͕̂ʂ̂Ƃ���ň��e�����o�����Ȃ̂Ŏ��~��
;;;		ignore-erros�̃R�X�g���ƂĂ����������̂Ń��[�v�̊O�ɏo����
;;;		����ł��ϐ����폜
;;;		*watch-initial-symbol-list*��*watch-symbol-list*�ɕύX
;;;		�w�b�_�ɂ��\�[�g�������
;;;		�]�����ɃG���[�����������ꍇ�̃A�C�R���ǉ�
;;;		�A�C�R���p�̃t�@�C������ύX
;;;		�c�[���o�[�p�̃r�b�g�}�b�v�t�@�C����ǉ�
;;;		*watch-show-tool-bar*���폜
;;;		watch-edit-label��ǉ�
;;;		watch-set-focus��ǉ�
;;;	Tue, 05 Mar 2002 22:06:01 +0900
;;;		�֐��̐����A�J�����̒�����ݒ�ł���悤�ɕύX
;;;		���낢��ƕύX�\��
;;;	Sat, 02 Mar 2002 22:57:31 +0900
;;;		ListView.dll ver.1.1�̕����\���Ή��ւ̑Ή�
;;;		���łɃc�[���o�[�����̂悤�ɑΉ�
;;;	Sat, 02 Mar 2002 01:33:46 +0900
;;;		����

;;; special thanks
;;;	ListView���쐬���ꂽkazu.y���Ɏӎ���\���グ�܂��B
;;;	�܂��A�c�[���o�[�֘A��OHKUBO Hiroshi����topmost.l���Q�l�ɂ��Ă��܂��B

(require "ListView")
(provide "watch")

(in-package "editor")

(export '(toggle-watch-listview
	  toggle-watch-enable
	  watch-tool-bar
	  watch-symbol
	  watch-start
	  watch-stop
	  watch-enable
	  watch-disable
	  watch-set-focus
	  watch-edit-label))

(export '(*watch-listview-id*
	  *watch-enable*
	  *watch-listview-pos*
	  *watch-listview-size*
	  *watch-test-list*
	  *watch-symbol-list*
	  *watch-last-list*
	  *watch-error-icon-file*
	  *watch-bounded-icon-file*
	  *watch-unbounded-icon-file*))

;;; watch����

; �ύX��
(defvar *watch-listview-pos* user::XPIS_TOP)
(defvar *watch-listview-size* 100)
(defvar *watch-test-list*
  '(; ���ꂾ���̓A�C�R���̕`��Ɋ֌W����̂ō폜���Ȃ��悤��
    ("�����" boundp 160)
    ; ����ȉ��͓K����
    ("�l" eval 160)
    ("����" (lambda (x) (and x (type-of (eval x)))) 80)
    ("�v�f��" (lambda (x) (and x (sequencep (eval x)) (length (eval x)))) 60)
    ("�ޯ̧۰��" local-variable-p 80)
    ("�����è" symbol-plist 160)))
(defvar *watch-symbol-list*
  ; �ꉞ�Ō�ɋ󔒂͓���Ă����Ă��������i�蔲���j
  '("editor::buffer-mode" "editor::mode-name" ""))
(defvar *watch-error-icon-file* (merge-pathnames "watch-error.ico" (etc-path)))
(defvar *watch-bounded-icon-file* (merge-pathnames "watch-bound.ico" (etc-path)))
(defvar *watch-unbounded-icon-file* (merge-pathnames "watch-unbound.ico" (etc-path)))

; �Q�Ɖ�
(defvar *watch-listview-id* nil)
(defvar *watch-enable* t)
(defvar *watch-last-list* nil)

; �����p
(defvar *watch-item-id* 0)

;;; watch��v�֐�

(defun watch-set-focus ()
  (interactive)
  (when *watch-listview-id*
    (user::listview-set-focus *watch-listview-id*)))

(defun watch-edit-label (&optional n)
  (interactive)
  (when *watch-listview-id*
    (unless (numberp n)
      (setq n (1- (length *watch-symbol-list*))))
    (user::listview-dll-edit-label *watch-listview-id* n)))

(defun watch-enable ()
  (interactive)
  (unless *watch-enable*
    (setq *watch-enable* t)
    (when *watch-listview-id*
      (watch-redraw))))

(defun watch-disable ()
  (interactive)
  (when *watch-enable*
    (setq *watch-enable* nil)
    (when *watch-listview-id*
      (watch-redraw))))

(defun watch-stop ()
  (interactive)
  (when *watch-listview-id*
    (user::listview-dll-remove-all-icons *watch-listview-id*)
    (user::listview-dll-delete-all-items *watch-listview-id*)
    (user::listview-close *watch-listview-id*)
    (setq *watch-listview-id* nil)))

(defun watch-start ()
  (interactive)
  (unless *watch-listview-id*
    (setq *watch-listview-id* (user::listview-create-ex *watch-listview-size* *watch-listview-pos*))
    (user::listview-dll-modify-style *watch-listview-id* user::LVS_TYPEMASK user::LVS_REPORT 0)
    (user::listview-dll-modify-style *watch-listview-id* user::LVS_TYPESTYLEMASK user::LVS_EDITLABELS 0)
    (user::listview-keydown-callback
     *watch-listview-id*
     '(lambda (x y z)
       (cond ((find y '(8 46)) ; BS DEL�̂݃A�C�e�����폜
	      (unless (= x (1- (length *watch-symbol-list*)))
		(user::listview-delete-item *watch-listview-id* x)
		(setq *watch-symbol-list* ; ���̋L�q���C�}�C�`
		      (append (subseq *watch-symbol-list* 0 x)
			      (subseq *watch-symbol-list* (1+ x))))
		(watch-redraw)))
	     ((find y '(9 27)) ; TAB ESC�̏ꍇ��xyzzy�ɖ߂�
	      (user::SetFocus (get-window-handle)))
	     ((find y '(113)) ; F2�̏ꍇ�͕ҏW
	      (watch-edit-label x)))))
    (user::listview-edit-label-callback
     *watch-listview-id*
     '(lambda (idx txt)
       (cond ((string= txt "")
	      (progn
		; �ŏI�s�̏ꍇ�͉������Ȃ�
		; �ŏI�s�ȊO�̏ꍇ�͍폜����
		(when (/= idx (1- (length *watch-symbol-list*)))
		  (user::listview-delete-item *watch-listview-id* idx)
		  (setq *watch-symbol-list*	; ���̋L�q���C�}�C�`
			(append (subseq *watch-symbol-list* 0 idx)
				(subseq *watch-symbol-list* (1+ idx)))))))
	     (t
	      (progn
		; �s���X�V����
		(user::listview-set-item-text *watch-listview-id* idx 0 txt)
		(setq *watch-symbol-list* ; ���̋L�q�͂����ƃ_��
		      (append (subseq *watch-symbol-list* 0 idx)
			      (list txt)
			      (subseq *watch-symbol-list* (1+ idx))))
		; �ŏI�s�̏ꍇ�� �s��ǉ�����
		(when (= idx (1- (length *watch-symbol-list*)))
		  (user::listview-insert-item *watch-listview-id* (1+ idx) ""
					      :icon *watch-unbounded-icon*
					      :id (incf *watch-item-id*))
		  (setq *watch-symbol-list*	; ����͖���������
			(append *watch-symbol-list* '("")))))))
       (watch-redraw)))
    (dotimes (idx (length *watch-test-list*))
      (let ((itm (nth idx *watch-test-list*)))
	(user::listview-insert-column
	 *watch-listview-id* idx
	 (or (caddr itm) 80) (car itm))))
    (setq *watch-error-icon* (user::listview-add-file-icon *watch-listview-id* *watch-error-icon-file*))
    (setq *watch-bounded-icon* (user::listview-add-file-icon *watch-listview-id* *watch-bounded-icon-file*))
    (setq *watch-unbounded-icon* (user::listview-add-file-icon *watch-listview-id* *watch-unbounded-icon-file*))
    (dotimes (idx (length *watch-symbol-list*))
      (user::listview-insert-item *watch-listview-id* idx
				  (nth idx *watch-symbol-list*)
				  :icon *watch-unbounded-icon*
				  :id (incf *watch-item-id*)))
    (watch-redraw t)
    (user::SetFocus (get-window-handle))))

;;; �t�b�N�p

(defun watch-symbol ()
  (and *watch-listview-id*
       *watch-enable*
       (watch-redraw)))

(add-hook '*post-command-hook* 'watch-symbol)

;;; �ĕ`��

(defun watch-redraw (&optional arg)
  (if *watch-enable*
      (let (elst)
	; �]�����ʎ擾
	(dolist (text *watch-symbol-list*)
	  (let (pkgname pkg symname sym)
	    (string-match "^\\(\\([^:]+\\)::?\\)?\\([^:]+\\)$" text)
	    (setq pkgname (or (match-string 2) "user"))
	    (setq symname (or (match-string 3) ""))
	    (and (setq pkg (find-package pkgname))
		 (setq sym (find-symbol symname pkg)))
	    (push (cons sym (and sym
				 (boundp sym)
				 (ignore-errors
				  (mapcar
				   #'(lambda (test)
				       (list (car test)
					     (funcall (cadr test) sym)))
				   *watch-test-list*))))
		  elst)))
	(setq elst (reverse elst))
	; �ύX�����������`�F�b�N�{�ޔ����ύX
	(when (or arg (not (equal *watch-last-list* elst)))
	  (setq *watch-last-list* elst)
	  (dotimes (idx (length elst))
	    (let (nthelst sym lst icon)
	      (setq nthelst (nth idx elst))
	      (setq sym (car nthelst))
	      (setq lst (cdr nthelst))
	      (dotimes (idy (length *watch-test-list*))
		(cond
		 ; �擪�̏ꍇ�̓V���{�������邩�H�]���ɐ����������H�ŃA�C�R����ύX
		 ((zerop idy)
		  (user::listview-set-item-icon
		   *watch-listview-id* idx
		   (cond ((null sym) *watch-unbounded-icon*)
			 ((null lst) *watch-error-icon*)
			 (t *watch-bounded-icon*))))
		 ; �V���{���������format�Őݒ�
		 ((and sym lst)
		  (user::listview-set-item-text
		   *watch-listview-id* idx idy
		   (format nil "~S" (cadr (nth idy lst)))))
		 ; �V���{�����Ȃ���΋󕶎���ݒ�
		 (t
		  (user::listview-set-item-text
		   *watch-listview-id* idx idy ""))))))
	  (message "watch ... change detected")))
    (progn
      ; �N���A���ׂ����e�����邩�`�F�b�N
      (when (or arg *watch-last-list*)
	(setq *watch-last-list* nil)
	(dotimes (idx (length *watch-symbol-list*))
	  (dotimes (idy (length *watch-test-list*))
	    (cond
	     ; �擪�̏ꍇ�̓A�C�R����ύX
	     ((zerop idy)
	      (user::listview-set-item-icon
	       *watch-listview-id* idx *watch-unbounded-icon*))
	     ; �ȍ~�͋󕶎���ݒ�
	     (t
	      (user::listview-set-item-text
	       *watch-listview-id* idx idy "")))))
	(message "watch ... cleared")))))

;;; �c�[���o�[�֘A

(defun tool-bar-update-watch-enable ()
  (cond ((null *watch-listview-id*) :disable)
	(*watch-enable* :check)))

(defun toggle-watch-listview ()
  (interactive)
  (if *watch-listview-id*
      (watch-stop)
    (watch-start)))

(defun toggle-watch-enable ()
  (interactive)
  (if *watch-enable*
      (watch-disable)
    (watch-enable)))

(defun watch-tool-bar ()
  (create-tool-bar 'watch-tool-bar
		   (merge-pathnames "watch-toolbar.bmp" (etc-path))
		   '(("watch�\��" 0 toggle-watch-listview)
		     ("watch�L��" 1 toggle-watch-enable tool-bar-update-watch-enable))))

(define-command-bar 'watch-tool-bar "watch(&W)")