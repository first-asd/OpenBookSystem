using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Resources;

namespace OpenBookSystemMVC.Utility
{
    public class AgeValidationAttribute : ValidationAttribute, IClientValidatable
    {
        private int _nFromAge;
        private int _nToAge;

        public AgeValidationAttribute(int FromAge, int ToAge)
        {
            _nFromAge = FromAge;
            _nToAge = ToAge;
        }

        public override bool IsValid(object value)
        {
            bool _result = false;
            string textValue = string.Empty;
            int nValue = 0;
            try
            {
                if (value == null)
                {
                    _result = true;
                }
                else
                {
                    textValue = value.ToString();
                    if (string.IsNullOrEmpty(textValue))
                    {
                        _result = true;
                    }
                    else if (int.TryParse(textValue, out nValue))
                    {
                        if ((nValue >= _nFromAge) && (nValue <= _nToAge))
                        {
                            _result = true;
                        }
                    }
                }
            }
            catch (Exception e)
            {
                _result = false;
                ExceptionLogger.LogException(e, "AgeValidationAttribute");
            }

            return _result;
        }

        public IEnumerable<ModelClientValidationRule> GetClientValidationRules(ModelMetadata metadata, ControllerContext context)
        {
            var rule = new ModelClientValidationRule
            {
                ErrorMessage = ClientDefault.EditPatientDetails_Age_Invalid,
                ValidationType = "agevalid"
            };
            rule.ValidationParameters["validfromage"] = _nFromAge;
            rule.ValidationParameters["validtoage"] = _nToAge;
            yield return rule;
        }

    }
}