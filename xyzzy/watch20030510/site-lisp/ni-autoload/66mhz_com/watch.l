;;; -*- Mode: Lisp; Package: user -*-
;;;
;;; watch.l --- watch��ni-autoload�p���W���[��

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

;;; description
;;;     watch��ni-autoload�p���W���[��

; �C�ӂ̎��_�Ŏ��s����̂�autoload�œǂݍ���
(export '(ed::toggle-watch-listview ed::toggle-watch-enable) "ed")
(autoload 'ed::toggle-watch-enable "watch" t)
(autoload 'ed::toggle-watch-listview "watch" t)
(autoload 'ed::watch-tool-bar "watch" t)