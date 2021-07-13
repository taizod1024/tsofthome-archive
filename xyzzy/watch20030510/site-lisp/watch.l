;;; -*- Mode: Lisp; Package: editor -*-
;;;
;;; watch.l --- シンボルのウォッチ機能

;;; author
;;;	YAMAMOTO Taizo

;;; date
;;;	Last updated: "2003-05-10"

;;; description
;;;	シンボルのウォッチを行います。デバグ時に使用下さい。
;;;	常時、シンボルを表示するのにListView.dllを使用しています。

;;; install
;;;	1.ListView.dllを導入します。
;;;
;;;		--------------------------------
;;;		http://www003.upp.so-net.ne.jp/rex/
;;;		--------------------------------
;;;
;;;	2.解凍して出来たファイルを以下のディレクトリにコピーします。
;;;
;;;		--------------------------------
;;;		site-lisp/watch.l     -> $XYZZY/site-lisp/watch.l
;;;		etc/watch-bound.ico   -> $XYZZY/etc/watch-bound.ico
;;;		etc/watch-unbound.ico -> $XYZZY/etc/watch-unbound.ico
;;;		etc/watch-error.ico   -> $XYZZY/etc/watch-error.ico
;;;		etc/watch-toolbar.bmp -> $XYZZY/etc/watch-toolbar.bmp
;;;		--------------------------------
;;;
;;;     3.~/.xyzzyもしくは$XYZZY/site-lisp/siteini.lに記述を追加します。
;;;
;;;		--------------------------------
;;;		(require "listview")
;;;		(require "watch")
;;;		--------------------------------
;;;
;;;     4.上記の設定を反映させるために、xyzzyを再起動します。
;;;	  ※siteinit.lに記述した場合には再ダンプもして下さい。

;;; uninstall
;;; 	1.installでコピーしたファイルを削除します。
;;;	2.ESC ESC (delete-command-bar 'editor::watch-tool-bar)
;;;	  とタイプします。
;;;     3.上記の設定を反映させるために、xyzzyを再起動します。
;;;	  ※siteinit.lに記述した場合には再ダンプもして下さい。

;;; keybind
;;;	ListView.dll上でのキーバインドは以下のとおりです。
;;;
;;;		--------------------------------
;;; 		DEL BS 	アイテムの削除
;;;		ESC TAB	xyzzyへフォーカスを遷移
;;;		F2	アイテムの編集
;;;		--------------------------------

;;; note
;;;	editor::*this-command*をウォッチすると処理の重さが分かります。
;;;	あまりに重い場合には使用を控えるようにして下さい。
;;;	Win98SE+Duron700MHz+256MBぐらいでも相当重い気がします。
;;;	追記）いろいろとチューニングした結果、そこそこ動く気がします

;;; changes
;;;	Sat, 10 May 2003 22:01:14 +0900
;;;		シンボルが変数じゃない場合の対応を追加
;;;	Sun, 27 Apr 2003 22:43:02 +0900
;;;		説明文を修正
;;;	Wed, 20 Mar 2002 07:43:06 +0900
;;;		F2を押したときにwatch-edit-labelを呼ぶように修正
;;;	Fri, 08 Mar 2002 21:56:07 +0900
;;;		亀井さんのアドバイス＋大久保さんのmeasure-watch-costを使ってチューニング
;;;		完全にcallback内のlispでリストを管理するように変更
;;;		userをuse-packageするのは別のところで悪影響が出そうなので取り止め
;;;		ignore-errosのコストがとても高かったのでループの外に出した
;;;		死んでた変数を削除
;;;		*watch-initial-symbol-list*を*watch-symbol-list*に変更
;;;		ヘッダによるソートを取りやめ
;;;		評価時にエラーが発生した場合のアイコン追加
;;;		アイコン用のファイル名を変更
;;;		ツールバー用のビットマップファイルを追加
;;;		*watch-show-tool-bar*を削除
;;;		watch-edit-labelを追加
;;;		watch-set-focusを追加
;;;	Tue, 05 Mar 2002 22:06:01 +0900
;;;		関数の整理、カラムの長さを設定できるように変更
;;;		いろいろと変更可能に
;;;	Sat, 02 Mar 2002 22:57:31 +0900
;;;		ListView.dll ver.1.1の複数表示対応への対応
;;;		ついでにツールバーもそのように対応
;;;	Sat, 02 Mar 2002 01:33:46 +0900
;;;		初版

;;; special thanks
;;;	ListViewを作成されたkazu.y氏に謝辞を申し上げます。
;;;	また、ツールバー関連はOHKUBO Hiroshi氏のtopmost.lを参考にしています。

(require "ListView")
(provide "watch")

(in-package "editor")

(export '(toggle-watch-listview
	  toggle-watch-enable
	  watch-tool-bar
	  watch-symbol
	  watch-start
	  watch-stop
	  watch-enable
	  watch-disable
	  watch-set-focus
	  watch-edit-label))

(export '(*watch-listview-id*
	  *watch-enable*
	  *watch-listview-pos*
	  *watch-listview-size*
	  *watch-test-list*
	  *watch-symbol-list*
	  *watch-last-list*
	  *watch-error-icon-file*
	  *watch-bounded-icon-file*
	  *watch-unbounded-icon-file*))

;;; watch準備

; 変更可
(defvar *watch-listview-pos* user::XPIS_TOP)
(defvar *watch-listview-size* 100)
(defvar *watch-test-list*
  '(; これだけはアイコンの描画に関係するので削除しないように
    ("ｼﾝﾎﾞﾙ" boundp 160)
    ; これ以下は適当に
    ("値" eval 160)
    ("ﾀｲﾌﾟ" (lambda (x) (and x (type-of (eval x)))) 80)
    ("要素数" (lambda (x) (and x (sequencep (eval x)) (length (eval x)))) 60)
    ("ﾊﾞｯﾌｧﾛｰｶﾙ" local-variable-p 80)
    ("ﾌﾟﾛﾊﾟﾃｨ" symbol-plist 160)))
(defvar *watch-symbol-list*
  ; 一応最後に空白は入れておいてください（手抜き）
  '("editor::buffer-mode" "editor::mode-name" ""))
(defvar *watch-error-icon-file* (merge-pathnames "watch-error.ico" (etc-path)))
(defvar *watch-bounded-icon-file* (merge-pathnames "watch-bound.ico" (etc-path)))
(defvar *watch-unbounded-icon-file* (merge-pathnames "watch-unbound.ico" (etc-path)))

; 参照可
(defvar *watch-listview-id* nil)
(defvar *watch-enable* t)
(defvar *watch-last-list* nil)

; 内部用
(defvar *watch-item-id* 0)

;;; watch主要関数

(defun watch-set-focus ()
  (interactive)
  (when *watch-listview-id*
    (user::listview-set-focus *watch-listview-id*)))

(defun watch-edit-label (&optional n)
  (interactive)
  (when *watch-listview-id*
    (unless (numberp n)
      (setq n (1- (length *watch-symbol-list*))))
    (user::listview-dll-edit-label *watch-listview-id* n)))

(defun watch-enable ()
  (interactive)
  (unless *watch-enable*
    (setq *watch-enable* t)
    (when *watch-listview-id*
      (watch-redraw))))

(defun watch-disable ()
  (interactive)
  (when *watch-enable*
    (setq *watch-enable* nil)
    (when *watch-listview-id*
      (watch-redraw))))

(defun watch-stop ()
  (interactive)
  (when *watch-listview-id*
    (user::listview-dll-remove-all-icons *watch-listview-id*)
    (user::listview-dll-delete-all-items *watch-listview-id*)
    (user::listview-close *watch-listview-id*)
    (setq *watch-listview-id* nil)))

(defun watch-start ()
  (interactive)
  (unless *watch-listview-id*
    (setq *watch-listview-id* (user::listview-create-ex *watch-listview-size* *watch-listview-pos*))
    (user::listview-dll-modify-style *watch-listview-id* user::LVS_TYPEMASK user::LVS_REPORT 0)
    (user::listview-dll-modify-style *watch-listview-id* user::LVS_TYPESTYLEMASK user::LVS_EDITLABELS 0)
    (user::listview-keydown-callback
     *watch-listview-id*
     '(lambda (x y z)
       (cond ((find y '(8 46)) ; BS DELのみアイテムを削除
	      (unless (= x (1- (length *watch-symbol-list*)))
		(user::listview-delete-item *watch-listview-id* x)
		(setq *watch-symbol-list* ; この記述もイマイチ
		      (append (subseq *watch-symbol-list* 0 x)
			      (subseq *watch-symbol-list* (1+ x))))
		(watch-redraw)))
	     ((find y '(9 27)) ; TAB ESCの場合はxyzzyに戻す
	      (user::SetFocus (get-window-handle)))
	     ((find y '(113)) ; F2の場合は編集
	      (watch-edit-label x)))))
    (user::listview-edit-label-callback
     *watch-listview-id*
     '(lambda (idx txt)
       (cond ((string= txt "")
	      (progn
		; 最終行の場合は何もしない
		; 最終行以外の場合は削除する
		(when (/= idx (1- (length *watch-symbol-list*)))
		  (user::listview-delete-item *watch-listview-id* idx)
		  (setq *watch-symbol-list*	; この記述もイマイチ
			(append (subseq *watch-symbol-list* 0 idx)
				(subseq *watch-symbol-list* (1+ idx)))))))
	     (t
	      (progn
		; 行を更新する
		(user::listview-set-item-text *watch-listview-id* idx 0 txt)
		(setq *watch-symbol-list* ; この記述はもっとダメ
		      (append (subseq *watch-symbol-list* 0 idx)
			      (list txt)
			      (subseq *watch-symbol-list* (1+ idx))))
		; 最終行の場合は 行を追加する
		(when (= idx (1- (length *watch-symbol-list*)))
		  (user::listview-insert-item *watch-listview-id* (1+ idx) ""
					      :icon *watch-unbounded-icon*
					      :id (incf *watch-item-id*))
		  (setq *watch-symbol-list*	; これは未だ許せる
			(append *watch-symbol-list* '("")))))))
       (watch-redraw)))
    (dotimes (idx (length *watch-test-list*))
      (let ((itm (nth idx *watch-test-list*)))
	(user::listview-insert-column
	 *watch-listview-id* idx
	 (or (caddr itm) 80) (car itm))))
    (setq *watch-error-icon* (user::listview-add-file-icon *watch-listview-id* *watch-error-icon-file*))
    (setq *watch-bounded-icon* (user::listview-add-file-icon *watch-listview-id* *watch-bounded-icon-file*))
    (setq *watch-unbounded-icon* (user::listview-add-file-icon *watch-listview-id* *watch-unbounded-icon-file*))
    (dotimes (idx (length *watch-symbol-list*))
      (user::listview-insert-item *watch-listview-id* idx
				  (nth idx *watch-symbol-list*)
				  :icon *watch-unbounded-icon*
				  :id (incf *watch-item-id*)))
    (watch-redraw t)
    (user::SetFocus (get-window-handle))))

;;; フック用

(defun watch-symbol ()
  (and *watch-listview-id*
       *watch-enable*
       (watch-redraw)))

(add-hook '*post-command-hook* 'watch-symbol)

;;; 再描画

(defun watch-redraw (&optional arg)
  (if *watch-enable*
      (let (elst)
	; 評価結果取得
	(dolist (text *watch-symbol-list*)
	  (let (pkgname pkg symname sym)
	    (string-match "^\\(\\([^:]+\\)::?\\)?\\([^:]+\\)$" text)
	    (setq pkgname (or (match-string 2) "user"))
	    (setq symname (or (match-string 3) ""))
	    (and (setq pkg (find-package pkgname))
		 (setq sym (find-symbol symname pkg)))
	    (push (cons sym (and sym
				 (boundp sym)
				 (ignore-errors
				  (mapcar
				   #'(lambda (test)
				       (list (car test)
					     (funcall (cadr test) sym)))
				   *watch-test-list*))))
		  elst)))
	(setq elst (reverse elst))
	; 変更があったかチェック＋退避情報変更
	(when (or arg (not (equal *watch-last-list* elst)))
	  (setq *watch-last-list* elst)
	  (dotimes (idx (length elst))
	    (let (nthelst sym lst icon)
	      (setq nthelst (nth idx elst))
	      (setq sym (car nthelst))
	      (setq lst (cdr nthelst))
	      (dotimes (idy (length *watch-test-list*))
		(cond
		 ; 先頭の場合はシンボルがあるか？評価に成功したか？でアイコンを変更
		 ((zerop idy)
		  (user::listview-set-item-icon
		   *watch-listview-id* idx
		   (cond ((null sym) *watch-unbounded-icon*)
			 ((null lst) *watch-error-icon*)
			 (t *watch-bounded-icon*))))
		 ; シンボルがあればformatで設定
		 ((and sym lst)
		  (user::listview-set-item-text
		   *watch-listview-id* idx idy
		   (format nil "~S" (cadr (nth idy lst)))))
		 ; シンボルがなければ空文字を設定
		 (t
		  (user::listview-set-item-text
		   *watch-listview-id* idx idy ""))))))
	  (message "watch ... change detected")))
    (progn
      ; クリアすべき内容があるかチェック
      (when (or arg *watch-last-list*)
	(setq *watch-last-list* nil)
	(dotimes (idx (length *watch-symbol-list*))
	  (dotimes (idy (length *watch-test-list*))
	    (cond
	     ; 先頭の場合はアイコンを変更
	     ((zerop idy)
	      (user::listview-set-item-icon
	       *watch-listview-id* idx *watch-unbounded-icon*))
	     ; 以降は空文字を設定
	     (t
	      (user::listview-set-item-text
	       *watch-listview-id* idx idy "")))))
	(message "watch ... cleared")))))

;;; ツールバー関連

(defun tool-bar-update-watch-enable ()
  (cond ((null *watch-listview-id*) :disable)
	(*watch-enable* :check)))

(defun toggle-watch-listview ()
  (interactive)
  (if *watch-listview-id*
      (watch-stop)
    (watch-start)))

(defun toggle-watch-enable ()
  (interactive)
  (if *watch-enable*
      (watch-disable)
    (watch-enable)))

(defun watch-tool-bar ()
  (create-tool-bar 'watch-tool-bar
		   (merge-pathnames "watch-toolbar.bmp" (etc-path))
		   '(("watch表示" 0 toggle-watch-listview)
		     ("watch有効" 1 toggle-watch-enable tool-bar-update-watch-enable))))

(define-command-bar 'watch-tool-bar "watch(&W)")
