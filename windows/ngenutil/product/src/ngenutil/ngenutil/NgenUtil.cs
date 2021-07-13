using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Data;
using System.Threading;
using System.Threading.Tasks;

namespace tsoft.NgenUtil
{
    /// <summary>
    /// Ngenユーティリティパラメタクラス
    /// </summary>
    public class NgenUtilParam
    {
        /// <summary>
        /// Ngenの対象となるフォルダもしくはファイル
        /// </summary>
        public string target;
    };

    /// <summary>
    /// Ngenコンテキストクラス
    /// </summary>
    public class NgenContext
    {
        /// <summary>
        /// Ngenで実行するアクション
        /// </summary>
        public string action;

        /// <summary>
        /// Ngenで実行する.NET Frameworkのバージョン
        /// </summary>
        public string version;

        /// <summary>
        /// Ngenで実行するシナリオ
        /// </summary>
        public string scenario;

        /// <summary>
        /// .NET Frameworkのランタイムのパス
        /// </summary>
        /// <returns></returns>
        public string RuntimePath()
        {
            return System.IO.Path.GetFullPath(System.Runtime.InteropServices.RuntimeEnvironment.GetRuntimeDirectory() + @"..\" + this.version + @"\");
        }
    };

    /// <summary>
    ///  Ngenパラメタクラス
    /// </summary>
    /// <remarks>
    /// ・DataGridViewへバインドするためプロパティとする。
    /// </remarks>
    public class NgenParam
    {
        /// <summary>
        /// Ngenで実行するアクション
        /// </summary>
        public string action { get; set; }

        /// <summary>
        /// Ngenの対象とするアセンブリ
        /// </summary>
        public string assembly { get; set; }

        /// <summary>
        /// Ngenの対象とするアセンブリの更新日時
        /// </summary>
        public string lastUpdated { get; set; }

        /// <summary>
        /// Ngenの実行結果の戻り値
        /// </summary>
        public string exitCode { get; set; }

        /// <summary>
        /// Ngenの実行結果の標準出力
        /// </summary>
        public string output { get; set; }

        /// <summary>
        /// Ngenコマンド
        /// </summary>
        public string command { get; set; }
    };

    /// <summary>
    /// Ngenユーティリティの実行クラス
    /// </summary>
    public class Utility
    {
        /// <summary>
        /// アセンブリ拡張子リスト
        /// </summary>
        private List<string> extensionList;

        /// <summary>
        /// .NET Frameworkバージョンリスト
        /// </summary>
        public List<string> versionList;

        /// <summary>
        /// シナリオリスト
        /// </summary>
        public List<string> scenarioList;

        /// <summary>
        /// アセンブリかどうかの判断
        /// </summary>
        /// <param name="asm"></param>
        /// <returns></returns>
        private bool IsAssembly(string asm)
        {
            return this.extensionList.Contains(System.IO.Path.GetExtension(asm).ToLower());
        }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public Utility()
        {
            // アセンブリ拡張子リストの初期化
            this.extensionList = new List<string> { ".exe", ".dll" };

            // .NET Frameworkバージョンリストの初期化
            this.versionList = System.IO.Directory.GetDirectories(System.Runtime.InteropServices.RuntimeEnvironment.GetRuntimeDirectory() + @"\..\")
                .ToList()
                .FindAll(x => System.IO.File.Exists(x + @"\ngen.exe"))
                .Select(x => System.IO.Path.GetFileName(x).ToString())
                .ToList();

            // シナリオリストの初期化
            this.scenarioList = new List<string> { "", "/Debug", "/Profile", "/NoDependencies" };
        }

        /// <summary>
        /// Ngenユーティリティパラメタリスト
        /// </summary>
        public BindingList<NgenUtilParam> ngenUtilParams = new BindingList<NgenUtilParam>();

        /// <summary>
        /// Ngenパラメタリスト
        /// </summary>
        public BindingList<NgenParam> ngenParams = new BindingList<NgenParam>();

        /// <summary>
        /// Ngen対象の追加
        /// </summary>
        /// <param name="args"></param>
        public void AddArgs(params string[] args)
        {
            // Ngenユーティリティパラメタリストへの追加
            foreach (var a in args)
            {
                this.AddTarget(a.RemoveSeparator());
            }

            // Ngenパラメタリストへの追加
            foreach (var p in this.ngenUtilParams)
            {
                this.AddAssembly(p.target);
            }

            // Ngenユーティリティパラメタリストのクリア
            this.ngenUtilParams.Clear();
        }

        /// <summary>
        /// Ngenユーティリティパラメタリストへの追加（パス）
        /// </summary>
        /// <param name="arg"></param>
        private void AddTarget(string arg)
        {
            var nup = new NgenUtilParam();
            nup.target = arg;
            this.AddTarget(nup);
        }

        /// <summary>
        /// Ngenユーティリティパラメタリストへの追加（Ngenユーティリティパラメタ）
        /// </summary>
        /// <param name="nup"></param>
        private void AddTarget(NgenUtilParam nup)
        {
            this.ngenUtilParams.Add(nup);
        }

        /// <summary>
        /// Ngenパラメタリストへの追加（パス）
        /// </summary>
        /// <param name="asm"></param>
        private void AddAssembly(string asm)
        {
            if (System.IO.Directory.Exists(asm))
            {
                foreach (var s in System.IO.Directory.GetFiles(asm))
                {
                    this.AddAssembly(s);
                }
            }
            else if (System.IO.File.Exists(asm))
            {
                if (this.IsAssembly(asm))
                {
                    var np = new NgenParam();
                    np.assembly = System.IO.Path.GetFullPath(asm);
                    np.lastUpdated = System.IO.File.GetLastWriteTime(asm).ToString();
                    this.AddAssembly(np);
                }
            }

        }

        /// <summary>
        /// Ngenパラメタリストへの追加（Ngenパラメタ）
        /// </summary>
        /// <param name="np"></param>
        private void AddAssembly(NgenParam np)
        {
            this.ngenParams.Add(np);
        }

        /// <summary>
        /// Ngenパラメタの実行結果のクリア
        /// </summary>
        /// <param name="np"></param>
        public void ClearResult(NgenParam np)
        {
            np.action = "";
            np.exitCode = "";
            np.output = "";
        }

        /// <summary>
        /// Ngenパラメタリストに対してNgenを実行
        /// </summary>
        /// <param name="nc"></param>
        /// <param name="np"></param>
        public void NgenAssembly(NgenContext nc, NgenParam np)
        {
            /*
             * NgenUtilAdmin全体で管理者権限を必要とする理由：
             * ・Ngenを実行する際だけ昇格させようとすると毎回ダイアログが表示されるので現実的ではない。
             * ・管理者権限で実行するには、UseShellExecute:false, Verb:runas, RedirectStandardOutput:falseが必要になり、メッセージが取れない。
             */
            System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo();
            psi.FileName = nc.RuntimePath() + "ngen.exe";
            psi.RedirectStandardInput = false;
            psi.RedirectStandardOutput = true;
            psi.CreateNoWindow = true;
            psi.UseShellExecute = false;
            psi.Arguments = np.action + " " + np.assembly.QuotePath() + " " + nc.scenario + " /nologo";
            np.command = psi.FileName + " " + psi.Arguments;

            System.Diagnostics.Process pr = System.Diagnostics.Process.Start(psi);
            np.output = pr.StandardOutput.ReadToEnd().Trim().Replace("\r\n\r\n", "\r\n");
            pr.WaitForExit();
            np.exitCode = pr.ExitCode.ToString();
        }

        /// <summary>
        /// コマンドプロンプトを開く
        /// </summary>
        /// <param name="nc"></param>
        public void NgenPrompt(NgenContext nc)
        {
            System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo();
            psi.FileName = @"cmd.exe";
            psi.UseShellExecute = false;
            psi.EnvironmentVariables["PATH"] += ";" + nc.RuntimePath();
            psi.WorkingDirectory = nc.RuntimePath();
            if (0 < this.ngenParams.Count())
            {
                psi.WorkingDirectory = this.ngenParams[0].assembly + @"\..\";
            }
            System.Diagnostics.Process pr = System.Diagnostics.Process.Start(psi);
        }
    }
}
