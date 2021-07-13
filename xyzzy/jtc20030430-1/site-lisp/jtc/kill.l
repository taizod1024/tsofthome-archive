;;; -*- Mode: Lisp; Package:user -*-
;;;
;;; kill.l --- JavaTinyConsole
;;;

;;; author
;;;	YAMAMOTO Taizo

;;; date
;;;	Last updated: "2003-04-28"

;;; �����O�ɓǂݍ���
(require "jtc/jtc")

; �q�X�g���ϐ��̍폜
(unregister-history-variable '*jtc-jdk-directory*)
(unregister-history-variable '*jtc-jdk-document-directory*)
(unregister-history-variable '*jtc-member-completion*)
(unregister-history-variable '*jtc-show-api-ref*)
(unregister-history-variable '*jtc-javac-history*)
(unregister-history-variable '*jtc-java-history*)
(unregister-history-variable '*jtc-java-args-history*)
(unregister-history-variable '*jtc-jdb-history*)
(unregister-history-variable '*jtc-make-history*)
(unregister-history-variable '*jtc-javadoc-history*)

; �o�C�g�R���p�C���t�@�C���̍폜
(dolist (f (list
	    (merge-pathnames "site-lisp/jtc/jtc.lc" (si:system-root))
	    (merge-pathnames "site-lisp/jtc/jtc-def.lc" (si:system-root))
	    (merge-pathnames "site-lisp/jtc/jtc-shell.lc" (si:system-root))
	    (merge-pathnames "site-lisp/jtc/jtc-menu.lc" (si:system-root))
	    (merge-pathnames "site-lisp/jtc/jtc-complete.lc" (si:system-root))))
  (delete-file f :if-does-not-exist :skip))

; �ꎞ�t�@�C���̍폜
(delete-file jtc::*jtc-temp-completion-file* :if-does-not-exist :skip)

; �c�[���o�[�̍폜
(delete-command-bar 'jtc::jtc-tool-bar)