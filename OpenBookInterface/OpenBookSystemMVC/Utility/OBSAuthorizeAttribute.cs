using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;

namespace OpenBookSystemMVC
{

    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
    public class OBSAuthorizeAttribute : AuthorizeAttribute
    {
        private bool _isAuthorized;

        public string RedirectUrl = OBSSecurity.RedirectRoute;

        protected override bool AuthorizeCore(System.Web.HttpContextBase httpContext)
        {
            _isAuthorized = base.AuthorizeCore(httpContext);
            return _isAuthorized;
        }

        public override void OnAuthorization(AuthorizationContext filterContext)
        {
            base.OnAuthorization(filterContext);
            if (!_isAuthorized && filterContext.RequestContext.HttpContext.User.Identity.IsAuthenticated)
            {
                filterContext.RequestContext.HttpContext.Response.Redirect(RedirectUrl);
            }
        }
    }
}