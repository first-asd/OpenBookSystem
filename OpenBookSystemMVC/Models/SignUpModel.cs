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
    public class SignUpViewModel
    {
        [Required(ErrorMessageResourceName = "Email_Req", ErrorMessageResourceType = typeof(Resources.ClientDefault))]
        [RegularExpression(@"\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*", 
            ErrorMessageResourceType=typeof(ClientDefault),
            ErrorMessageResourceName="SignUp_Invalid_Mail")]
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

        [Display(Name = "EditPatientDetails_Age", ResourceType = typeof(Resources.ClientDefault))]
        [AgeValidation( 1, 100,ErrorMessageResourceName="EditPatientDetails_Age_Invalid",ErrorMessageResourceType = typeof(Resources.ClientDefault))]
        public string Age { get; set; }

        [Display(Name = "EditPatientDetails_Gender", ResourceType = typeof(Resources.ClientDefault))]
        
        public Gender Gender { get; set; }

        [System.Web.Mvc.Compare("Password",
            ErrorMessageResourceType=typeof(ClientDefault),
            ErrorMessageResourceName="EditPatientDetails_Not_Same_Password")]
        [Display(Name = "Rep_Password", ResourceType = typeof(Resources.ClientDefault))]
        [DataType(DataType.Password)]
        public string ConfirmPassword { get; set;}

        [Display(Name = "Telephone", ResourceType = typeof(Resources.ClientDefault))]
        [RegularExpression(@"\d+",
            ErrorMessageResourceType = typeof(ClientDefault),
            ErrorMessageResourceName = "SignUp_Invalid_Phone")]
        public string PhoneNumber { get; set; }

        [ScaffoldColumn(false)] //изобщо не е нужно , но за позьоризъм
        public AccountRoles Role { get; set; }

        [MaxFileSize(FileCategories.Image, ErrorMessageResourceType = typeof(ClientDefault), ErrorMessageResourceName = "FileUpload_FileTooBig")]
        [ImagesOnly(ErrorMessageResourceType = typeof(ClientDefault), ErrorMessageResourceName = "SignUp_Unaccepted_Format")]
        public HttpPostedFileBase ImageFile { get; set; }

        public SignUpViewModel(AccountRoles role)
        {
            this.Role = role;
        }

        public SignUpViewModel()
        {
            Role = AccountRoles.User;
            PhoneNumber = string.Empty;
            Password = string.Empty;
            ConfirmPassword = string.Empty;
            FirstName = string.Empty;
            LastName = string.Empty;
            Email = string.Empty;
        }

    }
}