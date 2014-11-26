using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using Resources;

namespace OpenBookSystemMVC.Models
{
    public class LogInModel
    {
        [Required(ErrorMessage = "*")]
        [Display(Name = "LogIn_User_Name", ResourceType = typeof(Resources.ClientDefault))]
        public string UserName { get; set; }

        [Required(ErrorMessage = "*")]
        [DataType(DataType.Password)]
        [Display(Name = "LogIn_Password", ResourceType = typeof(Resources.ClientDefault))]
        public string Password { get; set; }

        [Display(Name = "LogIn_Remember_Me", ResourceType = typeof(Resources.ClientDefault))]
        public bool RememberMe { get; set; }
    }
}