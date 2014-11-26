using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace OpenBookSystemMVC.Models
{
    public class EditAccountModelBinder : DefaultModelBinder
    {
        protected override object CreateModel(ControllerContext controllerContext, ModelBindingContext bindingContext, Type modelType)
        {
            string nUserID = string.Empty;
            nUserID = bindingContext.ValueProvider.GetValue("nUserID").AttemptedValue;
            if (int.Parse(nUserID) == 0)
            {
                return new EditAccountModel();
            }
            else
            {
                return new EditAccountModel(nUserID);
            }
        }
    }
}