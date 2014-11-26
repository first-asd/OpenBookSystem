using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Routing;

namespace OpenBookSystemMVC.Models
{
    public class MenuItem
    {
        public string Label { get; set; }
        public string Route { get; set; }
        public bool IsSelected { get; set; }
        public string IconUrl { get; set; }
        public bool IsSeparator { get; set; }
        public string Hint { get; set; }
        public string Attributes { get; set; }

        public MenuItem()
        {
            IsSelected = false;
            IsSeparator = false;
            Attributes = string.Empty;
        }
    }

    public class OBISMenu
    {
        public OBISMenu()
        {
            Items = new List<MenuItem>();
        }
        public List<MenuItem> Items { get; set; }
        public bool IsUnAuthorizedUser { get; set; }
        public string HelpPage { get; set; }
    }
}