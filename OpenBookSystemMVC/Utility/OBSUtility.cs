using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using OpenBookSystemMVC.OBISReference;
using System.Threading;
using Resources;
using System.Configuration;
using System.Web.Configuration;
using System.Net.Mail;
using System.Text;
using System.ComponentModel;
using OpenBookSystemMVC;

namespace OpenBookSystemMVC
{

    #region Chat (deprecated)
    //    This code bellow is the implementation of a chat box which persists it's chat session.
    //It was to be removed so I commented it, just in case a decision from above to reinstate the chat is received.
    public static class ChatHistory
    {
        private static List<ChatMessage> _messageHistory = new List<ChatMessage>();

        public static List<object> GetUserHistory(long userId)
        {
            return (from message in _messageHistory
                    where message.SenderId == userId || message.ReceiverId == userId
                    select new
                    {
                        UserId = message.SenderId,
                        Content = message.Message,
                        TimeStamp = message.SentTime.ToString("HH:mm")
                    }).ToList<object>();
        }

        public static void DeleteUserHistory(long userId)
        {
            _messageHistory.RemoveAll((x) => x.SenderId == userId || x.ReceiverId == userId);
        }

        public static void SaveNewMessage(ChatMessage newMessage)
        {
            _messageHistory.Add(newMessage);
        }
    }

    public class ChatMessage
    {
        public long SenderId { get; set; }
        public string SenderName { get; set; }
        public long ReceiverId { get; set; }
        public string ReceiverName { get; set; }
        public DateTime SentTime { get; set; }
        public string Message { get; set; }
    }
    
    #endregion

    public static class MailHelpers 
    { 
        public static MailMessage CreateMailMessage(string recepient, bool isHtmlBody)
        {
            MailMessage message = new MailMessage();
            message.BodyEncoding = Encoding.UTF8;
            message.HeadersEncoding = Encoding.UTF8;
            message.SubjectEncoding = Encoding.UTF8;
            message.To.Add(new MailAddress(recepient));
            message.IsBodyHtml = isHtmlBody;

            return message;
        }
    }

    [FlagsAttribute]
    public enum UserOperations
    {
        OpenDocument = 1,
        SaveDocument = 2,
        ContactUserClick = 3,
        SummaryClick = 4,
        AddNoteClick = 5,
        SentenceSelected = 6,
        SentenceAccepted = 7,
        WordSelected = 8,
        SelectInsertImage = 9,
        SelectInsertDefinition = 10,
        SelectInsertAnaphora = 11,
        SelectReplaceWithSynonym = 12,
        PerformInsertImage = 13,
        PerformInsertDefinition = 14,
        PerformInsertAnaphora = 15,
        PerformReplaceWithSynonym = 16,
        PerformSummaryEdited = 17,
		ThemeChanged = 18,
		FontChanged = 19,
		UnderlineClick = 20,
		BoldClick = 21,
		HighlightClick = 22,
		MagnifyTextActivate = 23,
		MagnifyTextDisabled = 24,
		NoteInserted = 25,
		NoteDeleted = 26,
		ExplainWordClick = 27,
		ExplainWithPictureClick = 28,
        DocumentCheckedDone = 29


    }

    public enum LoggingOperationLevel
    {
        [Description("l1")]
        Level1 = 1,
        [Description("l2")]
        Level2 = 2
    }

    public static class UserLogging 
    {
        private const string _logFiletemplate = "{0:00}{1}_Logs.csv";
        private const string _logFileDownloadTemplate = "{0:00}_{1}_Logs.csv";
        public const string CsvDelimiter = ";";
        public const string DateTimeFormat = "dd.MM.yyyy HH:mm:ss";

        public static string LogHeader
        {
            get { 
                return string.Empty; 
            }
        }

        public static string LogFileName
        {
            get
            {
                return HttpContext.Current.Server.MapPath("/Logs/" + 
                    string.Format(_logFiletemplate, DateTime.Now.Month, DateTime.Now.Year));
            }
        }

        public static string LogDownloadName
        {
            get
            {
                return string.Format(_logFileDownloadTemplate, DateTime.Now.Month, DateTime.Now.Year);
            }
        }  

        public static void LogUserAction(string clientData)
        {
            if (bool.Parse(ConfigurationManager.AppSettings["LoggingEnabled"]))
            {
                Logger logger = new Logger();
                logger.Log(clientData, LogPlace.File, LogFileName, false); 
            }
        }

        public static string LogUserAction(UserOperations operation, AccountInfo user, LoggingOperationLevel level, object[] parameters, bool performLog = true)
        {
            string paramData = string.Empty;
            for (int i = 0; i < parameters.Length; i++)
            {
                paramData += parameters[i].ToString() + CsvDelimiter;
            }

            string logMessage = string.Format("{1}{0}{2}{0}{3}{0}{4}{0}{5}{0}{6}",
                CsvDelimiter,                           //{0}
                DateTime.Now.ToString(DateTimeFormat),  //{1}
                level.ToString(),                       //{2}
                operation,                              //{3}
                user.AccountId,                         //{4}
                user.Role.ToString(),                   //{5}
                paramData);                             //{6}

            if (bool.Parse(ConfigurationManager.AppSettings["LoggingEnabled"]) && performLog)
            {
                Logger logger = new Logger();
                logger.Log(logMessage, LogPlace.File, LogFileName, false); 
            }

            return logMessage;
        }
    }

    public static class HelpPages
    {
        private const string _helpLibrary = "Library";
        private const string _helpAccount = "Account";
        private const string _helpDocumentNew = "DocumentNew";
        private const string _helpDocumentRead = "DocumentRead";
        private const string _helpNotifications = "Notifications";
        private const string _helpExplanations = "WordExplanations";
        private const string _helpTests = "GetTest";
        private const string _helpUsersList = "UsersList";
        private const string _helpCarerLibrary = "CarerLibrary";
        private const string _helpDocumentReview = "DocumentReview";

        public static string Library { get { return _helpLibrary; } }
        public static string Account { get { return _helpAccount; } }
        public static string DocumentNew { get { return _helpDocumentNew; } }
        public static string DocumentRead { get { return _helpDocumentRead; } }
        public static string Notifications { get { return _helpNotifications; } }
        public static string WordExplanations { get { return _helpExplanations;  } }
        public static string Tests { get { return _helpTests; } }
        public static string UsersList { get { return _helpUsersList; } }
        public static string CarerLibrary { get { return _helpCarerLibrary; } }
        public static string DocumentReview { get { return _helpDocumentReview; } }

    }

    public static class CurrentUser
    {

        public static AccountInfo Details()
        {
            return HttpContext.Current.Session["UserAccountInfo"] != null ? (AccountInfo)HttpContext.Current.Session["UserAccountInfo"] : null;
        }

        public static AccountInfo Details(string userID)
        {
            AccountInfo user = null;
            if (HttpContext.Current.Session["UserAccountInfo"] != null)
            {
                user = (AccountInfo)HttpContext.Current.Session["UserAccountInfo"];
            }
            else
            {
                string result = OBSDataSource.GetUserProfile(long.Parse(userID), out user);
                if (!string.IsNullOrEmpty(result))
                {
                    //HttpContext.Current.Session.
                    throw new Exception(string.Format("Services cannot load GetUserProfile for the user: {0}", userID));
                }                
            }

            //string strCacheKey = string.Format("__OBSCacheKey_User_{0}", userID);

            //if (HttpContext.Current != null)
            //{
            //    user = HttpContext.Current.Cache.Get(strCacheKey) == null ? null : ((AccountInfo)HttpContext.Current.Cache.Get(strCacheKey));
            //    if (user == null)
            //    {
            //        string result = OBSDataSource.GetUserProfile(long.Parse(userID), out user);
            //        if (string.IsNullOrEmpty(result))
            //        {
            //        }
            //        else {
            //            //result = OBSDataSource.GetUserProfile(long.Parse(userID), out user);
            //            user = new AccountInfo(); // To prevent null reference exception                        
            //        }
            //    }
            //}
            //else
            //{
            //    string result = OBSDataSource.GetUserProfile(long.Parse(userID), out user);
            //    if (string.IsNullOrEmpty(result))
            //    {
            //    }
            //    else
            //    {
            //        //TODO
            //    }
            //}

            return user;
        }


        public static void CacheUser(AccountInfo user)
        {

            HttpContext.Current.Session["UserAccountInfo"] = user;
            //string strCacheKey = string.Format("__OBSCacheKey_User_{0}", user.AccountId);
            //if (HttpContext.Current != null)
            //{
            //    HttpContext.Current.Cache.Insert(strCacheKey, user, null, System.Web.Caching.Cache.NoAbsoluteExpiration, TimeSpan.FromDays(1));
            //}
        }
    }

    public static class LanguageDefaults
    {
        public static readonly string DefaultLanguage = "en-US";
        public static readonly int CookieExpirationDays = 30;
    }

    public static class LabelNames
    {
        public static string GetAccountButtonName(string FirstName)
        {
            string result = string.Empty;
            if (Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName == "en")
            {
                if (FirstName.EndsWith("s"))
                {
                    result = FirstName + "' ";
                }
                else
                {
                    result = FirstName + "'s ";
                }

                result += Resources.ClientDefault.SiteMaster_Account;
            }
            else
            {
                result = string.Format(ClientDefault.Navigation_UserAccount, FirstName);
            }
            
            return result;
        }

        public static string GetDocumentsButtonName(string FirstName)
        {
            string result = string.Empty;
            if (Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName == "en")
            {
                if (FirstName.EndsWith("s"))
                {
                    result = FirstName + "' ";
                }
                else
                {
                    result = FirstName + "'s ";
                }

                result += Resources.ClientDefault.SiteMaster_Documents;
            }
            else
            {
                result = string.Format(ClientDefault.Documents_Title, FirstName);
            }

            return result;
        }

        public static string GetPatientsButtonName(string FirstName)
        {
            string result = string.Empty;
            if (FirstName.EndsWith("s"))
            {
                result = FirstName + "' ";
            }
            else
            {
                result = FirstName + "'s ";
            }

            result += Resources.ClientDefault.SiteMaster_Patients;

            return result; 
        }
    }

    public enum FileCategories
    {
        Image,
        Text
    }

    public class OBSSecurity
    {
        private static string _redirectRoute = "~/Not-Authorized";
        private static string _carerHeadBackRoute = "/Users/List";
        private static string _userHeadBackRoute = "/Documents/List";

        public static string RedirectRoute { get { return _redirectRoute; } }
        public static string CarerHeadBackRoute { get { return _carerHeadBackRoute; } }
        public static string UserHeadBackRoute { get { return _userHeadBackRoute; } }



        public static bool SignUpEnabled
        {
            get
            {
                return bool.Parse(WebConfigurationManager.AppSettings["SignUpEnabled"]);
            }
        }

        public static bool FeedbackEnabled 
        {
            get
            {
                return bool.Parse(WebConfigurationManager.AppSettings["FeedbackEnabled"]);
            }
        }
    }

    public static class AcceptedImages
    {
        private static string[] _acceptedFileTypes = { ".bmp", ".png", ".jpeg", ".jpg" };
        private static string[] _acceptedMIMETypes = { "image/bmp", "image/png", "image/jpeg", "image/jpg", "image/pjpeg", "image/x-png" };
        private static int _maxImageSize = 5242880; // 5 MB
        private static string _maxSizeDisplayName = "5 MB";

        public static string[] AcceptedFileTypes { get { return _acceptedFileTypes; } }
        public static string[] AcceptedMIMETypes { get { return _acceptedMIMETypes; } }
        public static int MaximumAcceptedSize { get { return _maxImageSize; } }
        public static string MaxSizeDisplayName { get { return _maxSizeDisplayName; } }
        public static string FileTypesDisplayName { get {
            string result = string.Empty;
            if (_acceptedFileTypes.Any())
            {
                foreach (string item in _acceptedFileTypes)
                {
                    if (!string.IsNullOrEmpty(result))
                    {
                        result += " | ";
                    }

                    result += item;
                } 
            }
            return result;
        } }

    }

    public static class AcceptedDocuments
    {
        private static string[] _acceptedFileTypes = { ".txt", ".rtf", ".doc" };
        private static string[] _acceptedMIMETypes = { "text/plain", "text/rtf", "application/msword" };
        private static int _maxImageSize = 2097152; // 2 MB
        private static string _maxSizeDisplayName = "2 MB";

        public static string[] AcceptedFileTypes { get { return _acceptedFileTypes; } }
        public static string[] AcceptedMIMETypes { get { return _acceptedMIMETypes; } }
        public static int MaximumAcceptedSize { get { return _maxImageSize; } }
        public static string MaxSizeDisplayName { get { return _maxSizeDisplayName; } }
        public static string FileTypesDisplayName
        {
            get
            {
                string result = string.Empty;
                if (_acceptedFileTypes.Any())
                {
                    foreach (string item in _acceptedFileTypes)
                    {
                        if (!string.IsNullOrEmpty(result))
                        {
                            result += " | ";
                        }

                        result += item;
                    }
                }
                return result;
            }
        } 
    }

    public class MenuLanguage
    {
        public string LanguageKey { get; set; }
        public string IconUrl { get; set; }
        public string DisplayName { get; set; }

        public MenuLanguage(string LanguageKey, string IconUrl, string DisplayName)
        {
            this.LanguageKey = LanguageKey;
            this.IconUrl = IconUrl;
            this.DisplayName = DisplayName;
        }
    }

    public class UserMenuItem
    {
        private bool _isSelected = false;

        public string Url { get; set; }
        public string Name { get; set; }
        public string IconUrl { get; set; }
        public UserMenuItem(string Url, string Name, string IconUrl,bool IsSelected = false)
        {
            this.Url = Url;
            this.Name = Name;
            this.IconUrl = IconUrl;
            this.IsSelected = IsSelected;
        }
        public bool IsSelected { get { return _isSelected; } set { _isSelected = value;} }
    }

    public static class OBSImages
    {
        private static int _tempImageCounter = 0;
        public static int TempImagesCounter 
        { 
            get { return _tempImageCounter; } 
            set { _tempImageCounter = value; } 
        }
        public static string EmptyProfilePicture { get { return "../Images/patientFrame.png"; } }
    }

    public static class Constants
    {
        public const int DefaultDocumentFontSize = 18;

        public static DocumentSimplificationTools[] DefaultSimplificationTools = new DocumentSimplificationTools[] {             
            DocumentSimplificationTools.AskCarer, 
            DocumentSimplificationTools.ExplainWord, 
            DocumentSimplificationTools.ExplainWordWithPicture, 
            DocumentSimplificationTools.FontSize, 
            DocumentSimplificationTools.Highlight, 
            DocumentSimplificationTools.MagnifyingGlass, 
            DocumentSimplificationTools.Notes, 
            DocumentSimplificationTools.Themes,
            DocumentSimplificationTools.Underline,
            DocumentSimplificationTools.Bold
        };

        public static LineSpacingDefaults DefaultLineSpacing = LineSpacingDefaults.Medium;

        public static string DefaultDocumentFontName = "Tahoma";
    }

    public static class LayoutHelpers
    {
        public static bool IsChatAvailable
        {
            get
            {
                return HttpContext.Current.User.Identity.IsAuthenticated && 
                    !HttpContext.Current.Request.Path.Contains("Help") && 
                    CurrentUser.Details(HttpContext.Current.User.Identity.Name).Role == AccountRoles.User && 
                    CurrentUser.Details(HttpContext.Current.User.Identity.Name).CarerId != 0;
            }
        }
    }
}