using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using tsoft.NgenUtil;

namespace ngenutil
{
    /// <summary>
    /// メインプログラム
    /// </summary>
    static class Program
    {
        /// <summary>
        /// アプリケーションのメイン エントリ ポイントです。
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new FormAdmin(args));
        }
    }
}
