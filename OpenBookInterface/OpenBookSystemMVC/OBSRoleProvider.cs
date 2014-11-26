using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using OpenBookSystemMVC.OBISReference;

namespace OpenBookSystemMVC
{
    public class OBSRoleProvider : RoleProvider
    {
        public override void AddUsersToRoles(string[] usernames, string[] roleNames)
        {
            throw new NotImplementedException();
        }

        public override string ApplicationName
        {
            get
            {
                throw new NotImplementedException();
            }
            set
            {
                throw new NotImplementedException();
            }
        }

        public override void CreateRole(string roleName)
        {
            throw new NotImplementedException();
        }

        public override bool DeleteRole(string roleName, bool throwOnPopulatedRole)
        {
            throw new NotImplementedException();
        }

        public override string[] FindUsersInRole(string roleName, string usernameToMatch)
        {
            throw new NotImplementedException();
        }

        public override string[] GetAllRoles()
        {
            return new string[] { AccountRoles.User.ToString(), AccountRoles.Carer.ToString(), AccountRoles.Administrator.ToString() };
        }

        public override string[] GetRolesForUser(string username)
        {
            string[] strArr = new string[1];
            strArr[0] = GetUserRole(username).ToString();
            return strArr;
        }

        public override string[] GetUsersInRole(string roleName)
        {
            throw new NotImplementedException();
        }

        public override bool IsUserInRole(string username, string roleName)
        {
            bool result = false;
            string[] roles = GetRolesForUser(username);
            result = roles != null && roles[0] == roleName;
            return result;
        }

        public override void RemoveUsersFromRoles(string[] usernames, string[] roleNames)
        {
            throw new NotImplementedException();
        }

        public override bool RoleExists(string roleName)
        {
            throw new NotImplementedException();
        }

        public static AccountRoles GetUserRole(string strUserName)
        {
            AccountInfo user = new AccountInfo();
            try
            {
                 user = CurrentUser.Details(strUserName);
            }
            catch (Exception)
            {
                FormsAuthentication.SignOut();
                HttpContext.Current.Items["loggedOut"] = true;
                HttpContext.Current.Response.RedirectToRoute("SignOut", null);
                
            }
            if (user != null)
            {
                return user.Role;
            }
            else
            {                
                string result = OBSDataSource.GetUserProfile(long.Parse(strUserName), out user);

                if (string.IsNullOrEmpty(result))
                {
                    CurrentUser.CacheUser(user);
                    return CurrentUser.Details(strUserName).Role;
                }
                else
                {
                    //TODO 
                    return AccountRoles.User;
                }
            }

        }
    }
}