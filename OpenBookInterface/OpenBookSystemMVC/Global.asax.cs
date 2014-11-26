using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using OpenBookSystemMVC.Models;
using System.Text.RegularExpressions;
using OpenBookSystemMVC.Utility;
using System.IO;

namespace OpenBookSystemMVC
{
    // Note: For instructions on enabling IIS6 or IIS7 classic mode, 
    // visit http://go.microsoft.com/?LinkId=9394801
    public class MvcApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            AppDomain.CurrentDomain.UnhandledException += (sender, error) => File.AppendAllText("App_Data/Fatal.log", error.ExceptionObject.ToString() + "\r\n");
            ResourcesUtility ru = new ResourcesUtility(Server);
            ru.GenerateJSResources();
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
            ModelBinders.Binders.Add(typeof(EditAccountModel), new EditAccountModelBinder());
            //ModelBinders.Binders.Add(typeof(EditAccountModel), new LanguageObjectPreferencesBinder());
            //ModelBinders.Binders.DefaultBinder = new CustomModelBinder();
        }

        protected void Application_BeginRequest(Object sender, EventArgs e)
        {
            if (Request.Cookies["LanguageCookie"] != null)
            {
                string strUserLanguage = Request.Cookies["LanguageCookie"].Value;
                CultureInfo userCulture;

                if (string.IsNullOrEmpty(strUserLanguage))
                {
                    SetDefaultCulture();
                }
                else
                {
                    try
                    {
                        userCulture = new CultureInfo(strUserLanguage);
                        Thread.CurrentThread.CurrentCulture = userCulture;
                        Thread.CurrentThread.CurrentUICulture = userCulture;
                    }
                    catch (CultureNotFoundException)
                    {
                        SetDefaultCulture();
                        //ExceptionLogger.LogException(ex, "Application_BeginRequest");
                    }
                }
            }
            else
            {
                SetDefaultCulture();
            }
        }

        protected void SetDefaultCulture()
        {
            CultureInfo defaultCulture = new CultureInfo(LanguageDefaults.DefaultLanguage);
            Thread.CurrentThread.CurrentCulture = defaultCulture;
            Thread.CurrentThread.CurrentUICulture = defaultCulture;

            HttpCookie langCookie = new HttpCookie("LanguageCookie");
            langCookie.Value = LanguageDefaults.DefaultLanguage;
            langCookie.Expires = DateTime.Now.AddDays(LanguageDefaults.CookieExpirationDays);

            Response.Cookies.Set(langCookie);
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            // file not found - няма да логваме
            if ((this.Server.GetLastError().GetType() == typeof(HttpException)) &&
                Regex.IsMatch(this.Server.GetLastError().Message, "file(.+)exist", RegexOptions.IgnoreCase)) return;
            // запомняме си exception-а, за да го ползваме в страниците за грешки
            Application["Error"] = this.Server.GetLastError().GetBaseException();
            // Log Exception TODO filter based on web config
            //Kodar.Cms.ExceptionLogger.LogException(this.Server.GetLastError().GetBaseException(), this.Request.Url.AbsolutePath);
            ExceptionLogger.LogException(this.Server.GetLastError().GetBaseException(), this.Request.Url.AbsolutePath);
        }

        protected void Session_End(object sender, EventArgs e)
        {
            // Apparently I lose the User object at that point of time, so I can't drop the session
            //ChatHistory.DeleteUserHistory(long.Parse(User.Identity.Name));
        }
    }
}