using OpenBookSystemMVC.Models;
using OpenBookSystemMVC.OBISReference;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Mvc;

namespace OpenBookSystemMVC.Controllers
{
    public class TestController : Controller
    {
        public System.Web.Mvc.ActionResult GetExplanations(long documentId)
        {
            AccountInfo user = CurrentUser.Details(User.Identity.Name);
            OBSDataSource.MarkDocumentAsRead(documentId);

            if (user.CarerId == 0)
            {
                return RedirectToAction("Edit", "Documents", new { nDocID = documentId });
                //return RedirectToAction("/Documents/Edit?nDocID={0}", documentId);
            }
            else
            {
                TestModel model = FillModel(documentId);

                if (model == null)
                {
                    return RedirectToAction("List", "Documents");
                }
                return View(model);
            }
        }

        public System.Web.Mvc.ActionResult GetTest(long documentId)
        {
            TestModel model = FillModel(documentId);

            if (model == null)
            {
                return RedirectToAction("List", "Documents");
            }
            model.document.IsCompleted = true;
            long docId = 0;
            string result = OBSDataSource.SaveDocument(model.document, out docId);
            if (!String.IsNullOrEmpty(result))
            {
                return RedirectToAction("List", "Documents");
            }

            return View(model);
        }

        public System.Web.Mvc.ActionResult LoadQuestions(long documentId)
        {
            Test test = null;
            var dict = new Dictionary<string, List<string>>();

            string result = OBSDataSource.GetDocumentTest(documentId, out test);
            if (String.IsNullOrEmpty(result))
            {
                var questions = test.Questions.OrderBy(x => x.OrderIndex).ToList();

                //TODO: Remove hardcoded
                if (System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName == "en")
                {
                    questions = questions.Where(x => x.Id <= 2).ToList();
                }
                else if (Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName == "bg")
                {
                    questions = questions.Where(x => x.Id > 2).ToList();
                }

                return Json(questions);
            }
            else
            {
                return Json(string.Empty);
            }

        }

        public System.Web.Mvc.ActionResult SubmitTestAnswer(long answerId)
        {
            string result = OBSDataSource.SubmitTestAnswer(answerId);
            if (String.IsNullOrEmpty(result))
            {
                return Json(new { success = true });
            }
            else
            {
                return Json(new { success = false });
            }
        }

        private TestModel FillModel(long documentId)
        {
            //load document
            Document doc = null;
            string result = OBSDataSource.GetDocument(documentId, out doc);

            if (!String.IsNullOrEmpty(result))
            {
                return null;
            }

            return new TestModel(doc);
        }
    }
}
