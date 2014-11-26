using OpenBookSystemMVC.OBISReference;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;

namespace OpenBookSystemMVC.ActionFilters
{
    public class CustomAuthenticationFilter : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            filterContext.HttpContext.Items["loggedOut"] = false;
            if (filterContext.HttpContext.User.Identity.IsAuthenticated
                && (filterContext.HttpContext.Session == null
                || filterContext.HttpContext.Session["logged"] == null
                || (bool)filterContext.HttpContext.Session["logged"] != true))
            {
                AccountInfo user = (AccountInfo)filterContext.HttpContext.Session["UserAccountInfo"];

                if (user != null)
                {
                    OBSDataSource.Login(user.Email, user.Password);
                    filterContext.HttpContext.Session["logged"] = true;
                }
                else
                {
                    FormsAuthentication.SignOut();
                    filterContext.HttpContext.Items["loggedOut"] = true;
                    filterContext.Result = new RedirectToRouteResult("SignOut", null);
                    //OBSDataSource.Logout();
                    //ChatHistory.DeleteUserHistory(long.Parse(HttpContext.Current.User.Identity.Name));
                }
            }

            base.OnActionExecuting(filterContext);
        }
    }
}