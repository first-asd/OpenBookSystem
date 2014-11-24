using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using OpenBookSystemMVC.OBISReference;

namespace OpenBookSystemMVC.Models
{
    public class DocumentReviewModel
    {
        public string SimplifiedContent { get; set; }

        public long UserId { get; set; }

        public long CarerId { get; set; }

        public string DocumentTitle { get; set; }

        public long DocumentId { get; set; }

        public string ErrorMessage { get; set; }

        public string OriginalContent { get; set; }

        public string Summary { get; set; }

        public string UserActionsLog { get; set; }

        public AccountInfo User;

        public DocumentReviewModel()
        { 
            
        }

        public DocumentReviewModel(long docId, long userId)
        { 
            Document doc = new Document();
            string result = OBSDataSource.GetDocument(docId, out doc);
            if (string.IsNullOrEmpty(result))
            {
                SimplifiedContent = doc.SimplifiedContent;
                OriginalContent = doc.OriginalDocumentContent;
                DocumentTitle = doc.Title;
                DocumentId = doc.Id;
                CarerId = CurrentUser.Details(HttpContext.Current.User.Identity.Name).AccountId;
                UserId = userId;
                Summary = doc.Summary;
                OBSDataSource.GetUserProfile(userId, out User);                
            }
        }

        public DocumentReviewModel(Document simplifiedDocument)
        {
            SimplifiedContent = simplifiedDocument.SimplifiedContent;
            DocumentTitle = simplifiedDocument.Title;
            DocumentId = simplifiedDocument.Id;
            CarerId = simplifiedDocument.AuthorId;
            UserId = simplifiedDocument.UserId;
            Summary = simplifiedDocument.Summary;
            OriginalContent = simplifiedDocument.OriginalDocumentContent;
            OBSDataSource.GetUserProfile(UserId, out User); 
        }
    }
}