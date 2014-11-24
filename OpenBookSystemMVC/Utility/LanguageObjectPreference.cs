using OpenBookSystemMVC.OBISReference;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace OpenBookSystemMVC
{
    public class LanguageObjectPreference
    {
        public LanguagePreference data;

        public bool BoolValue 
        {
            get
            {
                if (data == null || data.Value == null || data.PrefrenceType != LanguagePreferenceType.Boolean)
                {
                    return false;
                }
                else
                {
                    return bool.Parse(data.Value);
                }
            }                
            set {
                data.PrefrenceType = LanguagePreferenceType.Boolean;
                data.Value = value.ToString(); 
            }
        }

        public int IntValue
        {
            get
            {
                if (data == null || data.Value == null || data.PrefrenceType != LanguagePreferenceType.Number)
                {
                    return 0;
                }
                else
                {
                    return int.Parse(data.Value);
                }
            }
                
            set {
                data.PrefrenceType = LanguagePreferenceType.Number;
                data.Value = value.ToString(); 
            }
        }

        public string EnumerationValue
        {
            get {
                    if (data == null || data.Value == null || data.PrefrenceType != LanguagePreferenceType.Enumerated)
                    {
                        return "0";
                    }
                    else
                    {                        
                        return data.Value.ToString();
                    }
                }
                
            set {
                data.PrefrenceType = LanguagePreferenceType.Enumerated;
                data.Value = value; 
            }
        }

        public string Caption 
        { 
            get { return data.Caption; } 
            set { data.Caption = value; } 
        }

        public LanguageObjectPreference()
        {
            data = new LanguagePreference();
            data.Caption = string.Empty;
            data.EnumerationOptions = null;
            data.PreferenceGroup = string.Empty;
            data.PrefrenceType = LanguagePreferenceType.Boolean;
            data.Value = null;
        }

    }
}
