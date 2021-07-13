;;; -*- Mode: lisp; Package: irc -*-
;;;
;;; irc-mode --- client side irc module

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

;;; description
;;;	クライアント側のIRCのモジュールです。
;;;	最低限の接続制御・チャネル管理・ユーザ管理を行います。

;;; install
;;;	1.解凍した後で、ディレクトリirc/を$XYZZY/site-lisp/にコピーします。
;;;	2.以下の手順でモジュールをバイトコンパイルします。
;;;
;;;		------------------------------------------------
;;;		M-x load-library[RET]
;;;		Load Library: irc/makefile[RET]
;;;		M-x irc-make[RET]
;;;		done.
;;;		------------------------------------------------
;;;
;;;	3.$XYZZY/site-lisp/irc/sample.ircを ~/.ircにコピーします。
;;;	4.~/.ircの内容を編集します。
;;;
;;;	  編集例：
;;;		------------------------------------------------
;;;             ;;; setup irc
;;;		(defvar *irc-server* "irc.tokyo.wide.ad.jp")
;;;		(defvar *irc-pass* "irc")
;;;		(defvar *irc-nick* "irc")
;;;		(defvar *irc-user* "irc")
;;;		(defvar *irc-realname* "irc irc")
;;;		(defvar *irc-channel-startup* '("#irc_test"))
;;;		(defvar *irc-quit-message* "bye")
;;;		(defvar *irc-away-message* "away")
;;;		------------------------------------------------
;;;
;;;     5.~/.xyzzyもしくは$XYZZY/site-lisp/siteini.lに記述を追加します。
;;;
;;;	  追加例：
;;;		------------------------------------------------
;;;             ;;; load irc
;;;		(load-library "irc/irc-mode")
;;;		(load-library "irc/irc-dialog")
;;;		; (load-library "irc/irc-ttray")
;;;		(load-library "irc/irc-ctcp")
;;;		(load-library "irc/irc-tool-bar")
;;;		(load-library "irc/irc-layout")
;;;		------------------------------------------------
;;;
;;;	6.上記の設定を反映させるために、xyzzyを再起動します。
;;;	  ※siteinit.lに記述した場合には再ダンプもして下さい。

;;; uninstall
;;;	1.以下の手順でモジュールを削除します。
;;;
;;;		------------------------------------------------
;;;		M-x load-library[RET]
;;;		Load Library: irc/makefile[RET]
;;;		M-x irc-make-clean[RET]
;;;		done.
;;;		------------------------------------------------
;;;
;;;	2.$XYZZY/site-lisp/ircを削除します。
;;;	3.~/.ircを削除します。
;;;     4.上記の設定を反映させるために、xyzzyを再起動します。
;;;	  ※siteinit.lに記述した場合には再ダンプもして下さい。

;;; keybind
;;;	ログバッファ：
;;;		標準：
;;;			C-c i c	IRCサーバとの接続／強制切断(toggle)
;;;			C-c i i	接続状況の表示
;;;			C-c i h	画面の自動スクロール／解除(toggle)
;;;			C-c i z	終了
;;;			C-c i v	次のircバッファへ移動
;;;			C-c i u	前のircバッファへ移動
;;;			C-g	バッファリングされたメッセージの廃棄
;;;			SPC	次行へ移動
;;;			RET	最終行へ移動
;;;			TAB	最終行へ移動
;;;		接続時：
;;;			C-c i q	IRCサーバからQUIT
;;;			C-c i n 自分のNICKの変更
;;;			C-c i j	任意のチャネルへJOIN
;;;			C-c i p	任意のチャネルからPART
;;;			C-c i M	任意のチャネル／NICKにPRIVMSG
;;;			C-c i C	任意のIRCコマンド
;;;			C-c i a	任意のメッセージでAWAY(toggle)
;;;			C-c i A	任意のメッセージでAWAY+NICKの変更(toggle)
;;;			C-c i w	任意のNICKをWHOIS
;;;	ダイアログバッファ：
;;;		標準：
;;;			C-c i c	IRCサーバとの接続／強制切断(toggle)
;;;			C-c i i	現在のチャネルの状況の表示
;;;			C-c i h	画面の自動スクロール／解除(toggle)
;;;			C-c i z	終了
;;;			C-c i u 前のircバッファへ移動
;;;			C-c i v	次のircバッファへ移動
;;;			C-g	バッファリングされたメッセージの廃棄
;;;			SPC	次行へ移動
;;;		接続時：
;;;			C-c i q	IRCサーバからQUIT
;;;			C-c i n	自分のNICKの変更
;;;			C-c i j	任意のチャネルへJOIN
;;;			C-c i C	任意のIRCコマンド
;;;			C-c i a	任意のメッセージでAWAY(toggle)
;;;			C-c i A	任意のメッセージでAWAY+NICKの変更(toggle)
;;;			C-c i w	任意のNICKをWHOIS
;;;		メッセージ：
;;;			C-c i m	現在のチャネル/NICKに任意のメッセージをPRIVMSG
;;;			TAB	バッファの最終行に移動後にPRIVMSG
;;;			RET	バッファの最終行に移動後にPRIVMSG
;;;		チャネル：
;;;			C-c i p	現在のチャネルからPART
;;;			C-c i t	現在のチャネルにトピックを設定
;;;			C-c i J	現在のチャネルに再JOIN
;;;		オペレータ：
;;;			C-c i +	現在のチャネルのオペレータ権限を配布
;;;			C-c i -	現在のチャネルのオペレータ権限を剥奪
;;;			C-c i k	現在のチャネルから任意のNICKを蹴り出す

;;; usage
;;;	1.irc-modeを実行します。実行後'c'でサーバに接続します。
;;;	　直ぐサーバに接続する場合にはirc-connectを実行します。
;;;
;;;		------------------------------------------------
;;;		M-x irc-mode[RET]
;;;		M-x irc-connect[RET]
;;;		------------------------------------------------

;;; note
;;;	・RFC1459/RFC2812を参考にしてます。
;;;	・ダイアログは離脱・切断・終了系のみ表示します。
;;;	・DCCは未対応です。
;;;	・IRCサーバの実装によってはうまくいかない。

;;; changes
;;;	Mon, 28 Apr 2003 06:45:08 +0900
;;;		・$XYZZY/.irc -> ~/.irc をみるよう変更
;;;		・$XYZZY/site-lisp/jtc/jtc-toolbar.bmp -> $XYZZY/etc/toolbar-jtc.bmp に移動
;;;		・説明文を修正
;;;	Sat, 15 Mar 2003 11:07:40 +0900
;;;		・circ -> irc-modeに変更
;;;		・circ/make.l -> irc/makefile.lに変更
;;;		・ダイアログバッファでキーを直接打った時にミニバッファに誘導するよう仕掛けを作った
;;;		・キーマップを変更。 #\C-c #\i をプリフィックスとして付けてみたり。
;;;		・無限ループに陥るバグの修正ロジック追加。
;;;		・空のダイアログバッファが出来る現象に対応したつもり。
;;;		・DCC-SENDの*受信側*だけ対応してみた。受信中はxyzzy全体をロックしているっぽいので、
;;;		  そのときにPINGが飛んでくると、無応答と思われるてかなりまずいかも。
;;;		  送信側はIPアドレスを調べなくちゃいけないのが面倒クサイので気が向いたら。
;;;	Sat, 13 Jul 2002 09:10:21 +0900
;;;		・レイアウト制御のバグを修正
;:;		・*irc-exit-hook*を削除（*irc-cleanup-hook*があった）
;;;	Tue, 09 Jul 2002 23:07:32 +0900
;;;		・"任意のIRCコマンド"のキーバインドを#\M→#\Cに変更
;;;		・簡単なツールバーを追加
;:;		・*irc-exit-hook*を追加
;;;		・irc-layout.l及びirc-toolbar.lを追加
;;;		・irc-quitをirc-exitに変更
;;;	Sun, 07 Jul 2002 21:24:07 +0900
;;;		・ツールバーの追加（最小限のものだけ追加）
;;;	Sat, 06 Jul 2002 04:47:45 +0900
;;;		・make.l/kill.lを追加
;;;	Mon, 13 May 2002 22:18:54 +0900
;;;		・初版

;;; todo
;;;	high priority:
;;;	・レイアウトをフレーム間でトグルするように
;;;	・ミニバッファで編集中にメッセージが届くとバッファがガクガクするので対処
;;;	・NAMEのリプライにもう少しちゃんと対応する
;;;	・DCC-SENDの送信側の実装
;;;	low priority:
;;;	・メッセージの自動スクロールをもうちょっと何とかする
;;;	・docstringをちゃんと書くように
;;;	・メッセージをもう少しまともに
;;;	・ヒストリ変数を使って頑張る
;;;	・タブバーの追加
;;;	・プロパティシートの追加
;;;	・ListView.dllを使って状況の表示
;;;	・何故かダイアログバッファが"[nil]"で作成される場合があるのでトラップを設定
;;;	  →実は*irc-channel*の中の構造体が腐ってたことが判明。PART/KICKのユーザ削除の
;;;	    ロジックがまずかったみたい

(require "irc/irc-base")
(require "irc/irc-dialog")
; (require "irc/irc-ttray")
(require "irc/irc-ctcp")
(require "irc/irc-tool-bar")
(require "irc/irc-layout")
