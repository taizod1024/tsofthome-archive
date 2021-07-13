using System;
using System.Runtime.InteropServices;
using System.Diagnostics;

namespace tsoft.desktoplauncher
{
    public class WinAPI
    {
        [DllImport("user32.dll")]
        public static extern IntPtr SetParent(IntPtr hwndChild, IntPtr hwndNewParent);

        [DllImport("user32.dll")]
        public static extern IntPtr FindWindow(string strclassName, string strWindowName);
        [DllImport("user32", EntryPoint = "FindWindowEx")]
        public static extern IntPtr FindWindowEx(IntPtr hWnd1, IntPtr hWnd2, string lpsz1, string lpsz2);

        public const int SW_NORMAL = 1;
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern int ShowWindow(System.IntPtr hWnd, int nCmdShow);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern bool SetForegroundWindow(System.IntPtr hWnd);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern IntPtr GetForegroundWindow();

        public const int GWL_STYLE = -16;
        public const int WS_CHILD = 0x40000000;
        [DllImport("user32", CharSet = CharSet.Auto)]
        public static extern int GetWindowLong(IntPtr hWnd, int index);
        [DllImport("user32", CharSet = CharSet.Auto)]
        public static extern int SetWindowLong(IntPtr hWnd, int index, int value);

        public static Process GetOtherProcess()
        {
            Process hThisProcess = Process.GetCurrentProcess();
            Process[] hProcesses = Process.GetProcessesByName(hThisProcess.ProcessName);
            int iThisProcessId = hThisProcess.Id;
            foreach (Process hProcess in hProcesses)
            {
                if (hProcess.Id != iThisProcessId)
                {
                    return hProcess;
                }
            }
            return null;
        }

        public static void ShowWindow(Process proc)
        {
            ShowWindow(proc.MainWindowHandle, SW_NORMAL);
            SetForegroundWindow(proc.MainWindowHandle);

        }
        public static bool IsTaskbarActive()
        {
            return GetForegroundWindow() == FindWindow("Shell_TrayWnd", null);
        }
    }
}
