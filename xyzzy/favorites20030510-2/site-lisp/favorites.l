;;; -*- Mode: Lisp; Package: editor -*-
;;;
;;; favorites --- ���C�ɓ���Ǘ�

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-05-13"

;;; description
;;;	���C�ɓ�����Ǘ����܂��B

;;; install
;;;	1.�𓀂����o����favorites.l��$XYZZY/site-lisp/�ɃR�s�[���܂��B
;;;     2.~/.xyzzy��������$XYZZY/site-lisp/siteini.l�ɋL�q��ǉ����܂��B
;;;
;;;		--------------------------------
;;;		(require "favorites")
;;;		--------------------------------
;;;
;;;     3.*favorites-path*�Ɏw�肵���p�X���쐬���܂��B
;;;	  �W���ł�$XYZZY/favorites�ł��B
;;;     4.��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy���ċN�����܂��B
;;;	  ��siteinit.l�ɋL�q�����ꍇ�ɂ͍ă_���v�����ĉ������B

;;; uninstall
;;;	1.$XYZZY/site-lisp/favorites.l���폜���܂��B
;;;	2.~/.xyzzy��������$XYZZY/site-lisp/siteini.l�̊֘A����ӏ����폜���܂��B
;;;	  ��siteinit.l�ɋL�q���Ă����Ȃ�΍ēx�_���v�������܂��B

;;; note
;;;	���ɂȂ�

;;; changes
;;;	Tue, 13 May 2003 00:24:59 +0900
;;;		�E�g���q��"lnk"�̏ꍇ�ɂ͕\�����Ȃ��悤�ɕύX
;;;	Sun, 11 May 2003 17:56:50 +0900
;;;		�E���j���[�͎w�肳�ꂽ�ʒu�ɑ}������悤�ɕύX
;;;	Sat, 10 May 2003 22:39:29 +0900
;;;		�E*favorites-accesskey*�ŃA�N�Z�X�L�[�̗L���𐧌��
;;;		�E*favorites-menu-position*�Ń��j���[��}������ʒu��ύX��
;;;			nil	: �擪�ɑ}��
;;;			����	: ���̈ʒu�ɑ}��
;;;			���̑�	: �^�O�ƌ��Ȃ��Ă��̎��̈ʒu�ɑ}��
;;;		�E*favorites-buffer-bar-context-menu-position*�Ń��j���[��}������ʒu��ύX��
;;;			nil	: �擪�ɑ}��
;;;			����	: ���̈ʒu�ɑ}��
;;;			���̑�	: �^�O�ƌ��Ȃ��Ă��̎��̈ʒu�ɑ}��
;;;		�E*favorites-open-with-shell*��shell-execute����t�@�C�����J��
;;;			nil	: find-file�Ńt�@�C�����J��
;;;			t	: �g���q�̊֘A�t���ɏ]���ăt�@�C�����J��
;;;		�E*favorites-resolve-shortcut-directory*�Ńf�B���N�g����W�J���邩�H
;;;			nil	: �]���ǂ���
;;;			t	: �f�B���N�g���ւ̃V���[�g�J�b�g�͓W�J
;;;	Wed, 30 Apr 2003 22:02:14 +0900
;;;		�E�����قǃ��j���[�����Ƃ��낪���������̂őS�ʏ��������B
;;;		�EOHKUBO���񂩂�̉��P�Ă̎�荞��
;;;			�E�t�@�C����������������:disable
;;;			�E�^�O�̒ǉ�
;;;			�E�A�N�Z�X�L�[�̒ǉ�
;;;	Mon, 28 Apr 2003 00:13:29 +0900
;;;		�E�������C��
;;;		�E�W���̃p�X��$XYZZY/favorites����~/favorites�ɕύX
;;;	Tue, 13 Aug 2002 10:08:32 +0900
;;;		�Ecreate-dir-menu��create-dir-list��update�̓����֐��ɕύX
;;;		�E�ݒ�t�@�C����load-library����΂悢�����ɏC��
;;;		�Edocstring��ǉ�
;;;		�E�f�t�H���g�̃p�X��c:/temp/favorites����~/favorites�ɕύX
;;; 	***
;;;		�E����

(provide "favorites")

;;; --------------------------------
;;; variable
;;; --------------------------------
(defvar *favorites-path* (merge-pathnames "favorites" (user-homedir-pathname))
  "���C�ɓ���̃p�X")

(defvar *favorites-menu* nil
  "���C�ɓ��胁�j���[")

(defvar *favorites-accesskey* t
  "���C�ɓ���̃A�N�Z�X�L�[�̗L��")

(defvar *favorites-menu-position* 'ed::tools
  "���C�ɓ����}������ʒu�i���j���[�j")

(defvar *favorites-buffer-bar-context-menu-position* nil
  "���C�ɓ����}������ʒu�i�o�b�t�@�o�[�̃R���e�L�X�g���j���[�j")

(defvar *favorites-open-with-shell* nil
  "���C�ɓ�����g���q�̊֘A�t���ɏ]���ĊJ�����H")

(defvar *favorites-resolve-shortcut-directory* t
  "���C�ɓ���̃f�B���N�g���ւ̃V���[�g�J�b�g��W�J���邩�H")

;;; --------------------------------
;;; function
;;; --------------------------------
(defun add-to-favorites (&optional (buf (selected-buffer)))
  "���C�ɓ���ɒǉ�"
  (interactive)
  (let ((f (get-buffer-file-name buf)))
    (if (and f
	     (file-exist-p f))
	(progn
	  (create-shortcut f *favorites-path*)
	  (update-favorites-menu)
	  (message "~A �����C�ɓ���ɒǉ����܂����B" (buffer-name buf)))
      (message "~A �̓t�@�C���ł͂���܂���" (buffer-name buf)))))

(defun open-favorites-path ()
  "���C�ɓ���̐���"
  (interactive)
  (let ((*filer-primary-directory* *favorites-path*)
	(*filer-secondary-directory* *favorites-path*)
	(*filer-modal* t))
    (open-filer))
  (update-favorites-menu))

(defun open-favorites-func (f)
  "���C�ɓ�����J��"
  (if (string= (pathname-type f) "lnk")
      (setq f (resolve-shortcut f)))
  (cond ((not (file-exist-p f))
	 (message "~A �̓����N�؂�ł�" (file-namestring f)))
	(*favorites-open-with-shell*
	 (shell-execute (map-slash-to-backslash f)))
	(t
	 (find-file f))))

(defun update-favorites-menu ()
  "���C�ɓ��胁�j���[�̍X�V"
  (interactive)
  (message "���C�ɓ�����X�V�� ...")
  (while (delete-menu *favorites-menu* 3 t))
  (add-favorites-menu *favorites-path* *favorites-menu*)
  (message "���C�ɓ�����X�V���܂���"))

(defun add-favorites-menu (path menu)
  "���C�ɓ��胁�j���[�̍쐬"
  (long-operation
    (let (dl fl gen)
      (setq dl (directory path :directory-only t :absolute t))
      (setq dl (sort dl #'string-lessp))
      (setq dl (mapcar #'remove-trail-slash dl))
      (setq fl (directory path :file-only t :absolute t))
      (setq fl (sort fl #'string-lessp))
      ; �A�N�Z�X�L�[�����p�W�F�l���[�^
      (setq gen (let (ccode)
		  #'(lambda ()
		      (cond ((null ccode) (setq ccode (char-code #\A)))
			    ((< ccode (char-code #\Z)) (incf ccode))
			    (t (setq ccode (char-code #\A))))
		      (code-char ccode))))
      ; �f�B���N�g��
      (dolist (dir dl)
	(let (popup-menu text)
	  (setq popup-menu (create-popup-menu))
	  (setq text (file-namestring dir))
	  (if *favorites-accesskey*
	      (setq text (concat text (format nil "(&~A)" (funcall gen)))))
	  (add-favorites-menu dir popup-menu)
	  (add-popup-menu menu popup-menu text)))
      ; �Z�p���[�^
      (and dl fl
	   (add-menu-separator menu))
      ; �t�@�C��
      (dolist (file fl)
	(let (file1 text func link popup-menu)
	  (setq file1 file)
	  (setq text (file-namestring file))
	  (if (string= (pathname-type text) "lnk")
	      (setq text (pathname-name text)))
	  (if *favorites-accesskey*
	      (setq text (concat text (format nil "(&~A)" (funcall gen)))))
	  (if (and *favorites-resolve-shortcut-directory*
		   (string= (pathname-type file1) "lnk")
		   (setq link (resolve-shortcut file1))
		   (file-directory-p link))
	      (progn
		(setq popup-menu (create-popup-menu))
		(add-favorites-menu link popup-menu)
		(add-popup-menu menu popup-menu text))
	    (progn
	      (setq func #'(lambda () (interactive) (open-favorites-func file1)))
	      (add-menu-item menu nil text func))))))))

(defun init-favorites ()
  "���C�ɓ���̏�����"
  ; ���j���[
  (let (pos menu menu-pos)
    (setq pos *favorites-menu-position*)
    (setq menu *app-menu*)
    (setq menu-pos (cond ((null pos) 0)
			 ((integerp pos) pos)
			 (t (get-menu-position menu pos))))
    (setq *favorites-menu*
	  (define-popup-menu
	    (:item 'favorites-add "���C�ɓ���ɒǉ�(&A)" 'add-to-favorites
	     #'(lambda () (or (get-buffer-file-name) :disable)))
	    (:item 'favorites-arrange "���C�ɓ���̐���(&O)..." 'open-favorites-path)
	    :sep))
    (insert-popup-menu menu menu-pos *favorites-menu* "���C�ɓ���(&A)"))
  ; �o�b�t�@�o�[
  (let (pos menu menu-pos)
    (setq pos *favorites-buffer-bar-context-menu-position*)
    (setq menu *buffer-bar-context-menu*)
    (setq menu-pos (cond ((null pos) 0)
			 ((integerp pos) pos)
			 (t (get-menu-position menu pos))))
    (insert-menu-separator menu menu-pos 'favorite-sep)
    (insert-menu-item menu menu-pos 'favorites-add "���C�ɓ���ɒǉ�(&A)"
		      #'(lambda () (interactive) (add-to-favorites *buffer-bar-context-menu-buffer*))
		      #'(lambda () (or (get-buffer-file-name *buffer-bar-context-menu-buffer*) :disable)))
    (update-favorites-menu)))

;;; hook
(add-hook '*init-app-menus-hook* #'init-favorites)