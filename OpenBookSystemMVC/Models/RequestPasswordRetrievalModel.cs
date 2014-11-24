using Resources;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace OpenBookSystemMVC.Models
{
    public class RequestPasswordRetrievalModel
    {
        [Required(ErrorMessageResourceName = "Email_Req", ErrorMessageResourceType = typeof(Resources.ClientDefault))]
        [RegularExpression(@"\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*",
            ErrorMessageResourceType = typeof(ClientDefault),
            ErrorMessageResourceName = "SignUp_Invalid_Mail")]
        [Display(Name = "Email", ResourceType = typeof(Resources.ClientDefault))]
        public string Email { get; set;}

        public string ErrorMessage { get; set; }
    }
}