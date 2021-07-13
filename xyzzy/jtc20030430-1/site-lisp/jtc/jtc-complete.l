;;; -*- Mode: Lisp; Package:jtc -*-
;;;
;;; jtc-complete.l --- JavaTinyConsole
;;;

;;; author
;;;	YAMAMOTO Taizo

;;; date
;;;	Last updated: "2003-05-02"

(provide "jtc/jtc-complete")

(require "java")
(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "jtc/jtc-def"))

(in-package "jtc")

(export '(jtc-do-completion
	  jtc-info
	  jtc-insert-open-paren
	  jtc-insert-close-paren
	  jtc-update-temp-completion-list
	  *jtc-completion-file-list*
	  *jtc-info-url-hook*
	  *jtc-info-hook*
	  *jtc-temp-completion-file*))

(defvar *jtc-completion-file-list*
  ; 補完ファイルのリスト（ワイルドカード可）
  ; このままだと起動時に自動的に一時補完リストの前回の結果を読み込んでくれる。
  (list (merge-pathnames "site-lisp/jtc/complete/*.lst" (si:system-root))))

(defvar *jtc-doclet* "ListClass")
(defvar *jtc-docletpath* (merge-pathnames "site-lisp/jtc/doclet" (si:system-root)))
(defvar *jtc-temp-completion-file* (merge-pathnames "site-lisp/jtc/complete/temp.lst" (si:system-root)))
(defvar *jtc-complete-initialized* nil)

(define-key ed::*java-mode-map* #\( 'jtc-insert-open-paren)
(define-key ed::*java-mode-map* #\) 'jtc-insert-close-paren)
(define-key ed::*java-mode-map* #\] 'jtc-insert-close-paren)
(define-key ed::*java-mode-map* #\. 'jtc-insert-close-paren)
(define-key ed::*java-mode-map* #\# 'jtc-insert-close-paren)
(define-key ed::*java-mode-map* #\TAB 'jtc-do-completion)
(set-syntax-punctuation ed::*java-mode-syntax-table* #\#)
(define-key ed::*java-mode-map* #\F1 'jtc-info)

(defvar *jtc-class-list* nil)		; クラスの一覧リスト
(defvar *jtc-member-list-hash* nil)	; 各クラス毎のメンバのリストを格納するハッシュ
(defvar *jtc-superclass-hash* nil)	; 各クラス毎のスーパークラスを格納するハッシュ
(defvar *jtc-jcinfo-hash* nil)		; クラス・メンバをキーとしてjcinfoを格納するハッシュ
; 備忘用：
; *jtc-jcinfo-hash*/*jtc-member-list-hash* をハッシュ（メンバ）を格納するハッシュ（クラス）にしなかったのは
; コンストラクタを補完リストから一々削除する必要があったため止めた。ハッシュのハッシュはカッコいいけど
; 少数の例外があるので諦めた。

(defvar *jtc-keyword-list*
  '("null" "true" "false" "class"
    "interface" "extends" "implements"
    "instanceof" "import" "package" "public"
    "protected" "private" "final" "static"
    "abstract" "native" "synchronized" "volatile"
    "transient" "for" "while" "do"
    "if" "else" "switch" "case"
    "default" "break" "continue" "return"
    "try" "catch" "finally" "throw"
    "throws" "const" "goto" "byte"
    "char" "short" "int" "long"
    "float" "double" "boolean" "void"
    "new"		; ※ narrow-to-term1/parse-term1では個別にチェックし素通しする
    "this" "super"	; ※ reduce-term1の中でオブジェクトとして使用するのでチェックしない
    ))

(defstruct jcinfo
  (kind "")
  (return "")
  (truename "")
  (name "")
  (signature "")
  (url ""))

;;; --------------------------------
;;; 情報の表示用フック
;;; ここではbrowser.dllを使わせて頂く
;;; www-modeとか外部のIEってのも勿論あり
;;; Sun, 07 Oct 2001 12:27:56 +0900
(defvar *jtc-info-url-hook*
  #'(lambda (i)
      (let ((p (car *jtc-jdk-document-directory*)))
	(concat ; "http://"でなければローカルなので、"file://"を追加
		(unless (string-match "^http://" p) "file://")
		; 指定されたパス
		p
		; "/"で終わってなければ"/"を追加
		(unless (string-match "/$" p) "/")
		; ディレクトリを設定
		"api/"
		; 補完リストから調達
		(jcinfo-url i)))))

(defvar *jtc-info-hook*
  #'(lambda (u)
      (let (navigate)
	(setq navigate
	      (or (and (find-package "browserex")
		       (find-symbol "navigate" "browserex"))
		  (find-symbol "navigate" "user")))
	(when navigate
	  (funcall navigate u)
	  (message u)))))

;;; --------------------------------
;;; 情報の表示
;;; Sun, 07 Oct 2001 12:27:56 +0900
(defun jtc-info ()
  (interactive)
  ; 変なシンタックスなら終了
  (when (parse-point-syntax (point))
    (return-from jtc-info nil))
  ; 初期化チェック
  ; 時間が掛かるので、可能な限りload-completion-fileの呼び出しを遅らせる。
  ; 対象は以下のとおり。
  ; - jtc-do-completion
  ; - jtc-info
  ; - jtc-insert-open-paren
  ; - jtc-insert-close-paren
  ; - jtc-update-temp-completion-list
  (unless *jtc-complete-initialized*
    (load-completion-file)
    (setq *jtc-complete-initialized* t))
  ; いろいろする
  (let (q r s u v w)
    (save-excursion
      (skip-syntax-spec-backward "w_")
      (setq q (point))
      (when (setq r (find (preceding-char) '(#\. #\#) :test 'char=))
	(setq s (reduce-term (parse-term))))
      (setq u (buffer-substring q (save-excursion (skip-syntax-spec-forward "w_") (point)))))
    (cond ; クラス名とかあるか？あるなら、それを考慮して使用
	  (s (cond ; (1)メンバ名があるか？ないならクラス名だけ使用
		   ((string-equal u "")
		    (if (setq w (get-jcinfo-class s))
			(popup-string (jcinfo-signature w) (point))
		      (popup-string (format nil "~A ???" s) (point))))
		   ; (2)知ってるクラス名でメンバ名も有るようだ
		   ((setq w (get-jcinfo-member s u))
		    (popup-string (jcinfo-signature w) (point)))
		   ; (3)知らないクラス名だから、メンバ名なんぞ知らない
		   ((popup-string (format nil "identifier ???") (point)))))
	  ; 単独で現れているようだ
	  (t (cond ; (4)変数名・メンバ名をクラス名に変換できる？
		   ((setq v (reduce-term (list u)))
		    (setq w (get-jcinfo-class v))
		    (popup-string (jcinfo-signature w) (point)))
		   ; (5)変数名・メンバ名でもないし、知ってるクラス名でもないようだ
		   ((string-equal u "")
		    (popup-string (format nil "where ???") (point)))
		   (t
		    (popup-string (format nil "class name ???\nidentifier ???" u) (point))))))
    ; フックの呼び出し
    (let (u)
      (and w
	   *jtc-show-api-ref*
	   *jtc-info-url-hook*
	   (setq u (funcall *jtc-info-url-hook* w))
	   *jtc-info-hook*
	   (funcall *jtc-info-hook* u)))))

;;; --------------------------------
;;; 開き括弧の場合
;;; Sun, 07 Oct 2001 12:28:24 +0900
(defun jtc-insert-open-paren (&optional (arg 1))
  (interactive "*p")
  ; 初期化チェック
  (unless *jtc-complete-initialized*
    (load-completion-file)
    (setq *jtc-complete-initialized* t))
  ; 開き括弧
  (let (p q)
    (multiple-value-bind (p q)
	(reduce-term (parse-term))
      (c-electric-insert arg)
      (when q
	(cond ((string-match "[f]" (jcinfo-kind q))
	       (popup-string "field name ???" (point)))
	      (t
	       (popup-string (jcinfo-signature q) (point))))))))

;;; --------------------------------
;;; 閉じ括弧の場合
;;; Sun, 07 Oct 2001 12:28:36 +0900
(defun jtc-insert-close-paren (&optional (arg 1))
  (interactive "*p")
  ; 初期化チェック
  (unless *jtc-complete-initialized*
    (load-completion-file)
    (setq *jtc-complete-initialized* t))
  ; 閉じ括弧
  (let (p q r)
    (self-insert-command arg)
    (multiple-value-bind (p q)
	(reduce-term (parse-term))
      (when p
	(cond ((setq r (get-jcinfo-class p))
	       (popup-string (jcinfo-signature r) (point)))
	      ((eq *last-command-char* #\.)
	       (popup-string (format nil "~A ???" p) (point)))
	      (t
	       (popup-string (format nil "~A" p) (point))))))))

;;; --------------------------------
;;; 補完処理
;;; Sat, 06 Jan 2001 07:55:44 +0900
(defun jtc-do-completion ()
  (interactive "*")
  ; 行頭の場合のインデント
  (when (save-excursion
	  (skip-chars-backward " \t")
	  (bolp))
    (c-indent-line)
    (return-from jtc-do-completion t))
  ; 補完無しなら終了
  (unless *jtc-member-completion*
    (return-from jtc-do-completion nil))
  ; 変なシンタックスなら終了
  (when (parse-point-syntax (point))
    (message "cannot do completion in string")
    (return-from jtc-do-completion nil))
  ; 初期化チェック
  (unless *jtc-complete-initialized*
    (load-completion-file)
    (setq *jtc-complete-initialized* t))
  ; 補完処理
  (let (p q r s u v w)
    (setq p (point))
    (save-excursion
      (skip-syntax-spec-backward "w_")
      (setq q (point))
      (setq r (find (preceding-char) '(#\. #\#) :test 'char=))
      (setq s (reduce-term (parse-term))))
    (cond (r (setq u (do-completion q p :list (gethash s *jtc-member-list-hash*) nil nil t))
	     (setq v (buffer-substring q (point)))
	     (setq z (get-jcinfo-member s v))
	     (if (and z (eq u t)) (popup-string (jcinfo-signature z) (point))))
	  (t (do-completion q p :list (append *jtc-keyword-list* *jtc-class-list*) nil nil t)))))

;;; --------------------------------
;;; 一時的補完リスト作成
(defun jtc-update-temp-completion-list ()
  (interactive)
  ; 初期化チェック
  (unless *jtc-complete-initialized*
    (load-completion-file)
    (setq *jtc-complete-initialized* t))
  ; 補完リスト作成
  (save-window-excursion
    (let ((cmd (format nil "~A -doclet ~A -docletpath \"~A\" *.java > \"~A\""
		       (car *jtc-javadoc-history*)
		       *jtc-doclet*
		       *jtc-docletpath*
		       *jtc-temp-completion-file*))
	  (dir (default-directory)))
      (long-operation
	(with-output-to-temp-buffer (*jtc-command-buffer-name*)
	  (format t "対象ﾃﾞｨﾚｸﾄﾘ\n\t~A\n一時補完ﾘｽﾄ作成中 ...\n\t~A" dir cmd))
	(message "一時補完ﾘｽﾄ作成中 ...")
	(execute-shell-command cmd t *jtc-output-buffer-name* t dir))
      (if (load-completion-file1 *jtc-temp-completion-file*)
	  (show-message "一時補完ﾘｽﾄの更新が完了しました。")
	(show-message "一時補完ﾘｽﾄの作成に失敗しました。")))))

;;; --------------------------------
;;; 情報の取得
;;; Sat, 06 Oct 2001 23:37:57 +0900
(defun get-jcinfo-member (x y)
  (let (z)
    (setq z (gethash (list x y) *jtc-jcinfo-hash*))
    (while (and x (not z))
      (setq x (gethash x *jtc-superclass-hash*))
      (setq z (gethash (list x y) *jtc-jcinfo-hash*)))
    z))

(defun get-jcinfo-class (x)
  (gethash (list x) *jtc-jcinfo-hash*))

;;; --------------------------------
;;; 解析範囲の特定
;;; ※とてつもなくいい加減
;;; 　parse-term1とは違い中身まで掘り下げる必要がないので、ループで前進する
;;; 　ただし、if/while/catchなどのキーワードが出て来たら、見当違いの場所なので終了する
;;; Sat, 06 Jan 2001 07:55:44 +0900
(defun narrow-to-term1 ()
  ; いきなりコメントや文字列の中なら終了
  (if (find (parse-point-syntax (point)) '(:string :comment))
      (return-from narrow-to-term1 nil))
  ; 上っ面だけを見て範囲を選択
  (let ((p (point)))
    (loop
      ; 取り敢えず空白をスキップ
      (skip-chars-backward " \t\n")
      (cond
       ; メンバ演算子らしいのでスキップ
       ; ※メンバ演算子だけは続けて出現したら失敗
       ((find (preceding-char) '(#\. #\#) :test 'char=)
	(backward-char)
	(skip-chars-backward " \t\n")
	(if (find (preceding-char) '(#\. #\#) :test 'char=)
	    (return-from narrow-to-term1 nil)))
       ; シンタックスが異なる場合にはそこで中断
       ; ※この条件にマッチするのは２回目以降
       ; ※よほど変な書き方をしないと引っ掛らない
       ((find (parse-point-syntax (point)) '(:string :comment))
	(skip-chars-backward " \t\n")
	(narrow-to-region (point) p)
	(return-from narrow-to-term1 t))
       ; 文字列ならばそこで中断
       ((and (syntax-string-p (preceding-char))
	     (eq (parse-point-syntax (1- (point))) :string))
	(while (and (scan-buffer "\"" :reverse t :no-dup t)
		    (parse-point-syntax (point))))
	(narrow-to-region (point) p)
	(return t))
       ; 括弧のスキップ
       ; ※マッチする括弧がなければ失敗
       ((save-excursion
	  (backward-char)
	  (looking-at "[\]\)]"))
	(backward-char)
	(unless (goto-matched-parenthesis)
	  (goto-char p)
	  (return-from narrow-to-term1 nil)))
       ; new 演算子のスキップ
       ; キーワードの中で new 演算子はスキップする
       ((looking-back "new")
	(goto-char (- (point) 3)))
       ; 識別子のスキップ
       ; ※if/while/catchなどが現れたらここで潰す
       ((save-excursion
	  (and (skip-syntax-spec-backward "w_")
	       (not (looking-at "[0-9]"))))
	(let ((q (point))
	      (r nil))
	  (skip-syntax-spec-backward "w_")
	  (setq r (buffer-substring q (point)))
	  (if (and (find r *jtc-keyword-list* :test 'string=)
		   (not (find r '("this" "super") :test 'string=)))
	      (return-from narrow-to-term1 nil))))
       ; 何も無ければそのまま終わろう
       (t
	; １回目にどこにも該当しなければ失敗
	(when (eq (point) p)
	  (return-from narrow-to-term1 nil))
	(return t))))
    ; 空白をスキップした分を元に戻す
    (skip-chars-forward " \t\n")
    ; キャストを外す
    ; ※キャストはメンバ演算子よりも優先度が低いため
    (if (looking-at "\\(([ \t\n]*[a-zA-Z_\\$][$0-9a-zA-Z_\\]*[ \t\n]*)[ \t\n]*\\)[^ \t\n\.\#]")
	(goto-char (match-end 1)))
    (narrow-to-region (point) p)))

;;; --------------------------------
;;; 範囲限定＋範囲解析
;;; ※とてつもなくいい加減
;;; 　narrow-to-term1で選択された範囲を最大限好意的に解釈する
;;; Sat, 06 Jan 2001 07:55:44 +0900
(defun parse-term ()
  (interactive)
  (save-excursion
    (save-restriction
      (when (narrow-to-term1)
	(parse-term1)))))

(defun parse-term1 ()
  ; 空白を飛ばす
  (skip-chars-forward " \t\n")
  ; new 演算子を飛ばす
  (when (looking-at "new[ \t\n]+")
    (goto-char (match-end 0)))
  (let (p s)
    (cond
     ; 文字列の場合
     ((and (syntax-string-p (following-char))
	   (eq (parse-point-syntax (1+ (point))) :string))
      (while (and (scan-buffer "\"" :no-dup t)
		  (parse-point-syntax (1+ (point)))))
      (goto-char (match-end 0))
      (setq s (list "String")))
     ; 識別子
     ((looking-at "\\([a-zA-Z_\\$][$0-9a-zA-Z_\\]*\\)[ \t\n]*")
      (goto-char (match-end 0))
      (setq s (list (match-string 1)))
      (when (looking-at "[\(\[]")
	(goto-matched-parenthesis)
	(forward-char)))
     ; 括弧付き（多分キャスト）
     ((char= (following-char) #\()
      (prog1
	  (save-excursion
	    (save-restriction
	      (setq p (save-excursion (goto-matched-parenthesis) (point)))
	      (forward-char)
	      (narrow-to-region (point) p)
	      (setq s (parse-term1))))
	(goto-char p)
	(forward-char)))
     (t
      nil))
    ; メンバとかだったら継続して解析
    ; ※この条件では、sがキャストの場合はsだけを返す。
    ; ※メンバの場合には、継続して解析する。
    (append s
	    (when (looking-at "[ \t\n]*[\.#]")
	      (goto-char (match-end 0))
	      (parse-term1)))))

;;; --------------------------------
;;; シーケンスのリダクション
;;; ※戻り値は型とその元になるメンバの構造体を返す
;;; ※基本的にメンバの取得を目的としている
;;; ※クラスそのものの情報はget-jcinfo-classを直接呼ぶこと
;;; Sat, 06 Jan 2001 07:55:44 +0900
(defun reduce-term (arg1)
  (if (find (car arg1) '("this" "super") :test 'string=) (pop arg1))
  (if (find (car arg1) *jtc-class-list* :test 'string=)
      (reduce-term1 arg1)
    (let ((q (scan-var (pop arg1))))
      (if q (reduce-term1 (cons q arg1))))))

(defun reduce-term1 (arg1 &optional arg2)
  (cond
   ; 元々無いのなら何にも返さない
   ((null arg1)
    (values nil nil))
   ; 要素が一つの場合、メンバの要素も返す
   ((eq (length arg1) 1)
    (let ((p (pop arg1)))
      (values p (or arg2 (gethash (list p p) *jtc-jcinfo-hash*)))))
   ; 要素が二つ以上有るならばリストを短くする
   (t
    ; メンバが無ければスーパークラスから引っ張る
    (let ((z (get-jcinfo-member (pop arg1) (pop arg1))))
      (if z (reduce-term1 (cons (jcinfo-return z) arg1) z))))))

;;; --------------------------------
;;; ローカル参照＋フィールド名の走査
;;; Sat, 06 Jan 2001 07:55:44 +0900
(defun scan-var (s)
  (unless (stringp s)
    (return-from scan-var nil))
  (save-excursion
    (save-restriction
      (narrow-to-region (point-min) (point)) ; ソースを途中に挿入する場合のために念の為、narrow-to-regionしとく
      (let ((p nil))
	(while (scan-buffer "\\({\\)\\|\\(}\\)\\|\\()\\)\\|\\(\\<\\([$a-zA-Z0-9_.]+\\)\\([ \t\n]*\\[[^\]]*\\][ \t\n]*\\|[ \t\n]+\\)\\(\\w+\\)\\)" :regexp t :reverse t :no-dup t)
	  (cond
	   ; シンタックスが中途半端ならスキップ
	   ((parse-point-syntax (point)))
	   ; 開く中括弧の場合は一つ上に遷移（以降は引数部分も対象）
	   ((match-string 1)
	    (setq p t))
	   ; 閉じる中括弧は必ずスキップ
	   ((match-string 2)
	    (goto-matched-parenthesis))
	   ; 閉じる小括弧は最初はスキップ（開く中括弧以降は対象）
	   ((match-string 3)
	    (if p
		(setq p nil)
	      (goto-matched-parenthesis)))
	   ; キーワードに含まれなければ、多分クラス
	   ((not (find (match-string 5) *jtc-keyword-list* :test 'string=))
	    (let ((q (match-string 5)))
	      ; とりあえず見つかったものが一致するか？
	      (if (string= s (match-string 7))
		  (return-from scan-var q))
	      ; 一緒に見つかったものが一致するか？
	      (save-excursion
		(while (scan-buffer "\\(;\\)\\|,[ \t\n]*\\(\\w+\\)" :regexp t :reverse nil :no-dup nil :tail t)
		  (cond
		   ; シンタックスが中途半端ならスキップ
		   ((parse-point-syntax (point)))
		   ; セミコロンがあったらこの宣言は抜ける
		   ((match-string 1)
		    (return nil))
		   ; 次に見つかったものが一致するか？
		   ((string= s (match-string 2))
		    (return-from scan-var q)))))))))))))

;;; --------------------------------
;;; 補完ファイルの読み込み
;;; Sat, 06 Jan 2001 07:55:44 +0900
(defun load-completion-file ()
  ; 初期化
  (setq *jtc-member-list-hash* (make-hash-table :test #'equal))
  (setq *jtc-jcinfo-hash* (make-hash-table :test #'equal))
  (setq *jtc-superclass-hash* (make-hash-table :test #'equal))
  ; 読み込み
  (long-operation
    (dolist (item *jtc-completion-file-list*)
      (mapcar 'load-completion-file1
	      (sort (directory item :absolute t) #'string-lessp)))))

(defun load-completion-file1 (arg1)
  ; 補完ファイルの読み込み
  (set-buffer (ed::find-file-internal arg1))
  (message "補完ﾘｽﾄ読込中 ... ~A" arg1)
  (goto-char (point-min))
  (unless (scan-buffer "")
    (kill-buffer (ed::find-file-internal arg1))
    (return-from load-completion-file1 nil))
  ; クラス単位でループ
  (while (looking-at "\\([^\n]*\\)\n\\([^\n]*\\)\n\\([^\n]*\\)\n\\([^\n]*\\)\n\\([^\n]*\\)\n")
    (goto-char (match-end 0))
    (let* ((p (match-string 1))
	   (q (if (< 0 (length (match-string 3)))
		  (match-string 3)))
	   (r (gethash q *jtc-member-list-hash*))
	   (s (match-string 4))
	   (v (make-jcinfo :truename (match-string 5)
			   :name p
			   :url s
			   :signature (match-string 2))))
      (setf (gethash p *jtc-superclass-hash*) q)
      (setf (gethash (list p) *jtc-jcinfo-hash*) v)
      ; メンバ単位でループ
      (while (looking-at "\\([^\n]*\\)\n\\([^\n]*\\)\n\\([^\n]*\\)\n\\([^\n]*\\)\n\\([^]*\\)\n")
	(goto-char (match-end 0))
	(let ((u (make-jcinfo :kind (match-string 1)
			      :return (match-string 2)
			      :truename (jcinfo-truename v)
			      :name (match-string 3)
			      :url (match-string 4)
			      :signature (concat (jcinfo-signature v) "\n" (match-string 5)))))
	  (setf (gethash (list p (jcinfo-name u)) *jtc-jcinfo-hash*) u)
	  (if (string-match "[mfl]" (jcinfo-kind u))
	      (pushnew (jcinfo-name u) r :test 'string=))))
      ; メンバの設定
      (pushnew p *jtc-class-list* :test 'string=)
      (setf (gethash p *jtc-member-list-hash*) r)))
  ; バッファの解放
  (kill-buffer (ed::find-file-internal arg1)))

