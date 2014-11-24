using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using OpenBookSystemMVC.OBISReference;
using Resources;
using System.Drawing;
using Newtonsoft.Json;

namespace OpenBookSystemMVC.Models
{
    public class EditDocumentModel
    {
        public string Title { get; set; }

        [DataType(DataType.MultilineText)]
        public string Content { get; set; }

        [DataType(DataType.MultilineText)]
        public string OriginalContent { get; set; }

        public long DocumentID { get; set; }

        public long CarerID { get; set; }

        public long ReceiverID { get; set; }

        [DataType(DataType.MultilineText)]
        [AllowHtml]
        public string SimplifiedContent { get; set; }        

        public AccountRoles Role { get; set; }

        [DataType(DataType.MultilineText)]
        public string URL { get; set; }

        [TextFileOnly(ErrorMessageResourceName = "SignUp_Unaccepted_Format", ErrorMessageResourceType = typeof(ClientDefault))]
        [MaxFileSize(FileCategories.Text,ErrorMessageResourceName="FileUpload_FileTooBig", ErrorMessageResourceType=typeof(ClientDefault))]
        public HttpPostedFileBase FileForConvert { get; set; }

        public AccountInfo User { get; set; }

        public string Error { get; set; }

        public string UserLabels { get; set; }

        public bool IsFavourite { get; set; }

        public bool IsCompleted { get; set; }

        public string Summary { get; set; }

        public string UserActionsLog { get; set; }

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

        #endregion

        #region DocumentSimplificationTools

        public bool AskCarer
        {
            get
            {
                return User.CarerId != 0 && User.Preferences != null && User.Preferences.SelectedDocumentSimplificationTools != null &&
                    User.Preferences.SelectedDocumentSimplificationTools.Where( x => x == DocumentSimplificationTools.AskCarer).Any();
            }
            set
            {

            }
        }

        public bool ExplainWordWithPicture
        {
            get
            {
                return User.Preferences != null && User.Preferences.SelectedDocumentSimplificationTools != null &&
                    User.Preferences.SelectedDocumentSimplificationTools.Where(x => x == DocumentSimplificationTools.ExplainWordWithPicture).Any();
            }
            set
            {
            }
        }

        public bool ExplainWord
        {
            get
            {
                return User.Preferences != null && User.Preferences.SelectedDocumentSimplificationTools != null &&
                    User.Preferences.SelectedDocumentSimplificationTools.Where(x => x == DocumentSimplificationTools.ExplainWord).Any();
            }
            set
            {
            }
        }

        public bool FontSize
        {
            get
            {
                return User.Preferences != null && User.Preferences.SelectedDocumentSimplificationTools != null &&
                    User.Preferences.SelectedDocumentSimplificationTools.Where(x => x == DocumentSimplificationTools.FontSize).Any();
            }
            set
            {
            }
        }

        public bool Notes
        {
            get
            {
                return User.Preferences != null && User.Preferences.SelectedDocumentSimplificationTools != null &&
                    User.Preferences.SelectedDocumentSimplificationTools.Where(x => (x == DocumentSimplificationTools.Notes)).Any();
            }
            set
            {
            }
        }

        public bool Highlight
        {
            get
            {
                return User.Preferences != null && User.Preferences.SelectedDocumentSimplificationTools != null &&
                    User.Preferences.SelectedDocumentSimplificationTools.Where(x => (x == DocumentSimplificationTools.Highlight)).Any();
            }
            set
            {
                //if (value)
                //{
                //    if (User.Preferences.SelectedDocumentSimplificationTools.Where(x => (x == DocumentSimplificationTools.Highlight)).Any())
                //    {
                //        List<DocumentSimplificationTools> tools = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                //        tools.Remove(DocumentSimplificationTools.Highlight);
                //        User.Preferences.SelectedDocumentSimplificationTools = tools.ToArray();
                //    }
                //    else
                //    {
                //        List<DocumentSimplificationTools> tools = User.Preferences.SelectedDocumentSimplificationTools.ToList();
                //        tools.Add(DocumentSimplificationTools.Highlight);
                //        User.Preferences.SelectedDocumentSimplificationTools = tools.ToArray();
                //    }
                //}
            }
        }

        public bool MagnifyingGlass
        {
            get
            {
                return User.Preferences != null && User.Preferences.SelectedDocumentSimplificationTools != null &&
                    User.Preferences.SelectedDocumentSimplificationTools.Where(x => x == DocumentSimplificationTools.MagnifyingGlass).Any();
            }
            set
            {
            }
        }

        public bool Themes
        {
            get
            {
                return User.Preferences != null && User.Preferences.SelectedDocumentSimplificationTools != null &&
                    User.Preferences.SelectedDocumentSimplificationTools.Where(x => x == DocumentSimplificationTools.Themes).Any();
            }
            set
            {
            }
        }

        public bool Underline
        {
            get
            {
                return User.Preferences != null && User.Preferences.SelectedDocumentSimplificationTools != null &&
                    User.Preferences.SelectedDocumentSimplificationTools.Where(x => x == DocumentSimplificationTools.Underline).Any();
            }
            set
            {
            }
        }

        public bool Bold
        {
            get
            {
                return User.Preferences != null && User.Preferences.SelectedDocumentSimplificationTools != null &&
                    User.Preferences.SelectedDocumentSimplificationTools.Where(x => x == DocumentSimplificationTools.Bold).Any();
            }
            set
            {
            }
        }

        public bool SummaryOn 
        {
            get
            {
                return User.Preferences != null && User.Preferences.SelectedDocumentSimplificationTools != null &&
                    User.Preferences.SelectedDocumentSimplificationTools.Where(x => x == DocumentSimplificationTools.Summary).Any();
            }
        }

        public bool ShowMultiwords
        {
            get {
                return User.Preferences != null && User.Preferences.SelectedDocumentSimplificationTools != null &&
                        User.Preferences.SelectedDocumentSimplificationTools.Where(x => x == DocumentSimplificationTools.ShowMultiwords).Any();
            }
            set { }
        }

        public bool ShowObstacles
        {
            get
            {
                return User.Preferences != null && User.Preferences.SelectedDocumentSimplificationTools != null &&
                        User.Preferences.SelectedDocumentSimplificationTools.Where(x => x == DocumentSimplificationTools.ShowObstacles).Any();
            }
            set { }
        }

        #endregion

        public string BasicJSONData { get; set; }

        public bool IsShared { get; set; }

        public string CalculatedLineSpacing
        {
            get
            {
                string result = string.Empty;

                if (User.Preferences.LineSpacing == LineSpacingDefaults.Small)
                {
                    result = "1.2em";
                }
                else
                {
                    result = ((double)User.Preferences.LineSpacing) / 2 + "em";
                }
                return result;
            }
        }

        public EditDocumentModel()
        {

            User = CurrentUser.Details(HttpContext.Current.User.Identity.Name);
            IsShared = true;

            List<Theme> userThemes = new List<Theme>();
            string result = OBSDataSource.GetUserThemes(User.AccountId, out userThemes);
            if (string.IsNullOrEmpty(result))
            {
                List<object> themes = new List<object>();

                //Need to to this,since I have to know which theme is the current one.
                foreach (Theme theme in userThemes)
                {
                    themes.Add(new
                    {
                        Id = theme.Id,
                        FontColor = theme.FontColor.ToHEX(),
                        BackgroundColor = theme.BackgroundColor.ToHEX(),
                        HighlightColor = theme.HighlightColor.ToHEX(),
                        IsCurrent = theme.Id == User.Preferences.CurrentTheme.Id,
                        MagnificationColor = theme.MagnificationColor.ToHEX()
                    });
                }
                UserLabels = JsonConvert.SerializeObject(themes);
            }

            #region Loading Preferences
            if (User.Preferences == null)
            {
                User.Preferences = new UserPreferences();
            }

            //if (User.Preferences.DocumentFontSize != 0)
            User.Preferences.DocumentFontSize = User.Preferences.DocumentFontSize;
            //else
            //    User.Preferences.DocumentFontSize = Constants.DefaultDocumentFontSize;

            #endregion
        }

        public bool IsNewDocument { get; set; }

        public EditDocumentModel(long nDocID)
            : this()
        {            
            Document doc = new Document();
            string result = OBSDataSource.GetDocument(nDocID, out doc);

            if (string.IsNullOrEmpty(result))
            {
                Title = doc.Title;
                OriginalContent = doc.OriginalDocumentContent;
                SimplifiedContent = doc.SimplifiedContent;
                CarerID = doc.AuthorId;
                DocumentID = nDocID;
                IsFavourite = doc.IsFavourite;
                IsCompleted = doc.IsCompleted;
                Summary = doc.Summary;

                BasicJSONData = JsonConvert.SerializeObject(new { 
                    UserName = this.User.FullName(),
                    DocumentTitle = doc.Title,
                    DocumentId = doc.Id                    
                });

            }
            else
            {
                Error = result;
            }
        }
    }
}