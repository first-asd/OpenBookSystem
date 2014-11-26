using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using OpenBookSystemMVC.OBISReference;
using OpenBookSystemMVC.Models;
using Resources;

namespace OpenBookSystemMVC.Controllers
{
    [OBSAuthorize(Roles="Carer")]
    public class UsersController : Controller
    {
        //TODO ERROR
        public System.Web.Mvc.ActionResult List()
        {
            PatientsListModel model = new PatientsListModel();

            string strErrorMessage = string.Empty;

            AccountInfo user = CurrentUser.Details(User.Identity.Name);
            model.CarerTitle = string.Format(ClientDefault.Users_Title, user.FullName());
            List<CarerUser> users;

            string result = OBSDataSource.GetCarerUsersPageList(out users);

            if (string.IsNullOrEmpty(result))
            {
                model.Patients = users;
            }
            else
            {
                //TODO
                ModelState.AddModelError("Model", result);
            }

            return View("List",model);
        }

        public System.Web.Mvc.ActionResult Delete(long userId)
        {
            string result = OBSDataSource.DeleteUserAccount(userId);
            return Json(result, JsonRequestBehavior.AllowGet);
        }

        //public System.Web.Mvc.ActionResult Register()
        //{
        //    EditPatientModel model = new EditPatientModel();
        //    AccountInfo user = CurrentUser.Details(User.Identity.Name);

        //    model.CarerID = user.AccountId;
        //    model.SaveButtonLabel = ClientDefault.Create_Account_C;

        //    return View("Register",model);
        //}

        //[HttpPost]
        //public System.Web.Mvc.ActionResult Register(EditPatientModel model)
        //{
        //    string strErrorMessage = string.Empty;
        //    if (ModelState.IsValid)
        //    {
        //        if (model.ImageFile.IsValidImageFile(out strErrorMessage))
        //        {
        //            AccountInfo newUser = new AccountInfo();
        //            string result = OBSDataSource.CreateUserAccount(ConvertModelToInfo(model), out newUser);

        //            if (string.IsNullOrEmpty(result))
        //            {
        //                return RedirectToAction("List");
        //            }
        //            else
        //            {
        //                ModelState.AddModelError("Model", result);
        //                return View("Register", model);
        //            }
        //        }
        //        else
        //        {
        //            ModelState.AddModelError("Model", strErrorMessage);
        //            return View("Register", model);
        //        }
        //    }
        //    else
        //    {
        //        return View("Register", model);
        //    }
        //}

        //public System.Web.Mvc.ActionResult Edit(string nPatientID)
        //{
        //    string strErrorMessage = string.Empty;
        //    EditPatientModel model = new EditPatientModel();
        //    model.SaveButtonLabel = ClientDefault.EditPatientDetails_Update_Account_C;

        //    AccountInfo user = null;
        //    string result = OBSDataSource.GetUserProfile(long.Parse(nPatientID), out user);
        //    if (string.IsNullOrEmpty(result) && (user != null))
        //    {
        //        model.Action = "Edit";
        //        model.AdditionalInformation = user.AdditionalInfo;
        //        model.Age = user.Age.ToString();
        //        model.CarerID = CurrentUser.Details(User.Identity.Name).AccountId;
        //        model.Role = AccountRoles.User;
        //        model.Gender = (Gender)Enum.Parse(typeof(Gender), user.Gender.ToString());
        //        model.FirstName = user.FirstName;
        //        model.LastName = user.LastName;
        //        model.ImageURL = user.ImgURL;
        //        model.Email = user.Email;
        //        model.UserID = user.AccountId;
        //        model.PhoneNumber = user.PhoneNumber;
        //        model.Password = user.Password;

        //        return View("Register", model);
        //    }
        //    else
        //    {
        //        ModelState.AddModelError("Model", result);
        //        return RedirectToAction("List");
        //    }
        //}

        //[HttpPost]
        //public System.Web.Mvc.ActionResult Edit(EditPatientModel model)
        //{
        //    string strErrorMessage = string.Empty;
        //    if (ModelState.IsValid)
        //    {
        //        if (model.ImageFile.IsValidImageFile(out strErrorMessage))
        //        {
        //            string result = OBSDataSource.UpdateUserAccount(ConvertModelToInfo(model));
        //            if (string.IsNullOrEmpty(result))
        //                return RedirectToAction("List");
        //            else
        //            {
        //                ModelState.AddModelError("Model", result);
        //                return View("Register", model);
        //            }
        //        }
        //        else
        //        {
        //            ModelState.AddModelError("Model", strErrorMessage);
        //            return View("Register", model);
        //        }
        //    }
        //    else
        //    {
        //        return View("Register", model);
        //    }
        //}

        //private AccountInfo ConvertModelToInfo(EditPatientModel model)
        //{
        //    AccountInfo user = new AccountInfo();
        //    user.AdditionalInfo = model.AdditionalInformation;

        //    int _nValue = 0;
        //    if (!string.IsNullOrEmpty(model.Age))
        //    {
        //        int.TryParse(model.Age, out _nValue);
        //    }
        //    user.Age = _nValue;
        //    user.CarerId = model.CarerID;
        //    user.PhoneNumber = model.PhoneNumber;
        //    user.Email = model.Email;
        //    user.FirstName = model.FirstName;
        //    user.LastName = model.LastName;
        //    user.Password = model.Password;
        //    user.Picture = model.ImageFile.ToUserImage();
        //    user.Role = AccountRoles.User;
        //    user.Gender = model.Gender;
        //    user.AccountId = model.UserID;
        //    return user;
        //}

    }
}
