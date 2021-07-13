;;; -*- Mode: Lisp; Package: user -*-
;;;
;;; ref2doc.l --- refrence.xmlからdocstringを生成

;;; author
;;;     YAMAMOTO Taizo <ymtz@pop02.odn.ne.jp>

;;; date
;;;     Last updated: Thu, 20 Mar 2003 06:47:23 +0900

;;; description
;;;	refrence.xmlからdocstringを生成します。
;;;     siteinit.l内部でreference.xmlの内容を適当にパーズして
;;;     関数や変数にdocstringを無理やり付けます。例えば、
;;;     describe-functionやaproposの時にその内容の一部を表示できます。

;;; install
;;;     1.解凍して出来たref2doc.lを$XYZZY/site-lisp/にコピーします。
;;;     2.reference.xmlを拾ってきて$XYZZY/etc/にコピーします。
;;;     3.$XYZZY/site-lisp/siteinit.lに以下のコードを追加します。
;;;       ※~/.xyzzyは不可
;;;
;;;		--------------------------------
;;;             (require "ref2doc")
;;;             (reference-to-docstring)
;;;		--------------------------------
;;;
;;;     4.xyzzyを再ダンプします。

;;; usage
;;;     describe-functionやaproposしてみてください。

;;; note
;;;     ldocを入れてる人は下の様に関数を再定義すると、呼出形式と一緒に
;;;     関数の説明を見ることができます。
;;;
;;;     (defun ed::ldoc-func-message (symbol)
;;;       "Print name and arguments of function bound to SYMBOL."
;;;       (message (concat (format nil "~S" symbol)
;;;                        " "
;;;                        (format nil "~:@(~A~): ~A"
;;;                                (ed::ldoc-func-get-args symbol)
;;;                                (or (car (split-string (documentation symbol 'function) #\LFD))
;;;                                    "not documented")))))
;;;

;;; changes
;;;	Fri, 02 May 2003 21:44:47 +0900
;;;		・評価用のバッファを使わないように変更
;;;	Sun, 27 Apr 2003 21:29:48 +0900
;;;		・netinstaller用に記述を変更
;;;		・etc/reference.xmlに変更
;;;		・*reference-xml-path* -> *reference-xml-file*
;;;	Mon, 31 Mar 2003 23:59:08 +0900
;;;		useしていないパッケージを考慮してみた。
;;;     Sun, 30 Mar 2003 12:06:41 +0900
;;;             初版

; siteinit.lでの評価時は(etc-path)は未設定だから(si:system-root)から参照する。
(defvar *reference-xml-file* (merge-pathnames "etc/reference.xml" (si:system-root)))

(defun reference-to-docstring ()
  "reference.xmlの内容からdocstringにする。"
  (interactive)
  (unwind-protect
      (progn
	(set-buffer (ed::find-file-internal *reference-xml-file*))
	(goto-char (point-min))
	(let (title desc sym pkg)
	  (while (and (scan-buffer "<title>\\([^\n<]*\\)" :regexp t :tail t)
		      (setq title (match-string 1))
		      (scan-buffer "<description>\n*\\([^<]*\\)" :regexp t :tail t)
		      (setq desc (match-string 1)))
	    (setq title (substitute-string title "&amp;" "&"))
	    (setq title (substitute-string title "&lt;" "<"))
	    (setq title (substitute-string title "&gt;" ">"))
	    (setq desc (substitute-string desc "&amp;" "&"))
	    (setq desc (substitute-string desc "&lt;" "<"))
	    (setq desc (substitute-string desc "&gt;" ">"))
	    (and (string-match "\\(\\([^:]+\\):+\\)?\\(.+\\)" title)
		 (setq pkg (or (match-string 2) "user"))
		 (setq sym (find-symbol (match-string 3) pkg))
		 (setf (get sym (if (fboundp sym)
				    'lisp::function-documentation
				  'lisp::variable-documentation))
		       desc)))))
    (delete-buffer (get-file-buffer *reference-xml-file*))))

