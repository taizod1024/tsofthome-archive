;;; -*- Mode: Lisp; Package: user -*-
;;;
;;; html+-mode.l --- html+-mode��ni-autoload�p���W���[��

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

;;; description
;;;     html+-mode��ni-autoload�p���W���[��

; �C�ӂ̎��_�Ŏ��s����̂�autoload�œǂݍ���
(export 'ed::html+-mode "ed")
(autoload 'html+-mode "html+-mode" t)
(pushnew '("\\.s?html?$" . html+-mode) *auto-mode-alist* :test 'equal)