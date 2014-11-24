using OpenBookSystemMVC.OBISReference;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Newtonsoft.Json;

namespace OpenBookSystemMVC.Models
{
    public class NotificationsModel
    {
        public string JsonData { get; set; }

        public string Error { get; set; }

        public NotificationsModel(long userid) {
            AccountInfo currentUser = CurrentUser.Details(HttpContext.Current.User.Identity.Name);
            List<Notification> notifications = new List<Notification>();
            List<AccountInfo> users = new List<AccountInfo>();
            string result = OBSDataSource.GetUserNotifications(out notifications);
            if (string.IsNullOrEmpty(result))
            {
                if (currentUser.Role == AccountRoles.Carer)
                {
                    result = OBSDataSource.GetCarerPatients(out users);
                    if (string.IsNullOrEmpty(result))
                    {

                    }
                    else
                    {
                        Error = result;
                    }
                }
                else if (currentUser.Role == AccountRoles.User)
                {
                    AccountInfo carerAccount = new AccountInfo();
                    result = OBSDataSource.GetUserProfile(currentUser.CarerId, out carerAccount);
                    if (string.IsNullOrEmpty(result))
                    {
                        users.Add(carerAccount);
                    }
                    else
                    {
                        Error = result;
                    }

                }
                
            }
            else
            {
                Error = result;
            }

            JsonData = JsonConvert.SerializeObject(new
            {
                IsCarer = currentUser.Role == AccountRoles.Carer,
                CurrentUserId = userid,
                Users = users.Select(x => new { 
                    Id = x.AccountId,
                    UserName = x.FullName()
                }),
                Notifications = notifications.Select(x => new
                {
                    Id = x.Id,
                    InternalDateText = x.SentOn.ToString("dd/MM/yyyy HH:mm:ss"),
                    Subject = x.Subject,
                    DocumentTitle = x.DocumentTitle,
                    DocumentId = x.DocumentId,
                    Content = x.MessageContent,
                    IsRead = x.IsRead,
                    SenderId = x.SenderId
                })
            });

        }
    }
}