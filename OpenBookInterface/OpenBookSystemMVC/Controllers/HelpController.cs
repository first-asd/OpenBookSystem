using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace OpenBookSystemMVC.Controllers
{
    public class HelpController : Controller
    {
        //
        // GET: /Help/

        public ActionResult ShowHelp(string strHelpPage)
        {
            if (strHelpPage == HelpPages.Account)
            {
                return View("HelpAccount");
            }
            else if (strHelpPage == HelpPages.DocumentNew)
            {
                return View("HelpDocumentNew");
            }
            else if (strHelpPage == HelpPages.DocumentRead)
            {
                return View("HelpDocumentRead");
            }
            else if (strHelpPage == HelpPages.Library)
            {
                return View("HelpLibrary");
            }
            else if (strHelpPage == HelpPages.Notifications)
            {
                return View("HelpNotifications");
            }
            else if (strHelpPage == HelpPages.WordExplanations)
            {
                return View("HelpWordExplanations");
            }
            else if (strHelpPage == HelpPages.Tests)
            {
                return View("HelpTests");
            }
            else if (strHelpPage == HelpPages.UsersList)
            {
                return View("HelpUsersList");
            }
            else if (strHelpPage == HelpPages.CarerLibrary)
            {
                return View("HelpCarerLibrary");
            }
            else if (strHelpPage == HelpPages.DocumentReview)
            {
                return View("HelpDocumentReview");
            }

            return View();
        }

    }
}
