;;; -*- Mode: Lisp; Package: editor -*-
;;;
;;; addref.l --- リファレンス作成支援

;;; author
;;;   original by
;;;	quarto <quarto@livedoor.com>
;;;  arranged by
;;;	YAMAMOTO Taizo <ymtz@pop02.odn.ne.jp>

;;; date
;;;	Last updated: 2002/02/09 21:33:19 +0900

;;; description
;;;	リファレンスの作成支援のツールです。

;;; note
;;;	へなちょこリファレンスは、逸見さん・服部さんと受け継がれ、現在は
;;;	大久保さんのサイトで公開されています。
;;;	info, info-modoki, HTML等のさまざま形式での利用を想定して、
;;;	XML(reference.xml)+変換ツールにより構成されています。
;;;
;;;	add-ref.lは、quartoさんによって作成され、2001/04/01にxyzzy MLに投稿されました。
;;;	reference.xmlへ最終的にマージするための編集用のXMLファイルを、簡単にメンテナンス
;;;	するためのものです。
;;;
;;;	addref.lは、addref.lを元にYAMAMOTO Taizoによりアレンジしたものです。

;;; install
;;;	1.解凍してaddref.lを$XYZZY/site-lispにコピーします。
;;;	2.バイトコンパイルします。
;;;
;;;		--------------------------------
;;;		M-x byte-compile-file
;;;		--------------------------------
;;;
;;;	3.~/.xyzzyもしくは$XYZZY/site-lisp/siteinit.lに記述を追加します。
;;;	　※書き溜めるためのXMLファイル(*addref-file*)は初回に作成されます。
;;;
;;;		--------------------------------
;;;		(require "addref")
;;;		--------------------------------
;;;
;;;	4.上記の設定を反映させるために、xyzzyを再起動します。

;;; keybind
;;;	C-x C-s	保存及び画面復帰

;;; usage
;;;	想定している使い方は以下の二通りです。
;;;
;;;	1.info-modokiの様に、単語上でaddref-anyを実行する。
;;;	2.addref, addref-function, addref-variableを実行し、文字列／シンボルを入力する。
;;;
;;;	入力された文字列／シンボルが未登録ならば、新規作成の確認ダイアログが表示されます。
;;;	info-modokiに近い感覚でメンテナンスが出来ると思います。
;;;	ちなみに、seealsoとlinkは値を連続入力可能です。何も入力せずにENTERすると終了です。

;;; note
;;;	1.reference.xmlをベースに編集しようと思うと検索にちょっと時間が掛かります。
;;;	　出来れば別ファイルで作業を行うことをお薦めします。
;;;	2.セクション判定はおそろしくいい加減です。
;;;	　内容を確認した上で選択してください。
;;;	　また、より経験的に適切な判定ルーチンがあれば教えてください。

;;; changes
;;;	Wed, 30 Apr 2003 23:14:52 +0900
;;;		・*addref-file*の格納位置を$XYZZY/site-lisp/から$XYZZY/etc/に変更
;;;	Mon, 28 Apr 2003 00:30:21 +0900
;;;		・*addref-filename*を*addref-file*に変更
;;;	Wed, 20 Feb 2002 00:22:41 +0900
;;;		・addref-function-1から*addref-functionに変更
;;;		・addref-variable-1から*addref-variableに変更
;;;		・*addrefを追加
;;;		・addref-search-fileで行頭のsetqを検出するように変更
;;;		・addref-get-typeから"Symbol"を削除
;;;	Fri, 15 Feb 2002 01:33:06 +0900
;;;		・思い立っていろいろと補完を追加（YAMAMOTO Taizoによる修正）
;;;		　マイナーモードに変更（xml-modeでの使用を想定）
;;;		　*delete-buffer-hook*でもウィンドウ配置の復帰で行うように変更
;;;		　性能を考慮して、保存しても閉じないように変更
;;;	Sun, 1 Apr 2001 01:11:57 +0900
;;;		・初版（quartoさんによりxyzzy MLに投稿された）

(provide "addref")

;;;
;;; いろいろ
;;;

(defvar *addref-file* (merge-pathnames "addref.xml" (etc-path))
  "addref: リファレンス編集用のXMLファイル")
(defvar *addref-search-path* (merge-pathnames "lisp" (si::system-root))
  "addref: 定義の検索パス")
(defvar *addref-window-height* 15
  "addref: 編集ウィンドウの大きさ")

(defvar *addref-ask-type* t
  "addref: 新規作成時のタイプの問い合わせ")
(defvar *addref-ask-arguments* t
  "addref: 新規作成時の引数の問い合わせ")
(defvar *addref-ask-package* t
  "addref: 新規作成時のパッケージの問い合わせ")
(defvar *addref-ask-seealso* t
  "addref: 新規作成時のSEEALSOの問い合わせ")
(defvar *addref-ask-link* nil
  "addref: 新規作成時のリンクの問い合わせ")
(defvar *addref-ask-section* t
  "addref: 新規作成時のセクションの問い合わせ")
(defvar *addref-ask-file* nil
  "addref: 新規作成時のファイルの問い合わせ")
(defvar *addref-type-list* '("Function" "Variable" "Macro" "Misc"
			     "Keyword" "Special Form" "BufferLocal" "Tips")
  "addref: タイプ一覧")
(defvar *addref-section-list* '("データ型" "変数と定数" "制御構造"
				"パッケージ" "関数" "マクロ" "シンボル"
				"数値" "文字" "文字列" "シーケンス"
				"リスト" "ハッシュ" "配列" "チャンク"
				"評価" "入出力" "ファイルシステム"
				"エラー" "ウィンドウ" "バッファ"
				"ミニバッファ" "リージョン" "モード"
				"シンタックス" "キーマップ" "テキスト"
				"検索・正規表現" "ダイアログ" "日付・時間"
				"メニュー" "ファイラー" "ポジション"
				"プロセス" "システム" "その他")
  
  "addref: セクション一覧")
(defvar *addref-popup-completion-list* t
  "addref: 補完時にポップアップリストを使用")

(defvar *addref-mode-map* nil
  "addref: マイナーモード用キーマップ")
(unless *addref-mode-map*
  (setq *addref-mode-map* (make-sparse-keymap))
  (define-key *addref-mode-map* '(#\C-x #\C-s) 'addref-end))

(defvar-local *addref-mode* nil)
(pushnew '(*addref-mode* . "AddRef") *minor-mode-alist* :key 'car)

(defstruct addref-topic
  title type arguments package desc seealso link section file)

;;;
;;; UI
;;;

;;; lisp-info-F1のようなものを想定
(defun addref-any ()
  "addref: ポイントから文字列を取得"
  ; ↓↓↓info-modoki.lから拝借
  (interactive)
  (let (beg end)
    (save-excursion
      (setq end (progn
		  (or (skip-syntax-spec-forward "w_j")
		      (skip-syntax-spec-backward "^w_j"))
		  (point)))
      (setq beg (progn
		  (skip-syntax-spec-backward "w_j")
		  (when (looking-at "^■")
		    (forward-char 1))
		  (point))))
    (unless (= beg end)
      (addref (buffer-substring beg end))))
  ;↑↑↑
  )

;;; 関数用
(defun addref-function ()
  "addref: 関数専用のリファレンス追加"
  (interactive)
  (let ((*minibuffer-popup-completion-list* *addref-popup-completion-list*))
    (call-interactively '*addref-function)))
(defun *addref-function (func)
  (interactive "aaddref-function: ")
  (addref func))

;;; 変数用
(defun addref-variable ()
  "addref: 変数専用のリファレンス追加"
  (interactive)
  (let ((*minibuffer-popup-completion-list* *addref-popup-completion-list*))
    (call-interactively '*addref-variable)))
(defun *addref-variable (var)
  (interactive "vaddref-variable: ")
  (addref var))

;;; 汎用
(defun addref (&optional str-or-sym)
  "addref: 汎用のリファレンス追加"
  (interactive)
  (let ((*minibuffer-popup-completion-list* *addref-popup-completion-list*))
    (funcall '*addref str-or-sym)))
(defun *addref (&optional str-or-sym)
  (interactive)
  (let ((tlst (addref-get-title-list))
	str sym)
    ; 入力をタイトルとシンボルに変換
    (unless str-or-sym
      (setq str-or-sym (completing-read "addref: " tlst)))
    (cond ((symbolp str-or-sym)
	   (setq sym str-or-sym)
	   (setq str (addref-symbol-name sym)))
	  ((find-symbol str-or-sym)
	   (setq sym (find-symbol str-or-sym))
	   (setq str (addref-symbol-name sym)))
	  (t
	   (setq sym nil)
	   (setq str str-or-sym)))
    ; 入力に応じて各エントリを埋めてから編集モードへ移行
    (cond ; 既存のタイトル
	  ((find str tlst :test 'string=)
	   (addref-fix str))
	  ; 新規作成のタイトル
	  ((yes-or-no-p "~A\n\n見あたりません、新規に作成しますか？" str)
	   (let ((tpc (make-addref-topic)))
	     ; シンボルなら適当に埋める
	     (if sym
		 (addref-set-symbol-to-topic sym tpc)
	       (setf (addref-topic-title tpc) str))
	     ; type
	     (when *addref-ask-type*
	       (message "completing ... type list")
	       (setf (addref-topic-type tpc)
		     (completing-read (format nil "~A ... type: " str)
				      *addref-type-list*
				      :default (addref-topic-type tpc)
				      :must-match t)))
	     ; arguments
	     (when *addref-ask-arguments*
	       (unless (find-if #'(lambda (x) (string= x (addref-topic-type tpc)))
				'("Variable" "BufferLocal" "Tips"))
		 (setf (addref-topic-arguments tpc)
		       (completing-read (format nil "~A ... arguments: " str)
					nil :default (addref-topic-arguments tpc)))))
	     ; package
	     (when *addref-ask-package*
	       (unless (find-if #'(lambda (x) (string= x (addref-topic-type tpc)))
				'("Tips"))
		 (message "completing ... package list")
		 (setf (addref-topic-package tpc)
		       (completing-read (format nil "~A ... package: " str)
					(mapcar 'package-name (list-all-packages))
					:default (addref-topic-package tpc)))))
	     ; seealso
	     (when *addref-ask-seealso*
	       (message "completing ... topic list")
	       (let (val olst (ilst (addref-topic-seealso tpc)))
		 (loop
		   (setq val
			 (completing-read (format nil "~A ... seealso #~D: "
						  str (1+ (length olst)))
					  tlst :default (pop ilst)))
		   (cond ((string/= val "")
			  (pushnew val olst :test 'string=))
			 ((null ilst)
			  (return)))
		   (message "seealso:~{ ~A~}" olst))
		 (setf (addref-topic-seealso tpc) olst)))
	     ; link
	     (when *addref-ask-link*
	       (message "completing ... link list")
	       (let (val olst (ilst (addref-topic-link tpc)))
		 (loop
		   (setq val
			 (completing-read (format nil "~A ... link #~D: "
						  str (1+ (length olst)))
					  nil :default (pop ilst)))
		   (cond ((string/= val "")
			  (pushnew val olst :test 'string=))
			 ((null ilst)
			  (return)))
		   (message "link:~{ ~A~}" olst))
		 (setf (addref-topic-link tpc) olst)))
	     ; section
	     (when *addref-ask-section*
	       (setf (addref-topic-section tpc)
		     (completing-read (format nil "~A ... section: " str)
				      *addref-section-list*
				      :default (addref-topic-section tpc)
				      :must-match t)))
	     ; file
	     (if (yes-or-no-p "ファイルを検索しますか？") ; symがある時だけでもいいが…
	       (setf (addref-topic-file tpc) (addref-search-file str))
	       (if *addref-ask-file*
		   (setf (addref-topic-file tpc)
			 (completing-read "file: " nil))))
	     (addref-add tpc)
	     (addref-fix tpc)))
	  ; 該当なし
	  (t nil))))

;;;
;;; 編集
;;;

(defvar *addref-winconf* nil)

(defun addref-add (tpc)
  "addref: 出来上がった空のトピックをバッファに追加"
  (save-excursion
    (set-buffer (ed::find-file-internal *addref-file*))
    (widen)
    (goto-char (point-min))
    (with-output-to-selected-buffer
      (addref-output-topic-format tpc))))

(defun addref-fix (tpc-or-str)
  "addref: 出来上がった空のトピックを編集開始"
  ; ウィンドウ配置の退避
  (unless *addref-winconf*
    (setq *addref-winconf* (current-window-configuration)))
  ; 編集ファイルをカレントバッファへ変更
  (let ((buf (ed::find-file-internal *addref-file*)))
    (unless (eq (selected-buffer) buf)
      (delete-other-windows)
      (pop-to-buffer buf *addref-window-height*)))
  ; タイトルの検索・範囲限定・移動
  (widen)
  (goto-char (point-min))
  (when (scan-buffer
	 (concat "<title>"
		 (if (addref-topic-p tpc-or-str)
		     (addref-topic-title tpc-or-str)
		   tpc-or-str)
		 "</title>"))
    (narrow-to-region
     (progn (scan-buffer "<chapter>" :reverse t :tail nil) (point))
     (progn (scan-buffer "</chapter>\n" :tail t) (point)))
    (unless (prog1 (buffer-modified-p) (addref-decode-entity))
      (not-modified))
    (scan-buffer "<description>\n" :reverse t :tail t)
    (skip-chars-forward " \t");
    (recenter 6) ; chapter-descriptionで6行
    ; addref-modeの開始
    (ed::toggle-mode '*addref-mode* t t)
    (update-mode-line t)
    (set-minor-mode-map *addref-mode-map*)))

(defun addref-end ()
  "addref: 編集完了"
  (interactive)
  (let ((buf (find-buffer (file-namestring *addref-file*))))
    ; バッファが存在しaddref-modeの場合だけ
    (when (and buf *addref-mode*)
      (set-buffer buf)
      (narrow-to-region
       (progn (scan-buffer "<chapter>" :reverse t :tail nil) (point))
       (progn (scan-buffer "</chapter>\n" :tail t) (point)))
      (addref-encode-entity)
      (widen)
      (save-buffer)
      ; addref-modeの終了
      (ed::toggle-mode '*addref-mode* nil t)
      (update-mode-line t)
      (unset-minor-mode-map *addref-mode-map*)
      ; ウィンドウ配置の復帰
      (when *addref-winconf*
	(set-window-configuration *addref-winconf*)
	(setq *addref-winconf* nil)))))

(add-hook '*delete-buffer-hook*
	  #'(lambda (buf)
	      ; 退避したウィンドウ配置がありaddref-modeの場合だけ
	      ; ※kill-buffer対策
	      (when (and *addref-mode*
			 *addref-winconf*)
		(set-window-configuration *addref-winconf*)
		(setq *addref-winconf* nil))
	      t))

(defun addref-get-title-list ()
  "addref: タイトルのリストを取得します"
  (let (lst)
    (save-excursion
      (set-buffer (ed::find-file-internal *addref-file*))
      (save-excursion
	(save-restriction
	  (widen)
	  (goto-char (point-min))
	  (while (scan-buffer "<title>\\(.*\\)</title>" :regexp t :no-dup t :tail t)
	    (pushnew (match-string 1) lst :test 'string=)))))
    lst))

;;;
;;; トピックの操作
;;;

(defun addref-retrieve-topic (tpc)
  "addref: トピックを抽出して構造体に格納します。"
  (save-excursion
    (save-restriction
      (widen)
      (narrow-to-region
       (progn (scan-buffer "<chapter>" :reverse t :tail nil) (point))
       (progn (scan-buffer "</chapter>\n" :tail t) (point)))
      (let* (ttitle ttype targuments tpackage tdesc tseealso tlink tsection tfile str end)
	(goto-char (point-min))
	(and (scan-buffer "<title>\\(.*\\)</title>" :regexp t :tail t)
	     (setq ttitle (match-string 1)))
	(goto-char (point-min))
	(and (scan-buffer "<type>\\(.*\\)</type>" :regexp t :tail t)
	     (setq ttype (match-string 1)))
	(goto-char (point-min))
	(and (scan-buffer "<arguments>\\(.*\\)</arguments>" :regexp t :tail t)
	     (setq targuments (match-string 1)))
	(goto-char (point-min))
	(and (scan-buffer "<package>\\(.*\\)</package>" :regexp t :tail t)
	     (setq tpackage (match-string 1)))
	(goto-char (point-min))
	(and (integerp
	      (setq str (and (scan-buffer "<description>\n?" :regexp t :tail t)
			     (match-end 0))))
	     (integerp
	      (setq end (and (scan-buffer "\n?</description>" :regexp t :tail nil)
			     (match-beginning 0))))
	     (setq tdesc (buffer-substring str end)))
	(goto-char (point-min))
	(while (and (integerp
		     (setq str (and (scan-buffer "<seealso>\n?" :regexp t :tail t)
				    (match-end 0))))
		    (integerp
		     (setq end (and (scan-buffer "\n?</seealso>" :regexp t :tail nil)
				    (match-beginning 0)))))
	  (pushnew (buffer-substring str end) tseealso :test 'string=))
	(goto-char (point-min))
	(and (scan-buffer "<link>\\(.*\\)</link>" :regexp t :tail t)
	     (setq tlink (match-string 1)))
	(goto-char (point-min))
	(while (and (integerp
		     (setq str (and (scan-buffer "<section>\n?" :regexp t :tail t)
				    (match-end 0))))
		    (integerp
		     (setq end (and (scan-buffer "\n?</section>" :regexp t :tail nil)
				    (match-beginning 0)))))
	  (pushnew (buffer-substring str end) tsection :test 'string=))
	(goto-char (point-min))
	(and (scan-buffer "<file>\\(.*\\)</file>" :regexp t :tail t)
	     (setq tfile (match-string 1)))
	(setf (addref-topic-title tpc) ttitle)
	(setf (addref-topic-type tpc) ttype)
	(setf (addref-topic-arguments tpc) targuments)
	(setf (addref-topic-package tpc) tpackage)
	(setf (addref-topic-desc tpc) tdesc)
	(setf (addref-topic-seealso tpc) tseealso)
	(setf (addref-topic-link tpc) tlink)
	(setf (addref-topic-section tpc) tsection)
	(setf (addref-topic-file tpc) tfile))))
  tpc)

(defun addref-output-topic-format (tpc)
  (format t "<chapter>\n")
  (format t "<title>~A</title>\n" (or (addref-topic-title tpc) ""))
  (format t "<type>~A</type>\n" (or (addref-topic-type tpc) ""))
  (format t "<arguments>~A</arguments>\n" (or (addref-topic-arguments tpc) ""))
  (format t "<package>~A</package>\n" (or (addref-topic-package tpc) ""))
  (format t "<description>\n~A\n</description>\n" (or (addref-topic-desc tpc) ""))
  (format t "~{<seealso>~A</seealso>\n~}" (or (addref-topic-seealso tpc) '("")))
  (format t "~{<link>~A</link>~}\n" (or (addref-topic-link tpc) '("")))
  (format t "<section>~A</section>\n" (or (addref-topic-section tpc) ""))
  (format t "<file>~A</file>\n" (or (addref-topic-file tpc) ""))
  (format t "</chapter>\n\n"))

(defun addref-set-symbol-to-topic (sym tpc)
  (let* ((ttitle (addref-symbol-name sym))
	 (ttype (addref-get-type sym))
	 (targuments (addref-get-arguments sym))
	 (tpackage (addref-get-package-name sym))
	 tdesc
	 tseealso
	 tlink
	 (tsection (addref-guess-section ttitle targuments))
	 tfile)
    (setf (addref-topic-title tpc) ttitle)
    (setf (addref-topic-type tpc) ttype)
    (setf (addref-topic-arguments tpc) targuments)
    (setf (addref-topic-package tpc) tpackage)
    (setf (addref-topic-desc tpc) tdesc)
    (setf (addref-topic-seealso tpc) tseealso)
    (setf (addref-topic-link tpc) tlink)
    (setf (addref-topic-section tpc) tsection)
    (setf (addref-topic-file tpc) tfile)))

;;;
;;; 実体参照のエンコード・デコード
;;;

(defvar *addref-tag-list*
  '("<chapter>" "<title>" "<type>" "<arguments>" "<description>"
    "<package>" "<seealso>" "<section>" "<link>" "<file>"
    "</chapter>" "</title>" "</type>" "</arguments>" "</description>"
    "</package>" "</seealso>" "</section>" "</link>" "</file>"
    "<!--" "-->"))
(defun addref-encode-entity ()
  (long-operation
    (save-excursion
      (goto-char (point-min))
      (while (scan-buffer "&\\|<\\|>" :no-dup t :regexp t :tail nil)
	(cond ((looking-for "&")
	       (unless (find-if 'looking-for '("&amp;" "&lt;" "&gt;"))
		 (forward-char)
		 (insert "amp;")
		 (backward-char)))
	      ((looking-for "<")
	       (unless (find-if 'looking-for *addref-tag-list*)
		 (delete-char)
		 (insert "&lt;")
		 (backward-char)))
	      ((looking-for ">")
	       (forward-char)
	       (unless (find-if 'looking-back *addref-tag-list*)
		 (delete-char -1)
		 (insert "&gt;")
		 (backward-char))))))))

(defun addref-decode-entity ()
  (long-operation
    (save-excursion
      (goto-char (point-min))
      (perform-replace "&amp;" "&" nil nil nil t)
      (goto-char (point-min))
      (perform-replace "&lt;" "<" nil nil nil t)
      (goto-char (point-min))
      (perform-replace "&gt;" ">" nil nil nil t))))

(defun addref-decode-entity-string (str)
  (substitute-string str "&amp;" "&")
  (substitute-string str "&lt;" "<")
  (substitute-string str "&gt;" ">"))

;;;
;;; シンボルから各種情報を取得
;;;

(defun addref-symbol-name (sym)
  (concat (and (keywordp sym) ":") (symbol-name sym)))

(defun addref-get-type (sym)
  (setq ttype
	(cond ((special-form-p sym) "Special Form")
	      ((macro-function sym) "Macro")
	      ((fboundp sym) "Function")
	      ((keywordp sym) "Keyword")
	      ((boundp sym)
	       (cond ((local-variable-p sym) "BufferLocal")
		     (t "Variable")))
	      (t "Misc"))))

(defun addref-get-arguments (sym)
  (when (fboundp sym)
    (let ((def (symbol-function sym))
	  (name (symbol-name sym))
	  args)
      ;↓↓↓describe-functionからそのまま
      (cond ((si:*builtin-function-p def)
	     (setq args (get sym 'si::builtin-function-argument)))
	    (t
	     (if (si:*closurep def)
		 (setq def (si:closure-body def)))
	     (when (or (eq (safe-car def) 'lambda)
		       (eq (safe-car def) 'macro))
	       (setq args (safe-cadr def)))))
      ;↑↑↑
      (with-output-to-string (so)
	(let ((*standard-output* so))
	  (format t "~a" name)
	  ;↓↓↓describe-functionからそのまま
	  (if (stringp args)
	      (format t " ~a" args)
	    (labels ((print-sexp (sexp)
		       (cond ((null sexp)
			      (princ "()"))
			     ((listp sexp)
			      (cond ((eq (car sexp) 'quote)
				     (princ "'")
				     (print-sexp (cadr sexp)))
				    ((eq (car sexp) 'function)
				     (princ "#'")
				     (print-sexp (cadr sexp)))
				    (t
				     (print-list sexp "(")
				     (princ ")"))))
			     ((member sexp lambda-list-keywords)
			      (format t "~a" sexp))
			     ((keywordp sexp)
			      (format t ":~:@(~a~)" sexp))
			     (t
			      (format t "~:@(~a~)" sexp))))
		     (print-list (args prefix)
		       (dolist (arg args)
			 (princ prefix)
			 (print-sexp arg)
			 (setq prefix " "))))
	      (print-list args " ")))
	  ;↑↑↑
	  )))))

(defun addref-get-package-name (sym)
  (package-name (symbol-package sym)))

(defun addref-guess-section (ttitle &optional targ)
  (string-matchp "^*?\\(.*\\)*?$" ttitle)
  (setq ttitle (match-string 1))
  (cond ; 確度高し
	((string-matchp "filer" ttitle) "ファイラー")
	((string-matchp "hash" ttitle) "ハッシュ")
	((string-matchp "array" ttitle) "配列")
	((string-matchp "package" ttitle) "パッケージ")
	((string-matchp "syntax" ttitle) "シンタックス")
	((string-matchp "menu" ttitle) "メニュー")
	((string-matchp "dialog" ttitle) "ダイアログ")
	((string-matchp "process" ttitle) "プロセス")
	((string-matchp "window\\|screen" ttitle) "ウィンドウ")
	((string-matchp "stream$" ttitle) "入出力")
	((string-matchp "\\(tool\\|command\\|tab\\)-bar" ttitle) "メニュー")
	((string-matchp "[^euxmolaih]p$" ttitle) "データ型")
	((string-matchp "^with-[io]" ttitle) "入出力")
	; 多分大丈夫
	((string-matchp "-char$" ttitle) "文字")
	((string-matchp "column\\|point" ttitle) "ポジション")
	((string-matchp "c[ad]+r$" ttitle) "リスト")
	((string-matchp "replace\\|match" ttitle) "検索・正規表現")
	((string-matchp "mode$" ttitle) "モード")
	; 条件反射的
	((string-matchp "macro" ttitle) "マクロ")
	((string-matchp "region" ttitle) "リージョン")
	((string-matchp "minibuffer" ttitle) "ミニバッファ")
	((string-matchp "string" ttitle) "文字列")
	((string-matchp "path-?name\\|directory" ttitle) "ファイルシステム")
	((string-matchp "time\\|date" ttitle) "日付・時間")
	; 残り物
	((string-matchp "system" ttitle) "システム")
	((string-matchp "seq" ttitle) "シーケンス")
	((string-matchp "eval" ttitle) "評価")
	((string-matchp "stream" ttitle) "入出力")
	((string-matchp "error" ttitle) "エラー")
	((string-matchp "mode" ttitle) "モード")
	((string-matchp "keymap" ttitle) "キーマップ")
	; 引数から
	((null targ))
	((string-matchp "regexp\\|pattern" targ) "検索・正規表現")
	((string-matchp "list" targ) "リスト")
	((string-matchp "form" targ) "制御構造")
	((string-matchp "seq" targ) "シーケンス")))

(require "grepd")
(defun addref-search-file (str)
  (let ((ed::*grep-case-fold-search* nil)
	(ed::*grep-word-search* nil)
	(ed::*grep-regexp-search* t)
	(ed::*grep-understand-escape-sequences* nil)
	(ed::*grep-subdir* t)
	(ed::*grep-async* nil)
	(ed::*grep-name-only* nil)
	(w (current-window-configuration))
	(rexp (concat "\\(defconstant\\|defvar\\|setq-default\\|defun\\|defun-builtin\\|defmacro\\|^(setq\\) "
		      (regexp-quote str)
		      " ?")))
    (ed::scan-files rexp "*.l" *addref-search-path*)
    (switch-to-buffer "*grep*")
    (prog1
	(if (eq (point-min) (point-max))
	    nil
	  (buffer-substring
	   (point-min)
	   (progn (scan-buffer ":[0-9]+:" :regexp t :tail nil) (point))))
      (set-window-configuration w))))

;;;
;;; おまけ
;;;
(defun addref-title-list-to-temp-buffer ()
  "addref: reference.xmlの内容からタイトルのリストを作る。"
  (interactive)
  (with-output-to-temp-buffer ("*addref title*")
    (format t "~{~A\n~}" (addref-decode-entity-string (addref-get-title-list)))))
