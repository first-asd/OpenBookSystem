using OpenBookSystemMVC.Models;
using OpenBookSystemMVC.OBISReference;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace OpenBookSystemMVC.Controllers
{
    public class NotificationsController : Controller
    {

        //public ActionResult List()
        //{
        //    NotificationsModel model = new NotificationsModel();

        //    return View(model);
        //}

        public System.Web.Mvc.ActionResult List(long id = 0)
        {
            NotificationsModel model = new NotificationsModel(id);

            return View(model);
        }

        public System.Web.Mvc.ActionResult MarkNotificationAsRead(long notifId = 0)
        {
            string result = string.Empty;

            result = OBSDataSource.MarkNotificationAsRead(notifId);
            if (string.IsNullOrEmpty(result))
            {
                return Json(new { Success = true });
            }
            else
            {
                return Json(new { Error = result, Success = false });
            }
        }

        public System.Web.Mvc.ActionResult DeleteNotification(long notifId)
        {
            string result = string.Empty;

            result = OBSDataSource.DeleteNotification(notifId);
            if (string.IsNullOrEmpty(result))
            {
                return Json(new { Success = true });
            }
            else
            {
                return Json(new { Error = result, Success = false });
               
            }
        }

        public System.Web.Mvc.ActionResult SendNotification(long docId, long receiverId, string subject, string content)
        {
            string result = string.Empty;
            Notification newNotification = new Notification();
            AccountInfo user = CurrentUser.Details(User.Identity.Name);
            newNotification.DocumentId = docId;
            newNotification.ReceiverId = receiverId;
            newNotification.SenderId = user.AccountId;
            newNotification.Subject = subject;
            newNotification.MessageContent = content;
            newNotification.SentOn = DateTime.Now;

            result = OBSDataSource.SendNotification(newNotification);
            if (string.IsNullOrEmpty(result))
            {
                return Json(new { Success = true });
            }
            else
            {
                return Json(new { Success = false, Error = result });
            }

        }
    }
}
