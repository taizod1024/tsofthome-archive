;;; -*- Mode: Lisp; Package:irc -*-
;;;
;;; makefile.l --- irc

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

(export '(irc-make irc-make-clean irc-make-package))

;;; make
(defun irc-make ()
  (interactive)
  (byte-compile-file (merge-pathnames "site-lisp/irc/irc-struct.l" (si:system-root)))
  (byte-compile-file (merge-pathnames "site-lisp/irc/irc-mode.l" (si:system-root)))
  (byte-compile-file (merge-pathnames "site-lisp/irc/irc-dialog.l" (si:system-root)))
  (byte-compile-file (merge-pathnames "site-lisp/irc/irc-ttray.l" (si:system-root)))
  (byte-compile-file (merge-pathnames "site-lisp/irc/irc-ctcp.l" (si:system-root)))
  (byte-compile-file (merge-pathnames "site-lisp/irc/irc-tool-bar.l" (si:system-root)))
  (byte-compile-file (merge-pathnames "site-lisp/irc/irc-layout.l" (si:system-root))))

;;; make clean
(defun irc-make-clean ()
  (interactive)
  ; delete byte compiled file
  (dolist (f (list
	      (merge-pathnames "site-lisp/irc/irc-struct.lc" (si:system-root))
	      (merge-pathnames "site-lisp/irc/irc-mode.lc" (si:system-root))
	      (merge-pathnames "site-lisp/irc/irc-dialog.lc" (si:system-root))
	      (merge-pathnames "site-lisp/irc/irc-ttray.lc" (si:system-root))
	      (merge-pathnames "site-lisp/irc/irc-ctcp.lc" (si:system-root))
	      (merge-pathnames "site-lisp/irc/irc-tool-bar.lc" (si:system-root))
	      (merge-pathnames "site-lisp/irc/irc-layout.lc" (si:system-root))
	      ))
    (delete-file f :if-does-not-exist :skip))
  ; kill tool bar
  (delete-command-bar 'irc::irc-tool-bar))

;;; make package
(defun irc-make-package ()
  (interactive)
  (irc-make-clean)
  (create-archive
   (merge-pathnames (format nil "site-lisp/irc-mode~A.lzh" (format-date-string "%Y%m%d")) (si:system-root))
   (list (merge-pathnames "site-lisp/irc/" (si:system-root)))
   (merge-pathnames "site-lisp/" (si:system-root))))
