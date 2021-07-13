namespace tsoft.NgenUtil
{
    partial class FormAdmin
    {
        /// <summary>
        /// 必要なデザイナー変数です。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 使用中のリソースをすべてクリーンアップします。
        /// </summary>
        /// <param name="disposing">マネージ リソースが破棄される場合 true、破棄されない場合は false です。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows フォーム デザイナーで生成されたコード

        /// <summary>
        /// デザイナー サポートに必要なメソッドです。このメソッドの内容を
        /// コード エディターで変更しないでください。
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FormAdmin));
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle4 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle5 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle6 = new System.Windows.Forms.DataGridViewCellStyle();
            this.toolStripContainer1 = new System.Windows.Forms.ToolStripContainer();
            this.statusStrip1 = new System.Windows.Forms.StatusStrip();
            this.pgbProgress = new System.Windows.Forms.ToolStripProgressBar();
            this.lblProgress = new System.Windows.Forms.ToolStripStatusLabel();
            this.dgvAssembly = new System.Windows.Forms.DataGridView();
            this.cmsAssembly = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.tsmiExec = new System.Windows.Forms.ToolStripMenuItem();
            this.tsmiExplorer = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.tsmiCopy = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator5 = new System.Windows.Forms.ToolStripSeparator();
            this.tsmiSelectAll = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStrip1 = new System.Windows.Forms.ToolStrip();
            this.lblVersion = new System.Windows.Forms.ToolStripLabel();
            this.cmbVersion = new System.Windows.Forms.ToolStripComboBox();
            this.cmbScenario = new System.Windows.Forms.ToolStripComboBox();
            this.toolStripSeparator3 = new System.Windows.Forms.ToolStripSeparator();
            this.btnInstall = new System.Windows.Forms.ToolStripButton();
            this.btnUninstall = new System.Windows.Forms.ToolStripButton();
            this.btnRefresh = new System.Windows.Forms.ToolStripButton();
            this.btnStop = new System.Windows.Forms.ToolStripButton();
            this.btnReference = new System.Windows.Forms.ToolStripButton();
            this.toolStripSeparator2 = new System.Windows.Forms.ToolStripSeparator();
            this.btnPrompt = new System.Windows.Forms.ToolStripButton();
            this.toolStripSeparator4 = new System.Windows.Forms.ToolStripSeparator();
            this.toolStripSeparator6 = new System.Windows.Forms.ToolStripSeparator();
            this.paramsBindingSource = new System.Windows.Forms.BindingSource(this.components);
            this.actionDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.type = new System.Windows.Forms.DataGridViewImageColumn();
            this.assemblyDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.lastUpdated = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.exitCodeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.output = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.command = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.toolStripContainer1.BottomToolStripPanel.SuspendLayout();
            this.toolStripContainer1.ContentPanel.SuspendLayout();
            this.toolStripContainer1.TopToolStripPanel.SuspendLayout();
            this.toolStripContainer1.SuspendLayout();
            this.statusStrip1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvAssembly)).BeginInit();
            this.cmsAssembly.SuspendLayout();
            this.toolStrip1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.paramsBindingSource)).BeginInit();
            this.SuspendLayout();
            // 
            // toolStripContainer1
            // 
            // 
            // toolStripContainer1.BottomToolStripPanel
            // 
            this.toolStripContainer1.BottomToolStripPanel.Controls.Add(this.statusStrip1);
            // 
            // toolStripContainer1.ContentPanel
            // 
            this.toolStripContainer1.ContentPanel.Controls.Add(this.dgvAssembly);
            this.toolStripContainer1.ContentPanel.Size = new System.Drawing.Size(1015, 318);
            this.toolStripContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.toolStripContainer1.Location = new System.Drawing.Point(0, 0);
            this.toolStripContainer1.Name = "toolStripContainer1";
            this.toolStripContainer1.Size = new System.Drawing.Size(1015, 366);
            this.toolStripContainer1.TabIndex = 0;
            this.toolStripContainer1.Text = "toolStripContainer1";
            // 
            // toolStripContainer1.TopToolStripPanel
            // 
            this.toolStripContainer1.TopToolStripPanel.Controls.Add(this.toolStrip1);
            // 
            // statusStrip1
            // 
            this.statusStrip1.Dock = System.Windows.Forms.DockStyle.None;
            this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.pgbProgress,
            this.lblProgress});
            this.statusStrip1.Location = new System.Drawing.Point(0, 0);
            this.statusStrip1.Name = "statusStrip1";
            this.statusStrip1.Size = new System.Drawing.Size(1015, 22);
            this.statusStrip1.TabIndex = 0;
            // 
            // pgbProgress
            // 
            this.pgbProgress.Name = "pgbProgress";
            this.pgbProgress.Size = new System.Drawing.Size(200, 16);
            // 
            // lblProgress
            // 
            this.lblProgress.Margin = new System.Windows.Forms.Padding(5, 3, 0, 2);
            this.lblProgress.Name = "lblProgress";
            this.lblProgress.Size = new System.Drawing.Size(0, 17);
            // 
            // dgvAssembly
            // 
            this.dgvAssembly.AllowUserToAddRows = false;
            this.dgvAssembly.AllowUserToDeleteRows = false;
            this.dgvAssembly.AllowUserToOrderColumns = true;
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(240)))), ((int)(((byte)(240)))), ((int)(((byte)(240)))));
            this.dgvAssembly.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle1;
            this.dgvAssembly.AutoGenerateColumns = false;
            this.dgvAssembly.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.AllCells;
            this.dgvAssembly.AutoSizeRowsMode = System.Windows.Forms.DataGridViewAutoSizeRowsMode.AllCells;
            this.dgvAssembly.BackgroundColor = System.Drawing.SystemColors.ControlLightLight;
            this.dgvAssembly.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvAssembly.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.actionDataGridViewTextBoxColumn,
            this.type,
            this.assemblyDataGridViewTextBoxColumn,
            this.lastUpdated,
            this.exitCodeDataGridViewTextBoxColumn,
            this.output,
            this.command});
            this.dgvAssembly.ContextMenuStrip = this.cmsAssembly;
            this.dgvAssembly.DataSource = this.paramsBindingSource;
            this.dgvAssembly.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvAssembly.GridColor = System.Drawing.SystemColors.Control;
            this.dgvAssembly.Location = new System.Drawing.Point(0, 0);
            this.dgvAssembly.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.dgvAssembly.Name = "dgvAssembly";
            this.dgvAssembly.ReadOnly = true;
            this.dgvAssembly.RowHeadersVisible = false;
            this.dgvAssembly.RowHeadersWidth = 20;
            this.dgvAssembly.RowTemplate.Height = 21;
            this.dgvAssembly.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.CellSelect;
            this.dgvAssembly.Size = new System.Drawing.Size(1015, 318);
            this.dgvAssembly.TabIndex = 11;
            this.dgvAssembly.CellFormatting += new System.Windows.Forms.DataGridViewCellFormattingEventHandler(this.dgvAssembly_CellFormatting);
            // 
            // cmsAssembly
            // 
            this.cmsAssembly.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.tsmiExec,
            this.tsmiExplorer,
            this.toolStripSeparator1,
            this.tsmiCopy,
            this.toolStripSeparator5,
            this.tsmiSelectAll});
            this.cmsAssembly.Name = "contextMenuStrip1";
            this.cmsAssembly.Size = new System.Drawing.Size(178, 104);
            this.cmsAssembly.Opening += new System.ComponentModel.CancelEventHandler(this.cmsAssembly_Opening);
            // 
            // tsmiExec
            // 
            this.tsmiExec.Image = global::tsoft.NgenUtil.Properties.Resources.ExeFile;
            this.tsmiExec.Name = "tsmiExec";
            this.tsmiExec.Size = new System.Drawing.Size(177, 22);
            this.tsmiExec.Text = "実行(&X)";
            this.tsmiExec.Click += new System.EventHandler(this.tsmiExec_Click);
            // 
            // tsmiExplorer
            // 
            this.tsmiExplorer.Image = global::tsoft.NgenUtil.Properties.Resources.Folder;
            this.tsmiExplorer.Name = "tsmiExplorer";
            this.tsmiExplorer.Size = new System.Drawing.Size(177, 22);
            this.tsmiExplorer.Text = "エクスプローラ(&E)";
            this.tsmiExplorer.Click += new System.EventHandler(this.tsmiExplorer_Click);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(174, 6);
            // 
            // tsmiCopy
            // 
            this.tsmiCopy.Image = global::tsoft.NgenUtil.Properties.Resources.Copy;
            this.tsmiCopy.Name = "tsmiCopy";
            this.tsmiCopy.Size = new System.Drawing.Size(177, 22);
            this.tsmiCopy.Text = "コピー(&C)";
            this.tsmiCopy.Click += new System.EventHandler(this.tsmiCopy_Click);
            // 
            // toolStripSeparator5
            // 
            this.toolStripSeparator5.Name = "toolStripSeparator5";
            this.toolStripSeparator5.Size = new System.Drawing.Size(174, 6);
            // 
            // tsmiSelectAll
            // 
            this.tsmiSelectAll.Image = global::tsoft.NgenUtil.Properties.Resources.SelectAll;
            this.tsmiSelectAll.Name = "tsmiSelectAll";
            this.tsmiSelectAll.Size = new System.Drawing.Size(177, 22);
            this.tsmiSelectAll.Text = "すべて選択(&A)";
            this.tsmiSelectAll.Click += new System.EventHandler(this.tsmiSelectAll_Click);
            // 
            // toolStrip1
            // 
            this.toolStrip1.Dock = System.Windows.Forms.DockStyle.None;
            this.toolStrip1.GripStyle = System.Windows.Forms.ToolStripGripStyle.Hidden;
            this.toolStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.lblVersion,
            this.cmbVersion,
            this.cmbScenario,
            this.toolStripSeparator3,
            this.btnInstall,
            this.btnUninstall,
            this.btnRefresh,
            this.btnStop,
            this.btnReference,
            this.toolStripSeparator2,
            this.btnPrompt,
            this.toolStripSeparator4,
            this.toolStripSeparator6});
            this.toolStrip1.LayoutStyle = System.Windows.Forms.ToolStripLayoutStyle.HorizontalStackWithOverflow;
            this.toolStrip1.Location = new System.Drawing.Point(0, 0);
            this.toolStrip1.Name = "toolStrip1";
            this.toolStrip1.Size = new System.Drawing.Size(1015, 26);
            this.toolStrip1.Stretch = true;
            this.toolStrip1.TabIndex = 0;
            // 
            // lblVersion
            // 
            this.lblVersion.Image = ((System.Drawing.Image)(resources.GetObject("lblVersion.Image")));
            this.lblVersion.Margin = new System.Windows.Forms.Padding(5, 1, 5, 2);
            this.lblVersion.Name = "lblVersion";
            this.lblVersion.Size = new System.Drawing.Size(127, 23);
            this.lblVersion.Text = " .NET Framework";
            // 
            // cmbVersion
            // 
            this.cmbVersion.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbVersion.Name = "cmbVersion";
            this.cmbVersion.Size = new System.Drawing.Size(121, 26);
            this.cmbVersion.ToolTipText = ".NET Frameworkのバージョンです。";
            this.cmbVersion.DropDownClosed += new System.EventHandler(this.cmbVersion_DropDownClosed);
            // 
            // cmbScenario
            // 
            this.cmbScenario.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbScenario.Name = "cmbScenario";
            this.cmbScenario.Size = new System.Drawing.Size(128, 26);
            this.cmbScenario.ToolTipText = "Ngenのシナリオを指定します。";
            this.cmbScenario.DropDownClosed += new System.EventHandler(this.cmbScenario_DropDownClosed);
            // 
            // toolStripSeparator3
            // 
            this.toolStripSeparator3.Name = "toolStripSeparator3";
            this.toolStripSeparator3.Size = new System.Drawing.Size(6, 26);
            // 
            // btnInstall
            // 
            this.btnInstall.Image = global::tsoft.NgenUtil.Properties.Resources.Add;
            this.btnInstall.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnInstall.Name = "btnInstall";
            this.btnInstall.Size = new System.Drawing.Size(208, 23);
            this.btnInstall.Text = "ネイティブイメージインストール";
            this.btnInstall.ToolTipText = "ネイティブイメージをネイティブイメージキャッシュにインストールします。";
            this.btnInstall.Click += new System.EventHandler(this.btnInstall_Click);
            // 
            // btnUninstall
            // 
            this.btnUninstall.Image = global::tsoft.NgenUtil.Properties.Resources.Delete;
            this.btnUninstall.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnUninstall.Name = "btnUninstall";
            this.btnUninstall.Size = new System.Drawing.Size(124, 23);
            this.btnUninstall.Text = "アンインストール";
            this.btnUninstall.ToolTipText = "ネイティブイメージとその依存関係をネイティブイメージキャッシュから削除します。";
            this.btnUninstall.Click += new System.EventHandler(this.btnUninstall_Click);
            // 
            // btnRefresh
            // 
            this.btnRefresh.Image = ((System.Drawing.Image)(resources.GetObject("btnRefresh.Image")));
            this.btnRefresh.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnRefresh.Name = "btnRefresh";
            this.btnRefresh.Size = new System.Drawing.Size(76, 23);
            this.btnRefresh.Text = "最新表示";
            this.btnRefresh.ToolTipText = "最新の状態に更新します。";
            this.btnRefresh.Click += new System.EventHandler(this.btnRefresh_Click);
            // 
            // btnStop
            // 
            this.btnStop.Image = ((System.Drawing.Image)(resources.GetObject("btnStop.Image")));
            this.btnStop.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnStop.Name = "btnStop";
            this.btnStop.Size = new System.Drawing.Size(52, 23);
            this.btnStop.Text = "停止";
            this.btnStop.ToolTipText = "実行中の処理を停止します。";
            this.btnStop.Click += new System.EventHandler(this.btnStop_Click);
            // 
            // btnReference
            // 
            this.btnReference.Alignment = System.Windows.Forms.ToolStripItemAlignment.Right;
            this.btnReference.Image = global::tsoft.NgenUtil.Properties.Resources.Help;
            this.btnReference.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnReference.Name = "btnReference";
            this.btnReference.Size = new System.Drawing.Size(100, 23);
            this.btnReference.Text = "リファレンス";
            this.btnReference.ToolTipText = "Ngenのリファレンスを表示します。";
            this.btnReference.Click += new System.EventHandler(this.btnHelp_Click);
            // 
            // toolStripSeparator2
            // 
            this.toolStripSeparator2.Alignment = System.Windows.Forms.ToolStripItemAlignment.Right;
            this.toolStripSeparator2.Name = "toolStripSeparator2";
            this.toolStripSeparator2.Size = new System.Drawing.Size(6, 26);
            // 
            // btnPrompt
            // 
            this.btnPrompt.Alignment = System.Windows.Forms.ToolStripItemAlignment.Right;
            this.btnPrompt.Image = ((System.Drawing.Image)(resources.GetObject("btnPrompt.Image")));
            this.btnPrompt.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnPrompt.Name = "btnPrompt";
            this.btnPrompt.Size = new System.Drawing.Size(136, 22);
            this.btnPrompt.Text = "コマンドプロンプト";
            this.btnPrompt.ToolTipText = "コマンドプロンプトを開きます。";
            this.btnPrompt.Click += new System.EventHandler(this.btnPrompt_Click);
            // 
            // toolStripSeparator4
            // 
            this.toolStripSeparator4.Alignment = System.Windows.Forms.ToolStripItemAlignment.Right;
            this.toolStripSeparator4.Name = "toolStripSeparator4";
            this.toolStripSeparator4.Size = new System.Drawing.Size(6, 26);
            // 
            // toolStripSeparator6
            // 
            this.toolStripSeparator6.Name = "toolStripSeparator6";
            this.toolStripSeparator6.Size = new System.Drawing.Size(6, 26);
            // 
            // paramsBindingSource
            // 
            this.paramsBindingSource.DataSource = typeof(tsoft.NgenUtil.NgenParam);
            // 
            // actionDataGridViewTextBoxColumn
            // 
            this.actionDataGridViewTextBoxColumn.DataPropertyName = "action";
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleCenter;
            this.actionDataGridViewTextBoxColumn.DefaultCellStyle = dataGridViewCellStyle2;
            this.actionDataGridViewTextBoxColumn.HeaderText = "アクション";
            this.actionDataGridViewTextBoxColumn.Name = "actionDataGridViewTextBoxColumn";
            this.actionDataGridViewTextBoxColumn.ReadOnly = true;
            this.actionDataGridViewTextBoxColumn.Width = 72;
            // 
            // type
            // 
            this.type.DataPropertyName = "type";
            this.type.HeaderText = "種類";
            this.type.Name = "type";
            this.type.ReadOnly = true;
            this.type.Width = 35;
            // 
            // assemblyDataGridViewTextBoxColumn
            // 
            this.assemblyDataGridViewTextBoxColumn.DataPropertyName = "assembly";
            dataGridViewCellStyle3.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            this.assemblyDataGridViewTextBoxColumn.DefaultCellStyle = dataGridViewCellStyle3;
            this.assemblyDataGridViewTextBoxColumn.HeaderText = "アセンブリ";
            this.assemblyDataGridViewTextBoxColumn.Name = "assemblyDataGridViewTextBoxColumn";
            this.assemblyDataGridViewTextBoxColumn.ReadOnly = true;
            this.assemblyDataGridViewTextBoxColumn.Width = 74;
            // 
            // lastUpdated
            // 
            this.lastUpdated.DataPropertyName = "lastUpdated";
            dataGridViewCellStyle4.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            this.lastUpdated.DefaultCellStyle = dataGridViewCellStyle4;
            this.lastUpdated.HeaderText = "更新日時";
            this.lastUpdated.Name = "lastUpdated";
            this.lastUpdated.ReadOnly = true;
            this.lastUpdated.Width = 78;
            // 
            // exitCodeDataGridViewTextBoxColumn
            // 
            this.exitCodeDataGridViewTextBoxColumn.DataPropertyName = "exitCode";
            dataGridViewCellStyle5.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleCenter;
            this.exitCodeDataGridViewTextBoxColumn.DefaultCellStyle = dataGridViewCellStyle5;
            this.exitCodeDataGridViewTextBoxColumn.HeaderText = "結果";
            this.exitCodeDataGridViewTextBoxColumn.Name = "exitCodeDataGridViewTextBoxColumn";
            this.exitCodeDataGridViewTextBoxColumn.ReadOnly = true;
            this.exitCodeDataGridViewTextBoxColumn.Width = 54;
            // 
            // output
            // 
            this.output.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.None;
            this.output.DataPropertyName = "output";
            dataGridViewCellStyle6.Alignment = System.Windows.Forms.DataGridViewContentAlignment.TopLeft;
            dataGridViewCellStyle6.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.output.DefaultCellStyle = dataGridViewCellStyle6;
            this.output.HeaderText = "出力";
            this.output.Name = "output";
            this.output.ReadOnly = true;
            this.output.Width = 1024;
            // 
            // command
            // 
            this.command.DataPropertyName = "command";
            this.command.HeaderText = "コマンド";
            this.command.Name = "command";
            this.command.ReadOnly = true;
            this.command.Width = 65;
            // 
            // FormAdmin
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1015, 366);
            this.Controls.Add(this.toolStripContainer1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MinimumSize = new System.Drawing.Size(640, 256);
            this.Name = "FormAdmin";
            this.SizeGripStyle = System.Windows.Forms.SizeGripStyle.Show;
            this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            this.Text = "Ngenユーティリティ";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.FormAdmin_FormClosing);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FormAdmin_FormClosed);
            this.Shown += new System.EventHandler(this.FormAdmin_Shown);
            this.LocationChanged += new System.EventHandler(this.FormAdmin_LocationChanged);
            this.SizeChanged += new System.EventHandler(this.FormAdmin_SizeChanged);
            this.toolStripContainer1.BottomToolStripPanel.ResumeLayout(false);
            this.toolStripContainer1.BottomToolStripPanel.PerformLayout();
            this.toolStripContainer1.ContentPanel.ResumeLayout(false);
            this.toolStripContainer1.TopToolStripPanel.ResumeLayout(false);
            this.toolStripContainer1.TopToolStripPanel.PerformLayout();
            this.toolStripContainer1.ResumeLayout(false);
            this.toolStripContainer1.PerformLayout();
            this.statusStrip1.ResumeLayout(false);
            this.statusStrip1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvAssembly)).EndInit();
            this.cmsAssembly.ResumeLayout(false);
            this.toolStrip1.ResumeLayout(false);
            this.toolStrip1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.paramsBindingSource)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.BindingSource paramsBindingSource;
        private System.Windows.Forms.ToolStripContainer toolStripContainer1;
        private System.Windows.Forms.StatusStrip statusStrip1;
        private System.Windows.Forms.DataGridView dgvAssembly;
        private System.Windows.Forms.ToolStrip toolStrip1;
        private System.Windows.Forms.ToolStripButton btnInstall;
        private System.Windows.Forms.ToolStripComboBox cmbVersion;
        private System.Windows.Forms.ToolStripButton btnPrompt;
        private System.Windows.Forms.ToolStripLabel lblVersion;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator3;
        private System.Windows.Forms.ToolStripButton btnUninstall;
        private System.Windows.Forms.ToolStripButton btnRefresh;
        public System.Windows.Forms.ToolStripProgressBar pgbProgress;
        public System.Windows.Forms.ToolStripStatusLabel lblProgress;
        private System.Windows.Forms.ToolStripButton btnReference;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator2;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator4;
        private System.Windows.Forms.ContextMenuStrip cmsAssembly;
        private System.Windows.Forms.ToolStripMenuItem tsmiSelectAll;
        private System.Windows.Forms.ToolStripMenuItem tsmiCopy;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator5;
        private System.Windows.Forms.ToolStripComboBox cmbScenario;
        private System.Windows.Forms.ToolStripButton btnStop;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator6;
        private System.Windows.Forms.ToolStripMenuItem tsmiExec;
        private System.Windows.Forms.ToolStripMenuItem tsmiExplorer;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.DataGridViewTextBoxColumn actionDataGridViewTextBoxColumn;
        private System.Windows.Forms.DataGridViewImageColumn type;
        private System.Windows.Forms.DataGridViewTextBoxColumn assemblyDataGridViewTextBoxColumn;
        private System.Windows.Forms.DataGridViewTextBoxColumn lastUpdated;
        private System.Windows.Forms.DataGridViewTextBoxColumn exitCodeDataGridViewTextBoxColumn;
        private System.Windows.Forms.DataGridViewTextBoxColumn output;
        private System.Windows.Forms.DataGridViewTextBoxColumn command;
    }
}

