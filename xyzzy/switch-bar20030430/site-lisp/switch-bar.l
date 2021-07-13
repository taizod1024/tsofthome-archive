;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; switch bar --- ツールバーの表示制御

;;; author
;;;	YAMAMOTO Taizo

;;; date
;;;	Last updated: "2003-04-29"

;;; description
;;;	ツールバーやその他の機能を簡単にトグルします。

;;; install
;;;	1.解凍して出来たswitch-bar.lをswitch-bar.lを$XYZZY/site-lisp/にコピーします。
;;;     2.~/.xyzzyもしくは$XYZZY/site-lisp/siteini.lに記述を追加します。
;;;	  
;;;		--------------------------------
;;;		(require "switch-bar")
;;;		--------------------------------
;;;	  
;;;     3.上記の設定を反映させるために、xyzzyを再起動します。
;;;	  ※siteinit.lに記述した場合には再ダンプもして下さい。

;;; uninstall
;;;	1.$XYZZY/site-lisp/switch-bar.lを削除します。
;;;	2.~/.xyzzyもしくは$XYZZY/site-lisp/siteini.lの関連する箇所を削除します。
;;;	  ※siteinit.lに記述していたならば再度ダンプし直します。

;;; usage
;;;	メニューバーのSwitch(C)を直接押すか、
;;;	Altを押してからcを押してください。

;;; note
;;;	・list-tool-barsの評価値を適当に解析して、
;;;	  ツールバーの表示状況を取得しています。
;;;	・自分の好みに合わせてデフォルトでは表示されない方にしています。

;;; changes
;;; 	Sun, 22 Sep 2002 00:38:23 +0900
;;;	・*switch-bar-initial*を追加
;;; 	Tue, 13 Aug 2002 09:44:01 +0900
;;;	・初版

(provide "switch-bar")

;;; variable
(defvar *switch-bar* nil
  "switch-barで非表示にしているバーのシンボル一覧")
(defvar *switch-function*
  '(toggle-ruler
    toggle-mode-line
    toggle-function-bar
    toggle-line-number)
  "switch-barでトグルする機能の一覧")
(defvar *switch-bar-hook* nil
  "switch-barの初期化用フック")
(defvar *switch-bar-initial* t
  "最初からバーを非表示にするか？")

;;; function
(defun init-switch-bar ()
  "switch-barの初期化"
  (add-menu-item *app-menu* 'switch "Switch(&C)" 'switch-bar)
  (when *switch-bar-initial*
    (switch-bar))
  (run-hooks '*switch-bar-hook*))

(defun switch-bar ()
  "バーのスイッチ"
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
  "switch-barで非表示にしているバーをxyzzy終了時に復元"
  (when *switch-bar*
    (dolist (sym *switch-bar*)
      (show-command-bar sym))
    (dolist (fn *switch-function*)
      (funcall fn))))

;;; hook
(add-hook '*init-app-menus-hook* #'init-switch-bar)
(add-hook '*save-history-hook* #'restore-switch-bar)
