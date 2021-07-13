;;; -*- Mode: lisp; Package: irc -*-
;;;
;;; irc-ttray --- client side irc module : tasktray option

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

;;; description
;;;	タスクトレイに接続状況を表示します。

;;; changes
;;;	Mon, 13 May 2002 22:18:54 +0900
;;;		初版

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "irc")
    (defpackage "irc"
      (:nicknames "irc")
      (:use "lisp" "editor")))
  (require "irc/irc")
  (require "ttray"))

(provide "irc/irc-ttray")

(in-package "irc")

;;; ------------------------------------------------
;;; variables
;;; ------------------------------------------------

;;; icon
(defvar *irc-icon-show-con* nil)
(defvar *irc-icon-show-dis* nil)
(defvar *irc-icon-hide-con* nil)
(defvar *irc-icon-hide-dis* nil)

;;; backup
(defvar *irc-icon-show-bak* nil)
(defvar *irc-icon-hide-bak* nil)
(defvar *irc-tip-bak* nil)

;;; ------------------------------------------------
;;; hook for message
;;; ------------------------------------------------

; default hook
#|
irc-setup
　　*irc-setup-hook*
　　　　irc-ttray-setup

irc-cleanup
　　*irc-cleanup-hook*
　　　　irc-ttray-cleanup

irc-open
　　*irc-open-hook*
　　　　irc-ttray-ttray-open

irc-sentinel
　　*irc-close-hook*
　　　　irc-command-close
　　　　　　*irc-closed-hook*
　　　　　　　　irc-ttray-ttray-closed
|#


;;; setup
(defun irc-ttray-setup ()
  "irc: ttrayの設定"
  ; backup
  (setq *irc-icon-show-bak* win-user::*ttray-icon-show*)
  (setq *irc-icon-hide-bak* win-user::*ttray-icon-hide*)
  (setq *irc-tip-bak* win-user::*ttray-tip*)
  ; allocate
  (let ((c (si:make-chunk nil 4)))
    ; show and connect
    (winapi::ExtractIconEx
	   (si:make-string-chunk
	      (map-slash-to-backslash
	       (merge-pathnames "irc-show-con.ico" (etc-path)))) 0 0 c 1)
    (setq *irc-icon-show-con* (si:unpack-uint32 c 0))
    ; show and disconnect
    (winapi::ExtractIconEx
	   (si:make-string-chunk
	      (map-slash-to-backslash
	       (merge-pathnames "irc-show-dis.ico" (etc-path)))) 0 0 c 1)
    (setq *irc-icon-show-dis* (si:unpack-uint32 c 0))
    ; hide and connect
    (winapi::ExtractIconEx
	   (si:make-string-chunk
	      (map-slash-to-backslash
	       (merge-pathnames "irc-hide-con.ico" (etc-path)))) 0 0 c 1)
    (setq *irc-icon-hide-con* (si:unpack-uint32 c 0))
    ; hide and disconnect
    (winapi::ExtractIconEx
	   (si:make-string-chunk
	      (map-slash-to-backslash
	       (merge-pathnames "irc-hide-dis.ico" (etc-path)))) 0 0 c 1)
    (setq *irc-icon-hide-dis* (si:unpack-uint32 c 0)))
  ; change
  (win-user::ttray-change-icon
	   :tip *irc-software*
	   :icon-hide *irc-icon-hide-dis*
	   :icon-show *irc-icon-show-dis*))
(add-hook '*irc-setup-hook* 'irc-ttray-setup)

;;; cleanup
(defun irc-ttray-cleanup ()
  "irc: ttrayの解放"
  ; restore
  (win-user::ttray-change-icon
	   :tip *irc-tip-bak*
	   :icon-show *irc-icon-show-bak*
	   :icon-hide *irc-icon-hide-bak*)
  ; clear
  (setq *irc-tip-bak* nil)
  (setq *irc-icon-show-bak* nil)
  (setq *irc-icon-hide-bak* nil)
  ; free
  (winapi::DestroyIcon *irc-icon-show-con*)
  (winapi::DestroyIcon *irc-icon-show-dis*)
  (winapi::DestroyIcon *irc-icon-hide-con*)
  (winapi::DestroyIcon *irc-icon-hide-dis*))
(add-hook '*irc-cleanup-hook* 'irc-ttray-cleanup)

;;; open
(defun irc-ttray-open ()
  "irc: 接続状態をttrayに設定"
  (win-user::ttray-change-icon
	   :tip "connected"
	   :icon-show *irc-icon-show-con*
	   :icon-hide *irc-icon-hide-con*))
(add-hook '*irc-open-hook* 'irc-ttray-open)

;;; closed
(defun irc-ttray-closed (text channel)
  "irc: 断絶状態をttrayに設定"
  (unless channel
    (win-user::ttray-change-icon
	     :tip "not connected"
	     :icon-show *irc-icon-show-dis*
	     :icon-hide *irc-icon-hide-dis*)))
(add-hook '*irc-closed-hook* 'irc-ttray-closed)

