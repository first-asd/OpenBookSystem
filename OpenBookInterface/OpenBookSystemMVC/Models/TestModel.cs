using OpenBookSystemMVC.OBISReference;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

namespace OpenBookSystemMVC.Models
{
    public class TestModel
    {
        public TestModel(Document doc)
        {
            this.document = doc;
        }

        public Document document = null;

        public string GetExplanationTable()
        {
            StringBuilder sb = new StringBuilder();

            List<DocumentDefinition> definitions = new List<DocumentDefinition>();
            var result = OBSDataSource.GetDocumentDefinitions(document.Id, out definitions);
            if (String.IsNullOrEmpty(result))
            {
                if (definitions.Count() > 0)
                {
                    foreach (var d in definitions)
                    {
                        sb.Append(String.Format(@"
                            <tr>
                                <td class='first_col'>{0}</td>
                                <td>{1}</td>
                            </tr>
                        ", d.Term, d.Definition));
                    }
                    string TableBeginTag = @"<table id='tableExplanations'>";
                    string TableEndTag = @"</table>";

                    return String.Format("{0}{1}{2}", TableBeginTag, sb.ToString(), TableEndTag);
                }
            }

            return String.Empty;
        }
    }
}