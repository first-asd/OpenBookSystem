using OpenBookSystemMVC.OBISReference;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace OpenBookSystemMVC.Models
{
    public class DocumentsModel
    {
        public string PageTitle { get; set; }
        public List<BaseDocumentInfo> Documents { get; set; }
        public string DocumentsJSON { get; set; }
        public string LabelsJSON { get; set; }
        public bool IsUser { get; set; }
        public long UserId { get; set; }

        public DocumentsModel()
        {
            Documents = new List<BaseDocumentInfo>();
        }
    }

    public class DocumentsMenuItem
    {
        public string IconURL { get; set; }
        public string ButtonLabel { get; set; }
        public string OnClickScript { get; set; }
    }

}