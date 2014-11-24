using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Newtonsoft.Json;

namespace OpenBookSystemMVC
{
    public class ImagesOnlyAttribute : ValidationAttribute, IClientValidatable
    {
        public override bool IsValid(object value)
        {
            HttpPostedFileBase file = value as HttpPostedFileBase;
            if (file != null)
            {
                return file.HasImageMIME();                
            }

            return true;
        }

        public override string FormatErrorMessage(string name)
        {
            return base.FormatErrorMessage(AcceptedImages.FileTypesDisplayName);
        }

        public IEnumerable<ModelClientValidationRule> GetClientValidationRules(ModelMetadata metadata, ControllerContext context)
        {
            var rule = new ModelClientValidationRule
            {
                ErrorMessage = FormatErrorMessage(string.Empty),
                ValidationType = "imgonly"
            };
            HtmlString types = new HtmlString(JsonConvert.SerializeObject(AcceptedImages.AcceptedFileTypes));
            rule.ValidationParameters["acceptedtypes"] = types; //AcceptedImages.AcceptedFileTypes;
            yield return rule;
        }
    }
}