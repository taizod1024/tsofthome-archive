using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Threading.Tasks;

namespace tsoft.NgenUtil
{
    /// <summary>
    /// フォームクラス
    /// </summary>
    public partial class FormAdmin : Form
    {
        /// <summary>
        /// フォームの状態を表す列挙型
        /// </summary>
        private enum States { Initializing, Waiting, Running, Stopping };

        /// <summary>
        /// フォームの状態
        /// </summary>
        private States state = States.Initializing;

        /// <summary>
        /// Ngen関連の処理を行うユーティリティオブジェクト
        /// </summary>
        private Utility util = new Utility();

        /// <summary>
        /// 引数のリスト
        /// </summary>
        private List<string> argList;

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="list">Ngen対象となるディレクトリやファイルのリスト</param>
        public FormAdmin(string[] list)
        {
            InitializeComponent();

            // コントロールの初期化
            InitializeControls(list);

            // 初期化を完了
            this.state = States.Waiting;

            // コントロールの表示を更新
            this.UpdateControls();
        }

        /// <summary>
        /// コントロールの初期化
        /// </summary>
        /// <param name="list"></param>
        private void InitializeControls(string[] list)
        {
            // 引数のリストの初期化
            this.argList = new List<string>(list);

            // アプリケーション設定から位置を復元
            this.Size = Properties.Settings.Default.FormAdminSize;
            this.Location = Properties.Settings.Default.FormAdminLocation;
            this.WindowState = Properties.Settings.Default.FormAdminWindowState;

            // フォームタイトルにバージョンを付加
            this.Text += " - " + System.Reflection.Assembly.GetExecutingAssembly().GetName().Version;

            // .NETのバージョンのリスト化
            // ・前回選択値もしくは最新のバージョンを選択
            this.util.versionList.ForEach(x =>
            {
                this.cmbVersion.Items.Add(x);
            });
            this.cmbVersion.SelectedIndex = this.util.versionList.Count - 1;
            this.cmbVersion.SelectedItem = Properties.Settings.Default.FormAdminNETFrameworkVersion;

            // シナリオのリスト化
            this.util.scenarioList.ForEach(x =>
            {
                this.cmbScenario.Items.Add(x);
            });
            this.cmbScenario.SelectedIndex = 0;
            this.cmbScenario.SelectedItem = Properties.Settings.Default.FormAdminScenario;

            // 引数に従ってNgen対象を追加
            this.util.AddArgs(list);
            this.paramsBindingSource.DataSource = this.util.ngenParams;
            if (0 < this.argList.Count && 0 == this.util.ngenParams.Count)
            {
                this.lblProgress.Text = "指定されたフォルダやファイルにアセンブリは見つかりませんでした。";
            }

            // イメージ列の初期化
            this.type.ValuesAreIcons = false;
            this.type.Description = "";
            this.type.DefaultCellStyle.NullValue = null;
        }

        /// <summary>
        /// フォームのサイズの変更
        /// ・最大化状態以外でサイズを記録。Form_Closingでは最大化状態では取得できないので随時記録。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FormAdmin_SizeChanged(object sender, EventArgs e)
        {
            if (this.WindowState != System.Windows.Forms.FormWindowState.Maximized)
            {
                Properties.Settings.Default.FormAdminSize = this.Size;
            }
        }

        /// <summary>
        /// フォームの位置の変更
        /// ・最大化状態以外で位置を記録。Form_Closingでは最大化状態では取得できないので随時記録。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FormAdmin_LocationChanged(object sender, EventArgs e)
        {
            if (this.WindowState != System.Windows.Forms.FormWindowState.Maximized)
            {
                Properties.Settings.Default.FormAdminLocation = this.Location;
            }
        }

        /// <summary>
        /// フォームのクローズ開始
        /// ・フォームの状態とバージョンを記録。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FormAdmin_FormClosing(object sender, FormClosingEventArgs e)
        {
            Properties.Settings.Default.FormAdminWindowState = this.WindowState;
            Properties.Settings.Default.FormAdminNETFrameworkVersion = this.cmbVersion.SelectedItem.ToString();
            Properties.Settings.Default.FormAdminScenario = this.cmbScenario.SelectedItem.ToString();
        }

        /// <summary>
        /// フォームのクローズ完了
        /// ・記録した各種状態を保存。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FormAdmin_FormClosed(object sender, FormClosedEventArgs e)
        {
            Properties.Settings.Default.Save();
        }

        /// <summary>
        /// コントロールの状態を更新
        /// </summary>
        private void UpdateControls()
        {
            bool b = (0 != this.util.ngenParams.Count);
            switch (this.state)
            {
                case States.Initializing:
                    this.cmbVersion.Enabled = false;
                    this.cmbScenario.Enabled = false;
                    this.btnInstall.Enabled = false;
                    this.btnUninstall.Enabled = false;
                    this.btnRefresh.Enabled = false;
                    this.btnStop.Enabled= false;
                    break;
                case States.Waiting:
                    this.cmbVersion.Enabled = true;
                    this.cmbScenario.Enabled = b;
                    this.btnInstall.Enabled = b;
                    this.btnUninstall.Enabled = b;
                    this.btnRefresh.Enabled = b;
                    this.btnStop.Enabled= false;
                    break;
                case States.Running:
                case States.Stopping:
                    this.cmbVersion.Enabled = false;
                    this.cmbScenario.Enabled = false;
                    this.btnInstall.Enabled = false;
                    this.btnUninstall.Enabled = false;
                    this.btnRefresh.Enabled = false;
                    this.btnStop.Enabled= true;
                    break;
            }
            // tsmiExec.Enabled = b; // 右クリック時に設定
            tsmiExplorer.Enabled = b;
            tsmiCopy.Enabled = b;
            tsmiSelectAll.Enabled = b;
        }

        /// <summary>
        /// Ngenの実行
        /// ・ユーティリティを非同期に実行
        /// ・実行結果をフォームに反映
        /// </summary>
        /// <param name="nc"></param>
        private void NgenAssembly(NgenContext nc)
        {
            // 実行条件のチェック
            if (0 == this.util.ngenParams.Count)
            {
                return;
            }

            // ユーティリティの実行準備
            this.state = States.Running;
            this.UpdateControls();

            // フォームの実行準備
            this.pgbProgress.Minimum = 0;
            this.pgbProgress.Maximum = this.util.ngenParams.Count;
            this.pgbProgress.Value = 0;

            // ユーティリティの非同期実行
            Task.Factory.StartNew(() =>
            {
                // ユーティリティのクリア
                for (var i = 0; i < this.util.ngenParams.Count; i++)
                {
                    var p = this.util.ngenParams[i];
                    this.util.ClearResult(p);
                }
                // フォームのクリア
                this.Invoke(
                    (System.Windows.Forms.MethodInvoker)delegate()
                    {
                        this.util.ngenParams.ResetBindings();
                    }
                );

                // ユーティリティの実行
                for (var i = 0; i < this.util.ngenParams.Count; i++)
                {
                    // 中断チェック
                    if (this.state == States.Stopping)
                    {
                        break;
                    }

                    var p = this.util.ngenParams[i];
                    p.action = nc.action;

                    // フォームの更新
                    this.Invoke(
                        (System.Windows.Forms.MethodInvoker)delegate()
                        {
                            this.util.ngenParams.ResetItem(i);
                            var j = i + 1;
                            this.pgbProgress.Value = j;
                            this.lblProgress.Text = this.util.ngenParams.Count.ToString() + "アセンブリ中、" + j.ToString() + "番目のアセンブリを処理しています ...";
                        }
                    );

                    // ユーティリティの実行
                    this.util.NgenAssembly(nc, p);

                    // フォームの更新
                    this.Invoke(
                        (System.Windows.Forms.MethodInvoker)delegate()
                        {
                            this.util.ngenParams.ResetItem(i);
                        }
                    );
                }

                // フォームへの反映
                this.Invoke(
                    (System.Windows.Forms.MethodInvoker)delegate()
                    {
                        // フォームの更新完了
                        this.lblProgress.Text
                            = (this.state == States.Stopping)
                            ? "処理を中断しました。"
                            : this.util.ngenParams.Count.ToString() + "アセンブリを処理しました。";

                        // ユーティリティの実行完了
                        this.state = States.Waiting;
                        this.UpdateControls();
                    }
                );
            });
        }

        /// <summary>
        /// フォーム表示時の読み込み
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FormAdmin_Shown(object sender, EventArgs e)
        {
            // アセンブリの状態の表示
            this.NgenAssembly(
                new NgenContext()
                {
                    action = "display",
                    version = this.cmbVersion.Text
                });
        }

        /// <summary>
        /// [インストール]ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnInstall_Click(object sender, EventArgs e)
        {
            this.NgenAssembly(
                new NgenContext() { 
                    action = "install", 
                    version = this.cmbVersion.Text,
                    scenario = this.cmbScenario.Text
                });
        }

        /// <summary>
        /// バージョン選択時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void cmbVersion_DropDownClosed(object sender, EventArgs e)
        {
            dgvAssembly.Focus();
        }

        /// <summary>
        /// シナリオ選択時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void cmbScenario_DropDownClosed(object sender, EventArgs e)
        {
            dgvAssembly.Focus();
        }

        /// <summary>
        /// [アンインストール]ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnUninstall_Click(object sender, EventArgs e)
        {
            this.NgenAssembly(
                new NgenContext()
                {
                    action = "uninstall",
                    version = this.cmbVersion.Text
                });
        }

        /// <summary>
        /// [最新表示]ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnRefresh_Click(object sender, EventArgs e)
        {
            this.NgenAssembly(
                new NgenContext()
                {
                    action = "display",
                    version = this.cmbVersion.Text
                });
        }

        /// <summary>
        /// [停止]ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnStop_Click(object sender, EventArgs e)
        {
            lock(this.lockObject) {
                this.state = States.Stopping;
            }
        }

        /// <summary>
        /// [停止]ボタン用ロックオブジェクト
        /// </summary>
        private readonly object lockObject = new object();

        /// <summary>
        /// [コマンドプロンプト]ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnPrompt_Click(object sender, EventArgs e)
        {
            this.util.NgenPrompt(
                new NgenContext()
                {
                    version = this.cmbVersion.Text
                });
        }

        /// <summary>
        /// [ヘルプ]ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnHelp_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Process.Start("http://msdn.microsoft.com/ja-jp/library/6t9t5wcf.aspx");
        }

        /// <summary>
        /// コンテキストメニュー表示時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void cmsAssembly_Opening(object sender, CancelEventArgs e)
        {
            this.tsmiExec.Enabled
                = (0 == this.util.ngenParams.Count)
                    ? false
                    : this.tsmiExec.Enabled = (System.IO.Path.GetExtension((string)this.dgvAssembly[this.assemblyDataGridViewTextBoxColumn.Name, this.dgvAssembly.CurrentCell.RowIndex].Value).ToLower() == ".exe");
        }

        /// <summary>
        /// [実行]ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tsmiExec_Click(object sender, EventArgs e)
        {
            string asm = (string)this.dgvAssembly[
                this.assemblyDataGridViewTextBoxColumn.Name,
                this.dgvAssembly.CurrentCell.RowIndex].Value;
            System.Diagnostics.Process.Start(asm);
        }

        /// <summary>
        /// [エクスプローラ]ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tsmiExplorer_Click(object sender, EventArgs e)
        {
            string asm = (string)this.dgvAssembly[
                this.assemblyDataGridViewTextBoxColumn.Name,
                this.dgvAssembly.CurrentCell.RowIndex].Value;
            System.Diagnostics.Process.Start("EXPLORER.EXE", @"/select," + asm);
        }

        /// <summary>
        /// [コピー]ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tsmiCopy_Click(object sender, EventArgs e)
        {
            Clipboard.SetDataObject(this.dgvAssembly.GetClipboardContent());
            this.lblProgress.Text = "選択されたセルをクリップボードにコピーしました。";
        }

        /// <summary>
        /// [すべて選択]ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tsmiSelectAll_Click(object sender, EventArgs e)
        {
            this.dgvAssembly.SelectAll();
            this.lblProgress.Text = "すべてのセルを選択しました。";
        }

        /// <summary>
        /// [種類]の画像の表示
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvAssembly_CellFormatting(object sender, DataGridViewCellFormattingEventArgs e)
        {
            DataGridView dgv = (DataGridView)sender;
            if (dgv.Columns[e.ColumnIndex].Name == this.type.Name && 0 <= e.RowIndex)
            {
                string asm = (string)dgv[
                    this.assemblyDataGridViewTextBoxColumn.Name,
                    e.RowIndex].Value;
                switch (System.IO.Path.GetExtension(asm).ToLower())
                {
                    case ".exe":
                        e.Value = Properties.Resources.ExeFile;
                        e.FormattingApplied = true;
                        break;
                    case ".dll":
                        e.Value = Properties.Resources.DllFile;
                        e.FormattingApplied = true;
                        break;
                }
            }
        }
    }
}
