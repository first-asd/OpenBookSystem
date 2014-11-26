using System.Web;
using System.Web.Mvc;

namespace OpenBookSystemMVC
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
            filters.Add(new AuthorizeAttribute());
            filters.Add(new OpenBookSystemMVC.ActionFilters.CustomAuthenticationFilter());
        }
    }
}