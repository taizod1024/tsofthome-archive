------------------------------------------------------------------------
ソフトウェア　　　バッチファイルユーティリティ 0.1.13.0131
ソフトウェア種類　ユーティリティ
著作権者　　　　　山本泰三
動作環境　　　　　Windows XP/Vista/7
連絡先　　　　　　cbf95600@pop02.odn.ne.jp
使用条件　　　　　フリーソフトウェア
著作権　　
　　本ソフトはフリーソフトです。自由にご使用ください。
　　なお，著作権は作者である山本が保有しています。
免責事項
　　このソフトウェアを使用したことによって生じた
　　すべての障害・損害・不具合等に関しては、
　　私と私の関係者および私の所属するいかなる団体・組織とも、
　　一切の責任を負いません。
　　各自の責任においてご使用ください。
------------------------------------------------------------------------


----------------
概要
----------------

バッチファイルを効率的に記述するためのコマンドです。


----------------
特長
----------------

バッチファイルユーティリティには以下の特長があります。

　・バッチファイルのラベルを一つのタスクとして見なして、
　　タスク間の関係性を明示的に記述することができます。

　・タスクは".t@sk"という拡張子のファイルに記述します。
　　このファイルをタスクファイルと呼びます。
　　タスクファイルの標準ファイル名は"task.t@sk"です。

　・タスクファイルを実行するには以下の方法があります。

　　　1)エクスプローラから、タスクファイルを実行する。
　　　2)コマンドプロンプトから、タスクファイルを実行する。
　　　3)コマンドプロンプトから、タスクファイルをバッチファイルに変換してから、バッチファイルを実行する。

　　1)2)は、バッチファイルユーティリティがインストールされている環境で実行します。
　　3)は、バッチファイルユーティリティがインストールされていない環境であっても実行できます。

　・タスクファイルの記述方法はバッチファイルの記述方法と同じです。
　　タスクの関係性や実行結果のための環境変数が用意されています。

≪タスクの関係性の例≫

　　ALL
　　├─TASK1
　　│　├─TASK11
　　│　└─TASK12
　　└─TASK2
　　　　├─TASK21
　　　　└─TASK22

≪タスクファイルの記述例≫

　　rem ----------------------------------------------------------------
　　rem task.t@sk
　　rem ----------------------------------------------------------------
　　
　　:ALL
　　　%task_depend_on% :TASK1 :TASK2
　　　%task_exit_if_error%
　　　echo task ALL
　　　%task_exit%
　　
　　:TASK1
　　　%task_depend_on% :TASK11 :TASK12
　　　%task_exit_if_error%
　　　echo task TASK1
　　　%task_exit%
　　
　　:TASK2
　　　%task_depend_on% :TASK21 :TASK22
　　　%task_exit_if_error%
　　　echo task TASK2
　　　%task_exit%
　　
　　:TASK11
　　　echo task TASK11
　　　%task_exit%
　　
　　:TASK12
　　　echo task TASK12
　　　%task_exit%
　
　　:TASK21
　　　echo task TASK21
　　　%task_exit%
　　
　　:TASK22
　　　echo task TASK22
　　　%task_exit%

≪タスクファイルの実行例≫

　　> t@sk
　　### task file : task.t@sk
　　### directory : C:\Documents and Settings\Administrator
　　### arguments :
　　### timestamp : 2013/01/20T08:21:51.64
　　### main target : ':[default]'
　　###   sub target : ':[default]'
　　###     sub target : ':TASK1'
　　###       sub target : ':TASK11'
　　task TASK11
　　###       sub return : ':TASK11' => 0
　　###       sub target : ':TASK12'
　　task TASK12
　　###       sub return : ':TASK12' => 0
　　task TASK1
　　###     sub return : ':TASK1' => 0
　　###     sub target : ':TASK2'
　　###       sub target : ':TASK21'
　　task TASK21
　　###       sub return : ':TASK21' => 0
　　###       sub target : ':TASK22'
　　task TASK22
　　###       sub return : ':TASK22' => 0
　　task TASK2
　　###     sub return : ':TASK2' => 0
　　task ALL
　　###   sub return : ':[default]' => 0
　　### main return : ':[default]' => 0
　　### timestamp : 2013/01/20T08:21:51.78
　　### main result : success !!!


----------------
インストール
----------------

インストーラを実行してください。


----------------
アンインストール
----------------

スタートメニューから[バッチファイルユーティリティ のアンインストール]を実行してください。 
もしくは、[プログラムの追加と削除]から[tsoft バッチファイルユーティリティ]を削除してください。


----------------
チュートリアル
----------------

以下の手順で実行してください。

①コマンドプロンプトを開きます。

②以下のコマンドを実行してサンプルのタスクファイルを作成します。
　作成されるタスクファイル名は"task.t@sk"です。

　　　　> t@st /g

②タスクファイルを編集します。
　タスクファイルの記述方法はバッチファイルと同じです。

③以下のコマンドでタスクファイルを実行します。

　　　　> t@st


----------------
コマンド形式
----------------

コマンド形式は以下のとおりです。

　　　　> t@sk /?
　　　　> t@sk [ /f ***.t@sk ][ /s ][ /p ][ :target1 [ :target2 [ ... ] ] ]
　　　　> t@sk [ /f ***.t@sk ][ /g | /v | /l ]

≪ヘルプ≫

　　■バッチファイルユーティリティのヘルプを表示する。

　　　　> t@sk /?

≪実行≫

　　■task.t@skを実行する。

　　　　> t@sk
　　　　> task.t@sk

　　■別のタスクファイルを実行する。

　　　　> t@sk /f app.t@sk
　　　　> app.t@sk

　　■task.t@skの:TASK1と:TASK2のタスクを実行する。

　　　　> t@sk :TASK1 :TASK2
　　　　> task.t@sk :TASK1 :TASK2

　　■ログ表示をせずにtask.t@skを実行する。

　　　　> t@sk /s
　　　　> task.t@sk /s

　　■task.t@skを実行し最後にpauseする。

　　　　> t@sk /p
　　　　> task.t@sk /p

≪その他≫

　　■サンプルのタスクファイルを作成する。

　　　　> t@sk /g

　　■タスクファイルからバッチファイルを作成する。

　　　　> t@sk /g
　　　　> task.t@sk /g

　　■タスクファイルのタスクをリスト表示する。

　　　　> t@sk /l
　　　　> task.t@sk /l


----------------
環境変数
----------------

タスクファイルの記述をサポートする環境変数が定義されています。

　　　　%task_depend_on% :target1 [ :target2 [ ... ] ]
　　　　%task_exit%
　　　　%task_exit_if_error%
　　　　%task_exit_with% [ result ]

≪タスクの関係性≫

　　■TASK1とTASK2に依存する。

　　　　%task_depend_on% :TASK1 :TASK2

≪タスクの実行結果≫

　　■タスクを終了する。戻り値は%ERRORLEVEL%とする。

　　　　%task_exit%

　　■%ERRORLEVEL%が0以外ならタスクを終了する。戻り値は%ERRORLEVEL%とする。

　　　　%task_exit_if_error%

　　■タスクを終了する。戻り値は指定する。

　　　　%task_exit_with% [ result ]


------------------------------------------------------------------------
