using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.UI;
using OpenBookSystemMVC.OBISReference;
using OpenBookSystemMVC.Models;


namespace OpenBookSystemMVC.Controllers
{
    public class AccountController : Controller
    {

        public System.Web.Mvc.ActionResult Edit(string nUserID)
        {
            EditAccountModel model = new EditAccountModel(nUserID);
            model.IsUpdate = true;
            if (!string.IsNullOrEmpty(model.Error))
            {
                ModelState.AddModelError("Model", model.Error);
            }
            return View("Edit", model);
        }

        [HttpPost]
        public System.Web.Mvc.ActionResult Edit(EditAccountModel model)
        {
            string result = string.Empty;

            if (ModelState.IsValid)
            {

                if (model.ImageFile.IsValidImageFile(out result))
                {
                    model.User.Picture = model.ImageFile.ToUserImage();
                }

                if (model.User.AccountId == 0)
                {
                    AccountInfo info = new AccountInfo();
                    result = OBSDataSource.CreateUserAccount(model.User, out info);
                    if (string.IsNullOrEmpty(result))
                    {
                        return RedirectToAction("List", "Users");
                    }
                    else
                    {
                        ModelState.AddModelError("Model", result);
                        return View("Edit", model);
                    }
                }
                else
                {
                    AccountInfo backupUser = new AccountInfo();
                    result = OBSDataSource.UpdateUserAccount(model.User);
                    if (string.IsNullOrEmpty(result))
                    {
                        if (CurrentUser.Details(User.Identity.Name).Role == AccountRoles.User)
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
                        ModelState.AddModelError("Model", result);
                        AccountInfo currentEditUser = new AccountInfo();

                        OBSDataSource.GetUserProfile(model.User.AccountId, out currentEditUser);

                        if (model.User == null)
                        {
                            model.User = backupUser;
                            model.User.Preferences = new UserPreferences();
                            model.User.Preferences.LanguagePreferences = new List<LanguagePreference>().ToArray();
                            model.User.Preferences.SelectedDocumentSimplificationTools = Constants.DefaultSimplificationTools;

                        }
                        else
                        {
                            model.User.Preferences.LanguagePreferences = currentEditUser.Preferences.LanguagePreferences;
                        }

                        return View("Edit", model);
                    }
                }
            }
            else
                return View("Edit", model);
        }

        [OBSAuthorize(Roles = "Carer")]
        public System.Web.Mvc.ActionResult Create()
        {
            EditAccountModel model = new EditAccountModel();
            return View("Edit", model);
        }

        [HttpPost]
        public long CreateTheme(string bgColor, string fColor, string hColor, string mColor, int userId)
        {
            long themeId = 0;
            string result = string.Empty;
            try
            {
                Theme theme = new Theme()
                {
                    UserId = userId,
                    BackgroundColor = System.Drawing.ColorTranslator.FromHtml(String.Format("{0}", bgColor)),
                    HighlightColor = System.Drawing.ColorTranslator.FromHtml(String.Format("{0}", hColor)),
                    FontColor = System.Drawing.ColorTranslator.FromHtml(String.Format("{0}", fColor)),
                    MagnificationColor = System.Drawing.ColorTranslator.FromHtml(String.Format("{0}", mColor))
                };

                result = OBSDataSource.CreateTheme(theme, out themeId);
                if (string.IsNullOrEmpty(result))
                {
                    return themeId;
                }
            }
            catch (Exception ex)
            {
                ExceptionLogger.LogException(ex, "AccountController.CreateTheme");
            }
            return 0;
        }

        [AllowAnonymous]
        [HttpPost]
        public JsonResult UploadImage(int account_id)
        {


            return null;
        }
    }    
}
