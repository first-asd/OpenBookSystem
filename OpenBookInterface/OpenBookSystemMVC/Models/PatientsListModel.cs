using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using OpenBookSystemMVC.OBISReference;
using Resources;

namespace OpenBookSystemMVC.Models
{
    public class PatientsListModel
    {
        public string CarerTitle { get; set; }

        public List<CarerUser> Patients { get; set; }

        public List<PatientsMenuItem> MenuItems { get; set; }

        public PatientsListModel()
        {
            Patients = new List<CarerUser>();

            MenuItems = new List<PatientsMenuItem>();

            MenuItems.Add(new PatientsMenuItem { ButtonLabel = ClientDefault.Documents_Delete_C, IconURL = "/Images/deletePatientIcon.png", OnClickScript = "if(CheckPatSelected()) { DeletePatient(); } else { return false;}" });
            MenuItems.Add(new PatientsMenuItem { ButtonLabel = ClientDefault.Documents_Edit_C, IconURL = "/Images/editPationtIcon.png", OnClickScript = "if(CheckPatSelected()) { EditPatient(); } else { return false;}" });
            MenuItems.Add(new PatientsMenuItem { ButtonLabel = ClientDefault.Documents_Add_C, IconURL = "/Images/addPatientIcon.png", OnClickScript = "AddPatient();"});
        }

        public string UserImageUrl(long userId) 
        {
            return string.Format("/GetUserImage/{0}",userId);
        }

        public string EditUserProfile(long userId)
        {
            return string.Format("/Account/Edit?nUserID={0}&preferences=true", userId);
        }

        public string EditUserLibrary(long userId)
        {
            return string.Format("/Documents/UserList/{0}",userId);
        }

        public string ViewUserNotifications(long userId)
        {
            return string.Format("/Notifications/List/{0}", userId);
        }

        public string EditUserProfileFront(long userId)
        {
            return string.Format("/Account/Edit?nUserID={0}", userId);
        }
    }

    public class PatientsMenuItem
    {
        public string IconURL { get; set; }
        public string ButtonLabel { get; set; }
        public string OnClickScript { get; set; }
    }
}