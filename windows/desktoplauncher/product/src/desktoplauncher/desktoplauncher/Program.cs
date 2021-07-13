using System;
using System.Windows.Forms;
using System.Diagnostics;

namespace tsoft.desktoplauncher
{
    static class Program
    {
        private const string APPNAME = "デスクトップランチャ";
        private const string APPNAME2 = "エクスプローラの再起動";

        /// <summary>
        /// アプリケーションのメインエントリポイントです。
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            if (args.Length == 1 && args[0] == "/explorer")
            {
                RebootExplorer();
            }
            else if (args.Length == 0)
            {
                LaunchDesktop();
            }
            else
            {
                UnknownOption(args);
            }
        }

        private static void RebootExplorer()
        {
            Process proc = WinAPI.GetOtherProcess();
            if (null != proc)
            {
                // 起動済ならダイアログで注意して終了
                MessageBox.Show("デスクトップランチャが起動されています。\nエクスプローラの再起動を実行する前にデスクトップランチャを終了させてください。", APPNAME2, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
            else
            {
                // 未起動ならダイアログで確認してから実行
                if (MessageBox.Show("エクスプローラを再起動します。\nすべてのエクスプローラウィンドウが閉じられます。\nよろしいですか？", APPNAME2, MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
                {
                    Process[] prcs = Process.GetProcessesByName("explorer");
                    foreach (Process prc in prcs)
                    {
                        prc.Kill();
                        prc.WaitForExit();
                    }
                    // 何故か自動的に起動するためProcess.Start()は省略
                    // http://itnandemolab.blog70.fc2.com/blog-entry-3196.html
                    // Process.Start("explorer.exe");
                    MessageBox.Show("エクスプローラを再起動しました。", APPNAME, MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            }
        }

        private static void UnknownOption(string[] args)
        {
            MessageBox.Show("不明な引数です。\n引数:" + args[0], APPNAME, MessageBoxButtons.OK, MessageBoxIcon.Error);
        }

        private static void LaunchDesktop()
        {
            // 起動済なら表示する
            Process proc = WinAPI.GetOtherProcess();
            if (null != proc)
            {
                WinAPI.ShowWindow(proc);
                return;
            }

            // 未起動なら起動する
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new FormLauncher());
        }
    }
}
