using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using OpenBookSystemMVC.OBISReference;
using Resources;
using System.Drawing;
using OpenBookSystemMVC.Utility;
using System.Reflection;
using System.Resources;
using System.Web.Http.ModelBinding;
using System.Text;
using System.Web.WebPages.Html;
using System.IO;

namespace OpenBookSystemMVC.Models
{
    public class DocumentSimplificationTool
    {
        public string PresentName { get; set; }
        public DocumentSimplificationTools Tool { get; set; }
        public bool Active { get; set; }
    }

    public class EditAccountModel
    {
        [Required(ErrorMessageResourceName = "Email_Req", ErrorMessageResourceType = typeof(Resources.ClientDefault))]
        [RegularExpression(@"\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*",
            ErrorMessageResourceType = typeof(ClientDefault),
            ErrorMessageResourceName = "SignUp_Invalid_Mail")]
        [Display(Name = "UserAccount_Email", ResourceType = typeof(Resources.ClientDefault))]
        public string Email
        {
            get
            {
                return User.Email;
            }
            set
            {
                User.Email = value;
            }
        }

        [Display(Name = "Telephone", ResourceType = typeof(Resources.ClientDefault))]
        [RegularExpression(@"\d+",
            ErrorMessageResourceType = typeof(ClientDefault),
            ErrorMessageResourceName = "SignUp_Invalid_Phone")]
        public string PhoneNumber
        {
            get
            {
                return User.PhoneNumber;
            }
            set
            {
                User.PhoneNumber = value;
            }
        }

        [DataType(DataType.MultilineText)]
        [Display(Name = "UserAccount_OtherInfo", ResourceType = typeof(Resources.ClientDefault))]
        public string AdditionalInformation
        {
            get
            {
                return User.AdditionalInfo;
            }
            set
            {
                User.AdditionalInfo = value;
            }
        }


        [DataType(DataType.MultilineText)]
        [Display(Name = "UserAccount_OtherInfo", ResourceType = typeof(Resources.ClientDefault))]
        public string CarersComment
        {
            get
            {
                return User.CarersComment;
            }
            set
            {
                User.CarersComment = value;
            }
        }

        [MaxFileSize(FileCategories.Image, ErrorMessageResourceType = typeof(ClientDefault), ErrorMessageResourceName = "FileUpload_FileTooBig")]
        [ImagesOnly(ErrorMessageResourceType = typeof(ClientDefault), ErrorMessageResourceName = "SignUp_Unaccepted_Format")]
        public HttpPostedFileBase ImageFile
        {
            get;
            set;
        }

        public string ImageURL
        {
            get
            {
                return User.ImgURL;
            }
        }

        public AccountRoles Role
        {
            get
            {
                return User.Role;
            }
        }

        public string FullName
        {
            get
            {
                return User.FullName();
            }
        }

        [Required(ErrorMessageResourceName = "First_Name_Req", ErrorMessageResourceType = typeof(Resources.ClientDefault))]
        [Display(Name = "SignUp_First_Name", ResourceType = typeof(Resources.ClientDefault))]
        public string FirstName
        {
            get
            {
                return User.FirstName;
            }
            set
            {
                User.FirstName = value;
            }
        }

        [Required(ErrorMessageResourceName = "Last_Name_Req", ErrorMessageResourceType = typeof(Resources.ClientDefault))]
        [Display(Name = "SignUp_Last_Name", ResourceType = typeof(Resources.ClientDefault))]
        public string LastName
        {
            get
            {
                return User.LastName;
            }
            set
            {
                User.LastName = value;
            }
        }

        [Required(ErrorMessageResourceName = "Password_Req", ErrorMessageResourceType = typeof(Resources.ClientDefault))]
        [Display(Name = "SignUp_Password", ResourceType = typeof(Resources.ClientDefault))]
        [DataType(DataType.Password)]
        public string Password
        {
            get
            {
                return User.Password;
            }
            set
            {
                User.Password = value;
            }
        }

        [System.Web.Mvc.Compare("Password",
            ErrorMessageResourceType = typeof(ClientDefault),
            ErrorMessageResourceName = "EditPatientDetails_Not_Same_Password")]
        [Display(Name = "Rep_Password", ResourceType = typeof(Resources.ClientDefault))]
        [DataType(DataType.Password)]
        public string ConfirmPassword
        {
            get;
            set;
        }

        //EditPatientDetails_Age_Invalid
        [AgeValidation(1, 100, ErrorMessageResourceName = "EditPatientDetails_Age_Invalid", ErrorMessageResourceType = typeof(ClientDefault))]
        [Display(Name = "EditPatientDetails_Age", ResourceType = typeof(ClientDefault))]
        public string Age
        {
            get
            {
                if (User.Age == 0)
                {
                    return string.Empty;
                }
                else
                {
                    return User.Age.ToString();
                }
            }
            set
            {
                int _nValue = 0;
                if (string.IsNullOrEmpty(value))
                {
                    User.Age = 0;
                }
                else if (int.TryParse(value, out _nValue))
                {
                    User.Age = _nValue;
                }
            }
        }

        [Display(Name = "UserAccount_Gender", ResourceType = typeof(ClientDefault))]
        public Gender Gender
        {
            get
            {
                return User.Gender;
            }
            set
            {
                User.Gender = value;
            }
        }

        public AccountInfo User { get; set; }

        public string Error { get; set; }

        public bool IsUpdate { get; set; }

        #region Preferences

        public string DocumentFontSize
        {
            get
            {
                return User.Preferences.DocumentFontSize.ToString();
            }
            set
            {
                User.Preferences.DocumentFontSize = int.Parse(value);
            }
        }

        //public int DocumentLineSpacing
        //{
        //    get
        //    {
        //        return (int)User.Preferences.LineSpacing;
        //    }
        //    set
        //    {
        //        User.Preferences.LineSpacing = (LineSpacingDefaults)value;
        //    }
        //}

        public LineSpacingDefaults DocumentLineSpacing
        {
            get
            {
                return User.Preferences.LineSpacing;
            }
            set 
            {
                User.Preferences.LineSpacing = value;
            }
        }

        public long DefaultThemeId
        {
            get
            {
                return User.Preferences.CurrentTheme.Id;
            }
            set
            {
                if (User.Preferences.CurrentTheme != null)
                {
                    User.Preferences.CurrentTheme.Id = value;
                }
            }
        }

        public string DocumentFontName
        {
            get
            {
                return User.Preferences.DocumentFontName;
            }
            set
            {
                User.Preferences.DocumentFontName = value;
            }
        }

        #region Toolbar buttons

        [Display(Name = "UserAccount_Themes", ResourceType = typeof(ClientDefault))]
        public bool ThemesTool
        {
            get
            {
                return User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.Themes);
            }
            set
            {
                if (value == true && !User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.Themes))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Add(DocumentSimplificationTools.Themes);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
                else if (value == false && User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.Themes))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Remove(DocumentSimplificationTools.Themes);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
            }
        }

        [Display(Name = "UserAccount_Highlight", ResourceType = typeof(ClientDefault))]
        public bool HighlightTool
        {
            get
            {
                return User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.Highlight);
            }
            set
            {
                if (value == true && !User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.Highlight))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Add(DocumentSimplificationTools.Highlight);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
                else if (value == false && User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.Highlight))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Remove(DocumentSimplificationTools.Highlight);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
            }
        }


        [Display(Name = "UserAccount_FontSize", ResourceType = typeof(ClientDefault))]
        public bool FontSizeTool
        {
            get
            {
                return User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.FontSize);
            }
            set
            {
                if (value == true && !User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.FontSize))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Add(DocumentSimplificationTools.FontSize);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
                else if (value == false && User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.FontSize))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Remove(DocumentSimplificationTools.FontSize);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
            }
        }

        [Display(Name = "EditDocument_ExplainWord", ResourceType = typeof(ClientDefault))]
        public bool ExplainWordTool
        {
            get
            {
                return User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.ExplainWord);
            }
            set
            {
                if (value == true && !User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.ExplainWord))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Add(DocumentSimplificationTools.ExplainWord);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
                else if (value == false && User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.ExplainWord))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Remove(DocumentSimplificationTools.ExplainWord);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
            }
        }

        [Display(Name = "EditDocument_ExplainWithPicture", ResourceType = typeof(ClientDefault))]
        public bool ExplainWordWithPictureTool
        {
            get
            {
                return User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.ExplainWordWithPicture);
            }
            set
            {
                if (value == true && !User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.ExplainWordWithPicture))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Add(DocumentSimplificationTools.ExplainWordWithPicture);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
                else if (value == false && User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.ExplainWordWithPicture))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Remove(DocumentSimplificationTools.ExplainWordWithPicture);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
            }
        }

        [Display(Name = "DocumentEdit_Magnify", ResourceType = typeof(ClientDefault))]
        public bool MagnifyTool
        {
            get
            {
                return User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.MagnifyingGlass);
            }
            set
            {
                if (value == true && !User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.MagnifyingGlass))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Add(DocumentSimplificationTools.MagnifyingGlass);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
                else if (value == false && User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.MagnifyingGlass))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Remove(DocumentSimplificationTools.MagnifyingGlass);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
            }
        }

        [Display(Name = "DocumentEdit_Notes", ResourceType = typeof(ClientDefault))]
        public bool NotesTool
        {
            get
            {
                return User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.Notes);
            }
            set
            {
                if (value == true && !User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.Notes))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Add(DocumentSimplificationTools.Notes);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
                else if (value == false && User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.Notes))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Remove(DocumentSimplificationTools.Notes);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
            }
        }

        [Display(Name = "EditDocument_AskCarer", ResourceType = typeof(ClientDefault))]
        public bool AskCarer
        {
            get
            {
                return User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.AskCarer);
            }
            set
            {
                if (value == true && !User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.AskCarer))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Add(DocumentSimplificationTools.AskCarer);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
                else if (value == false && User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.AskCarer))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Remove(DocumentSimplificationTools.AskCarer);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
            }
        }
        [Display(Name = "DocumentEdit_Underline", ResourceType = typeof(ClientDefault))]
        public bool Underline
        {
            get
            {
                return User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.Underline);
            }
            set
            {
                if (value == true && !User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.Underline))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Add(DocumentSimplificationTools.Underline);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
                else if (value == false && User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.Underline))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Remove(DocumentSimplificationTools.Underline);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
            }
        }

        [Display(Name = "DocumentEdit_Bold", ResourceType = typeof(ClientDefault))]
        public bool Bold
        {
            get
            {
                return User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.Bold);
            }
            set
            {
                if (value == true && !User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.Bold))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Add(DocumentSimplificationTools.Bold);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
                else if (value == false && User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.Bold))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Remove(DocumentSimplificationTools.Bold);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
            }
        }

        [Display(Name = "DocumentReview_Summary", ResourceType = typeof(ClientDefault))]
        public bool Summary
        {
            get
            {
                return User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.Summary);
            }
            set
            {
                if (value == true && !User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.Summary))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Add(DocumentSimplificationTools.Summary);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
                else if (value == false && User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.Summary))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Remove(DocumentSimplificationTools.Summary);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
            }
        }

        [Display(Name = "EditDocument_ShowMultiwords", ResourceType = typeof(ClientDefault))]
        public bool ShowMultiwords
        {
            get
            {
                return User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.ShowMultiwords);
            }
            set
            {
                if (value == true && !User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.ShowMultiwords))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Add(DocumentSimplificationTools.ShowMultiwords);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
                else if (value == false && User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.ShowMultiwords))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Remove(DocumentSimplificationTools.ShowMultiwords);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
            }
        }

        [Display(Name = "EditDocument_ShowObstacles", ResourceType = typeof(ClientDefault))]
        public bool ShowObstacles
        {
            get
            {
                return User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.ShowObstacles);
            }
            set
            {
                if (value == true && !User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.ShowObstacles))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Add(DocumentSimplificationTools.ShowObstacles);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
                else if (value == false && User.Preferences.SelectedDocumentSimplificationTools.Contains(DocumentSimplificationTools.ShowObstacles))
                {
                    var tempList = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                    tempList.Remove(DocumentSimplificationTools.ShowObstacles);
                    User.Preferences.SelectedDocumentSimplificationTools = tempList.ToArray();
                }
            }
        }

        #endregion

        #endregion

        #region DocumentSimplificationTools

        public bool ReplaceWordWithPicture
        {
            get
            {
                return User.Preferences != null && User.Preferences.SelectedDocumentSimplificationTools != null &&
                    User.Preferences.SelectedDocumentSimplificationTools.Where(x => (x == DocumentSimplificationTools.ExplainWordWithPicture)).Any();
            }
            set
            {
                if (value)
                {
                    if (!User.Preferences.SelectedDocumentSimplificationTools.Where(x => (x == DocumentSimplificationTools.ExplainWordWithPicture)).Any())
                    {
                        List<DocumentSimplificationTools> tools = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                        tools.Add(DocumentSimplificationTools.ExplainWordWithPicture);
                        User.Preferences.SelectedDocumentSimplificationTools = tools.ToArray();
                    }
                }
                else
                {
                    if (User.Preferences.SelectedDocumentSimplificationTools.Where(x => (x == DocumentSimplificationTools.ExplainWordWithPicture)).Any())
                    {
                        List<DocumentSimplificationTools> tools = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                        tools.Remove(DocumentSimplificationTools.ExplainWordWithPicture);
                        User.Preferences.SelectedDocumentSimplificationTools = tools.ToArray();
                    }
                }
            }
        }

        public bool ExplainWord
        {
            get
            {
                return User.Preferences != null && User.Preferences.SelectedDocumentSimplificationTools != null &&
                    User.Preferences.SelectedDocumentSimplificationTools.Where(x => (x == DocumentSimplificationTools.ExplainWord)).Any();
            }
            set
            {
                if (value)
                {
                    if (!User.Preferences.SelectedDocumentSimplificationTools.Where(x => (x == DocumentSimplificationTools.ExplainWord)).Any())
                    {
                        List<DocumentSimplificationTools> tools = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                        tools.Add(DocumentSimplificationTools.ExplainWord);
                        User.Preferences.SelectedDocumentSimplificationTools = tools.ToArray();
                    }
                }
                else
                {
                    if (User.Preferences.SelectedDocumentSimplificationTools.Where(x => (x == DocumentSimplificationTools.ExplainWord)).Any())
                    {
                        List<DocumentSimplificationTools> tools = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                        tools.Remove(DocumentSimplificationTools.ExplainWord);
                        User.Preferences.SelectedDocumentSimplificationTools = tools.ToArray();
                    }
                }
            }
        }

        [Display(Name = "DocumentEdit_Notes", ResourceType = typeof(ClientDefault))]
        public bool Notes
        {
            get
            {
                return User.Preferences != null && User.Preferences.SelectedDocumentSimplificationTools != null &&
                    User.Preferences.SelectedDocumentSimplificationTools.Where(x => (x == DocumentSimplificationTools.Notes)).Any();
            }
            set
            {
                if (value)
                {
                    if (!User.Preferences.SelectedDocumentSimplificationTools.Where(x => (x == DocumentSimplificationTools.Notes)).Any())
                    {
                        List<DocumentSimplificationTools> tools = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                        tools.Add(DocumentSimplificationTools.Notes);
                        User.Preferences.SelectedDocumentSimplificationTools = tools.ToArray();
                    }
                }
                else
                {
                    if (User.Preferences.SelectedDocumentSimplificationTools.Where(x => (x == DocumentSimplificationTools.Notes)).Any())
                    {
                        List<DocumentSimplificationTools> tools = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                        tools.Remove(DocumentSimplificationTools.Notes);
                        User.Preferences.SelectedDocumentSimplificationTools = tools.ToArray();
                    }
                }
            }
        }

        #endregion

        private AccountInfo _CurrentUser = CurrentUser.Details(HttpContext.Current.User.Identity.Name);
        private List<LanguageObjectPreference> _langPrefs = new List<LanguageObjectPreference>();

        public bool IsCarerSelfEditing
        {
            get
            {
                return _CurrentUser.Role == AccountRoles.Carer && _CurrentUser.AccountId == User.AccountId;
            }
        }

        public AccountInfo CurrentlyLoggedUser 
        {
            get { return _CurrentUser; }
        }

        // This is the custom editor templated property, which is used to save/load the language preferences.
        public List<LanguageObjectPreference> LanguageObjectPreferences
        {            
            get 
            {

                if (_langPrefs.Count == 0)
                {
                    foreach (LanguagePreference item in User.Preferences.LanguagePreferences)
                    {
                        _langPrefs.Add(new LanguageObjectPreference { data = item });
                    }                    
                }

                return _langPrefs;
            }
            set 
            {
                //List<LanguagePreference> langPrefs = new List<LanguagePreference>();
                foreach (LanguageObjectPreference item in value)
                {
                    LanguagePreference oldPref = User.Preferences.LanguagePreferences.Where(x => x.Caption == item.data.Caption).FirstOrDefault();
                    if (oldPref != null)
                    {
                        oldPref = SetLanguagePreferenceValue(oldPref, item);
                    }                    
                }

                //User.Preferences.LanguagePreferences = langPrefs.ToArray();
            }
        }

        // Called forth when new user has to be created.
        public EditAccountModel()  
        {
            User = new AccountInfo();
            User.Preferences = new UserPreferences();
            User.Preferences.DocumentFontSize = Constants.DefaultDocumentFontSize;
            User.Preferences.DocumentFontName = Constants.DefaultDocumentFontName;
            User.Role = AccountRoles.User;
            User.CarerId = CurrentUser.Details(HttpContext.Current.User.Identity.Name).AccountId;
            User.Preferences.SelectedDocumentSimplificationTools = Constants.DefaultSimplificationTools;
            User.Preferences.CurrentTheme = new Theme();

            IEnumerable<LanguagePreference> prefs = null;

            string result = OBSDataSource.GetDefaultLanguageSettings(out prefs);
            if (string.IsNullOrEmpty(result))
            {
                User.Preferences.LanguagePreferences = prefs.ToArray();
            }
            else
            {
                User.Preferences.LanguagePreferences = new List<LanguagePreference>().ToArray();
            }
            IsUpdate = false;
        }

        // Invoked upon requesting details for specific user.
        public EditAccountModel(string strUserID)
        {
            IsUpdate = true;
            AccountInfo user;
            string result = OBSDataSource.GetUserProfile(long.Parse(strUserID), out user);

            if (string.IsNullOrEmpty(result))
            {
                User = user;

                if (User.Preferences == null)
                {
                    User.Preferences = new UserPreferences();
                }

                if (User.Preferences.SelectedDocumentSimplificationTools == null)
                {
                    User.Preferences.SelectedDocumentSimplificationTools = new DocumentSimplificationTools[0];
                }
            }
            else
            {
                User = new AccountInfo();
                User.Preferences = new UserPreferences();
                User.Preferences.SelectedDocumentSimplificationTools = new DocumentSimplificationTools[0];
                Error = result;
            }
        }

        #region Helper Methods
        //Generate Themes ListBox
        public string GenerateThemesListBox()
        {
            List<Theme> lstThemes = new List<Theme>();
            string result = string.Empty;
            Theme currentTheme = new Theme();

            AccountInfo currentUser = CurrentUser.Details(HttpContext.Current.User.Identity.Name);

            if (currentUser.Role == AccountRoles.User)
            {
                result = OBSDataSource.LoadUserThemes(currentUser.AccountId, out lstThemes);
                currentTheme = currentUser.Preferences.CurrentTheme;
            }
            else if (currentUser.Role == AccountRoles.Carer && IsUpdate && User.AccountId == currentUser.AccountId)
            {
                result = OBSDataSource.LoadUserThemes(currentUser.AccountId, out lstThemes);
                currentTheme = currentUser.Preferences.CurrentTheme;
            }            
            else if (currentUser.Role == AccountRoles.Carer && User.AccountId != currentUser.AccountId && IsUpdate)
            {
                result = OBSDataSource.LoadUserThemes(User.AccountId, out lstThemes);
                currentTheme = User.Preferences.CurrentTheme;
            }
            else if (currentUser.Role == AccountRoles.Carer && User.AccountId != currentUser.AccountId && !IsUpdate)
            {
                result = OBSDataSource.LoadDefaultThemes(out lstThemes);
                if (string.IsNullOrEmpty(result) && lstThemes.Count > 0)
                {
                    currentTheme = lstThemes[0];
                }
            }

            DefaultThemeId = currentTheme.Id;
           
            if (!string.IsNullOrEmpty(result))
            {
                return String.Empty;
            }
            else
            {
                StringBuilder ThemesHtml = new StringBuilder();
                foreach (Theme t in lstThemes)
                {
                    ThemesHtml.Append(String.Format(
                        @"<li data-id='{0}' {1}>
                            <div>
                                <div class='theme-outer-box'>
                                    <div class='color'
                                        style='border-left-color: {2}; border-top-color: {2}; border-right-color: {3}; border-bottom-color: {3};'>
                                    </div>
                                </div>
                                <div class='theme_name' data-colors='[""{5}"",""{6}""]' style='background-color: {3}; color: {2};'>{4}</div>
                            </div>
                            <div class='clear'></div>
                        </li>"
                        , 
                        t.Id,                                                               //{0}
                        currentTheme.Id == t.Id ? "class='selected_element'" : String.Empty,//{1} 
                        t.FontColor.ToHEX(),                                                //{2}
                        t.BackgroundColor.ToHEX(),                                          //{3}           
                        ClientDefault.UserAccount_ExampleTemplate,                          //{4}
                        t.HighlightColor.ToHEX(),                                           //{5}           
                        t.MagnificationColor.ToHEX()                                        //{6}
                        ));
                }

                return ThemesHtml.ToString();
            }
        }

        public string GenerateCurrentThemeBox()
        {
            Theme theme = _CurrentUser.Preferences.CurrentTheme;

            return string.Format(@"                            
            <div class='currentTheme'>
                <div class='theme-outer-box'>
                    <div class='color' style='border-left-color: {0}; border-top-color: {0}; border-right-color: {1}; border-bottom-color: {1};'>
                    </div>                    
                </div>
                <div class='theme_name' data-colors='[""{3}"",""{4}""]' style='background-color: {1}; color: {0};'>{2}</div>
                <div class='ddlIcon icon-caret-down'></div>
            </div>", 
                   theme.FontColor.ToHEX(),                     //{0}
                   theme.BackgroundColor.ToHEX(),               //{1}
                   ClientDefault.UserAccount_ExampleTemplate,   //{2}
                   theme.HighlightColor.ToHEX(),                //{3}
                   theme.MagnificationColor.ToHEX()             //{4}
                   );
        }

        //Generate FontSize ListBox
        public string GenerateFontSizeListBoxItems()
        {
            List<int> values = new List<int>() { 14, 16, 18, 20, 22, 24, 0 };
            string itemPattern = @"<option value='{0}' {3} style='font-size: {1}px;'>{2}</option>";
            string result = String.Empty;
            foreach (var v in values)
            {
                int val = v == 0 ? 18 : v;
                result += String.Format(itemPattern, v, val, v == 0 ? "AA" : "Aa", v == User.Preferences.DocumentFontSize ? "selected='selected'" : String.Empty);
            }

            return result;
        }

        //Generate Line Spacing ListBox
        public string GenerateLineSpacingListBoxItems()
        {
            List<LineSpacingDefaults> values = Enum.GetValues(typeof(LineSpacingDefaults)).Cast<LineSpacingDefaults>().ToList();
            string result = String.Empty;
            string itemPattern = @"<option value='{0}' {2}>{1}</option>";

            foreach (var v in values)
            {
                result += String.Format(itemPattern, (int)v, v.ToString(), v == User.Preferences.LineSpacing ? "selected='selected'" : String.Empty);
            }

            return result;
        }

        //Generate Line Spacing ListBox
        public string GenerateLabelsListBox()
        {
            List<LibraryLabel> lstLabels;
            string result = OBSDataSource.GetUserLabels(out lstLabels, User.AccountId);
            if (!string.IsNullOrEmpty(result))
            {
                return String.Empty;
            }
            else
            {
                string htmlResult = String.Empty;

                foreach (var l in lstLabels)
                {
                    htmlResult += String.Format(@"
                        <li data-label-id='{0}'>
                            <div>
                                <div class='label_name' style='color: {3}; background-color: {1};'>{2}</div>
                                <div class='fright'>
                                    <div data-label-edit='{0}' class='c_button hoverfix'>{4}</div>
                                    <div data-label-delete='{0}' class='c_button hoverfix'>{5}</div>
                                </div>
                            </div>
                            <div class='clear'></div>
                        </li>
                    ", l.ID, l.LabelColor.ToHEX(), l.Name, l.FontColor.ToHEX(), ClientDefault.UserAccount_Edit, ClientDefault.UserAccount_Delete);
                }

                return htmlResult;
            }
        }

        //Generate Text Fonts ListBox
        public string GenerateTextFontListBox()
        {
            List<string> lstFontNames = new List<string>()
            {
                "Times New Roman",
                "Verdana",
                "Tahoma",
                "Calibri"
            };

            string itemPattern = @"<option value='{0}' {1} style='font-family: {0}'>{0}</option>";

            StringBuilder sb = new StringBuilder();

            foreach (var fnt in lstFontNames)
            {
                sb.Append(String.Format(itemPattern, fnt, fnt == User.Preferences.DocumentFontName ? "selected='selected'" : String.Empty));
            }

            return sb.ToString();
        }

        public LanguagePreference SetLanguagePreferenceValue(LanguagePreference oldValue, LanguageObjectPreference newValue)
        {
            if (oldValue.PrefrenceType == LanguagePreferenceType.Boolean)
            {
                oldValue.Value = newValue.BoolValue.ToString();
            }
            else if (oldValue.PrefrenceType == LanguagePreferenceType.Number)
            {
                oldValue.Value = newValue.IntValue.ToString();
            }
            else if (oldValue.PrefrenceType == LanguagePreferenceType.Enumerated)
            {
                oldValue.Value = newValue.EnumerationValue;
            }

            return oldValue;
        }
        
        #endregion

    }
}
