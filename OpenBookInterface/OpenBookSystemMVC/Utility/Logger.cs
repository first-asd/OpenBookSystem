using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Diagnostics;
using System.Reflection;

namespace OpenBookSystemMVC
{
    [Serializable]
    public enum LogPlace { File, EventLog, FileAndEventLog };

    [Serializable]
    public class Logger
    {
        object logLock;
        EventLog eventLog;

        #region Public Properties
        
        public LogPlace DefaultLogPlace { get; set; }
        public string DefaultLogFileName { get; set; }

        public string EventSource 
        {
            get { return eventLog.Source; }
            set { eventLog.Source = value; }
        }

        public string EventLogName
        {
            get { return eventLog.Log; }
            set { eventLog.Log = value; }
        }

        #endregion

        public Logger(LogPlace logPlace)
        {
            logLock = new object();

            FileInfo fi = new FileInfo(Assembly.GetEntryAssembly().Location);
            DefaultLogFileName = fi.FullName.Substring(0, fi.FullName.Length - fi.Extension.Length) + ".log";

            eventLog = new EventLog();
            eventLog.Log = "Application";
            eventLog.Source = fi.Name.Substring(0, fi.Name.Length - fi.Extension.Length);

            DefaultLogPlace = logPlace;
        }

        public Logger()
        {
            logLock = new object();
        }

        public void Log(string str, LogPlace logPlace, string fileName, bool includeDetails)
        {
            lock (logLock)
            {
                if (logPlace == LogPlace.File || logPlace == LogPlace.FileAndEventLog)
                    WriteToFile(str, fileName, includeDetails);

                if (logPlace == LogPlace.EventLog || logPlace == LogPlace.FileAndEventLog)
                    WriteToEventLog(str);
            }
        }

        public void Log(string str)
        {
            Log(str, DefaultLogPlace, DefaultLogFileName, true);
        }

        public void Log(string str, Exception e, bool includeStackTrace, bool includeInnerStackTrace)
        {
            string tempStr = str;

            Exception currentException = e;
            while (currentException != null)
            {
                tempStr += Environment.NewLine + 
                           currentException.GetType().ToString() + ": " + currentException.Message;            
                
                if (includeStackTrace)
                {
                    tempStr += Environment.NewLine +
                               "Stack Trace: " + Environment.NewLine +
                               currentException.StackTrace;
                }

                if (includeInnerStackTrace)
                {
                    currentException = currentException.InnerException;
                    if (currentException != null)
                        tempStr += Environment.NewLine + Environment.NewLine +
                                   "Inner Exception:";
                }
                else
                    break;
            }

            Log(tempStr);
        }

        public void Log(string str, Exception e)
        {
            Log(str, e, true, true);
        }

        private bool WriteToFile(string str, string fileName, bool includeDetails)
        {
            try
            {
                using (StreamWriter sw = File.AppendText(fileName))
                {
                    if (includeDetails)
                        sw.WriteLine(DateTime.Now.ToString());
                    sw.WriteLine(str);
                    if (includeDetails)
                        sw.WriteLine();
                }

                return true;
            }
            catch
            {
                // Couldn't write to the log file
                return false;
            }
        }

        private bool WriteToEventLog(string str)
        {
            try
            {
                eventLog.WriteEntry(str, System.Diagnostics.EventLogEntryType.Warning);
                return true;
            }
            catch
            {
                return false;
            }
        }
    }
}
