using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace tsoft.NgenUtil
{
    public static class Shared
    {
        public static string QuotePath(this string s)
        {
            return "\"" + s.Trim('\"') + "\"";
        }

        public static string RemoveSeparator(this string s)
        {
            return s.Trim('\"').TrimEnd('\\');
        }
    };
}
