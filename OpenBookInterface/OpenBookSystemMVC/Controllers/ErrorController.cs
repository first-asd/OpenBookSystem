using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace OpenBookSystemMVC.Controllers
{
    [AllowAnonymous]
    public class ErrorController : Controller
    {
        public ActionResult BrowserNotSupported()
        {
            return View("UnsupportedBrowser");
        }

        public ActionResult ServerError()
        {
            return View("GeneralError");
        }
    }
}
