using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Newtonsoft.Json;

namespace OpenBookSystemMVC
{
    public class TextFileOnlyAttribute : ValidationAttribute, IClientValidatable
    {
        public override bool IsValid(object value)
        {
            HttpPostedFileBase file = value as HttpPostedFileBase;
            if (file != null)
            {
                return file.HasTextMIME();
            }

            return true;
        }

        public override string FormatErrorMessage(string name)
        {
            return base.FormatErrorMessage(AcceptedDocuments.FileTypesDisplayName);
        }

        public IEnumerable<ModelClientValidationRule> GetClientValidationRules(ModelMetadata metadata, ControllerContext context)
        {
            var rule = new ModelClientValidationRule
            {
                ErrorMessage = FormatErrorMessage(string.Empty),
                ValidationType = "txtonly"
            };
            HtmlString types = new HtmlString(JsonConvert.SerializeObject(AcceptedDocuments.AcceptedFileTypes));
            rule.ValidationParameters["acceptedtypes"] = types; //AcceptedImages.AcceptedFileTypes;
            yield return rule;
        }
    }
}