using System;
using System.Collections.Generic;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using OpenBookSystemMVC.OBISReference;
using OpenBookSystemMVC.Models;
using Resources;
using OpenBookSystemMVC.Utility;
using System.IO;
using System.Net.Mail;
using System.Text;
using System.Configuration;

namespace OpenBookSystemMVC.Controllers
{
    public class MasterController : Controller
    {

        [AllowAnonymous]
        public System.Web.Mvc.ActionResult Home(string LanguageToken)
        {
            SetLanguage(LanguageToken);
            ViewData["ShowHead"] = true;

            if (User.Identity.IsAuthenticated && Session["UserAccountInfo"] == null)
            {
                return RedirectToAction("SignOut");
            }

            if (User.Identity.IsAuthenticated)
            {
                if (User.IsInRole(AccountRoles.Carer.ToString()))
                {
                    return RedirectToAction("List", "Users");
                }
                else if (User.IsInRole(AccountRoles.User.ToString()))
                {
                    return RedirectToAction("New", "Documents");
                }
                else
                {
                    LogInModel logInModel = new LogInModel();
                    return View("LogIn", logInModel);
                }
            }
            else
            {
                LogInModel logInModel = new LogInModel();
                return View("LogIn", logInModel);
            }
        }

        [AllowAnonymous]
        [HttpPost]
        public System.Web.Mvc.ActionResult LogIn(LogInModel loginModel)
        {
            if (ModelState.IsValid)
            {
                if (Membership.ValidateUser(loginModel.UserName, loginModel.Password))
                {
                    ResourcesUtility ru = new ResourcesUtility(Server);
                    ru.GenerateJSResources();

                    //AccountInfo user = HttpContext.Session["UserAccountInfo"] == null ? null : HttpContext.Session["UserAccountInfo"] as AccountInfo;
                    AccountInfo user = CurrentUser.Details();

                    bool isLogged = false;
                    isLogged = HttpContext.Session["UserLogged"] != null && (bool)HttpContext.Session["UserLogged"];

                    if (isLogged)
                    {                        
                        Session.Add("logged", true);
                        FormsAuthentication.SetAuthCookie(user.AccountId.ToString(), loginModel.RememberMe);

                        Session["UserAccountInfo"] = user;

                        //if (loginModel.RememberMe)
                        //{
                        //    HttpContext.Cache.Insert(user.AccountId.ToString(), user, null, System.Web.Caching.Cache.NoAbsoluteExpiration, TimeSpan.FromDays(365));
                        //}
                        //else if (HttpContext.Cache[user.AccountId.ToString()] != null)
                        //{
                        //    HttpContext.Cache.Remove(user.AccountId.ToString());
                        //}
                        HttpContext.Session.Remove("UserLogged");
                    }

                    if (user.Role == AccountRoles.Carer)
                    {
                        return RedirectToAction("List", "Users");
                    }
                    else if (user.Role == AccountRoles.User)
                    {
                        return RedirectToAction("New", "Documents");
                    }
                }
                else
                {
                    ViewData["ShowHead"] = true;
                    ModelState.AddModelError("", ClientDefault.LogIn_Log_In_Failed);
                }
            }

            return View("LogIn", loginModel);
        }

        public System.Web.Mvc.ActionResult SignOut()
        {
            FormsAuthentication.SignOut();
            OBSDataSource.Logout();
            LogInModel loginModel = new LogInModel();
            return RedirectToAction("Home");
        }

        [AllowAnonymous]
        public System.Web.Mvc.ActionResult SignUp(int SignType)
        {
            if (OBSSecurity.SignUpEnabled)
            {
                ViewData["ShowHead"] = true;

                SignUpViewModel model = new SignUpViewModel();

                if (SignType == 1)
                {
                    model = new SignUpViewModel(AccountRoles.User);
                    return View("SignUp", model);
                }
                else if (SignType == 2)
                {
                    model = new SignUpViewModel(AccountRoles.Carer);
                    return View("SignUp", model);
                } 
            }

            return RedirectToAction("Home");
        }

        protected void SetLanguage(string LangToken)
        {
            if (!string.IsNullOrEmpty(LangToken))
            {
                CultureInfo userCulture;
                try
                {
                    userCulture = new CultureInfo(LangToken);
                    Thread.CurrentThread.CurrentCulture = userCulture;
                    Thread.CurrentThread.CurrentUICulture = userCulture;

                    HttpCookie langCookie = new HttpCookie("LanguageCookie");
                    langCookie.Value = userCulture.Name;
                    langCookie.Expires = DateTime.Now.AddDays(LanguageDefaults.CookieExpirationDays);

                    Response.Cookies.Set(langCookie);
                }
                catch (CultureNotFoundException e)
                {
                    //Nothing to do ... someone's messing with the URL, /careface anyway.
                    ExceptionLogger.LogException(e, "MasterController.SetLanguage");
                }
            }
        }

        [HttpPost]
        [AllowAnonymous]
        public System.Web.Mvc.ActionResult SignUp(SignUpViewModel model)
        {
            if (OBSSecurity.SignUpEnabled)
            {
                if (ModelState.IsValid)
                {
                    string strErrorMessage = string.Empty;
                    if (model.ImageFile.IsValidImageFile(out strErrorMessage))
                    {
                        AccountInfo newUser = new AccountInfo();
                        int _nValue = 0;

                        newUser.Email = model.Email;
                        newUser.FirstName = model.FirstName;
                        newUser.LastName = model.LastName;
                        newUser.Password = model.Password;
                        newUser.PhoneNumber = model.PhoneNumber;
                        if (!string.IsNullOrEmpty(model.Age))
                        {
                            int.TryParse(model.Age, out _nValue);
                        }
                        newUser.Age = _nValue;

                        if (model.ImageFile.HasImageFile())
                        {
                            newUser.Picture = new UserImage();
                            newUser.Picture = model.ImageFile.ToUserImage();
                        }

                        if (model.Role == AccountRoles.User)
                        {
                            newUser.Role = AccountRoles.User;
                        }
                        else if (model.Role == AccountRoles.Carer)
                        {
                            newUser.Role = AccountRoles.Carer;
                        }

                        UserPreferences prefs = new UserPreferences();
                        prefs.DocumentFontSize = Constants.DefaultDocumentFontSize;
                        prefs.DocumentFontName = Constants.DefaultDocumentFontName;
                        newUser.Preferences = prefs;
                        newUser.Preferences.SelectedDocumentSimplificationTools = Constants.DefaultSimplificationTools;
                        newUser.Preferences.LineSpacing = Constants.DefaultLineSpacing;

                        string result = OBSDataSource.RegisterUserAccount(newUser);
                        if (string.IsNullOrEmpty(result))
                        {
                            return View("CheckEmail");
                        }
                        else
                        {
                            //TODO SHOW INFO
                            ModelState.AddModelError(string.Empty, result);
                            return View("SignUp", model);
                        }
                    }
                    else
                    {
                        ModelState.AddModelError(string.Empty, strErrorMessage);
                        return View("SignUp", model);
                    }
                }
                else
                {
                    return View("SignUp", model);
                }
            }
            else
            {
                return RedirectToAction("Home");
            }
        }

        [AllowAnonymous]
        public System.Web.Mvc.ActionResult ActivateAccount(Guid mailedGuid)
        {
            string result = OBSDataSource.ActivateUserAccount(mailedGuid);
            return RedirectToAction("Home");
        }

        public System.Web.Mvc.ActionResult NotAuthorized()
        {
            NotAuthorizedModel model = new NotAuthorizedModel(OBSRoleProvider.GetUserRole(User.Identity.Name));
            return View();
        }
        
        public System.Web.Mvc.FileResult GetUserImage(long userId)
        {
            UserImage image = new UserImage();
            string result = OBSDataSource.GetUserImage(userId, out image);
            if (string.IsNullOrEmpty(result) && image != null)
            {
                return new FileContentResult(image.FileContent, image.ContentType);
            }
            else
            {
                return new FilePathResult(Server.MapPath("/Images/patientFrame.png"),"image/png");
            }
        }

        [HttpPost]
        public System.Web.Mvc.ActionResult SubmitFeedback(string feedbackMessage) 
        {
            if (string.IsNullOrWhiteSpace(feedbackMessage))
            {
                return Json(new {
                    Error = ClientDefault.Feedback_ErrorEmpty
                });
            }
            else
            {
                AccountInfo user = CurrentUser.Details(User.Identity.Name);
                try
                {
                    SmtpClient smtp = new SmtpClient();
                    MailMessage message = MailHelpers.CreateMailMessage(ConfigurationManager.AppSettings["FeedbackRecepient"], false);
                    message.Subject = "System Feedback";
                    message.Body = string.Format("User ID:{0} {1}{1} User Name:{2} {1}{1} Feedback Message: {3}", user.AccountId, Environment.NewLine, user.FullName(), feedbackMessage);

                    smtp.Send(message);

                    return Json(new { 
                        Success = ClientDefault.Feedback_Success
                    });
                }
                catch (SmtpFailedRecipientsException ex)
                {
                    return Json(new
                    {
                        Error = ClientDefault.Feedback_RecepientError
                    });
                }
                catch (SmtpException ex)
                {
                    return Json(new
                    {
                        Error = ClientDefault.Feedback_SMTPError
                    });
                }
            }            
        }

        [AllowAnonymous]
        public System.Web.Mvc.ActionResult RequestPasswordRetrieval()
        {
            if (Request.IsAuthenticated)
            {
                if (User.IsInRole("Carer"))
                {
                    return RedirectToAction("List", "Users");
                }
                else if (User.IsInRole("User"))
                {
                    return RedirectToAction("List", "Documents");
                }
                else
                {
                    return RedirectToAction("List", "Users");
                }
            }
            else
            {
                return View("RequestPasswordRetrieval", new RequestPasswordRetrievalModel());       
            }
        }

        [AllowAnonymous]
        [HttpPost]
        public System.Web.Mvc.ActionResult RequestPasswordRetrieval(RequestPasswordRetrievalModel model)
        {
            if (Request.IsAuthenticated)
            {
                if (User.IsInRole("Carer"))
                {
                    return RedirectToAction("List", "Users");
                }
                else if (User.IsInRole("User"))
                {
                    return RedirectToAction("List", "Documents");
                }
                else
                {
                    return RedirectToAction("List", "Users");
                }
            }
            else
            {
                string result = OBSDataSource.RequestPasswordRetrieval(model.Email);
                if (string.IsNullOrEmpty(result))
                {
                    return View("PasswordRequestSent");
                }
                else
                {
                    model.ErrorMessage = result;
                    return View("RequestPasswordRetrieval", model);

                }

                
            }            
        }

        public System.Web.Mvc.ActionResult WhatIsNew()
        {
            return View("WhatIsNew");
        }

    }

}