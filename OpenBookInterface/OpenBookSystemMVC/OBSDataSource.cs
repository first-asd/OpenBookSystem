using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Newtonsoft.Json;
using OpenBookSystemMVC.OBISReference;
using System.Web.Security;
using System.ServiceModel;
using System.Diagnostics;
using System.IO;


namespace OpenBookSystemMVC
{
    public static class OBSDataSource
    {
        
        private static OpenBookAPIServiceClient _client = null;

        public static OpenBookAPIServiceClient Client_
        {
            
            get
            {
                if (_client == null)
                {
                    _client = new OpenBookAPIServiceClient();
                    _client.ChannelFactory.Faulted += new EventHandler(Client_Faulted);
                    _client.Open();
                }

                return _client;
            }
        }

        private static void Client_Faulted(object sender, EventArgs e)
        {
            _client.Abort();
            _client = new OpenBookAPIServiceClient();
            _client.ChannelFactory.Faulted += new EventHandler(Client_Faulted);
        } 

        #region Fields

        public static bool ShowDetailedError = false;

        /*
        private static MockupAPIClient client
        {
            get
            {
                return (MockupAPIClient)HttpContext.Current.Session["serviceClient"];
            }

            set
            {
                HttpContext.Current.Session["serviceClient"] = value;
            }
        }
         */
        private static Guid AuthenticationToken
        {
            get
            {
                //Experimental, when session expires, this here threw null reference exception on "return (Guid)HttpContext.Current.Session["AuthenticationToken"];"
                //This should, at least, not throw that exception.
                return HttpContext.Current.Session["AuthenticationToken"] == null ? new Guid() : (Guid)HttpContext.Current.Session["AuthenticationToken"];
            }
            set
            {
                HttpContext.Current.Session["AuthenticationToken"] = value;
            }
        }

        #endregion

        #region Users

        public static string Login(string username, string password)
        {

            try
            {
                LoginRequest request = new LoginRequest() { Username = username, Password = password };

                LoginResponse response = null;

                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<LoginResponse>(() => client.Login(request), client);
                }      

                var info = response.AccountInfo;

                if (response.ResultStatus.Result == ActionResult.Success && response.AccountInfo != null)
                {
                    AuthenticationToken = response.SessionToken;

                    string resultDetails = OBSDataSource.GetUserProfile(info.AccountId, out info);
                    if (string.IsNullOrEmpty(resultDetails))
                    {
                        CurrentUser.CacheUser(info);
                        HttpContext.Current.Session["UserLogged"] = true;
                        return string.Empty;
                    }
                    else
                    {
                        return resultDetails;
                    }

                }
                else
                {
                    return FormatFailedResultMessage("Login", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }

            }
            catch (Exception e)
            {
                return FormatExceptionMessage("Login", e, "username : " + username + ", password : " + password, Resources.ClientDefault.ServerCommunicationError);
            }

        }

        public static void Logout()
        {
            try
            {
                
                RequestBase request = GetBaseRequest();

                ResponseBase response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<ResponseBase>( () => client.Logout(request), client);    
                }
                
                HttpContext.Current.Session["AuthenticationToken"] = null;
                
                if (response.ResultStatus.Result != ActionResult.Success)
                    FormatFailedResultMessage("Logout", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
            }
            catch (Exception e)
            {
                FormatExceptionMessage("OBSDataSource.Logout", e, null, Resources.ClientDefault.ServerCommunicationError);
                ExceptionLogger.LogException(e, "OBSDataSource.Logout");
            }
        }

        public static string ActivateUserAccount(Guid userGuid)
        {
            try
            {

                ValidateVerificationTicketRequest request = new ValidateVerificationTicketRequest();
                request.AuthenticationToken = AuthenticationToken;
                request.Ticket = userGuid;
                ResponseBase response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<ResponseBase>(() => client.ValidateVerificationTicket(request), client);
                }
                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    return string.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("ValidateVerificationTicket", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }

            }
            catch (Exception e)
            {
                return FormatExceptionMessage("OBSDataSource.ValidateVerificationTicket", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string RegisterUserAccount(AccountInfo user)
        {
            try
            {

                RegisterAccountRequset request = new RegisterAccountRequset();
                request.Account = user;
                ResponseBase response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<ResponseBase>(() => client.RegisterAccount(request), client);
                }

                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    return string.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("RegisterUserAccount", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                return FormatExceptionMessage("OBSDataSource.RegisterUserAccount", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string CreateUserAccount(AccountInfo user, out AccountInfo AccountInfo)
        {
            AccountInfo = null;
            try
            {
                CreateUserAccountRequest request = new CreateUserAccountRequest();
                request.AuthenticationToken = AuthenticationToken;
                request.Account = user;
                CreateUserAccountResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<CreateUserAccountResponse>(() => client.CreateUserAccount(request), client);
                }

                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    AccountInfo = response.AccountInfo;
                    return string.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("CreateUserAccount", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                return FormatExceptionMessage("OBSDataSource.CreateUserAccount", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string UpdateUserAccount(AccountInfo user)
        {
            AccountInfo info = new AccountInfo();
            try
            {
                UpdateAccountProfileRequest request = new UpdateAccountProfileRequest();
                request.Account = user;
                request.AuthenticationToken = AuthenticationToken;
                UpdateAccountProfileResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<UpdateAccountProfileResponse>(() => client.UpdateAccountProfile(request), client);
                }

                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    info = response.UpdatedAccount;
                    //if updating own account
                    if (CurrentUser.Details(HttpContext.Current.User.Identity.Name).Role == user.Role)
                    {
                        CurrentUser.CacheUser(user);    
                    }                    

                    return string.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("UpdateUserAccount", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                return FormatExceptionMessage("OBSDataSource.UpdateUserAccount", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string DeleteUserAccount(long userId)
        {
            DeleteUserAccountRequest request = new DeleteUserAccountRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.UserId = userId;

            try
            {

                ResponseBase response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<ResponseBase>(() => client.DeleteUserAccount(request), client);
                }

                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    return string.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("DeleteUserAccount", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                return FormatExceptionMessage("OBSDataSource.DeleteUserAccount", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string GetUserProfile(long userId, out AccountInfo AccountInfo)
        {
            try
            {
                AccountInfo = null;
                GetAccountInfoRequest request = new GetAccountInfoRequest();
                request.AuthenticationToken = AuthenticationToken;
                request.UserId = userId;
                GetAccountInfoResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<GetAccountInfoResponse>(() => client.GetAccountInfo(request), client); 
                }
                //response = ServiceCall(

                //var response = Client.GetAccountInfo(request);

                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    AccountInfo = response.User;
                    return string.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("GetUserProfile", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                AccountInfo = null;
                return FormatExceptionMessage("OBSDataSource.GetUserProfile", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string GetCarerPatients(out List<AccountInfo> patients)
        {
            try
            {
                RequestBase request = GetBaseRequest();

                GetCarersUsersResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<GetCarersUsersResponse>(() => client.GetCarersUsers(request), client);
                }
                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    patients = response.CarersUsers.ToList(); ;
                    return string.Empty;
                }
                else
                {
                    patients = new List<AccountInfo>();
                    return FormatFailedResultMessage("GetCarersPatients", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                patients = new List<AccountInfo>();
                return FormatExceptionMessage("OBSDataSource.GetCarerPatients", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string GetCarerUsersPageList(out List<CarerUser> patients) 
        {
            try
            {
                RequestBase request = GetBaseRequest();

                GetCarerUsersPageListResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<GetCarerUsersPageListResponse>(() => client.GetCarerUsersPageList(request), client);
                }

                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    patients = response.CarersUsers.ToList();
                    return string.Empty;
                }
                else
                {
                    patients = new List<CarerUser>();
                    return FormatFailedResultMessage("GetCarerUsersPageList", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                patients = new List<CarerUser>();
                return FormatExceptionMessage("OBSDataSource.GetCarerUsersPageList", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string GetUserImage(long userId, out UserImage image)
        {
            GetUserImageRequest request = new GetUserImageRequest();
            request.UserId = userId;
            request.AuthenticationToken = AuthenticationToken;

            GetUserImageResponse response = null;
            using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
            {
                response = ServiceCall<GetUserImageResponse>(() => client.GetUserImage(request), client);
            }
            try
            {

                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    image = response.Image;
                    return string.Empty;
                }
                else
                {
                    image = null;
                    return FormatFailedResultMessage("GetUserImage", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception ex)
            {
                
                image = null;
                return FormatFailedResultMessage("GetUserImage", "Exception" , ex.Message, null);
            }
        }

        public static string GetUserThemes(long userId, out List<Theme> themes)
        {
            LoadUserThemesRequest request = new LoadUserThemesRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.UserId = userId;

            LoadUserThemesResponse response = null;
            using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
            {
                response = ServiceCall<LoadUserThemesResponse>(() => client.LoadUserThemes(request), client);
            }

            if (response.ResultStatus.Result == ActionResult.Success)
            {
                themes = response.Themes.ToList();
                return string.Empty;
            }
            else
            {
                themes = new List<Theme>();
                FormatFailedResultMessage("GetUserThemes", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                return response.ResultStatus.ErrorMessage;
            }
        }

        public static string GetDefaultLanguageSettings(out IEnumerable<LanguagePreference> preferences)
        {
            preferences = null;
            string resultMessage = String.Empty;
            RequestBase request = GetBaseRequest();

            GetDefaultLanguageSettingsResponse response = null;
            using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
            {
                response = ServiceCall<GetDefaultLanguageSettingsResponse>(() => client.GetDefaultLanguageSettings(request), client);
            }
            try
            {
                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    resultMessage = String.Empty;
                    preferences = response.Preferences.ToList();
                }
                else
                {
                    preferences = new List<LanguagePreference>();
                    FormatFailedResultMessage("GetDefaultLanguageSettings", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                    resultMessage = response.ResultStatus.ErrorMessage;
                }
            }
            catch (Exception ex)
            {
                preferences = new List<LanguagePreference>();
                resultMessage = FormatExceptionMessage("OBSDataSource.GetDefaultLanguageSettings", ex, null, Resources.ClientDefault.ServerCommunicationError);
            }

            return resultMessage;
        }

        public static string RequestPasswordRetrieval(string email)
        {
            string result = string.Empty;
            RetrievePasswordRequest request = new RetrievePasswordRequest();
            ResponseBase response = new ResponseBase();
            request.Email = email;

            using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
            {
                response = ServiceCall<ResponseBase>(() => client.RetrievePassword(request), client);
            }

            if (response.ResultStatus.Result == ActionResult.Success)
            {
                result = string.Empty;
            }
            else
            {
                result = response.ResultStatus.ErrorMessage;
            }

            return result;
        }

        #endregion

        #region Library

        public static string GetUserLabels(out List<LibraryLabel> labels, long accountId)
        {
            labels = null;
            GetAccountLabelsRequest request = new GetAccountLabelsRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.AccountId = accountId;

            GetAccountLabelsResponse response = null;
            using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
            {
                response = ServiceCall<GetAccountLabelsResponse>(() => client.GetAccountLabels(request), client);
            }

            if (response.ResultStatus.Result == ActionResult.Success)
            {
                if (response.Labels != null)
                {
                    labels = response.Labels.ToList();
                }

                return string.Empty;
            }
            else
            {
                labels = new List<LibraryLabel>();
                return FormatFailedResultMessage("GetUserLabels", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
            }
        }

        public static string DeleteLabel(long labelId)
        {
            DeleteLabelRequest request = new DeleteLabelRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.LabelId = labelId;

            ResponseBase response = null;
            using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
            {
                response = ServiceCall<ResponseBase>(() => client.DeleteLabel(request), client);
            }

            if (response.ResultStatus.Result == ActionResult.Success)
            {
                return string.Empty;
            }
            else
            {
                return FormatFailedResultMessage("DeleteLabel", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
            }
        }

        public static string CreateLabel(out long labelId, LibraryLabel label)
        {
            CreateLabelRequest request = new CreateLabelRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.Label = label;

            CreateLabelResponse response = null;
            using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
            {
                response = ServiceCall<CreateLabelResponse>(() => client.CreateLabel(request), client);
            }

            if (response.ResultStatus.Result == ActionResult.Success)
            {
                labelId = response.LabelId;
                return string.Empty;
            }
            else
            {
                labelId = 0;
                return FormatFailedResultMessage("CreateLabel", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
            }
        }

        public static string UpdateLabel(LibraryLabel label)
        {
            UpdateLabelRequest request = new UpdateLabelRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.Label = label;

            ResponseBase response = null;
            using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
            {
                response = ServiceCall<ResponseBase>(() => client.UpdateLabel(request), client);
            }

            if (response.ResultStatus.Result == ActionResult.Success)
            {
                return string.Empty;
            }
            else
            {
                return FormatFailedResultMessage("UpdateLabel", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
            }
        }

        public static string UpdateDocumentLabels(long documentId, long[] arrLabelIds)
        {
            SaveDocumentLabelsRequest request = new SaveDocumentLabelsRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.DocumentId = documentId;
            request.LabelIds = arrLabelIds == null ? new long[0] : arrLabelIds;

            ResponseBase response = null;
            using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
            {
                response = ServiceCall<ResponseBase>(() => client.SaveDocumentLabels(request), client);
            }
            if (response.ResultStatus.Result == ActionResult.Success)
            {
                return string.Empty;
            }
            else
            {
                return FormatFailedResultMessage("UpdateDocumentLabels", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
            }
        }

        public static string UpdateDocumentFavouriteStatus(long documentId, bool newStatus)
        {
            ChangeDocumentFavouriteStatusRequest request = new ChangeDocumentFavouriteStatusRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.DocumentId = documentId;
            request.IsFavourite = newStatus;

            ResponseBase response = null;
            using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
            {
                response = ServiceCall<ResponseBase>(() => client.ChangeDocumentFavouriteStatus(request), client);
            }

            if (response.ResultStatus.Result == ActionResult.Success)
            {
                return string.Empty;
            }
            else
            {
                return FormatFailedResultMessage("UpdateDocumentFavouriteStatus", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
            }
        }

        #endregion

        #region Documents

        public static string GetUserDocuments(long userId, long labelId, out List<BaseDocumentInfo> documents)
        {
            GetLibraryItemsRequest request = new GetLibraryItemsRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.UserId = userId;

            try
            {

                GetLibraryItemsResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<GetLibraryItemsResponse>(() => client.GetLibraryItems(request), client);
                }
                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    documents = response.Documents.ToList();
                    return string.Empty;
                }
                else
                {
                    documents = new List<BaseDocumentInfo>();
                    return FormatFailedResultMessage("GetUserDocuments", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                documents = new List<BaseDocumentInfo>();
                return FormatExceptionMessage("OBSDataSource.GetUserDocuments", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string SimplifyDocument(long patientId, OriginalUserDocument document, out Document simplifiedDocument)
        {
            simplifiedDocument = null;
            SimplifyDocumentRequest request = new SimplifyDocumentRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.UserId = patientId;
            request.Document = document;
            request.SimplifySentenceMode = false;

            try
            {

                SimplifyDocumentResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<SimplifyDocumentResponse>(() => client.SimplifyDocument(request), client);
                }
                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    simplifiedDocument = response.SimplifiedDocument;
                    return string.Empty;
                }
                else
                {
                     return FormatFailedResultMessage("SimplifyDocument", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                return FormatExceptionMessage("OBSDataSource.SimplifyDocument", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string GetWordExplanations(long patientId, string word, out string[] wordExplanations)
        {
            wordExplanations = new string[0];
            ExplainWordRequest request = new ExplainWordRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.UserId = patientId;
            request.Word = word;

            try
            {

                ExplainWordResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<ExplainWordResponse>(() => client.ExplainWord(request), client);
                }
                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    return string.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("GetWordExplanations", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                return FormatExceptionMessage("OBSDataSource.GetWordExplanations", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string GetWordPictures(long patientId, string word, out string[] imageUrls)
        {
            imageUrls = null;
            ExplainWordWithPicturesRequest request = new ExplainWordWithPicturesRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.UserId = patientId;
            request.Word = word;

            try
            {

                ExplainWordWithPicturesResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<ExplainWordWithPicturesResponse>(() => client.ExplainWordWithPictures(request), client);
                }
                if (response.ResultStatus.Result == ActionResult.Success && response.PictureURLs != null)
                {
                    imageUrls = response.PictureURLs;
                    return string.Empty;
                }
                else
                {
                    imageUrls = new string[0];
                    return FormatFailedResultMessage("GetWordPictures", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                imageUrls = new string[0];
                return FormatExceptionMessage("OBSDataSource.GetWordPictures", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string SaveDocument(Document document, out long documentId)
        {
            documentId = -1;
            SaveDocumentRequest request = new SaveDocumentRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.Document = document;
            if (request.Document.Summary == null)
            {
                request.Document.Summary = string.Empty;
            }

            try
            {
                SaveDocumentResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<SaveDocumentResponse>(() => client.SaveDocument(request), client);
                }
                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    documentId = response.DocumentId;
                    return string.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("SaveDocument", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                return FormatExceptionMessage("OBSDataSource.SaveDocument", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string GetDocument(long documentId, out Document document)
        {
            document = null;
            GetDocumentRequest request = new GetDocumentRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.DocumentId = documentId;

            try
            {
                GetDocumentResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<GetDocumentResponse>(() => client.GetDocument(request), client);
                }
                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    document = response.Document;
                    return string.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("GetDocument", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                return FormatExceptionMessage("OBSDataSource.GetDocument", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string ExplainWord(long userId, string word, out WordExplanation explanation)
        {
            explanation = null;
            ExplainWordRequest request = new ExplainWordRequest();
            request.Word = word;
            request.UserId = userId;
            request.AuthenticationToken = AuthenticationToken;

            try
            {
                ExplainWordResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<ExplainWordResponse>(() => client.ExplainWord(request), client);
                }
                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    explanation = response.Explanation;
                    return string.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("ExplainWord", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                return FormatExceptionMessage("OBSDataSource.ExplainWord", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string ExplainWordWithPictures(long userId, string word, out List<string> pictureURLs)
        {
            pictureURLs = null;
            ExplainWordWithPicturesRequest request = new ExplainWordWithPicturesRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.UserId = userId;
            request.Word = word;

            try
            {
                ExplainWordWithPicturesResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<ExplainWordWithPicturesResponse>(() => client.ExplainWordWithPictures(request), client);
                }
                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    pictureURLs = response.PictureURLs.ToList();
                    return String.Empty;
                }
                else
                {
                    pictureURLs = new List<string>();
                    return FormatFailedResultMessage("ExplainWord", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                pictureURLs = new List<string>();
                return FormatExceptionMessage("OBSDataSource.ExplainWord", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string GetDocumentDefinitions(long documentId, out List<DocumentDefinition> definitions)
        {
            GetDocumentDefinitionsRequest request = new GetDocumentDefinitionsRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.DocumentId = documentId;
            definitions = new List<DocumentDefinition>();

            try
            {
                GetDocumentDefinitionsResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<GetDocumentDefinitionsResponse>(() => client.GetDocumentDefinitions(request), client);
                }

                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    if (response.Definitions != null && response.Definitions.Count() > 0)
                    {
                        definitions = response.Definitions.ToList();
                    }
                    return string.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("GetDocumentDefinitions", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                return FormatExceptionMessage("OBSDataSource.GetDocumentDefinitions", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string MarkDocumentAsRead(long documentId)
        {
            string result = String.Empty;
            MarkDocumentAsReadRequest request = new MarkDocumentAsReadRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.DocumentId = documentId;

            try
            {
                ResponseBase response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<ResponseBase>(() => client.MarkDocumentAsRead(request), client);
                }

                if (response.ResultStatus.Result == ActionResult.Error || response.ResultStatus.Result == ActionResult.AccessDenied)
                {
                    result = FormatFailedResultMessage("MarkDocumentAsRead", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                result = FormatExceptionMessage("OBSDataSource.MarkDocumentAsRead", e, null, Resources.ClientDefault.ServerCommunicationError);
            }

            return result;
        }
        //TODO Not now
        //public static bool GetDocumentHistoryInfo(long documentId, out DocumentVersion[] documentHistory)
        //{
        //    documentHistory = new DocumentVersion[0];
        //    try
        //    {
        //        var result = client.GetDocumentHistoryInfo(out documentHistory, documentId);
        //        if (result.Result == ActionResult.Success)
        //        {
        //            return true;
        //        }
        //        else
        //        {
        //            FormatFailedResultMessage("GetDocumentHistoryInfo", result.Result.ToString(), result.ErrorMessage, null);
        //            return false;
        //        }
        //    }
        //    catch (Exception e)
        //    {
        //        FormatExceptionMessage("GetDocumentHistoryInfo", e.Message, null);
        //        ExceptionLogger.LogException(e, "OBSDataSource.GetDocumentHistoryInfo");
        //        return false;
        //    }
        //}

        //TODO not now
        //public static bool GetDocumentVersionContent(long documentId, long documentVersionId, out string simplifiedContent)
        //{
        //    simplifiedContent = null;
        //    try
        //    {
        //        var result = client.GetDocumentVersionContent(out simplifiedContent, documentId, documentVersionId);
        //        if (result.Result == ActionResult.Success)
        //        {
        //            return true;
        //        }
        //        else
        //        {
        //            FormatFailedResultMessage("GetDocumentVersionContent", result.Result.ToString(), result.ErrorMessage, null);
        //            return false;
        //        }
        //    }
        //    catch (Exception e)
        //    {
        //        FormatExceptionMessage("GetDocumentVersionContent", e.Message, null);
        //        ExceptionLogger.LogException(e, "OBSDataSource.GetDocumentVersionContent");
        //        return false;
        //    }
        //}

        public static string DeleteDocument(long documentId)
        {
            DeleteDocumentRequest request = new DeleteDocumentRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.DocumentId = documentId;

            try
            {
                ResponseBase response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<ResponseBase>(() => client.DeleteDocument(request), client);
                }
                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    return string.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("DeleteDocument", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {                
                return FormatExceptionMessage("OBSDataSource.DeleteDocument", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        //public static string GetLastDocuments(long userId, out List<Notification> notifications)
        //{
        //    GetLastDocumentsRequest request = new GetLastDocumentsRequest();
        //    request.AuthenticationToken = AuthenticationToken;
        //    request.UserId = userId;

        //    MockupAPIClient client = new MockupAPIClient();
        //    client.Open();

        //    notifications = new List<Notification>();

        //    var response = client.GetLastDocuments(request);

        //    if (response.ResultStatus.Result == ActionResult.Success)
        //    {
        //        if (response.Documents != null && response.Documents.Length > 0)
        //        {
        //            foreach (BaseDocumentInfo docItem in response.Documents)
        //            {
        //                notifications.Add(new Notification
        //                {
        //                    DocumentId = docItem.Id,
        //                    DocumentTitle = docItem.Title,
        //                    SentOn = docItem.DateModified,
        //                    MessageContent = string.Empty
        //                });
        //            }
        //        }

        //        return string.Empty;
        //    }
        //    else 
        //    {
        //        return FormatFailedResultMessage("GetLastDocuments", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
        //    }
        //}

        public static string GetWordSynonyms(string questionedWord, out List<WordSynonym> synonyms)
        {
            GetWordSynonymsRequest request = new GetWordSynonymsRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.QuestionedWord = questionedWord;

            try
            {
                GetWordSynonymsResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<GetWordSynonymsResponse>(() => client.GetWordSynonyms(request), client);
                }

                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    synonyms = response.Synonyms.ToList();
                    return String.Empty;
                }
                else
                {
                    synonyms = new List<WordSynonym>();
                    return FormatFailedResultMessage("GetWordSynonyms", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                synonyms = new List<WordSynonym>();
                return FormatExceptionMessage("OBSDataSource.GetWordSynonyms", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string GetCarerWordPictures(string questionWord, out IEnumerable<string> urls)
        {
            GetCarerWordPicturesRequest request = new GetCarerWordPicturesRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.QuestionedWord = questionWord;

            try
            {
                GetCarerWordPicturesResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<GetCarerWordPicturesResponse>(() => client.GetCarerWordPictures(request), client);
                }
                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    urls = response.URLs.ToList();
                    return String.Empty;
                }
                else
                {
                    urls = new List<string>();
                    return FormatFailedResultMessage("GetCarerWordPictures", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                urls = new List<string>();
                return FormatExceptionMessage("OBSDataSource.GetCarerWordPictures", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string GetCarerWordDefinitions(string questionWord, out IEnumerable<string> definitions)
        {
            GetCarerWordDefinitionsRequest request = new GetCarerWordDefinitionsRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.QuestionedWord = questionWord;

            try
            {
                GetCarerWordDefinitionsResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<GetCarerWordDefinitionsResponse>(() => client.GetCarerWordDefinitions(request), client);
                }

                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    definitions = response.Definitions.ToList();
                    return String.Empty;
                }
                else
                {
                    definitions = new List<string>();
                    return FormatFailedResultMessage("GetCarerWordDefinitions", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                definitions = new List<string>();
                return FormatExceptionMessage("OBSDataSource.GetCarerWordDefinitions", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string SimplifyCarerDocument(long userId, OriginalUserDocument document, out Document simplifiedDocument)
        {
            SimplifyCarerDocumentRequest request = new SimplifyCarerDocumentRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.Document = document;
            request.UserId = userId;
            simplifiedDocument = null;
            request.SimplifySentenceMode = false;

            try
            {
                SimplifyCarerDocumentResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<SimplifyCarerDocumentResponse>(() => client.SimplifyCarerDocument(request), client);
                }

                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    simplifiedDocument = response.SimplifiedDocument;
                    return String.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("SimplifyCarerDocument", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }

            }
            catch (Exception e)
            {
                return FormatExceptionMessage("OBSDataSource.SimplifyCarerDocument", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string SaveCarerEditedDocument(Document document,out long documentId)
        {
            documentId = 0;
            SaveCarerEditedDocumentRequest request = new SaveCarerEditedDocumentRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.Document = document;
            if (request.Document.Summary == null)
            {
                request.Document.Summary = string.Empty;
            }

            try
            {
                SaveCarerEditedDocumentResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<SaveCarerEditedDocumentResponse>(() => client.SaveCarerEditedDocument(request), client);
                }

                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    documentId = response.DocumentId;
                    return String.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("SaveCarerEditedDocument", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                return FormatExceptionMessage("OBSDataSource.SaveCarerEditedDocument", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string GetTransformedSentenceData(string simplifiedSentence, long documentId, out DocumentSentence sentenceData)
        {
            sentenceData = null;
            GetTransformedSentenceDataRequest request = new GetTransformedSentenceDataRequest();
            //request.DocumentId = documentId;
            request.AuthenticationToken = AuthenticationToken;
            request.SimplifiedSentence = simplifiedSentence;

            try
            {
                GetTransformedSentenceDataResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<GetTransformedSentenceDataResponse>(() => client.GetTransformedSentenceData(request), client);
                }
                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    if (response.SentenceData.AlternativeStructures == null)
                    {
                        response.SentenceData.AlternativeStructures = new AlternativeStructure[0] { };
                    }

                    //if (response.SentenceData.AlternativeStructures == null || response.SentenceData.AlternativeStructures.Length == 0)
                    //{
                    //    response.SentenceData.AlternativeStructures = new AlternativeStructure[1] { new AlternativeStructure { 
                    //       Type = AlternativeStructureTypes.Original,
                    //       Content = response.SentenceData.OriginalSentence
                    //    }};
                    //}
                    //else 
                    //{
                    //    response.SentenceData.AlternativeStructures.ToList().Insert(0, new AlternativeStructure { 
                    //       Type = AlternativeStructureTypes.Original,
                    //       Content = response.SentenceData.OriginalSentence
                    //    });
                    //}

                    sentenceData = response.SentenceData;

                    return String.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("GetTransformedSentenceData", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                return FormatExceptionMessage("OBSDataSource.GetTransformedSentenceData", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string SubmitAcceptedSentence(string acceptedSentence, long documentID, string unmodifiedSentence, out string sentence)
        {
            sentence = String.Empty;

            SubmitAcceptedSentenceRequest request = new SubmitAcceptedSentenceRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.AcceptedSentence = acceptedSentence;
            request.DocumentId = documentID;
            request.UnmodifiedSentence = unmodifiedSentence;

            try
            {
                SubmitAcceptedSentenceResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<SubmitAcceptedSentenceResponse>(() => client.SubmitAcceptedSentence(request), client);
                }
                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    sentence = response.Sentence;
                    return String.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("SubmitAcceptedSentence", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                return FormatExceptionMessage("OBSDataSource.SubmitAcceptedSentence", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string GetWordAnaphoras(string questionWord, out List<WordAnaphora> anaphoras)
        {
            GetAnaphoraResolutionRequest request = new GetAnaphoraResolutionRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.QuestionedWord = questionWord;

            try
            {
                GetAnaphoraResolutionResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<GetAnaphoraResolutionResponse>(() => client.GetAnaphoraResolution(request), client);                    
                }

                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    anaphoras = response.Anaphoras.ToList();
                    return String.Empty;
                }
                else
                {
                    anaphoras = new List<WordAnaphora>();
                    return FormatFailedResultMessage("GetAnaphoraResolution", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                anaphoras = new List<WordAnaphora>();
                return FormatExceptionMessage("OBSDataSource.GetAnaphoraResolution", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string GetObstacleInfo(int obstacleId, out string[] obstacleInfo)
        {
            GetObstacleInfoRequest request = new GetObstacleInfoRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.ObstacleId = obstacleId;

            try
            {
                GetObstacleInfoResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<GetObstacleInfoResponse>(() => client.GetObstacleInfo(request), client);
                }

                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    obstacleInfo = response.ObstacleInfo;
                    return String.Empty;
                }
                else
                {
                    obstacleInfo = new string[0];
                    return FormatFailedResultMessage("GetObstacleInfo", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                obstacleInfo = new string[0];
                return FormatExceptionMessage("GetObstacleInfo", e, null, Resources.ClientDefault.ServerCommunicationError);
            }

        }

        public static string ReprocessSentence(string sentence, out string processedSentence)
        {
            SimplifyDocumentRequest request = new SimplifyDocumentRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.Document = new OriginalUserDocument() { 
                Text = sentence,
                Type = OriginalDocumentType.odtString                
            };
            request.SimplifySentenceMode = true;

            processedSentence = string.Empty;

            try
            {
                SimplifyDocumentResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<SimplifyDocumentResponse>(() => client.SimplifyDocument(request), client);
                }

                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    processedSentence = response.SimplifiedDocument.SimplifiedContent;
                    return String.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("GetObstacleInfo", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {                
                return FormatExceptionMessage("GetObstacleInfo", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        #endregion

        #region Notifications

        public static string SendNotification(Notification notif)
        {
            string result = string.Empty;
            SendNotificationRequest request = new SendNotificationRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.NewNotification = notif;

            try
            {
                ResponseBase response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<ResponseBase>(() => client.SendNotification(request), client);
                }
                if (response.ResultStatus.Result == ActionResult.Error || response.ResultStatus.Result == ActionResult.AccessDenied)
                {
                    result = FormatFailedResultMessage("SendNotification", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                result = FormatExceptionMessage("OBSDataSource.SendNotification", e, null, Resources.ClientDefault.ServerCommunicationError);
            }

            return result;
        }

        public static string MarkNotificationAsRead(long notificationID)
        {
            MarkNotificationAsReadRequest request = new MarkNotificationAsReadRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.NotificationId = notificationID;

            string result = string.Empty;

            try
            {
                ResponseBase response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<ResponseBase>(() => client.MarkNotificationAsRead(request), client);
                }

                if(response.ResultStatus.Result == ActionResult.Error || response.ResultStatus.Result == ActionResult.AccessDenied)
                {
                    result = FormatFailedResultMessage("MarkNotificationAsRead", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                result = FormatExceptionMessage("OBSDataSource.MarkNotificationAsRead", e, null, Resources.ClientDefault.ServerCommunicationError);
            }

            return result;
        }

        public static string DeleteNotification(long notificationID)
        {
            string result = string.Empty;
            DeleteNotificationRequest request = new DeleteNotificationRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.NotificationId = notificationID;

            try
            {
                ResponseBase response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<ResponseBase>(() => client.DeleteNotification(request), client);
                }

                if (response.ResultStatus.Result == ActionResult.Error || response.ResultStatus.Result == ActionResult.AccessDenied)
                {
                    result = FormatFailedResultMessage("DeleteNotification", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                result = FormatExceptionMessage("OBSDataSource.DeleteNotification", e, null, Resources.ClientDefault.ServerCommunicationError);
            }

            return result;
        }

        public static string GetUserNotifications(out List<Notification> notifications)
        {
            string result = string.Empty;
            RequestBase request = GetBaseRequest();
            notifications = new List<Notification>();
            GetUserNotificationsResponse response = null;

            try
            {

                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<GetUserNotificationsResponse>(() => client.GetUserNotifications(request), client);
                }

                //Service<IOpenBookAPIService>.Use(x => { response = x.GetUserNotifications(request); });

                //response = _ServiceCall(client => client.GetUserNotifications(request)); 


                if (response.ResultStatus.Result == ActionResult.Error || response.ResultStatus.Result == ActionResult.AccessDenied)
                {
                    result = FormatFailedResultMessage("GetUserNotifications", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
                else if (response.ResultStatus.Result == ActionResult.Success)
                {
                    notifications = response.Notifications.ToList();
                }
            }
            catch (Exception e)
            {
                result = FormatExceptionMessage("OBSDataSource.GetUserNotifications", e, null, Resources.ClientDefault.ServerCommunicationError);
            }

            return result; 
        }

        #endregion

        #region Tests

        public static string GetDocumentTest(long documentId, out Test documentTest)
        {
            documentTest = null;
            GetDocumentTestRequest request = new GetDocumentTestRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.DocumentId = documentId;

            try
            {
                GetDocumentTestResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<GetDocumentTestResponse>(() => client.GetDocumentTest(request), client);
                }

                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    documentTest = response.DocumentTest;
                    return string.Empty;
                }
                else
                {
                    documentTest = new Test();
                    return FormatFailedResultMessage("GetDocumentTest", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                documentTest = new Test();
                return FormatExceptionMessage("OBSDataSource.GetDocumentTest", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string SubmitTestAnswer(long answerId)
        {
            SubmitTestAnswerRequest request = new SubmitTestAnswerRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.AnswerId = answerId;

            try
            {
                ResponseBase response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<ResponseBase>(() => client.SubmitTestAnswer(request), client);
                }
                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    return String.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("SubmitTestAnswer", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                return FormatExceptionMessage("OBSDataSource.SubmitTestAnswer", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        #endregion

        #region Helpers

        public delegate void UseServiceDelegate<I>(I client);

        public static class Service<Interface>
        {
            public static ChannelFactory<Interface> _channelFactory = new ChannelFactory<Interface>("WSHttpBinding_IOpenBookApi");

            public static void Use(UseServiceDelegate<Interface> call)
            {
                IClientChannel proxy = (IClientChannel)_channelFactory.CreateChannel();
                bool success = false;
                try
                {
                    call((Interface)proxy);
                    proxy.Close();
                    success = true;
                }
                finally
                {
                    if (!success)
                    {
                        proxy.Abort();
                        //proxy.Dispose();
                        //proxy = (IClientChannel)_channelFactory.CreateChannel();
                        //call((Interface)proxy);                        
                    }
                }
            }
        }

        public static Response ServiceCall<Response>(Func<Response> serviceCall, OpenBookAPIServiceClient client) where Response : new()
        {
            Response response = new Response();

            try
            {
                response = serviceCall();
            }
            catch (Exception e)
            {
                client.Abort();
                client = new OpenBookAPIServiceClient();
                client.Open();
                try
                {
                    response = serviceCall();
                }
                catch (Exception ex)
                {
                    client.Abort();
                    client = new OpenBookAPIServiceClient();
                    client.Open();
                    response = serviceCall();
                }
            }
            
            return response;
        }

        public static string FormatExceptionMessage(string strServiceMethodName, Exception exception, object objRequest, string humanReadableErrorMessage)
        {
            string result = string.Format("Exception in service call: {0}. \n ExceptionMessage: {1}. \n Request: {2} \n", strServiceMethodName, exception.Message, JsonConvert.SerializeObject(objRequest));
            ExceptionLogger.LogException(exception, strServiceMethodName);
            if (ShowDetailedError)
            {
                return result;
            }
            else
            {
                return humanReadableErrorMessage;
            }
        }

        public static string FormatFailedResultMessage(string strServiceMethodName, string strStatus, string strReason, object objRequest)
        {
            string result = string.Format("Error in service call: {0}. \n ErrorStatus: {1}. \n ErrorReason: {2}. \n Request: {3} \n", strServiceMethodName, strStatus, strReason, JsonConvert.SerializeObject(objRequest));
            ExceptionLogger.LogError(result, strServiceMethodName);
            if (ShowDetailedError)
            {
                return result;
            }
            else
            {
                return strReason;
            }
        }

        private static RequestBase GetBaseRequest()
        {
            RequestBase request = new RequestBase();
            request.AuthenticationToken = AuthenticationToken;
            return request;
        }

        #endregion

        #region Themes

        public static string CreateTheme(Theme newTheme, out long themeId)
        {
            themeId = 0;
            CreateThemeRequest request = new CreateThemeRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.NewTheme = newTheme;

            try
            {
                CreateThemeResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<CreateThemeResponse>(() => client.CreateTheme(request), client);
                }
                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    themeId = response.ThemeId;
                    return string.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("CreateTheme", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                return FormatExceptionMessage("OBSDataSource.CreateTheme", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string LoadUserThemes(long userId, out List<Theme> themes)
        {
            themes = new List<Theme>();
            LoadUserThemesRequest request = new LoadUserThemesRequest();
            request.AuthenticationToken = AuthenticationToken;
            request.UserId = userId;

            try
            {
                LoadUserThemesResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<LoadUserThemesResponse>(() => client.LoadUserThemes(request), client);
                }
                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    themes = response.Themes.ToList();
                    return string.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("LoadUserThemes", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                return FormatExceptionMessage("OBSDataSource.LoadUserThemes", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }

        public static string LoadDefaultThemes(out List<Theme> themes)
        {
            themes = new List<Theme>();
            RequestBase request = GetBaseRequest();

            try
            {
                LoadDefaultThemesResponse response = null;
                using (OpenBookAPIServiceClient client = new OpenBookAPIServiceClient())
                {
                    response = ServiceCall<LoadDefaultThemesResponse>(() => client.LoadDefaultThemes(request), client);
                }
                if (response.ResultStatus.Result == ActionResult.Success)
                {
                    themes = response.Themes.ToList(); ;
                    return string.Empty;
                }
                else
                {
                    return FormatFailedResultMessage("LoadDefaultThemes", response.ResultStatus.Result.ToString(), response.ResultStatus.ErrorMessage, null);
                }
            }
            catch (Exception e)
            {
                return FormatExceptionMessage("OBSDataSource.LoadDefaultThemes", e, null, Resources.ClientDefault.ServerCommunicationError);
            }
        }
        
        #endregion
    }
}