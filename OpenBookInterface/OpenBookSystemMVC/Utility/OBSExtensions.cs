using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Html;
using OpenBookSystemMVC.OBISReference;
using Resources;
using System.Globalization;
using System.Collections;
using System.Threading;

namespace OpenBookSystemMVC
{
    public static class OBSExtensions
    {
        #region File upload and handling

        public static bool HasImageMIME(this HttpPostedFileBase image)
        {

            if (image != null)
            {
                foreach (string mime in AcceptedImages.AcceptedMIMETypes)
                {
                    if (mime == image.ContentType)
                    {
                        return true;
                    }
                }
            }

            return false;
        }

        public static bool HasImageFile(this HttpPostedFileBase image)
        {
            if (image != null)
            {
                string FileExtension = System.IO.Path.GetExtension(image.FileName).ToLower();
                foreach (string extension in AcceptedImages.AcceptedFileTypes)
                {
                    if (extension == FileExtension)
                    {
                        return true;
                    }
                }
            }

            return false;
        }

        public static bool IsValidImageFile(this HttpPostedFileBase image, out string strErrorMessage)
        {
            strErrorMessage = string.Empty;

            if (image == null)
            {
                return true;
            }

            if (image.HasImageMIME() && image.HasImageFile())
            {
                if (image.ContentLength > AcceptedImages.MaximumAcceptedSize)
                {
                    strErrorMessage = string.Format(ClientDefault.FileUpload_FileTooBig, AcceptedImages.MaxSizeDisplayName);
                    return false;
                }

                return true;
            }
            else
            {
                strErrorMessage = ClientDefault.FileUpload_FileNotCorrectType;
                return false;
            }
;
        }

        public static bool HasTextMIME(this HttpPostedFileBase file)
        {
            if (file != null)
            {
                foreach (string type in AcceptedDocuments.AcceptedMIMETypes)
                {
                    if (type == file.ContentType)
                    {
                        return true;
                    }
                }
            }

            return false;
        }

        public static bool HasTextFile(this HttpPostedFileBase file)
        {
            string FileExtension = System.IO.Path.GetExtension(file.FileName).ToLower();

            if (file != null)
            {
                foreach (string extension in AcceptedDocuments.AcceptedFileTypes)
                {
                    if (extension == FileExtension)
                    {
                        return true;
                    }
                }
            }

            return false; 
        }

        public static byte[] GetContent(this HttpPostedFileBase file)
        {
            byte[] content = null;
            if (file != null)
            {
                content = new byte[file.ContentLength];
                file.InputStream.Position = 0;
                file.InputStream.Read(content, 0, file.ContentLength);
                return content;
            }
            else
            {
                return content;
            }
        }

        public static string FullName(this AccountInfo user)
        {
           return user.FirstName + " " + user.LastName;
        }

        public static UserImage ToUserImage(this HttpPostedFileBase image)
        {
            string strErrorMessage = string.Empty;
            UserImage userImage = null;

            if (image.IsValidImageFile(out strErrorMessage) && (image != null))
            {
                userImage = new UserImage();
                userImage.ContentType = image.ContentType;
                userImage.FileContent = image.GetContent();
                userImage.FileName = image.FileName;
            }

            return userImage;
        }

        public static List<SelectListItem> ToSelectList(this List<AccountInfo> users, bool HasEmptyElement)
        {
            List<SelectListItem> result = new List<SelectListItem>();
            if (users.Any())
            {
                if (HasEmptyElement)
                {
                    result.Add(new SelectListItem { Value = string.Empty, Text = string.Empty, Selected = true });
                }

                foreach (AccountInfo user in users)
                {
                    result.Add(new SelectListItem { Text = user.FullName(), Value = user.AccountId.ToString() });
                }
            }

            return result;
        }

        #endregion

        public static string ToHEX(this System.Drawing.Color color)
        {
            return "#" + color.R.ToString("X2") + color.G.ToString("X2") + color.B.ToString("X2");
        }
    }

    public static class EnumDropDownList
    {
        public static HtmlString EnumDropDownListFor<TModel, TProperty>(this HtmlHelper<TModel> htmlHelper, Expression<Func<TModel, TProperty>> modelExpression, object htmlAttributes)
        {
            var typeOfProperty = modelExpression.ReturnType;
            if (!typeOfProperty.IsEnum)
                throw new ArgumentException(string.Format("Type {0} is not an enum", typeOfProperty));



            List<SelectListItem> listItems = new List<SelectListItem>();
            Array values = Enum.GetValues(typeOfProperty);
            Array names = Enum.GetNames(typeOfProperty);
            for (int i = 0; i < values.Length; i++)
            {
                listItems.Add(new SelectListItem { Value = values.GetValue(i).ToString(), Text = names.GetValue(i).ToString() });
            }
            SelectList selList = new SelectList(listItems, "Value", "Text");

            return htmlHelper.DropDownListFor(modelExpression, LocalizeEnumValues(selList), htmlAttributes);
        }

        private static IEnumerable<SelectListItem> LocalizeEnumValues(SelectList enumList) 
        {
            List<SelectListItem> result = new List<SelectListItem>();
  
            foreach (SelectListItem item in enumList)
            {
                SelectListItem newItem = new SelectListItem();
                newItem.Value = item.Value;
                newItem.Text = LocalizeTextValue(item.Text);

                result.Add(newItem);
            }


            return result;
        }

        //  This is outrageous.
        private static string LocalizeTextValue(string textValue)
        {
            string resourceKey = string.Empty;
            string result = textValue;
            CultureInfo enCulture = new CultureInfo("en-GB");
            var resourceSet = ClientDefault.ResourceManager.GetResourceSet(enCulture, true, true).OfType<DictionaryEntry>();
            // I cananot use FirstOrDefault, because I cannot use != null or == null with DictionaryEntry, so I have to do it the hard way.
            // Since all our enums have english names, first search the record in the english dictionary, then if one is found, go get the specific culture one.
            // I feel terrible for doing this :(
            List<DictionaryEntry> entry = resourceSet.Where(x => x.Value.ToString() == textValue).DefaultIfEmpty(new DictionaryEntry("NOT_FOUND","NOT_FOUND")).ToList();
            
            
            if (entry[0].Value.ToString() != "NOT_FOUND")
            {
                resourceKey = entry[0].Key.ToString();

                resourceSet = ClientDefault.ResourceManager.GetResourceSet(Thread.CurrentThread.CurrentCulture, true, true).OfType<DictionaryEntry>();
                entry = resourceSet.Where(x => x.Key.ToString() == resourceKey).DefaultIfEmpty(new DictionaryEntry("NOT_FOUND", "NOT_FOUND")).ToList();
                if (entry[0].Value.ToString() != "NOT_FOUND")
                {
                    result = entry[0].Value.ToString();
                }
            }
            

            return result;
        }
    }



}