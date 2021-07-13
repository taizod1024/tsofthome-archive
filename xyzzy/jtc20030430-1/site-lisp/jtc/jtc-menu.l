;;; -*- Mode: Lisp; Package:jtc -*-
;;;
;;; jtc-menu.l --- JavaTinyConsole
;;;

;;; author
;;;	YAMAMOTO Taizo

;;; date
;;;	Last updated: "2003-04-29"

(provide "jtc/jtc-menu")

(require "optprop")
(require "cmdbar")
(require "java")

(in-package "jtc")

;;; �q�X�g���ϐ�

(define-history-variable *jtc-jdk-directory* "c:/jdk1.3")
(define-history-variable *jtc-jdk-document-directory* '("c:/jdk-ja-doc" "http://java.sun.com/j2se/1.3/ja/docs/ja/"))
(define-history-variable *jtc-member-completion* t)
(define-history-variable *jtc-show-api-ref* t)
(define-history-variable *jtc-javac-history* '("javac" "javac -g"))
(define-history-variable *jtc-java-history* '("java"))
(define-history-variable *jtc-java-args-history* '(" "))
(define-history-variable *jtc-jdb-history* '("jdb"))
(define-history-variable *jtc-make-history* '("make" "nmake" "smake make"))
(define-history-variable *jtc-javadoc-history* '("javadoc"))

;;; �v���_�E�����j���[

; �R�}���h�̎��s���K�v�ȏꍇ�����I���Ƃ���

(defvar *jtc-menu-dir*
  (define-popup-menu
    (:item nil "���߲�(&C)" 'jtc-javac-directory 'jtc-bar-update-compile-dir)
    (:item nil "�ĺ��߲�(&R)" 'jtc-javac-directory1 'jtc-bar-update-compile-dir1)))

(defvar *jtc-menu* nil)
(defun jtc-setup-menu ()
  (setq *jtc-menu*
	(let ((menu (copy-menu-items *app-menu* (create-menu))))
	  (insert-popup-menu menu (get-menu-position menu 'ed::help)
			     (define-popup-menu
			       (:item nil "���߲�(&C)" 'jtc-javac-buffer 'jtc-bar-update-compile-buffer)
			       (:item nil "�ĺ��߲�(&R)" 'jtc-javac-buffer1 'jtc-bar-update-compile-buffer1)
			       (:menu nil "�ިڸ��(&D)" *jtc-menu-dir* 'jtc-bar-update-compile-dir)
			       (:item nil "Ҳ�(&M)" 'jtc-make-command 'jtc-bar-is-not-process-running)
			       :sep
			       (:item nil "���s(&X)" 'jtc-java-buffer 'jtc-bar-update-compile-buffer1)

			       (:item nil "���޸�(&B)" 'jtc-jdb-buffer 'jtc-bar-update-compile-buffer1)
			       :sep
			       (:item nil "��~(&I)" 'jtc-shell-send-interrupt 'jtc-bar-is-process-running)
			       :sep
			       (:item nil "�ꎞ�⊮ؽčX�V(&T)" 'jtc-update-temp-completion-list 'jtc-bar-update-compile-dir2)
			       :sep
			       (:item nil "�����è(&P)" 'jtc-show-property))
			     "JavaTinyConsole(&J)")
	  menu))
  (setq *app-menu* *jtc-menu*))

(unless *jtc-menu*
  (cond (*app-menu*
	 (jtc-setup-menu)
	 (set-menu *app-menu*))
	(t
	 (add-hook '*init-app-menus-hook* 'jtc-setup-menu))))

;;; �c�[���o�[
(defun jtc-bar-update-compile-buffer ()
  (if (or (find (check-buffer) '(:nofilename :nojavafile :compiled))
	  (is-process-running))
      :disable))

(defun jtc-bar-update-compile-buffer1 ()
  (if (or (find (check-buffer) '(:nofilename :noclassfile :nojavafile :modified))
	  (is-process-running))
      :disable))

(defun jtc-bar-update-compile-dir ()
  (if (or (find (check-dir) '(:nojavafiles :compiled))
	  (is-process-running))
      :disable))

(defun jtc-bar-update-compile-dir1 ()
  (if (or (find (check-dir) '(:nojavafiles :modified))
	  (is-process-running))
      :disable))

(defun jtc-bar-update-compile-dir2 ()
  (if (or (not *jtc-member-completion*)
	  (find (check-dir) '(:nojavafiles))
	  (is-process-running))
      :disable))

(defun jtc-bar-is-not-process-running ()
  (if (is-process-running) :disable))

(defun jtc-bar-is-process-running ()
  (unless (is-process-running) :disable))

; �R�}���h�̎��s���K�v�Ȃ��Ƃ��I����
(defun jtc-tool-bar ()
  (create-tool-bar 'jtc-tool-bar
		   (merge-pathnames "toolbar-jtc.bmp" (etc-path))
		   '(("���߲� - �ޯ̧" 0 jtc-javac-buffer)
		     ("���߲� - �ިڸ��" 1 jtc-javac-directory)
		     ("Ҳ�" 2 jtc-make-command)
		     :sep
		     ("���s - �ޯ̧" 3 jtc-java-buffer)
		     ("���޸� - �ޯ̧" 4 jtc-jdb-buffer)
		     :sep
		     ("��~" 5 jtc-shell-send-interrupt)
		     :sep
		     ("�����è" 6 jtc-show-property))))
(define-command-bar 'jtc-tool-bar "JavaTinyConsole(&J)")

;;; �v���p�e�B�y�[�W

; �׋��p
(add-option-prop-page
 'jtc-page
 '(dialog 0 0 235 139
   (:caption "JavaTinyConsole")
   (:font 9 "�l�r �o�S�V�b�N")
   (:control
    (:button nil "�ݽİ��ިڸ��"	#x50000007 7 8 231 45)
    ;(
      (:static nil "JDK�ިڸ��(&O):"	#x50020000 12 20 68 8)
      (:edit rtdir nil			#x50810480 72 18 126 13)
      (:button rtref "�Q��..."		#x50010000 202 18 28 13)
      (:static nil "JDK�޷����(&P):"	#x50020000 12 36 68 8)
      (:combobox dcdir nil		#x50210042 72 34 126 66)
      (:button dcref "�Q��..."		#x50010000 202 34 28 13) ;)
    ;-
    (:button nil "����"			#x50000007 7 57 231 29)
    ;(
      (:button member "���ނ�⊮(&M)"	#x50010003 16 69 56 10)
      (:button ref "�̧�ݽ��\��(&R)"	#x50010003 80 69 64 10) ;)
    ;-
    (:button nil "�����"		#x50000007 7 90 231 93)
    ;(
      (:static nil "���߲�(&C):"	#x50020000 12 102 40 8)
      (:combobox compile nil		#x50210042 50 100 128 66)
      (:static nil "���s(&X):"		#x50020000 12 118 40 8)
      (:combobox exec nil		#x50810042 50 116 60 66)
      (:combobox execargs nil		#x50810042 112 116 108 66)
      (:static nil "���޸�(&D):"	#x50020000 12 134 40 8)
      (:combobox debug nil		#x50810042 50 132 128 66)
      (:static nil "Ҳ�(&M):"		#x50020000 12 150 40 8)
      (:combobox make nil		#x50810042 50 148 128 66)
      (:static nil "javadoc(&J):"	#x50020000 12 166 40 8)
      (:combobox javadoc nil		#x50810042 50 164 128 66)
      ;)
    ))
 #'(lambda ()
     (list (cons 'rtdir *jtc-jdk-directory*)
	   (cons 'dcdir (car *jtc-jdk-document-directory*))
	   (cons 'dcdir *jtc-jdk-document-directory*)
	   (cons 'member *jtc-member-completion*)
	   (cons 'ref *jtc-show-api-ref*)
	   (cons 'compile (car *jtc-javac-history*))
	   (cons 'compile *jtc-javac-history*)
	   (cons 'exec (car *jtc-java-history*))
	   (cons 'exec *jtc-java-history*)
	   (cons 'execargs (car *jtc-java-args-history*))
	   (cons 'execargs *jtc-java-args-history*)
	   (cons 'debug (car *jtc-jdb-history*))
	   (cons 'debug *jtc-jdb-history*)
	   (cons 'make (car *jtc-make-history*))
	   (cons 'make *jtc-make-history*)
	   (cons 'javadoc (car *jtc-javadoc-history*))
	   (cons 'javadoc *jtc-javadoc-history*)))
 '((member :enable (javadoc))
   (ref :enable (dcdir dcref))
   (rtref :related rtdir :directory-name-dialog (:title "JDK�̲ݽİ��ިڸ��"))
   (dcref :related dcdir :directory-name-dialog (:title "JDK�޷���Ă̲ݽİ��ިڸ��")))
 #'(lambda (data)
     (setq *jtc-jdk-directory* (cdr (assoc 'rtdir data)))
     (setq *jtc-member-completion* (cdr (assoc 'member data)))
     (setq *jtc-show-api-ref* (cdr (assoc 'ref data)))
     (add-history (cdr (assoc 'compile data)) '*jtc-javac-history*)
     (add-history (cdr (assoc 'debug data)) '*jtc-jdb-history*)
     (add-history (cdr (assoc 'exec data)) '*jtc-java-history*)
     (add-history (cdr (assoc 'execargs data)) '*jtc-java-args-history*)
     (add-history (cdr (assoc 'make data)) '*jtc-make-history*)
     (add-history (cdr (assoc 'javadoc data)) '*jtc-javadoc-history*)
     (if *jtc-show-api-ref*
       (add-history (cdr (assoc 'dcdir data)) '*jtc-jdk-document-directory*))
     (if *jtc-member-completion*
       (add-history (cdr (assoc 'javadoc data)) '*jtc-javadoc-history*))))

(setq *jtc-property-page-no* (1- (length ed::*option-prop-page*)))