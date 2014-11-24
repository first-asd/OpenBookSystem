using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using OpenBookSystemMVC.OBISReference;

namespace OpenBookSystemMVC.Models
{
    public class NotAuthorizedModel
    {
        private string _headBackRoute = string.Empty;

        public string HeadBackRoute { get { return _headBackRoute; } }

        public NotAuthorizedModel()
        {
            
        }                

        public NotAuthorizedModel(AccountRoles userRole)
        {
            if (userRole == AccountRoles.Carer)
            {
                _headBackRoute = OBSSecurity.CarerHeadBackRoute;
            }
            else if (userRole == AccountRoles.User)
            {
                _headBackRoute = OBSSecurity.UserHeadBackRoute;
            }
        }
    }
}