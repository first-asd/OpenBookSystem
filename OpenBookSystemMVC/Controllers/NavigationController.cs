using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web.UI;
using OpenBookSystemMVC.OBISReference;
using OpenBookSystemMVC.Models;
using Resources;
using System.Web.Security;

namespace OpenBookSystemMVC.Controllers
{
    public class NavigationController : Controller
    {
        private static MenuItem Separator { 
            get {
                return new MenuItem { 
                    IconUrl = "/Images/Separator.png", 
                    IsSeparator = true, 
                    Label = string.Empty, 
                    Route = string.Empty };
            } 
        }

        [AllowAnonymous]
        public System.Web.Mvc.ActionResult Menu()
        {
            OBISMenu menuModel = new OBISMenu();
            List<MenuItem> menuItems = new List<MenuItem>();
            if (!User.Identity.IsAuthenticated)
            {
                menuModel.IsUnAuthorizedUser = true;
                MenuItem enItem = new MenuItem { IsSelected = false, IconUrl = "/Images/flag_en.png", Label = "English", Route = "/en"};
                MenuItem bgItem = new MenuItem {IsSelected = false, IconUrl = "/Images/flag_bg.png", Label = "Български", Route = "/bg" };
                MenuItem esItem = new MenuItem { IsSelected = false, IconUrl = "/Images/flag_es.png", Label = "Español", Route = "/es" };

                string strLangToken = Request.RequestContext.RouteData.Values["LanguageToken"] == null ? string.Empty : Request.RequestContext.RouteData.Values["LanguageToken"].ToString();

                if (string.IsNullOrEmpty(strLangToken))
                {
                    strLangToken = Request.Cookies["LanguageCookie"] == null ? LanguageDefaults.DefaultLanguage : Request.Cookies["LanguageCookie"].Value;
                }
                
                if(strLangToken == "bg") 
                {
                    bgItem.IsSelected = true;
                }
                else if (strLangToken == "es")
                {
                    esItem.IsSelected = true;
                }
                else if (strLangToken == "en")
                {
                    enItem.IsSelected = true;
                }
                else
                {
                    enItem.IsSelected = true;
                }

                menuModel.Items.Add(esItem);
                menuModel.Items.Add(enItem);
                menuModel.Items.Add(bgItem);
            }
            else
            {
                if (Request.Path.Contains("Help"))
                {
                    //If it is a help page - no menu bar is displayed
                    menuModel.IsUnAuthorizedUser = false;
                    menuModel.Items = new List<MenuItem>();
                }
                else 
                {
                    if (User.IsInRole(AccountRoles.User.ToString()))
                    {
                        menuModel.Items = InitPatientMenuItems(menuItems); ;
                        menuModel.HelpPage = GetHelpPageRoute();
                        menuModel.IsUnAuthorizedUser = false;
                    }
                    else if (User.IsInRole(AccountRoles.Carer.ToString()))
                    {
                        menuModel.Items = InitCarerMenuItems(menuItems);
                        menuModel.HelpPage = GetHelpPageRoute();
                        menuModel.IsUnAuthorizedUser = false;
                    }
                    else
                    {

                        // Sometimes ASP.NET forms authentication membership session user is logged in, 
                        // however his information is missing from the cache and he has no Role , which causes empty menu.
                        FormsAuthentication.SignOut();
                        OBSDataSource.Logout();
                        return RedirectToAction("Home", "Master");
                    } 
                }
            }
            return View(menuModel);
        }

        private List<MenuItem> InitCarerMenuItems(List<MenuItem> menuItems)
        {
            AccountInfo user = CurrentUser.Details(User.Identity.Name);

            //MenuItem itemDocuments = new MenuItem();
            //itemDocuments.IconUrl = "/Images/docsIcon.png";
            //itemDocuments.Hint = LabelNames.GetDocumentsButtonName(user.FirstName);
            //itemDocuments.Label = ClientDefault.SiteMaster_Documents;
            //itemDocuments.Route = "/Documents/List";

            MenuItem itemMyAccount = new MenuItem();
            itemMyAccount.IconUrl = "/Images/profileIcon.png";
            itemMyAccount.Label = ClientDefault.SiteMaster_My_Account;
            itemMyAccount.Hint = LabelNames.GetAccountButtonName(user.FirstName);
            itemMyAccount.Route = string.Format("/Account/Edit?nUserID={0}",User.Identity.Name);

            MenuItem itemSignOut = new MenuItem();
            itemSignOut.IconUrl = "/Images/logOutIcon.png";
            itemSignOut.Label = ClientDefault.SiteMaster_Log_Out;
            itemSignOut.Route = "/SignOut";

            MenuItem itemPatients = new MenuItem();
            itemPatients.IconUrl = "/Images/patientsIcon.png";
            itemPatients.Label = ClientDefault.SiteMaster_Patients;
            itemPatients.Route = "/Users/List";
            itemPatients.Hint = LabelNames.GetPatientsButtonName(user.FirstName);

            MenuItem itemNotifications = new MenuItem();
            itemNotifications.IconUrl = "/Images/site.master/NotificationIcon.png";
            itemNotifications.Label = ClientDefault.SiteMaster_Notifications;
            itemNotifications.Route = "/Notifications/List";

            //MenuItem itemHelp = new MenuItem();
            //itemHelp.IconUrl = "/Images/site.master/HelpIcon.png";
            //itemHelp.Label = ClientDefault.SiteMaster_Help;
            //itemHelp.Attributes = "onclick=showHelpDialog();";

            MenuItem itemWhatsNew = new MenuItem();
            //itemHelp.IconUrl = "/Images/site.master/HelpIcon.png";
            itemWhatsNew.Label = ClientDefault.SiteMaster_WhatIsNew;
            itemWhatsNew.Attributes = "class='icon-lightbulb'";
            itemWhatsNew.Route = "/WhatIsNew";



            //if (Request.Url.AbsolutePath.Contains("Documents"))
            //{
            //    itemDocuments.IsSelected = true;
            //}
            //else 
            if (Request.Url.AbsolutePath.Contains("Account"))
            {
                if (Request.Url.AbsolutePath.Contains("Account/Create"))
                {
                    itemPatients.IsSelected = true; 
                }
                else if (HttpContext.Request.QueryString["nUserID"] != null)
                {
                    long nUserID = long.Parse(HttpContext.Request.QueryString["nUserID"]);
                    if (nUserID != user.AccountId)
                    {
                        itemPatients.IsSelected = true;
                    }
                    else
                    {
                        itemMyAccount.IsSelected = true;
                    }
                }
                else
                {
                    itemMyAccount.IsSelected = true;
                }
            }
            else if (Request.Url.AbsolutePath.Contains("Users"))
            {
                itemPatients.IsSelected = true;
            }

            menuItems.Add(itemSignOut);
            menuItems.Add(Separator);
            menuItems.Add(itemMyAccount);
            menuItems.Add(Separator);
            //menuItems.Add(itemDocuments);
            //menuItems.Add(Separator);
            menuItems.Add(itemNotifications);
            menuItems.Add(Separator);
            menuItems.Add(itemPatients);
            menuItems.Add(Separator);
            //menuItems.Add(itemHelp);
            menuItems.Add(Separator);
            menuItems.Add(itemWhatsNew);
            return menuItems;
        }

        private List<MenuItem> InitPatientMenuItems(List<MenuItem> menuItems)
        {
            AccountInfo user = CurrentUser.Details(User.Identity.Name);

            MenuItem itemDocuments = new MenuItem();
            itemDocuments.IconUrl = "/Images/docsIcon.png";
            itemDocuments.Hint = LabelNames.GetDocumentsButtonName(user.FirstName);
            itemDocuments.Label = ClientDefault.SiteMaster_Documents;
            itemDocuments.Route = "/Documents/List";

            MenuItem itemMyAccount = new MenuItem();
            itemMyAccount.IconUrl = "/Images/profileIcon.png";
            itemMyAccount.Label = ClientDefault.SiteMaster_My_Account;
            itemMyAccount.Hint = LabelNames.GetAccountButtonName(user.FirstName);
            itemMyAccount.Route = string.Format("/Account/Edit?nUserID={0}", User.Identity.Name);

            MenuItem itemSignOut = new MenuItem();
            itemSignOut.IconUrl = "/Images/logOutIcon.png";
            itemSignOut.Label = ClientDefault.SiteMaster_Log_Out;
            itemSignOut.Route = "/SignOut";

            MenuItem itemNotifications = new MenuItem();
            itemNotifications.IconUrl = "/Images/site.master/NotificationIcon.png";
            itemNotifications.Label = ClientDefault.SiteMaster_Notifications;
            itemNotifications.Route = "/Notifications/List";

            //MenuItem itemHelp = new MenuItem();
            //itemHelp.IconUrl = "/Images/site.master/HelpIcon.png";
            //itemHelp.Label = ClientDefault.SiteMaster_Help;
            //itemHelp.Attributes = "onclick=showHelpDialog();";

            if (Request.Url.AbsolutePath.Contains("Documents"))
            {
                itemDocuments.IsSelected = true;
            }
            else if (Request.Url.AbsolutePath.Contains("Account"))
            {
                itemMyAccount.IsSelected = true;
            }

            menuItems.Add(itemSignOut);
            menuItems.Add(Separator);
            menuItems.Add(itemMyAccount);                                   
            menuItems.Add(Separator);
            menuItems.Add(itemDocuments);
            if (user.CarerId != 0)
            {
                menuItems.Add(Separator);
                menuItems.Add(itemNotifications); 
            }
            menuItems.Add(Separator);
            //menuItems.Add(itemHelp);

            return menuItems;
        }

        private string GetHelpPageRoute()
        {
            string strResult = string.Empty;
            if (Request.Path.Contains("Notifications"))
            {
                strResult = HelpPages.Notifications;
            }
            else if (Request.Path.Contains("Documents/List"))
            {
                strResult = HelpPages.Library;
            }
            else if (Request.Path.Contains("Documents/Edit"))
            {
                strResult = HelpPages.DocumentRead;
            }
            else if (Request.Path.Contains("Account"))
            {
                strResult = HelpPages.Account;
            }
            else if (Request.Path.Contains("Documents/New"))
            {
                strResult = HelpPages.DocumentNew;
            }
            else if (Request.Path.Contains("GetExplanation"))
            {
                strResult = HelpPages.WordExplanations;
            }
            else if (Request.Path.Contains("GetTest"))
            {
                strResult = HelpPages.Tests;
            }
            else if (Request.Path.Contains("Users/List"))
            {
                strResult = HelpPages.UsersList;
            }
            else if (Request.Path.Contains("Documents/UserList"))
            {
                strResult = HelpPages.CarerLibrary;
            }
            else if (Request.Path.Contains("DocumentReview"))
            {
                strResult = HelpPages.DocumentReview;
            }

            return strResult;
        }
    }
}
