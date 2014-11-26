using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Text;
using System.Web.Configuration;
using System.IO;

namespace OpenBookSystemMVC
{
    public static class ExceptionLogger
    {
        private static string errorFilePath;
        private static string delimiter = Environment.NewLine;


        static ExceptionLogger()
        {
            //errorFilePath = HttpContext.Current.ApplicationInstance.Server.MapPath("~/App_Data/ErrorLog.txt");
        }

        public static void LogException(Exception ex, string location)
        {
            if (ex == null) return;
            if (ex is System.Threading.ThreadAbortException) return;
            if (string.IsNullOrEmpty(errorFilePath)) 
                errorFilePath = HttpContext.Current.ApplicationInstance.Server.MapPath("~/App_Data/ErrorLog.txt");

            StringBuilder sbError = new StringBuilder();

            AppendError(sbError, "Entry date", DateTime.Now.ToString("dd'-'MM'-'yyyy HH':'mm':'ss"));
            AppendError(sbError, "Exception type", (ex.GetType().FullName));
            AppendError(sbError, "Stack trace", ex.StackTrace);
            AppendError(sbError, "Location", location);
            AppendError(sbError, "Exception message", GetErrorMessage(ex));

            WriteError(sbError.ToString());
        }

        public static void LogError(string message, string location)
        {                       
            if (string.IsNullOrEmpty(errorFilePath))
                errorFilePath = HttpContext.Current.ApplicationInstance.Server.MapPath("~/App_Data/ErrorLog.txt");

            StringBuilder sbError = new StringBuilder();

            AppendError(sbError, "Entry date", DateTime.Now.ToString("dd'-'MM'-'yyyy HH':'mm':'ss"));
            AppendError(sbError, "Exception type", ("Custom error"));
            AppendError(sbError, "Stack trace", "");
            AppendError(sbError, "Location", location);
            AppendError(sbError, "Exception message", message);

            WriteError(sbError.ToString());
        }

        private static string GetErrorMessage(Exception ex)
        {
            StringBuilder sbErrorMessage = new StringBuilder(ex.Message.Length);
            do
            {
                sbErrorMessage.Append(ex.Message);
                sbErrorMessage.Append(Environment.NewLine);
                ex = ex.InnerException;
            } 
            while (ex != null);
            return sbErrorMessage.ToString();
        }

        private static void AppendError(StringBuilder sb, string title, string message)
        {
            if (sb.Length != 0) sb.Append(delimiter);
            sb.Append(title + ": ");
            sb.Append(message);
        }

        private static void WriteError(string errorMessage)
        {
            using (FileStream fsErrorLogger = new FileStream(errorFilePath, FileMode.Append))
            {
                using (StreamWriter swErrorLogger = new StreamWriter(fsErrorLogger))
                {
                    swErrorLogger.WriteLine(errorMessage + Environment.NewLine);
                }
            }
        }
    }
}