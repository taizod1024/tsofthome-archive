;;; -*- Mode: Lisp; Package: user -*-
;;;
;;; tdict.l --- tdict��ni-autoload�p���W���[��

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

;;; description
;;;     tdict��ni-autoload�p���W���[��

; �C�ӂ̎��_�Ŏ��s����̂�autoload�œǂݍ���
(export '(ed::tdict-mode ed::tdict-reload) "ed") 
(autoload 'tdict-mode "tdict" t)
(autoload 'tdict-reload "tdict" t)