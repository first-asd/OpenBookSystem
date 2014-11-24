using Newtonsoft.Json;
using OpenBookSystemMVC.OBISReference;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace OpenBookSystemMVC.Controllers
{
    public class ChatController : Controller
    {
        public System.Web.Mvc.ActionResult SendMessage(string msgContent, long senderId, long receiverId)
        {
            AccountInfo senderInfo = new AccountInfo();
            AccountInfo receiverInfo = new AccountInfo();
            OBSDataSource.GetUserProfile(senderId, out senderInfo);
            OBSDataSource.GetUserProfile(receiverId, out receiverInfo);


            ChatMessage message = new ChatMessage();
            message.Message = msgContent;
            message.SenderId = senderId;
            message.SenderName = senderInfo.FirstName;
            message.ReceiverId = receiverId;
            message.ReceiverName = receiverInfo.FirstName;
            message.SentTime = DateTime.Now;

            ChatHistory.SaveNewMessage(message);

            return Json(JsonConvert.SerializeObject(new { Success = true }),JsonRequestBehavior.AllowGet);
        }

        public System.Web.Mvc.ActionResult LoadChatData()
        {
            if (User.Identity.IsAuthenticated)
            {
                AccountInfo info = CurrentUser.Details(User.Identity.Name);

                return Json(
                    new
                    {
                        UserId = info.AccountId,
                        CarerId = info.CarerId,
                        FirstName = info.FirstName,
                        UserRole = info.Role.ToString(),
                        MessageHistory = ChatHistory.GetUserHistory(info.AccountId)
                    }, JsonRequestBehavior.AllowGet);
            }
            else
            {
                return Json(string.Empty, JsonRequestBehavior.AllowGet);
            }
        }

    }
}
