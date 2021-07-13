;;; -*- Mode: Lisp; Package: user -*-
;;;
;;; ref2doc.l --- refrence.xml����docstring�𐶐�

;;; author
;;;     YAMAMOTO Taizo <ymtz@pop02.odn.ne.jp>

;;; date
;;;     Last updated: Thu, 20 Mar 2003 06:47:23 +0900

;;; description
;;;	refrence.xml����docstring�𐶐����܂��B
;;;     siteinit.l������reference.xml�̓��e��K���Ƀp�[�Y����
;;;     �֐���ϐ���docstring�𖳗����t���܂��B�Ⴆ�΁A
;;;     describe-function��apropos�̎��ɂ��̓��e�̈ꕔ��\���ł��܂��B

;;; install
;;;     1.�𓀂��ďo����ref2doc.l��$XYZZY/site-lisp/�ɃR�s�[���܂��B
;;;     2.reference.xml���E���Ă���$XYZZY/etc/�ɃR�s�[���܂��B
;;;     3.$XYZZY/site-lisp/siteinit.l�Ɉȉ��̃R�[�h��ǉ����܂��B
;;;       ��~/.xyzzy�͕s��
;;;
;;;		--------------------------------
;;;             (require "ref2doc")
;;;             (reference-to-docstring)
;;;		--------------------------------
;;;
;;;     4.xyzzy���ă_���v���܂��B

;;; usage
;;;     describe-function��apropos���Ă݂Ă��������B

;;; note
;;;     ldoc�����Ă�l�͉��̗l�Ɋ֐����Ē�`����ƁA�ďo�`���ƈꏏ��
;;;     �֐��̐��������邱�Ƃ��ł��܂��B
;;;
;;;     (defun ed::ldoc-func-message (symbol)
;;;       "Print name and arguments of function bound to SYMBOL."
;;;       (message (concat (format nil "~S" symbol)
;;;                        " "
;;;                        (format nil "~:@(~A~): ~A"
;;;                                (ed::ldoc-func-get-args symbol)
;;;                                (or (car (split-string (documentation symbol 'function) #\LFD))
;;;                                    "not documented")))))
;;;

;;; changes
;;;	Fri, 02 May 2003 21:44:47 +0900
;;;		�E�]���p�̃o�b�t�@���g��Ȃ��悤�ɕύX
;;;	Sun, 27 Apr 2003 21:29:48 +0900
;;;		�Enetinstaller�p�ɋL�q��ύX
;;;		�Eetc/reference.xml�ɕύX
;;;		�E*reference-xml-path* -> *reference-xml-file*
;;;	Mon, 31 Mar 2003 23:59:08 +0900
;;;		use���Ă��Ȃ��p�b�P�[�W���l�����Ă݂��B
;;;     Sun, 30 Mar 2003 12:06:41 +0900
;;;             ����

; siteinit.l�ł̕]������(etc-path)�͖��ݒ肾����(si:system-root)����Q�Ƃ���B
(defvar *reference-xml-file* (merge-pathnames "etc/reference.xml" (si:system-root)))

(defun reference-to-docstring ()
  "reference.xml�̓��e����docstring�ɂ���B"
  (interactive)
  (unwind-protect
      (progn
	(set-buffer (ed::find-file-internal *reference-xml-file*))
	(goto-char (point-min))
	(let (title desc sym pkg)
	  (while (and (scan-buffer "<title>\\([^\n<]*\\)" :regexp t :tail t)
		      (setq title (match-string 1))
		      (scan-buffer "<description>\n*\\([^<]*\\)" :regexp t :tail t)
		      (setq desc (match-string 1)))
	    (setq title (substitute-string title "&amp;" "&"))
	    (setq title (substitute-string title "&lt;" "<"))
	    (setq title (substitute-string title "&gt;" ">"))
	    (setq desc (substitute-string desc "&amp;" "&"))
	    (setq desc (substitute-string desc "&lt;" "<"))
	    (setq desc (substitute-string desc "&gt;" ">"))
	    (and (string-match "\\(\\([^:]+\\):+\\)?\\(.+\\)" title)
		 (setq pkg (or (match-string 2) "user"))
		 (setq sym (find-symbol (match-string 3) pkg))
		 (setf (get sym (if (fboundp sym)
				    'lisp::function-documentation
				  'lisp::variable-documentation))
		       desc)))))
    (delete-buffer (get-file-buffer *reference-xml-file*))))
