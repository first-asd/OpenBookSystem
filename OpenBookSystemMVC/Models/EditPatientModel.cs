using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using OpenBookSystemMVC.OBISReference;
using OpenBookSystemMVC.Utility;
using Resources;

namespace OpenBookSystemMVC.Models
{
    
    public class EditPatientModel
    {
        [Required(ErrorMessageResourceName = "Email_Req", ErrorMessageResourceType = typeof(Resources.ClientDefault))]
        [RegularExpression(@"\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*",
            ErrorMessageResourceType = typeof(ClientDefault),
            ErrorMessageResourceName = "SignUp_Invalid_Mail")]
        [Display(Name = "Email", ResourceType = typeof(Resources.ClientDefault))]
        public string Email { get; set; }

        [Required(ErrorMessageResourceName = "First_Name_Req", ErrorMessageResourceType = typeof(Resources.ClientDefault))]
        [Display(Name = "SignUp_First_Name", ResourceType = typeof(Resources.ClientDefault))]
        public string FirstName { get; set; }

        [Required(ErrorMessageResourceName = "Last_Name_Req", ErrorMessageResourceType = typeof(Resources.ClientDefault))]
        [Display(Name = "SignUp_Last_Name", ResourceType = typeof(Resources.ClientDefault))]
        public string LastName { get; set; }

        [Required(ErrorMessageResourceName = "Password_Req", ErrorMessageResourceType = typeof(Resources.ClientDefault))]
        [Display(Name = "SignUp_Password", ResourceType = typeof(Resources.ClientDefault))]
        [DataType(DataType.Password)]
        public string Password { get; set; }

        [System.Web.Mvc.Compare("Password",
            ErrorMessageResourceType = typeof(ClientDefault),
            ErrorMessageResourceName = "EditPatientDetails_Not_Same_Password")]
        [Display(Name = "Rep_Password", ResourceType = typeof(Resources.ClientDefault))]
        [DataType(DataType.Password)]
        public string ConfirmPassword { get; set; }

        [Display(Name = "Telephone", ResourceType = typeof(Resources.ClientDefault))]
        [RegularExpression(@"\d+",
            ErrorMessageResourceType = typeof(ClientDefault),
            ErrorMessageResourceName = "SignUp_Invalid_Phone")]
        public string PhoneNumber { get; set; }

        [AgeValidation(1,100,ErrorMessageResourceName="EditPatientDetails_Age_Invalid",ErrorMessageResourceType=typeof(ClientDefault))]
        [Display(Name = "EditPatientDetails_Age",ResourceType = typeof(ClientDefault))]
        public string Age { get; set; }

        public Gender Gender { get; set; } 

        [ScaffoldColumn(false)] //изобщо не е нужно , но за позьоризъм
        public AccountRoles Role { get; set; }

        [MaxFileSize(FileCategories.Image, ErrorMessageResourceType = typeof(ClientDefault), ErrorMessageResourceName = "FileUpload_FileTooBig")]
        [ImagesOnly(ErrorMessageResourceType = typeof(ClientDefault), ErrorMessageResourceName = "SignUp_Unaccepted_Format")]
        public HttpPostedFileBase ImageFile { get; set; }

        [DataType(DataType.MultilineText)]
        [Display(Name = "EditPatientDetails_Additional_Information", ResourceType = typeof(Resources.ClientDefault))]
        public string AdditionalInformation { get; set; }

        public string Action { get; set; }

        public long CarerID { get; set; }

        public string ImageURL { get; set; }

        public long UserID { get; set; }

        public string DisplayImage()
        {
            if (string.IsNullOrEmpty(ImageURL))
            {
                return "~/Images/profile_photoFrm.png";
            }
            else
            {
                return ImageURL;
            }
        }

        public string SaveButtonLabel { get; set; }

        public EditPatientModel()
        {
            Age = string.Empty;
            Action = "Register";
            ImageURL = string.Empty;
        }
    }
}