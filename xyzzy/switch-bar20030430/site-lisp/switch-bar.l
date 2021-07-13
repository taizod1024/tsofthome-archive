;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; switch bar --- �c�[���o�[�̕\������

;;; author
;;;	YAMAMOTO Taizo

;;; date
;;;	Last updated: "2003-04-29"

;;; description
;;;	�c�[���o�[�₻�̑��̋@�\���ȒP�Ƀg�O�����܂��B

;;; install
;;;	1.�𓀂��ďo����switch-bar.l��switch-bar.l��$XYZZY/site-lisp/�ɃR�s�[���܂��B
;;;     2.~/.xyzzy��������$XYZZY/site-lisp/siteini.l�ɋL�q��ǉ����܂��B
;;;	  
;;;		--------------------------------
;;;		(require "switch-bar")
;;;		--------------------------------
;;;	  
;;;     3.��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy���ċN�����܂��B
;;;	  ��siteinit.l�ɋL�q�����ꍇ�ɂ͍ă_���v�����ĉ������B

;;; uninstall
;;;	1.$XYZZY/site-lisp/switch-bar.l���폜���܂��B
;;;	2.~/.xyzzy��������$XYZZY/site-lisp/siteini.l�̊֘A����ӏ����폜���܂��B
;;;	  ��siteinit.l�ɋL�q���Ă����Ȃ�΍ēx�_���v�������܂��B

;;; usage
;;;	���j���[�o�[��Switch(C)�𒼐ډ������A
;;;	Alt�������Ă���c�������Ă��������B

;;; note
;;;	�Elist-tool-bars�̕]���l��K���ɉ�͂��āA
;;;	  �c�[���o�[�̕\���󋵂��擾���Ă��܂��B
;;;	�E�����̍D�݂ɍ��킹�ăf�t�H���g�ł͕\������Ȃ����ɂ��Ă��܂��B

;;; changes
;;; 	Sun, 22 Sep 2002 00:38:23 +0900
;;;	�E*switch-bar-initial*��ǉ�
;;; 	Tue, 13 Aug 2002 09:44:01 +0900
;;;	�E����

(provide "switch-bar")

;;; variable
(defvar *switch-bar* nil
  "switch-bar�Ŕ�\���ɂ��Ă���o�[�̃V���{���ꗗ")
(defvar *switch-function*
  '(toggle-ruler
    toggle-mode-line
    toggle-function-bar
    toggle-line-number)
  "switch-bar�Ńg�O������@�\�̈ꗗ")
(defvar *switch-bar-hook* nil
  "switch-bar�̏������p�t�b�N")
(defvar *switch-bar-initial* t
  "�ŏ�����o�[���\���ɂ��邩�H")

;;; function
(defun init-switch-bar ()
  "switch-bar�̏�����"
  (add-menu-item *app-menu* 'switch "Switch(&C)" 'switch-bar)
  (when *switch-bar-initial*
    (switch-bar))
  (run-hooks '*switch-bar-hook*))

(defun switch-bar ()
  "�o�[�̃X�C�b�`"
  (interactive)
  (cond (*switch-bar*
	 (dolist (sym *switch-bar*)
	   (show-command-bar sym))
	 (message "~D bars showed" (length *switch-bar*))
	 (setq *switch-bar* nil))
	(t
	 (setq *switch-bar*
	       (apply 'append
		      (mapcar #'(lambda (x) (mapcar 'car x))
			      (butlast (list-tool-bars)))))
	 (message "~D bars hided" (length *switch-bar*))
	 (dolist (sym *switch-bar*)
	   (hide-command-bar sym))))
  (dolist (fn *switch-function*)
    (funcall fn)))

(defun restore-switch-bar ()
  "switch-bar�Ŕ�\���ɂ��Ă���o�[��xyzzy�I�����ɕ���"
  (when *switch-bar*
    (dolist (sym *switch-bar*)
      (show-command-bar sym))
    (dolist (fn *switch-function*)
      (funcall fn))))

;;; hook
(add-hook '*init-app-menus-hook* #'init-switch-bar)
(add-hook '*save-history-hook* #'restore-switch-bar)