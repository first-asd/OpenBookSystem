using OpenBookSystemMVC.OBISReference;
using System.Web;
using System.Drawing;
using System.Web.Mvc;
using System.ComponentModel.DataAnnotations;
using System;


namespace OpenBookSystemMVC.Models
{
    public class PrintDocumentModel
    {
        [DataType(DataType.MultilineText)]
        [AllowHtml]
        public string SimplifiedContent { get; set; }
        
        public string Title { get; set; }
        
        AccountInfo User { get; set; }

        public string Error { get; set; }

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

        public PrintDocumentModel(long documentId)
        {
            Document document;

            User = CurrentUser.Details(HttpContext.Current.User.Identity.Name);

            string result = OBSDataSource.GetDocument(documentId, out document);
            if (string.IsNullOrEmpty(result))
            {
                if (document != null)
                {
                    SimplifiedContent = document.SimplifiedContent;
                    Title = document.Title;
                }
                else
                {

                }
            }
            else
            {
                Error = result;
            }
        }
       
    }
}