using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace OpenBookSystemMVC
{
    // Pattern used as seen in Darin Dimitrov's example : http://stackoverflow.com/questions/10985878/jquery-validation-add-custom-method-to-validate-on-submit
    public class MaxFileSizeAttribute : ValidationAttribute, IClientValidatable
    {
        private FileCategories _fileCategory;

        public MaxFileSizeAttribute(FileCategories FileCategory)
        {
            _fileCategory = FileCategory;

            if (FileCategory == FileCategories.Image)
            {
                this.MaxFileSize = AcceptedImages.MaximumAcceptedSize;
            }
            else if (FileCategory == FileCategories.Text)
            {
                this.MaxFileSize = AcceptedDocuments.MaximumAcceptedSize;
            }
        }

        public int MaxFileSize { get; private set; }

        public override bool IsValid(object value)
        {
            HttpPostedFileBase file = value as HttpPostedFileBase;
            if (file != null)
            {
                int fileSize = file.ContentLength;
                return fileSize < MaxFileSize;
            }

            return true;
        }

        public override string FormatErrorMessage(string name)
        {
            if (_fileCategory == FileCategories.Image)
            {
                return base.FormatErrorMessage(AcceptedImages.MaxSizeDisplayName);
            }
            else if (_fileCategory == FileCategories.Text)
            {
                return base.FormatErrorMessage(AcceptedDocuments.MaxSizeDisplayName);
            }
            else
            {
                return base.FormatErrorMessage(AcceptedImages.MaxSizeDisplayName);
            }
        }

        public IEnumerable<ModelClientValidationRule> GetClientValidationRules(ModelMetadata metadata, ControllerContext context)
        {
            var rule = new ModelClientValidationRule
            {
                ErrorMessage = FormatErrorMessage(MaxFileSize.ToString()),
                ValidationType = "maxsize"
            };
            rule.ValidationParameters["maxsize"] = MaxFileSize;
            yield return rule;
        }
    }
}