;;; -*- Mode: Lisp; Package:user -*-
;;;
;;; make.l --- JavaTinyConsole
;;;

;;; author
;;;	YAMAMOTO Taizo

;;; date
;;;	Last updated: "2003-04-28"

;;; �q�X�g���ϐ��̕ϊ�

; Sun, 21 Oct 2001 14:19:08 +0900
(let ((s (find-symbol "*jtc-jdk-document-directory*" "user")))
  (and s (not (listp (eval s)))
       (set s (list (eval s)))))

;;; �q�X�g���ϐ��̔p�~
(unregister-history-variable '*jtc-show-tool-bar*)

;;; �p�b�P�[�W�̐錾
(require "jtc/jtc-def")
 
;;; �o�C�g�R���p�C��

(byte-compile-file (merge-pathnames "site-lisp/jtc/jtc.l" (si:system-root)))
(byte-compile-file (merge-pathnames "site-lisp/jtc/jtc-def.l" (si:system-root)))
(byte-compile-file (merge-pathnames "site-lisp/jtc/jtc-shell.l" (si:system-root)))
(byte-compile-file (merge-pathnames "site-lisp/jtc/jtc-menu.l" (si:system-root)))
(byte-compile-file (merge-pathnames "site-lisp/jtc/jtc-complete.l" (si:system-root)))
