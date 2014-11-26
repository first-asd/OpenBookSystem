using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using OpenBookSystemMVC.Models;
using Resources;
using System.IO;
using System.Web.Routing;
using OpenBookSystemMVC.OBISReference;
using Newtonsoft.Json;
using System.Drawing;
using System.Text.RegularExpressions;
using iTextSharp.text.pdf;
using System.Net.Mail;
using System.Configuration;
using System.Text;
using iTextSharp.text.html.simpleparser;
using iTextSharp.tool.xml.pipeline.html;
using iTextSharp.tool.xml.html;
using iTextSharp.tool.xml;
using iTextSharp.tool.xml.parser;
using HtmlAgilityPack;

namespace OpenBookSystemMVC.Controllers
{
    public class DocumentsController : Controller
    {
        // When user visits his own library
        public System.Web.Mvc.ActionResult List()
        {
            DocumentsModel model = new DocumentsModel();
            AccountInfo currentUser = CurrentUser.Details(User.Identity.Name);
            model.PageTitle = string.Format(ClientDefault.Documents_Title, currentUser.FullName());

            string result = InitModelData(model, currentUser);
            if (string.IsNullOrEmpty(result))
            {
                return View("Documents", model);
            }
            else
            {
                ModelState.AddModelError("Model", result);
                return View("Documents", model);
            }            
        }

        // When carer visits patient's library
        public System.Web.Mvc.ActionResult UserList(long id)
        {
            DocumentsModel model = new DocumentsModel();
            AccountInfo libraryUser = new AccountInfo();
            string getProfileResult = OBSDataSource.GetUserProfile(id, out libraryUser);
            if (string.IsNullOrEmpty(getProfileResult))
            {
                model.PageTitle = string.Format(ClientDefault.Documents_Title, libraryUser.FullName());
                model.UserId = id;

                string result = InitModelData(model, libraryUser);
                if (string.IsNullOrEmpty(result))
                {
                    return View("Documents", model);
                }
                else
                {
                    ModelState.AddModelError("Model", result);
                    return View("Documents", model);
                }
            }
            else
            {
                return RedirectToAction("List", "Users");
            }

        }

        public System.Web.Mvc.ActionResult DeleteDocument(int nDocID)
        {
            string result = OBSDataSource.DeleteDocument(nDocID);
            return Json(result, JsonRequestBehavior.AllowGet);
        }

        public System.Web.Mvc.ActionResult DeleteDocuments(long[] arrDocuments)
        {
            string result = string.Empty;

            foreach (long docId in arrDocuments)
            {
                result = OBSDataSource.DeleteDocument(docId);
            }

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [Authorize(Roles="User")]
        public System.Web.Mvc.ActionResult Edit(long nDocID)
        {
            ViewBag.IsUnSaved = false;
            string strErrorMessage = string.Empty;
            EditDocumentModel model = new EditDocumentModel(nDocID);
            if (!string.IsNullOrEmpty(model.Error))
            {
                ModelState.AddModelError("Model", model.Error);
                return View("EditDocument", model);
            }
            else
            {
                AccountInfo user = CurrentUser.Details(User.Identity.Name);

                model.Role = user.Role;
                model.IsNewDocument = false;
                model.CarerID = user.CarerId;

                model.UserActionsLog = UserLogging.LogUserAction(UserOperations.OpenDocument, user, LoggingOperationLevel.Level1, new object[] { nDocID }, false);
            }           

            return View("EditDocument", model);
        }

        public System.Web.Mvc.ActionResult NewDocument(long UserID = 0)
        {
            if (HttpContext.Items["loggedOut"] != null && (bool)HttpContext.Items["loggedOut"])
            {
                return RedirectToAction("Home", "Master");
            }

            ViewBag.IsUnSaved = "false";
            string strErrorMessage = string.Empty;
            EditDocumentModel model = new EditDocumentModel();
            AccountInfo user = CurrentUser.Details(User.Identity.Name);

            model.Role = user.Role;
            model.IsNewDocument = true;

            if (model.Role == AccountRoles.User)
            {
                model.CarerID = user.CarerId;
            }
            else if (model.Role == AccountRoles.Carer)
            {
                model.ReceiverID = UserID;
            }

            return View("EditDocument", model);
        }

        #region Exports

        public System.Web.Mvc.FileResult ExportTxt(long DocumentID)
        {
            Document doc = null;
            OBSDataSource.GetDocument(DocumentID, out doc);
            
            HtmlDocument htmlDocument = new HtmlDocument();
            htmlDocument.LoadHtml(doc.SimplifiedContent);
            AddHtmlDocNewLines(htmlDocument);

            return File(Encoding.UTF8.GetBytes(htmlDocument.DocumentNode.InnerText), "text/plain", string.Format("{0}.txt", doc.Title));
        }

        public System.Web.Mvc.FileResult ExportHtml(long DocumentID)
        {
            Document doc = null;
            OBSDataSource.GetDocument(DocumentID, out doc);
            long userId = Convert.ToInt64(HttpContext.User.Identity.Name);

            AccountInfo ai = null;
            OBSDataSource.GetUserProfile(userId, out ai);
            if (doc == null || ai == null)
            {
                return null;
            }

            string cssStyles = String.Empty;
            string cssClasses = String.Empty;
            if (ai.Preferences != null)
            {
                Color bc = ai.Preferences.CurrentTheme.BackgroundColor;
                Color fc = ai.Preferences.CurrentTheme.FontColor;
                cssStyles += String.Format("background-color: #{0};", bc.R.ToString("X2") + bc.G.ToString("X2") + bc.B.ToString("X2"));
                cssStyles += String.Format("color: #{0};", fc.R.ToString("X2") + fc.G.ToString("X2") + fc.B.ToString("X2"));
                cssStyles += string.Format("font-size: {0}px;", ai.Preferences.DocumentFontSize > 0 ? ai.Preferences.DocumentFontSize : 18);
                cssStyles += string.Format("line-height: {0}em;", (int)ai.Preferences.LineSpacing * 0.5);
                cssStyles += string.Format("font-family: {0}", ai.Preferences.DocumentFontName);
                cssStyles += string.Format("font-family: {0}", ai.Preferences.DocumentFontName);
                if (ai.Preferences.DocumentFontSize == 0)
                {
                    cssStyles += "text-transform: uppercase;";
                }

                bc = ai.Preferences.CurrentTheme.HighlightColor;
                cssClasses += String.Format(".highlight {{ background-color: {0} !important; }}", bc.ToHEX());
                cssClasses += ".bold { font-weight: bold; }";
                cssClasses += ".underline { text-decoration: underline; }";
                cssClasses += ".word img { width: 100px; height: 100px; }";
            }

            string htmlHeader = String.Format(@"<!DOCTYPE html>
                    <html>
                    <head>
                        <meta charset=""utf-8"" />
                    <title>{0}</title>
                    <style type=""text/css"">
                        body {{
                            font-family: Arial;
                            {1}
                        }}
                        {2}
                    </style>
                    </head>
                    <body>", doc.Title, cssStyles, cssClasses);

                                string htmlFooter = @"</body>
                    </html>";

            string returnContent = String.Format("{0}{1}{2}", htmlHeader, doc.SimplifiedContent, htmlFooter);          

            return File(Encoding.UTF8.GetBytes(returnContent), "text/html", string.Format("{0}.html", doc.Title));
        }

        public System.Web.Mvc.FileResult ExportPdf(long DocumentID)
        {
            iTextSharp.text.Document pdfDoc = new iTextSharp.text.Document(iTextSharp.text.PageSize.A4, 50, 50, 20, 70);
            MemoryStream output = new MemoryStream();
            PdfWriter writer = PdfWriter.GetInstance(pdfDoc, output);
            long userId = Convert.ToInt64(HttpContext.User.Identity.Name);
            OpenBookSystemMVC.OBISReference.Document doc = null;
            OBSDataSource.GetDocument(DocumentID, out doc);
            AccountInfo ai = null;
            OBSDataSource.GetUserProfile(userId, out ai);
            if (doc == null || ai == null)
            {
                return null;
            }

            string returnContent = doc.SimplifiedContent;
            if (ai.Preferences.DocumentFontSize == 0)
            {
                returnContent = returnContent.ToUpper();            
            }

            pdfDoc.Open();

            iTextSharp.text.html.simpleparser.StyleSheet ST = new iTextSharp.text.html.simpleparser.StyleSheet();

            if (ai.Preferences != null)
            {
                iTextSharp.text.FontFactory.Register(Server.MapPath("/Content/fonts/verdana.ttf"), "Verdana");
                iTextSharp.text.FontFactory.Register(Server.MapPath("/Content/fonts/times.ttf"), "Times New Roman");
                iTextSharp.text.FontFactory.Register(Server.MapPath("/Content/fonts/calibri.ttf"), "Calibri");
                iTextSharp.text.FontFactory.Register(Server.MapPath("/Content/fonts/tahoma.ttf"), "Tahoma");

                iTextSharp.text.Font font = iTextSharp.text.FontFactory.GetFont(
                    ai.Preferences.DocumentFontName,
                    ai.Preferences.DocumentFontSize > 0 ? ai.Preferences.DocumentFontSize : 18);


                ST.LoadTagStyle(iTextSharp.text.html.HtmlTags.BODY, iTextSharp.text.html.HtmlTags.FACE, ai.Preferences.DocumentFontName);
            }
            else
            {
                ST.LoadTagStyle(iTextSharp.text.html.HtmlTags.BODY, iTextSharp.text.html.HtmlTags.FACE, "Times New Roman");
            }

            ST.LoadTagStyle(iTextSharp.text.html.HtmlTags.BODY, iTextSharp.text.html.HtmlTags.ENCODING, BaseFont.IDENTITY_H);

            List<iTextSharp.text.IElement> htmlElements = HTMLWorker.ParseToList(new StringReader(returnContent), ST);

            FormatImgElements(htmlElements);


            foreach (var item in htmlElements)
            {

                pdfDoc.Add(item);
            }

            pdfDoc.Close();

            var bytes = output.ToArray();


            return File(bytes, "application/pdf", string.Format("{0}.pdf", doc.Title));
        }

        private void AddHtmlDocNewLines(HtmlDocument doc)
        {            
            foreach (var item in doc.DocumentNode.SelectNodes("//p"))
            {
                HtmlNode newLine = doc.CreateElement("span");
                newLine.InnerHtml = "\n";
                item.AppendChild(newLine);
            }
        }

        //new HtmlNode(HtmlNodeType.Text, doc, item.ChildNodes.Count)
        //private HtmlNode GetNewlineNode(HtmlDocument doc, HtmlNode )

        private void FormatImgElements(List<iTextSharp.text.IElement> htmlElements)
        {
            foreach (iTextSharp.text.IElement item in htmlElements)
            {
                if (item.Chunks.Count > 1)
                {
                    FormatImgInChunks(item.Chunks.ToList());
                }                
            }
        }

        private void FormatImgInChunks(List<iTextSharp.text.Chunk> chunks)
        {
            for (int i = 0; i < chunks.Count; i++ )
            {
                if (chunks[i].Chunks.Count > 1)
                {
                    FormatImgInChunks(chunks[i].Chunks.ToList());
                }
                else if (chunks[i].Role == PdfName.FIGURE)
                {
                    var img = chunks[i].GetImage();
                    img.ScaleAbsolute(100f, 100f);
                    iTextSharp.text.Chunk imgChunk = new iTextSharp.text.Chunk(img, 120f, 120f);
                    chunks.RemoveAt(i);
                    chunks.Insert(i, imgChunk);                    
                }
            }
        }

        #endregion

        [HttpPost]
        [Authorize(Roles = "User")]
        [ValidateInput(false)]
        public System.Web.Mvc.ActionResult SaveDocument(EditDocumentModel model)
        {
            string strErrorMessage = string.Empty;
            long nDocID = 0;
            Document doc = new Document();
            doc.DateModified = DateTime.Now;
            doc.IsCompleted = model.IsCompleted;
            doc.OriginalDocumentContent = model.OriginalContent;
            doc.SimplifiedContent = model.SimplifiedContent;
            doc.Title = model.Title;
            doc.AuthorId = model.User.AccountId;//model.CarerID == 0 ? model.User.AccountId : model.CarerID;
            doc.UserId = model.User.AccountId;
            doc.Id = model.DocumentID;
            doc.IsFavourite = model.IsFavourite;
            doc.Summary = model.Summary;
            doc.Id = model.DocumentID;

            string result = OBSDataSource.SaveDocument(doc, out nDocID);
            if (string.IsNullOrEmpty(result))
            {
                //model. += UserLogging.LogUserAction(UserOperations.SaveDocument, model.User, LoggingOperationLevel.Level1, new object[] { doc.Id }, false);
                //UserLogging.LogUserAction(model.
                UserLogging.LogUserAction(model.UserActionsLog);
                UserLogging.LogUserAction(UserOperations.SaveDocument, model.User, LoggingOperationLevel.Level1, new object[] { doc.Id });
                return RedirectToAction("List", "Documents");
            }
            else
            {
                ViewBag.IsUnSaved = true;
                ModelState.AddModelError("Model", result);
                return View("EditDocument", model);
            }
        }

        [HttpPost]
        [ValidateInput(false)]
        public System.Web.Mvc.ActionResult NewDocument(EditDocumentModel model)
        {

            string strErrorMessage = string.Empty;

            if (ModelState.IsValid)
            {
                ModelState.Clear();
                model.IsNewDocument = false;
                OriginalUserDocument newDocument = new OriginalUserDocument();
                Document simpDocument = new Document();
                if (model.User.Role == AccountRoles.User)
                {
                    simpDocument.AuthorId = model.User.AccountId;
                    simpDocument.UserId = model.User.AccountId;
                }
                else if (model.User.Role == AccountRoles.Carer)
                {
                    simpDocument.AuthorId = model.User.AccountId;
                    simpDocument.UserId = model.ReceiverID;                    
                }

                if (!string.IsNullOrEmpty(model.Content))
                {
                    newDocument.Text = model.Content;
                    newDocument.Type = OriginalDocumentType.odtString;
                }
                else if (!string.IsNullOrEmpty(model.URL))
                {

                    newDocument.Url = model.URL;
                    newDocument.Type = OriginalDocumentType.odtUrl;
                }
                else if (model.FileForConvert.HasTextMIME() && model.FileForConvert.HasTextFile())
                {
                    newDocument.FileName = model.FileForConvert.FileName;
                    newDocument.FileContent = model.FileForConvert.GetContent();
                    newDocument.Type = OriginalDocumentType.odtFile;
                }

                string result = String.Empty;

                if (String.IsNullOrEmpty(model.Content)
                    && String.IsNullOrEmpty(model.URL)
                    && (!model.FileForConvert.HasTextMIME() || !model.FileForConvert.HasTextFile()))
                {
                    result = ClientDefault.EditDocument_NoTextInput;
                }
                else
                {
                    if (model.User.Role == AccountRoles.User)
                    {
                        result = OBSDataSource.SimplifyDocument(model.User.AccountId, newDocument, out simpDocument);
                    }
                    else if (model.User.Role == AccountRoles.Carer)
                    {
                        result = OBSDataSource.SimplifyCarerDocument(model.ReceiverID, newDocument, out simpDocument);
                    }
                    
                }

                if (string.IsNullOrEmpty(result))
                {
                    model.OriginalContent = simpDocument.OriginalDocumentContent;
                    model.SimplifiedContent = simpDocument.SimplifiedContent;
                    model.DocumentID = simpDocument.Id;
                    model.Summary = simpDocument.Summary;
                    AccountInfo currentUser = CurrentUser.Details(User.Identity.Name);

                    model.UserActionsLog = UserLogging.LogUserAction(UserOperations.OpenDocument, currentUser, LoggingOperationLevel.Level1, new object[] { model.DocumentID }, false);

                    if (model.User.Role == AccountRoles.Carer)
                    {
                        DocumentReviewModel reviewModel = new DocumentReviewModel(simpDocument);

                        return View("DocumentReview", reviewModel);
                    }
                }
                else
                {
                    ModelState.AddModelError("Model", result);
                    model.IsNewDocument = true;
                    View("EditDocument", model);
                }

            }
            ViewBag.IsUnSaved = "true";
            return View("EditDocument", model);
        }

        private string InitModelData(DocumentsModel model, AccountInfo user)
        {
            string result = string.Empty;
            List<BaseDocumentInfo> documents = new List<BaseDocumentInfo>();
            List<LibraryLabel> labels = new List<LibraryLabel>();
            AccountInfo currentUser = CurrentUser.Details(User.Identity.Name);

            result = OBSDataSource.GetUserDocuments(user.AccountId, -1, out documents);
            if (!string.IsNullOrEmpty(result))
            {
                return result;

            }
            result = OBSDataSource.GetUserLabels(out labels, user.AccountId);
            if (!string.IsNullOrEmpty(result))
            {
                return result;
            }

            // User is viewing own documents
            if (currentUser.AccountId == user.AccountId)
            {                               
                model.IsUser = true;
            }
            // Carer is viewing user's documents
            else if (currentUser.Role == AccountRoles.Carer)
            {
                model.IsUser = false;
            }

            List<object> lDocumentsJSON = new List<object>();
            documents = documents.OrderByDescending(x => x.IsFavourite).ThenByDescending(x => x.DateModified).ToList();
            foreach (BaseDocumentInfo doc in documents)
            {
                lDocumentsJSON.Add(new
                {
                    Id = doc.Id,
                    Title = doc.Title,
                    Summary = doc.Summary,
                    IsFavourite = doc.IsFavourite,
                    IsChecked = false,
                    Labels = doc.DocumentLabels,
                    CreatedOn = doc.DateModified.ToString("dd.MM.yyyy"),
                    IsDone = doc.IsCompleted,
                    IsRead = doc.IsRead,
                    IsGlobal = doc.AuthorId == 0
                });
            }

            List<object> lLabelsJSON = new List<object>();
            foreach (LibraryLabel label in labels)
            {
                lLabelsJSON.Add(new
                {
                    Id = label.ID,
                    Name = label.Name,
                    @Color = label.LabelColor.ToHEX(),
                    FontColor = label.FontColor.ToHEX()
                });
            }

            model.DocumentsJSON = JsonConvert.SerializeObject(lDocumentsJSON);
            model.LabelsJSON = JsonConvert.SerializeObject(lLabelsJSON);

            return result;
        }

        public System.Web.Mvc.ActionResult Print(long nDocID)
        {
            PrintDocumentModel printModel = new PrintDocumentModel(nDocID);
            if (!string.IsNullOrEmpty(printModel.Error))
            {
                ModelState.AddModelError("Model", printModel.Error);
            }
            return View("Print", printModel);
        }

        public FileResult GetOperationsLog()
        {
            if (!System.IO.File.Exists(UserLogging.LogFileName))
            {
                FileStream fs = System.IO.File.Create(UserLogging.LogFileName);
                fs.Dispose();

            }
            Response.Write('\uFEFF');
            FilePathResult fpr = new FilePathResult(UserLogging.LogFileName, "text/csv");
            fpr.FileDownloadName = UserLogging.LogDownloadName;
            Response.ContentEncoding = Encoding.UTF8;
            return fpr;
        }

        #region Document Review

        [HttpPost]
        [ValidateInput(false)]
        //[Authorize(Roles = "Carer")]
        public System.Web.Mvc.ActionResult DocumentReview(DocumentReviewModel model)
        {
            bool HasError = false;
            string result = string.Empty;
            Document doc = new Document();
            long docId = model.DocumentId;
            // new document
            if (docId == 0)
            {
                doc.SimplifiedContent = model.SimplifiedContent;
                doc.OriginalDocumentContent = model.OriginalContent;
                doc.UserId = model.UserId;
                doc.AuthorId = model.CarerId;
                doc.IsPrivate = false;
                doc.IsRead = false;
                doc.IsFavourite = false;
                doc.Title = model.DocumentTitle;
                doc.IsCompleted = false;
                doc.DateModified = DateTime.Now;

                result = OBSDataSource.SaveCarerEditedDocument(doc, out docId);
                if (!string.IsNullOrEmpty(result))
                {
                    model.ErrorMessage = result;
                    HasError = true;
                }
                else
                {
                    AccountInfo user = new AccountInfo();
                    OBSDataSource.GetUserProfile(model.CarerId, out user);
                    UserLogging.LogUserAction(model.UserActionsLog);
                    UserLogging.LogUserAction(UserOperations.SaveDocument, user, LoggingOperationLevel.Level1, new object[] { doc.Id });
                }

            }
            else
            {
                result = OBSDataSource.GetDocument(model.DocumentId, out doc);
                if (string.IsNullOrEmpty(result))
                {
                    doc.SimplifiedContent = model.SimplifiedContent;
                    doc.Title = model.DocumentTitle;
                    doc.Summary = model.Summary;

                    result = OBSDataSource.SaveCarerEditedDocument(doc, out docId);

                    if (!string.IsNullOrEmpty(result))
                    {
                        model.ErrorMessage = result;
                        HasError = true;
                    }
                    else
                    {
                        AccountInfo user = new AccountInfo();
                        OBSDataSource.GetUserProfile(model.CarerId, out user);
                        UserLogging.LogUserAction(model.UserActionsLog);
                        UserLogging.LogUserAction(UserOperations.SaveDocument, user, LoggingOperationLevel.Level1, new object[] { doc.Id });
                    }
                }
                else
                {
                    model.ErrorMessage = result;
                    HasError = true;
                }
            }

            if (HasError)
            {
                return View("DocumentReview", model);
            }
            else
            {
                return RedirectToAction("UserList", "Documents", new { id = model.UserId });
                //return RedirectToRoute(string.Format("/Documents/UserList/{0}", model.UserId));
            }
        }

        //[Authorize(Roles = "Carer")]
        public System.Web.Mvc.ActionResult DocumentReview(long docId, long userId)
        {
            DocumentReviewModel model = new DocumentReviewModel(docId, userId);
            OBSDataSource.MarkDocumentAsRead(docId);

            AccountInfo user = new AccountInfo();
            OBSDataSource.GetUserProfile(model.CarerId, out user);

            model.UserActionsLog = UserLogging.LogUserAction(UserOperations.OpenDocument, user, LoggingOperationLevel.Level1, new object[] { model.DocumentId }, false); 

            return View("DocumentReview", model);
        }

        [Authorize(Roles = "Carer")]
        public System.Web.Mvc.ActionResult GetSentenceData(string sentence, long documentId)
        {
            DocumentSentence docSent = new DocumentSentence();
            string result = OBSDataSource.GetTransformedSentenceData(sentence, documentId, out docSent);

            
            return Json(new { 
                AlternativeStructures = docSent.AlternativeStructures
                .Select( x => new { 
                    Content = x.Content, 
                    Type = x.Type.ToString() 
                }).ToList(),
                OriginalSentence = docSent.OriginalSentence
            });
        }

        [Authorize(Roles = "Carer")]
        public System.Web.Mvc.ActionResult GetWordSynonyms(string word)
        { 
            List<WordSynonym> synonyms = new List<WordSynonym>();
            string result = OBSDataSource.GetWordSynonyms(word, out synonyms);
            if (string.IsNullOrEmpty(result))
            {
                return Json(synonyms.Select(x => new
                {
                    Html = x.Synonym,
                    Description = x.Description
                }).ToList());
            }
            else
            {
                return Json(new {Error = result});
            }
        }

        [Authorize(Roles = "Carer")]
        public System.Web.Mvc.ActionResult GetWordPictures(string word)
        {
            IEnumerable<string> pictures = null;
            string result = OBSDataSource.GetCarerWordPictures(word, out pictures);
            if (string.IsNullOrEmpty(result))
            {
                return Json(pictures);
            }
            else
            {
                return Json(new { Error = result });
            }
        }

        [Authorize(Roles = "Carer")]
        public System.Web.Mvc.ActionResult GetWordDefinitions(string word)
        {
            IEnumerable<string> definitions = null;
            string result = OBSDataSource.GetCarerWordDefinitions(word, out definitions);
            if (string.IsNullOrEmpty(result))
            {
                return Json(definitions);
            }
            else
            {
                return Json(new { Error = result });
            }
        }

        [Authorize(Roles = "Carer")]
        public System.Web.Mvc.ActionResult SubmitAcceptedSentence(string newSentence, string oldSentence, long docId)
        {
            string annotetedSentence = string.Empty;

            string result = OBSDataSource.SubmitAcceptedSentence(newSentence, docId, oldSentence, out annotetedSentence);
            if (string.IsNullOrEmpty(result))
            {
                return Json(new {Sentence = annotetedSentence});
            }
            else
            {
                return Json(new {Error = result});
            }

        }

        [Authorize(Roles = "Carer")]
        public System.Web.Mvc.ActionResult GetWordAnaphoras(string word)
        {
            List<WordAnaphora> anaphoras = new List<WordAnaphora>();
            string result = OBSDataSource.GetWordAnaphoras(word, out anaphoras);
            if (string.IsNullOrEmpty(result))
            {
                return Json(anaphoras.Select(x => new
                {
                    Html = x.Anaphora,
                }).ToList());
            }
            else
            {
                return Json(new { Error = result });
            }
        }

        [HttpPost]
        [Authorize(Roles = "Carer")]
        public System.Web.Mvc.ActionResult SendSentenceFeedback(string feedbackMessage, string simplifiedSentence, int documentId)
        {
            if (string.IsNullOrWhiteSpace(feedbackMessage))
            {
                return Json(new
                {
                    Error = ClientDefault.Feedback_ErrorEmpty
                });
            }
            else
            {
                AccountInfo user = CurrentUser.Details(User.Identity.Name);
                try
                {
                    SmtpClient smtp = new SmtpClient();
                    MailMessage message = MailHelpers.CreateMailMessage(ConfigurationManager.AppSettings["FeedbackRecepient"], false);
                    message.Subject = "Sentence Feedback";
                    message.Body = string.Format("User ID:{0} {1}{1} User Name:{2} {1}{1} DocumentID: {3}  {1}{1} Feedback Message: {4}; {1}{1} Simplified Sentence: {5}", 
                        user.AccountId, 
                        Environment.NewLine, 
                        user.FullName(), 
                        documentId,
                        feedbackMessage,
                        simplifiedSentence);

                    smtp.Send(message);

                    return Json(new
                    {
                        Success = ClientDefault.Feedback_Success
                    });
                }
                catch (SmtpFailedRecipientsException ex)
                {
                    return Json(new
                    {
                        Error = ClientDefault.Feedback_RecepientError
                    });
                }
                catch (SmtpException ex)
                {
                    return Json(new
                    {
                        Error = ClientDefault.Feedback_SMTPError
                    });
                }
            }
        }

        [Authorize(Roles = "Carer")]
        public System.Web.Mvc.ActionResult GetObstacleFeedback(int obstacleId)
        {
            string[] feedback = null;
            string result = OBSDataSource.GetObstacleInfo(obstacleId, out feedback);
            
            if (string.IsNullOrEmpty(result))
            {
                for (int i = 0; i < feedback.Length; i++)
                {
                    feedback[i] = GetFeedbackLocalization(feedback[i]);
                }

                return Json(new {Feedback = feedback });
            }
            else
            {
                return Json(new {Error = result });
            }
        }

        [Authorize(Roles = "Carer")]
        public System.Web.Mvc.ActionResult ReprocessSentence(string sentence)
        {
            string result = string.Empty;
            string reprocessedSentence = string.Empty;
            result = OBSDataSource.ReprocessSentence(sentence, out reprocessedSentence);
            if (string.IsNullOrEmpty(result))
            {
                return Json(new { 
                    Sentence = reprocessedSentence
                });
            }
            else
            {
                return Json(new { 
                    Error = result
                });
            }
        }

        private string GetFeedbackLocalization(string feedbackTerm)
        {
            switch (feedbackTerm)
            {
                case ObstacleProperties.Acronym_Definitions: return ClientDefault.ObstacleFeedback_AcronymDefinitions;
                case ObstacleProperties.Coreference_Corefentity: return ClientDefault.ObstacleFeedback_CoreferenceCorefentity;
                case ObstacleProperties.Coreference_DefiniteDescription: return ClientDefault.ObstacleFeedback_CoreferenceDefiniteDescription;
                case ObstacleProperties.FigLangSet_FigLangDefinitions: return ClientDefault.ObstacleFeedback_FiglangsetFigLangDefinitions;
                case ObstacleProperties.Idiom_Definitions: return ClientDefault.ObstacleFeedback_IdiomDefinitions;
                case ObstacleProperties.Longword_Definitions: return ClientDefault.ObstacleFeedback_LongwordDefinitions;
                case ObstacleProperties.Longword_Synonyms: return ClientDefault.ObstacleFeedback_LongwordSynonyms;
                case ObstacleProperties.Multiword_Definitions: return ClientDefault.ObstacleFeedback_MultiwordDefinitions;
                case ObstacleProperties.Multiword_Synonyms: return ClientDefault.ObstacleFeedback_MultiwordSynonyms;
                case ObstacleProperties.Multiword_WikiUrls: return ClientDefault.ObstacleFeedback_MultiwordWikiurls;
                case ObstacleProperties.Polysemic_Definitions: return ClientDefault.ObstacleFeedback_PolysemicDefinitions;
                case ObstacleProperties.Polysemic_Synonyms: return ClientDefault.ObstacleFeedback_PolysemicSynonym;
                case ObstacleProperties.Rare_Definitions: return ClientDefault.ObstacleFeedback_RareDefinitions;
                case ObstacleProperties.Rare_Synonyms: return ClientDefault.ObstacleFeedback_RareSynonyms;
                case ObstacleProperties.Special_Definitions: return ClientDefault.ObstacleFeedback_SpecializedDefinitions;
                case ObstacleProperties.Specialized_Synonyms: return ClientDefault.ObstacleFeedback_SpecializedSynonyms;
                default: return feedbackTerm;
            }
        }

        private static class ObstacleProperties
        {
            /// <summary>
            /// acronymn-definitions
            /// </summary>
            public const string Acronym_Definitions = "acronymn-definitions";

            /// <summary>
            /// coreference-corefentity
            /// </summary>
            public const string Coreference_Corefentity = "coreference-corefentity";

            /// <summary>
            /// coreference-definitedescription
            /// </summary>
            public const string Coreference_DefiniteDescription = "coreference-definitedescription";

            /// <summary>
            /// figlangset-figlangdefinitions
            /// </summary>
            public const string FigLangSet_FigLangDefinitions = "figlangset-figlangdefinitions";

            /// <summary>
            /// idiom-definitions
            /// </summary>
            public const string Idiom_Definitions = "idiom-definitions";

            /// <summary>
            /// longword-definitions
            /// </summary>
            public const string Longword_Definitions = "longword-definitions";

            /// <summary>
            /// longword-synonyms
            /// </summary>
            public const string Longword_Synonyms = "longword-synonyms";

            /// <summary>
            /// multiword-definitions
            /// </summary>
            public const string Multiword_Definitions = "multiword-definitions";

            /// <summary>
            /// multiword-synonyms
            /// </summary>
            public const string Multiword_Synonyms = "multiword-synonyms";

            /// <summary>
            /// multiword-wikiurls
            /// </summary>
            public const string Multiword_WikiUrls = "multiword-wikiurls";
            
            /// <summary>
            /// polysemic-definitions
            /// </summary>
            public const string Polysemic_Definitions = "polysemic-definitions";

            /// <summary>
            /// polysemic-synonyms
            /// </summary>
            public const string Polysemic_Synonyms = "polysemic-synonyms";

            /// <summary>
            /// rare-definitions
            /// </summary>
            public const string Rare_Definitions = "rare-definitions";

            /// <summary>
            /// rare-synonyms
            /// </summary>
            public const string Rare_Synonyms = "rare-synonyms";

            /// <summary>
            /// specialized-definitions
            /// </summary>
            public const string Special_Definitions = "specialized-definitions";

            /// <summary>
            /// specialized-synonyms
            /// </summary>
            public const string Specialized_Synonyms = "specialized-synonyms";
        }


        #endregion

        #region Word Explanation

        [HttpPost]
        public string ExplainWord(string word)
        {
            WordExplanation we = null;
            string result = String.Empty;
            long userId = 0;

            try
            {
                bool parsed = Int64.TryParse(HttpContext.User.Identity.Name, out userId);
                if (!parsed)
                {
                    return null;
                }

                result = OBSDataSource.ExplainWord(userId, word, out we);

                if (string.IsNullOrEmpty(result))
                {
                    return JsonConvert.SerializeObject(we);
                }
                else
                {
                    return JsonConvert.SerializeObject(new {
                        Error = result
                    });
                }
            }
            catch (Exception ex)
            {
                ExceptionLogger.LogException(ex, "AccountController.ExplainWord");
            }
            return null;
        }

        [HttpPost]
        public string ExplainWordWithPictures(string word)
        {
            string result = String.Empty;
            long userId = 0;
            List<string> urls = new List<string>();

            try
            {
                bool parsed = Int64.TryParse(HttpContext.User.Identity.Name, out userId);
                if (!parsed)
                {
                    return null;
                }

                result = OBSDataSource.ExplainWordWithPictures(userId, word, out urls);

                if (string.IsNullOrEmpty(result))
                {
                    return JsonConvert.SerializeObject(urls);
                }
                else
                {
                    return JsonConvert.SerializeObject(new { 
                        Error = result
                    });
                }
            }
            catch (Exception ex)
            {
                ExceptionLogger.LogException(ex, "AccountController.ExplainWordWithPictures");
            }
            return null;
        }

        #endregion

        #region Library

        public System.Web.Mvc.ActionResult DeleteLabel(long nLabelID)
        {
            string result = OBSDataSource.DeleteLabel(nLabelID);
            if (string.IsNullOrEmpty(result))
            {
                return Json(new { Result = true });
            }
            else
            {
                return Json(new { Result = false, ErrorMessage = result });
            }
        }

        public System.Web.Mvc.ActionResult CreateLabel(string strLabelName, string strColorName, string strFontColorName)
        {
            if (string.IsNullOrEmpty(strLabelName))
            {
                return Json(string.Empty);
            }
            else
            {
                LibraryLabel newLabel = new LibraryLabel();
                newLabel.Name = strLabelName;
                newLabel.UserId = CurrentUser.Details(User.Identity.Name).AccountId;
                try
                {
                    newLabel.LabelColor = ColorTranslator.FromHtml(strColorName);
                    newLabel.FontColor = ColorTranslator.FromHtml(strFontColorName);
                }
                catch (Exception)
                {
                    return Json(string.Empty);
                }

                long labelId = 0;
                string result = OBSDataSource.CreateLabel(out labelId, newLabel);
                if (string.IsNullOrEmpty(result))
                {
                    return Json(new { Id = labelId });
                }
                else
                {
                    return Json(string.Empty);
                }
            }

        }

        public System.Web.Mvc.ActionResult UpdateLabel(string strLabelName, string strColorName, string strFontColorName, int nId)
        {
            if (string.IsNullOrEmpty(strLabelName) || string.IsNullOrEmpty(strColorName) || string.IsNullOrEmpty(strFontColorName))
            {
                return Json(string.Empty);
            }
            else
            {
                LibraryLabel newLabel = new LibraryLabel();
                newLabel.Name = strLabelName;
                newLabel.UserId = CurrentUser.Details(User.Identity.Name).AccountId;
                newLabel.ID = nId;
                try
                {
                    newLabel.LabelColor = ColorTranslator.FromHtml(strColorName);
                    newLabel.FontColor = ColorTranslator.FromHtml(strFontColorName);
                }
                catch (Exception)
                {
                    return Json(string.Empty);
                }

                string result = OBSDataSource.UpdateLabel(newLabel);
                if (string.IsNullOrEmpty(result))
                {
                    return Json(new { success = true });
                }
                else
                {
                    return Json(new { success = false });
                }
            }

        }

        public System.Web.Mvc.ActionResult ToggleDocumentFavourite(long nDocID, bool IsFavourite)
        {
            string result = OBSDataSource.UpdateDocumentFavouriteStatus(nDocID, IsFavourite);
            if (string.IsNullOrEmpty(result))
            {
                return Json(new { Result = true });
            }
            else
            {
                return Json(new { Result = false, ErrorMessage = result });
            }
            //return Json(string.Empty);
        }

        public System.Web.Mvc.ActionResult ToggleDocumentCompleted(long nDocId)
        {
            Document doc = null;
            string result = OBSDataSource.GetDocument(nDocId, out doc);
            if (String.IsNullOrEmpty(result))
            {
                doc.IsCompleted = !doc.IsCompleted;
                result = OBSDataSource.SaveDocument(doc, out nDocId);
                if (String.IsNullOrEmpty(result))
                {
                    return Json(new { success = true, isDone = doc.IsCompleted });
                }
                else
                {
                    return Json(new { success = false });
                }
            }
            else
            {
                return Json(new { success = false });
            }
        }

        public System.Web.Mvc.ActionResult UpdateDocumentLabels(long nDocID, long[] labels)
        {
            string result = OBSDataSource.UpdateDocumentLabels(nDocID, labels);
            if (string.IsNullOrEmpty(result))
            {
                return Json(new { Result = true });
            }
            else
            {
                return Json(new { Result = false, ErrorMessage = result });
            }
        }

        public System.Web.Mvc.ActionResult AskCarer(string subject, string message, long documentId)
        {            
            AccountInfo user = CurrentUser.Details(User.Identity.Name);
            Notification newNotification = new Notification();
            newNotification.DocumentId = documentId;
            newNotification.SenderId = user.AccountId;
            newNotification.ReceiverId = user.CarerId;
            newNotification.MessageContent = message;
            newNotification.SentOn = DateTime.Now;
            newNotification.Subject = subject;

            string result = string.Empty;
            result = OBSDataSource.SendNotification(newNotification);
            if (string.IsNullOrEmpty(result))
            {
                return Json(new { Result = true });
            }
            else
            {
                return Json(new { Result = false, ErrorMessage = result });
            }
            
        }

        #endregion

    }
}
