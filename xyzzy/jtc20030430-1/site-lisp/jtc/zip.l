;;; -*- Mode: Lisp; Package:user -*-
;;;
;;; zip.l --- JavaTinyConsole
;;;

;;; author
;;;	YAMAMOTO Taizo

;;; date
;;;	Last updated: "2003-04-28"

(load-library "jtc/jtc")
(load-library "jtc/kill")
(create-archive
 (merge-pathnames (format nil "site-lisp/jtc~A.lzh" (format-date-string "%Y%m%d")) (si:system-root))
 (list (merge-pathnames "site-lisp/jtc/" (si:system-root)))
 (merge-pathnames "site-lisp/" (si:system-root)))

