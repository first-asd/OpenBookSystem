using Resources;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Resources;
using System.Text;
using System.Threading;
using System.Web;

namespace OpenBookSystemMVC.Utility
{
    public class ResourcesUtility
    {
        private string JsPath { get; set; }
        //private string ResourcesPath { get; set; }

        public ResourcesUtility(HttpServerUtilityBase server)
        {
            JsPath = server.MapPath(String.Format("~/Scripts/Resources"));
        }

        public ResourcesUtility(HttpServerUtility server)
        {
            JsPath = server.MapPath(String.Format("~/Scripts/Resources"));
        }

        public static string GetCurrentResourceBundle()
        {
            // Assuming the default language is english
            var result = "~/bundles/resourcesEN";
            if (Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName == "es")
            {
                result = "~/bundles/resourcesES";
            }
            else if (Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName == "bg")
            {
                result = "~/bundles/resourcesBG";
            }

            return result;
        }

        public void GenerateJSResources()
        {
            for (int i = 0; i < Enum.GetNames(typeof(Languages)).Length; i++)
            {
                string jsResult = String.Format(
@"(function () {{
    if (typeof window.Localization == 'undefined') window.Localization = {{ }};
    {0}
    {1}
    {2}
}})();",
                GetJsResources(Languages.bg.ToString(), ((Languages)i).ToString()),
                GetJsResources(Languages.en.ToString(), ((Languages)i).ToString()),
                GetJsResources(Languages.es.ToString(), ((Languages)i).ToString()));

                string jsFilePath = Path.Combine(JsPath, String.Format(@"Resources{0}.js", ((Languages)i).ToString().ToUpper()));
                using (System.IO.FileStream stream = new System.IO.FileStream(jsFilePath, System.IO.FileMode.Create))
                {
                    using (System.IO.StreamWriter sw = new System.IO.StreamWriter(stream))
                    {
                        sw.Write(jsResult);
                        sw.Flush();
                    }
                }
            }
        }

        private string GetJsResources(string LanguageAbbreviation, string CurrentLanguage)
        {
            string json = "undefined";
            if (CurrentLanguage == LanguageAbbreviation)
            {
                StringBuilder sb = new StringBuilder();
                string lineEnd = String.Format(",{0}", Environment.NewLine);

                CultureInfo culture = new CultureInfo(CurrentLanguage);
                var resourceSet = ClientDefault.ResourceManager.GetResourceSet(culture, true, true).OfType<DictionaryEntry>().OrderBy(x => x.Key);
                foreach (DictionaryEntry entry in resourceSet)
                {
                    sb.Append(String.Format("\t\t{0}: '{1}'{2}", entry.Key, entry.Value.ToString().Replace("'", @"\'"), lineEnd));
                }
                json = sb.ToString();
                int lastEndLineIndex = json.LastIndexOf(lineEnd);
                if (lastEndLineIndex >= 0)
                {
                    json = json.Remove(lastEndLineIndex, lineEnd.Length);
                }

                json = String.Format("{{{1}{0}{1}\t}}", json, Environment.NewLine);
            }

            string jsSource = String.Format(@"window.Localization.{0}{1} = {2};", "resources", LanguageAbbreviation.ToUpper(), json);
            return jsSource;
        }

        public enum Languages
        {
            en,
            bg,
            es
        }
    }
}