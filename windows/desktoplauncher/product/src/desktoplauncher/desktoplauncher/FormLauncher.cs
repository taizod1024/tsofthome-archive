using System;
using System.Windows.Forms;
using System.Diagnostics;

namespace tsoft.desktoplauncher
{
    public partial class FormLauncher : Form
    {

        #region メンバ変数

        IntPtr hwndDesktop;
        int styleDesktop;
        IntPtr hwndParent;
        FormWindowState statePrev;

        #endregion

        #region コンストラクタ

        public FormLauncher()
        {
            // 画面の初期化
            InitializeComponent();
        }

        #endregion

        #region イベントハンドラ

        private void FormLauncher_Load(object sender, EventArgs e)
        {
            Debug.WriteLine(DateTime.Now.ToString() + " " + System.Reflection.MethodBase.GetCurrentMethod().Name);

            // フォームの初期化
            this.InitFormLauncher();

            // フォームをセットアップ
            this.SetupFormLauncher();
        }

        private void FormLauncher_Activated(object sender, EventArgs e)
        {
            Debug.WriteLine(DateTime.Now.ToString() + " " + System.Reflection.MethodBase.GetCurrentMethod().Name);

            //// フォームのセットアップ
            //this.SetupFormLauncher();
        }

        private void FormLauncher_Deactivated(object sender, EventArgs e)
        {
            Debug.WriteLine(DateTime.Now.ToString() + " " + System.Reflection.MethodBase.GetCurrentMethod().Name);

            // フォームのセットアップ解除
            this.UnsetupFormLauncher();

            // タイマ開始
            timerWatcher.Start();
        }

        private void timerWatcher_Tick(object sender, EventArgs e)
        {
            Debug.WriteLine(DateTime.Now.ToString() + " " + System.Reflection.MethodBase.GetCurrentMethod().Name);

            // タイマ終了
            timerWatcher.Stop();

            if (Form.ActiveForm != this)
            {
                if (this.WindowState != FormWindowState.Minimized)
                {
                    this.WindowState = FormWindowState.Minimized;
                }

            }
        }

        private void FormLauncher_Resize(object sender, EventArgs e)
        {
            Debug.WriteLine(DateTime.Now.ToString() + " " + System.Reflection.MethodBase.GetCurrentMethod().Name);

            if (this.WindowState != this.statePrev)
            {
                switch (this.WindowState)
                {
                    case FormWindowState.Maximized:
                    case FormWindowState.Normal:
                        this.SetupFormLauncher();
                        break;
                    case FormWindowState.Minimized:
                        this.UnsetupFormLauncher();
                        break;
                }
                this.statePrev = this.WindowState;
            }
        }

        private void FormLauncher_FormClosed(object sender, FormClosedEventArgs e)
        {
            Debug.WriteLine(DateTime.Now.ToString() + " " + System.Reflection.MethodBase.GetCurrentMethod().Name);

            // フォームのセットアップ解除
            this.UnsetupFormLauncher();
        }

        private void buttonClose_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        #endregion

        #region プロセス

        private void InitFormLauncher()
        {
            // タイトル修正
            this.Text += " " + System.Reflection.Assembly.GetExecutingAssembly().GetName().Version;

            // プライベートメンバの初期化
            this.hwndDesktop = IntPtr.Zero;
            this.styleDesktop = 0;
            this.hwndParent = IntPtr.Zero;
            this.statePrev = FormWindowState.Normal;

            // デスクトップウィンドウ及びスタイルの取得
            this.hwndDesktop = WinAPI.FindWindow("Progman", "Program Manager");
            this.styleDesktop = WinAPI.GetWindowLong(this.hwndDesktop, WinAPI.GWL_STYLE);

            // フォームをプライマリスクリーンの大きさに設定
            this.Width = Screen.PrimaryScreen.WorkingArea.Width;
            this.Height = Screen.PrimaryScreen.WorkingArea.Height;

            // DoubleBufferの有効化
            this.SetStyle(ControlStyles.ResizeRedraw, true);
            this.SetStyle(ControlStyles.DoubleBuffer, true);
            this.SetStyle(ControlStyles.UserPaint, true);
            this.SetStyle(ControlStyles.AllPaintingInWmPaint, true);
        }

        private void SetupFormLauncher()
        {
            if (this.WindowState != FormWindowState.Minimized)
            {
                if (this.hwndParent == IntPtr.Zero)
                {
                    WinAPI.SetWindowLong(this.hwndDesktop, WinAPI.GWL_STYLE, WinAPI.GetWindowLong(this.panelBody.Handle, WinAPI.GWL_STYLE));
                    this.hwndParent = WinAPI.SetParent(this.hwndDesktop, this.panelBody.Handle);

                    this.Width = Screen.PrimaryScreen.WorkingArea.Width;
                    this.Height = Screen.PrimaryScreen.WorkingArea.Height;
                }
            }
        }

        private void UnsetupFormLauncher()
        {
            if (this.hwndParent != IntPtr.Zero)
            {
                WinAPI.SetWindowLong(this.hwndDesktop, WinAPI.GWL_STYLE, styleDesktop);
                WinAPI.SetParent(this.hwndDesktop, this.hwndParent);
                this.hwndParent = IntPtr.Zero;
            }
        }

        #endregion

    }
}
