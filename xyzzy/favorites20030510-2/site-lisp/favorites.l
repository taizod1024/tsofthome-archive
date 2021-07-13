;;; -*- Mode: Lisp; Package: editor -*-
;;;
;;; favorites --- お気に入り管理

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-05-13"

;;; description
;;;	お気に入りを管理します。

;;; install
;;;	1.解凍した出来たfavorites.lを$XYZZY/site-lisp/にコピーします。
;;;     2.~/.xyzzyもしくは$XYZZY/site-lisp/siteini.lに記述を追加します。
;;;
;;;		--------------------------------
;;;		(require "favorites")
;;;		--------------------------------
;;;
;;;     3.*favorites-path*に指定したパスを作成します。
;;;	  標準では$XYZZY/favoritesです。
;;;     4.上記の設定を反映させるために、xyzzyを再起動します。
;;;	  ※siteinit.lに記述した場合には再ダンプもして下さい。

;;; uninstall
;;;	1.$XYZZY/site-lisp/favorites.lを削除します。
;;;	2.~/.xyzzyもしくは$XYZZY/site-lisp/siteini.lの関連する箇所を削除します。
;;;	  ※siteinit.lに記述していたならば再度ダンプし直します。

;;; note
;;;	特になし

;;; changes
;;;	Tue, 13 May 2003 00:24:59 +0900
;;;		・拡張子が"lnk"の場合には表示しないように変更
;;;	Sun, 11 May 2003 17:56:50 +0900
;;;		・メニューは指定された位置に挿入するように変更
;;;	Sat, 10 May 2003 22:39:29 +0900
;;;		・*favorites-accesskey*でアクセスキーの有無を制御可
;;;		・*favorites-menu-position*でメニューを挿入する位置を変更可
;;;			nil	: 先頭に挿入
;;;			整数	: その位置に挿入
;;;			その他	: タグと見なしてその次の位置に挿入
;;;		・*favorites-buffer-bar-context-menu-position*でメニューを挿入する位置を変更可
;;;			nil	: 先頭に挿入
;;;			整数	: その位置に挿入
;;;			その他	: タグと見なしてその次の位置に挿入
;;;		・*favorites-open-with-shell*でshell-executeからファイルを開く
;;;			nil	: find-fileでファイルを開く
;;;			t	: 拡張子の関連付けに従ってファイルを開く
;;;		・*favorites-resolve-shortcut-directory*でディレクトリを展開するか？
;;;			nil	: 従来どおり
;;;			t	: ディレクトリへのショートカットは展開
;;;	Wed, 30 Apr 2003 22:02:14 +0900
;;;		・驚くほどメニューを作るところが汚かったので全面書き換え。
;;;		・OHKUBOさんからの改善案の取り込み
;;;			・ファイル名が無かったら:disable
;;;			・タグの追加
;;;			・アクセスキーの追加
;;;	Mon, 28 Apr 2003 00:13:29 +0900
;;;		・説明文修正
;;;		・標準のパスを$XYZZY/favoritesから~/favoritesに変更
;;;	Tue, 13 Aug 2002 10:08:32 +0900
;;;		・create-dir-menuとcreate-dir-listをupdateの内部関数に変更
;;;		・設定ファイルでload-libraryすればよいだけに修正
;;;		・docstringを追加
;;;		・デフォルトのパスをc:/temp/favoritesから~/favoritesに変更
;;; 	***
;;;		・初版

(provide "favorites")

;;; --------------------------------
;;; variable
;;; --------------------------------
(defvar *favorites-path* (merge-pathnames "favorites" (user-homedir-pathname))
  "お気に入りのパス")

(defvar *favorites-menu* nil
  "お気に入りメニュー")

(defvar *favorites-accesskey* t
  "お気に入りのアクセスキーの有無")

(defvar *favorites-menu-position* 'ed::tools
  "お気に入りを挿入する位置（メニュー）")

(defvar *favorites-buffer-bar-context-menu-position* nil
  "お気に入りを挿入する位置（バッファバーのコンテキストメニュー）")

(defvar *favorites-open-with-shell* nil
  "お気に入りを拡張子の関連付けに従って開くか？")

(defvar *favorites-resolve-shortcut-directory* t
  "お気に入りのディレクトリへのショートカットを展開するか？")

;;; --------------------------------
;;; function
;;; --------------------------------
(defun add-to-favorites (&optional (buf (selected-buffer)))
  "お気に入りに追加"
  (interactive)
  (let ((f (get-buffer-file-name buf)))
    (if (and f
	     (file-exist-p f))
	(progn
	  (create-shortcut f *favorites-path*)
	  (update-favorites-menu)
	  (message "~A をお気に入りに追加しました。" (buffer-name buf)))
      (message "~A はファイルではありません" (buffer-name buf)))))

(defun open-favorites-path ()
  "お気に入りの整理"
  (interactive)
  (let ((*filer-primary-directory* *favorites-path*)
	(*filer-secondary-directory* *favorites-path*)
	(*filer-modal* t))
    (open-filer))
  (update-favorites-menu))

(defun open-favorites-func (f)
  "お気に入りを開く"
  (if (string= (pathname-type f) "lnk")
      (setq f (resolve-shortcut f)))
  (cond ((not (file-exist-p f))
	 (message "~A はリンク切れです" (file-namestring f)))
	(*favorites-open-with-shell*
	 (shell-execute (map-slash-to-backslash f)))
	(t
	 (find-file f))))

(defun update-favorites-menu ()
  "お気に入りメニューの更新"
  (interactive)
  (message "お気に入りを更新中 ...")
  (while (delete-menu *favorites-menu* 3 t))
  (add-favorites-menu *favorites-path* *favorites-menu*)
  (message "お気に入りを更新しました"))

(defun add-favorites-menu (path menu)
  "お気に入りメニューの作成"
  (long-operation
    (let (dl fl gen)
      (setq dl (directory path :directory-only t :absolute t))
      (setq dl (sort dl #'string-lessp))
      (setq dl (mapcar #'remove-trail-slash dl))
      (setq fl (directory path :file-only t :absolute t))
      (setq fl (sort fl #'string-lessp))
      ; アクセスキー生成用ジェネレータ
      (setq gen (let (ccode)
		  #'(lambda ()
		      (cond ((null ccode) (setq ccode (char-code #\A)))
			    ((< ccode (char-code #\Z)) (incf ccode))
			    (t (setq ccode (char-code #\A))))
		      (code-char ccode))))
      ; ディレクトリ
      (dolist (dir dl)
	(let (popup-menu text)
	  (setq popup-menu (create-popup-menu))
	  (setq text (file-namestring dir))
	  (if *favorites-accesskey*
	      (setq text (concat text (format nil "(&~A)" (funcall gen)))))
	  (add-favorites-menu dir popup-menu)
	  (add-popup-menu menu popup-menu text)))
      ; セパレータ
      (and dl fl
	   (add-menu-separator menu))
      ; ファイル
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
  "お気に入りの初期化"
  ; メニュー
  (let (pos menu menu-pos)
    (setq pos *favorites-menu-position*)
    (setq menu *app-menu*)
    (setq menu-pos (cond ((null pos) 0)
			 ((integerp pos) pos)
			 (t (get-menu-position menu pos))))
    (setq *favorites-menu*
	  (define-popup-menu
	    (:item 'favorites-add "お気に入りに追加(&A)" 'add-to-favorites
	     #'(lambda () (or (get-buffer-file-name) :disable)))
	    (:item 'favorites-arrange "お気に入りの整理(&O)..." 'open-favorites-path)
	    :sep))
    (insert-popup-menu menu menu-pos *favorites-menu* "お気に入り(&A)"))
  ; バッファバー
  (let (pos menu menu-pos)
    (setq pos *favorites-buffer-bar-context-menu-position*)
    (setq menu *buffer-bar-context-menu*)
    (setq menu-pos (cond ((null pos) 0)
			 ((integerp pos) pos)
			 (t (get-menu-position menu pos))))
    (insert-menu-separator menu menu-pos 'favorite-sep)
    (insert-menu-item menu menu-pos 'favorites-add "お気に入りに追加(&A)"
		      #'(lambda () (interactive) (add-to-favorites *buffer-bar-context-menu-buffer*))
		      #'(lambda () (or (get-buffer-file-name *buffer-bar-context-menu-buffer*) :disable)))
    (update-favorites-menu)))

;;; hook
(add-hook '*init-app-menus-hook* #'init-favorites)
