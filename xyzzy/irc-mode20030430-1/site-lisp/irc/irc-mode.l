;;; -*- Mode: lisp; Package: irc -*-
;;;
;;; irc-mode --- client side irc module

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

;;; description
;;;	�N���C�A���g����IRC�̃��W���[���ł��B
;;;	�Œ���̐ڑ�����E�`���l���Ǘ��E���[�U�Ǘ����s���܂��B

;;; install
;;;	1.�𓀂�����ŁA�f�B���N�g��irc/��$XYZZY/site-lisp/�ɃR�s�[���܂��B
;;;	2.�ȉ��̎菇�Ń��W���[�����o�C�g�R���p�C�����܂��B
;;;
;;;		------------------------------------------------
;;;		M-x load-library[RET]
;;;		Load Library: irc/makefile[RET]
;;;		M-x irc-make[RET]
;;;		done.
;;;		------------------------------------------------
;;;
;;;	3.$XYZZY/site-lisp/irc/sample.irc�� ~/.irc�ɃR�s�[���܂��B
;;;	4.~/.irc�̓��e��ҏW���܂��B
;;;
;;;	  �ҏW��F
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
;;;     5.~/.xyzzy��������$XYZZY/site-lisp/siteini.l�ɋL�q��ǉ����܂��B
;;;
;;;	  �ǉ���F
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
;;;	6.��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy���ċN�����܂��B
;;;	  ��siteinit.l�ɋL�q�����ꍇ�ɂ͍ă_���v�����ĉ������B

;;; uninstall
;;;	1.�ȉ��̎菇�Ń��W���[�����폜���܂��B
;;;
;;;		------------------------------------------------
;;;		M-x load-library[RET]
;;;		Load Library: irc/makefile[RET]
;;;		M-x irc-make-clean[RET]
;;;		done.
;;;		------------------------------------------------
;;;
;;;	2.$XYZZY/site-lisp/irc���폜���܂��B
;;;	3.~/.irc���폜���܂��B
;;;     4.��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy���ċN�����܂��B
;;;	  ��siteinit.l�ɋL�q�����ꍇ�ɂ͍ă_���v�����ĉ������B

;;; keybind
;;;	���O�o�b�t�@�F
;;;		�W���F
;;;			C-c i c	IRC�T�[�o�Ƃ̐ڑ��^�����ؒf(toggle)
;;;			C-c i i	�ڑ��󋵂̕\��
;;;			C-c i h	��ʂ̎����X�N���[���^����(toggle)
;;;			C-c i z	�I��
;;;			C-c i v	����irc�o�b�t�@�ֈړ�
;;;			C-c i u	�O��irc�o�b�t�@�ֈړ�
;;;			C-g	�o�b�t�@�����O���ꂽ���b�Z�[�W�̔p��
;;;			SPC	���s�ֈړ�
;;;			RET	�ŏI�s�ֈړ�
;;;			TAB	�ŏI�s�ֈړ�
;;;		�ڑ����F
;;;			C-c i q	IRC�T�[�o����QUIT
;;;			C-c i n ������NICK�̕ύX
;;;			C-c i j	�C�ӂ̃`���l����JOIN
;;;			C-c i p	�C�ӂ̃`���l������PART
;;;			C-c i M	�C�ӂ̃`���l���^NICK��PRIVMSG
;;;			C-c i C	�C�ӂ�IRC�R�}���h
;;;			C-c i a	�C�ӂ̃��b�Z�[�W��AWAY(toggle)
;;;			C-c i A	�C�ӂ̃��b�Z�[�W��AWAY+NICK�̕ύX(toggle)
;;;			C-c i w	�C�ӂ�NICK��WHOIS
;;;	�_�C�A���O�o�b�t�@�F
;;;		�W���F
;;;			C-c i c	IRC�T�[�o�Ƃ̐ڑ��^�����ؒf(toggle)
;;;			C-c i i	���݂̃`���l���̏󋵂̕\��
;;;			C-c i h	��ʂ̎����X�N���[���^����(toggle)
;;;			C-c i z	�I��
;;;			C-c i u �O��irc�o�b�t�@�ֈړ�
;;;			C-c i v	����irc�o�b�t�@�ֈړ�
;;;			C-g	�o�b�t�@�����O���ꂽ���b�Z�[�W�̔p��
;;;			SPC	���s�ֈړ�
;;;		�ڑ����F
;;;			C-c i q	IRC�T�[�o����QUIT
;;;			C-c i n	������NICK�̕ύX
;;;			C-c i j	�C�ӂ̃`���l����JOIN
;;;			C-c i C	�C�ӂ�IRC�R�}���h
;;;			C-c i a	�C�ӂ̃��b�Z�[�W��AWAY(toggle)
;;;			C-c i A	�C�ӂ̃��b�Z�[�W��AWAY+NICK�̕ύX(toggle)
;;;			C-c i w	�C�ӂ�NICK��WHOIS
;;;		���b�Z�[�W�F
;;;			C-c i m	���݂̃`���l��/NICK�ɔC�ӂ̃��b�Z�[�W��PRIVMSG
;;;			TAB	�o�b�t�@�̍ŏI�s�Ɉړ����PRIVMSG
;;;			RET	�o�b�t�@�̍ŏI�s�Ɉړ����PRIVMSG
;;;		�`���l���F
;;;			C-c i p	���݂̃`���l������PART
;;;			C-c i t	���݂̃`���l���Ƀg�s�b�N��ݒ�
;;;			C-c i J	���݂̃`���l���ɍ�JOIN
;;;		�I�y���[�^�F
;;;			C-c i +	���݂̃`���l���̃I�y���[�^������z�z
;;;			C-c i -	���݂̃`���l���̃I�y���[�^�����𔍒D
;;;			C-c i k	���݂̃`���l������C�ӂ�NICK���R��o��

;;; usage
;;;	1.irc-mode�����s���܂��B���s��'c'�ŃT�[�o�ɐڑ����܂��B
;;;	�@�����T�[�o�ɐڑ�����ꍇ�ɂ�irc-connect�����s���܂��B
;;;
;;;		------------------------------------------------
;;;		M-x irc-mode[RET]
;;;		M-x irc-connect[RET]
;;;		------------------------------------------------

;;; note
;;;	�ERFC1459/RFC2812���Q�l�ɂ��Ă܂��B
;;;	�E�_�C�A���O�͗��E�E�ؒf�E�I���n�̂ݕ\�����܂��B
;;;	�EDCC�͖��Ή��ł��B
;;;	�EIRC�T�[�o�̎����ɂ���Ă͂��܂������Ȃ��B

;;; changes
;;;	Mon, 28 Apr 2003 06:45:08 +0900
;;;		�E$XYZZY/.irc -> ~/.irc ���݂�悤�ύX
;;;		�E$XYZZY/site-lisp/jtc/jtc-toolbar.bmp -> $XYZZY/etc/toolbar-jtc.bmp �Ɉړ�
;;;		�E���������C��
;;;	Sat, 15 Mar 2003 11:07:40 +0900
;;;		�Ecirc -> irc-mode�ɕύX
;;;		�Ecirc/make.l -> irc/makefile.l�ɕύX
;;;		�E�_�C�A���O�o�b�t�@�ŃL�[�𒼐ڑł������Ƀ~�j�o�b�t�@�ɗU������悤�d�|���������
;;;		�E�L�[�}�b�v��ύX�B #\C-c #\i ���v���t�B�b�N�X�Ƃ��ĕt���Ă݂���B
;;;		�E�������[�v�Ɋׂ�o�O�̏C�����W�b�N�ǉ��B
;;;		�E��̃_�C�A���O�o�b�t�@���o���錻�ۂɑΉ���������B
;;;		�EDCC-SEND��*��M��*�����Ή����Ă݂��B��M����xyzzy�S�̂����b�N���Ă�����ۂ��̂ŁA
;;;		  ���̂Ƃ���PING�����ł���ƁA�������Ǝv����Ă��Ȃ�܂��������B
;;;		  ���M����IP�A�h���X�𒲂ׂȂ����Ⴂ���Ȃ��̂��ʓ|�N�T�C�̂ŋC����������B
;;;	Sat, 13 Jul 2002 09:10:21 +0900
;;;		�E���C�A�E�g����̃o�O���C��
;:;		�E*irc-exit-hook*���폜�i*irc-cleanup-hook*���������j
;;;	Tue, 09 Jul 2002 23:07:32 +0900
;;;		�E"�C�ӂ�IRC�R�}���h"�̃L�[�o�C���h��#\M��#\C�ɕύX
;;;		�E�ȒP�ȃc�[���o�[��ǉ�
;:;		�E*irc-exit-hook*��ǉ�
;;;		�Eirc-layout.l�y��irc-toolbar.l��ǉ�
;;;		�Eirc-quit��irc-exit�ɕύX
;;;	Sun, 07 Jul 2002 21:24:07 +0900
;;;		�E�c�[���o�[�̒ǉ��i�ŏ����̂��̂����ǉ��j
;;;	Sat, 06 Jul 2002 04:47:45 +0900
;;;		�Emake.l/kill.l��ǉ�
;;;	Mon, 13 May 2002 22:18:54 +0900
;;;		�E����

;;; todo
;;;	high priority:
;;;	�E���C�A�E�g���t���[���ԂŃg�O������悤��
;;;	�E�~�j�o�b�t�@�ŕҏW���Ƀ��b�Z�[�W���͂��ƃo�b�t�@���K�N�K�N����̂őΏ�
;;;	�ENAME�̃��v���C�ɂ������������ƑΉ�����
;;;	�EDCC-SEND�̑��M���̎���
;;;	low priority:
;;;	�E���b�Z�[�W�̎����X�N���[��������������Ɖ��Ƃ�����
;;;	�Edocstring�������Ə����悤��
;;;	�E���b�Z�[�W�����������܂Ƃ���
;;;	�E�q�X�g���ϐ����g���Ċ撣��
;;;	�E�^�u�o�[�̒ǉ�
;;;	�E�v���p�e�B�V�[�g�̒ǉ�
;;;	�EListView.dll���g���ď󋵂̕\��
;;;	�E���̂��_�C�A���O�o�b�t�@��"[nil]"�ō쐬�����ꍇ������̂Ńg���b�v��ݒ�
;;;	  ������*irc-channel*�̒��̍\���̂������Ă����Ƃ������BPART/KICK�̃��[�U�폜��
;;;	    ���W�b�N���܂��������݂���

(require "irc/irc-base")
(require "irc/irc-dialog")
; (require "irc/irc-ttray")
(require "irc/irc-ctcp")
(require "irc/irc-tool-bar")
(require "irc/irc-layout")