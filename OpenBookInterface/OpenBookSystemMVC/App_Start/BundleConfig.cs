using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Optimization;

namespace OpenBookSystemMVC
{
    public class BundleConfig
    {
        public static void RegisterBundles(BundleCollection bundles)
        {
            BundleTable.EnableOptimizations = true;
            bundles.UseCdn = false;

            #region Script bundles 
            bundles.Add(new ScriptBundle("~/bundles/jquery", "//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js") //"//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"
                .Include(
                "~/Scripts/jquery-1.8.2.js"));

            bundles.Add(new ScriptBundle("~/bundles/jquery-validation", "//ajax.aspnetcdn.com/ajax/jquery.validate/1.10.0/jquery.validate.min.js")
                .Include(
                "~/Scripts/jquery.validate.min.js"));

            bundles.Add(new ScriptBundle("~/bundles/jquery-unobtrusive", "//ajax.aspnetcdn.com/ajax/mvc/3.0/jquery.unobtrusive-ajax.min.js")
                .Include(
                "~/Scripts/jquery.unobtrusive-ajax.min.js"));

            bundles.Add(new ScriptBundle("~/bundles/jquery-unobtrusive-validate")// , "//ajax.aspnetcdn.com/ajax/mvc/3.0/jquery.validate.unobtrusive.min.js")
                .Include(
                "~/Scripts/jquery.validate.unobtrusive.min.js"));

            bundles.Add(new ScriptBundle("~/bundles/modernizr")
                .Include(
                "~/Scripts/modernizr.custom.full.js"
                ));

            bundles.Add(new ScriptBundle("~/bundles/menuHelper")
                .Include(
                "~/Scripts/HelpMenu.js"));

            bundles.Add(new ScriptBundle("~/bundles/fileValidations")
                .Include(
                "~/Scripts/FileSizeValidation.js",
                "~/Scripts/ImagesOnlyValidation.js",
                "~/Scripts/TextFilesOnlyValidation.js"));

            bundles.Add(new ScriptBundle("~/bundles/smoothscroller")
                .Include(
                "~/Scripts/jquery.mousewheel.min.js",
                "~/Scripts/jquery.smoothdivscroll-1.2-min.js",
                "~/Scripts/SmoothScrollerHelpers.js"));

            bundles.Add(new ScriptBundle("~/bundles/colorpicker")
                .Include(
                "~/Scripts/jquery.colorPicker.js"));

            bundles.Add(new ScriptBundle("~/bundles/smoothhelper")
                .Include(
                "~/Scripts/SmoothScrollerHelpers.js"));

            bundles.Add(new ScriptBundle("~/bundles/editdoc")
                .Include(
                "~/Scripts/DocumentEditHelpers.js"));

            bundles.Add(new ScriptBundle("~/bundles/jeditable")
                .Include(
                "~/Scripts/jquery.jeditable.js"));

            bundles.Add(new ScriptBundle("~/bundles/globals")
                .Include(
                "~/Scripts/GoogleAnalytics.js",
                "~/Scripts/Globals.js",
                //"~/Scripts/jquery-ui-1.9.1.custom.min.js",
                "~/Scripts/jquery.outerhtml.js",
                "~/Scripts/Layout.js"));

            bundles.Add(new ScriptBundle("~/bundles/useracc")
                .Include(
                "~/Scripts/jquery.colorPicker.js",
                "~/Scripts/UserAccount.js"));

            bundles.Add(new ScriptBundle("~/bundles/agevalid")
                .Include("~/Scripts/AgeRangeValidation.js"));

            bundles.Add(new ScriptBundle("~/bundles/login")
                .Include("~/Scripts/LogIn.js"));

            bundles.Add(new ScriptBundle("~/bundles/knockout", "http://ajax.aspnetcdn.com/ajax/knockout/knockout-2.2.1.js")
                .Include("~/Scripts/knockout-2.2.1.js"));

            bundles.Add(new ScriptBundle("~/bundles/knockout-mapping")
                .Include("~/Scripts/knockout-mapping-2.3.5.js"));

            bundles.Add(new ScriptBundle("~/bundles/chosen")
                .Include("~/Scripts/chosen/chosen.jquery.min.js"));

            bundles.Add(new ScriptBundle("~/bundles/test")
                .Include("~/Scripts/Tests.js"));

            bundles.Add(new ScriptBundle("~/bundles/library")
            .Include("~/Scripts/LibraryViewModel.js"));

            bundles.Add(new ScriptBundle("~/bundles/moment")
                .Include("~/Scripts/moment/moment.min.js"));

            bundles.Add(new ScriptBundle("~/bundles/resourcesBG")
                .Include("~/Scripts/Resources/ResourcesBG.js"));

            bundles.Add(new ScriptBundle("~/bundles/resourcesEN")
                .Include("~/Scripts/Resources/ResourcesEN.js"));

            bundles.Add(new ScriptBundle("~/bundles/resourcesES")
                .Include("~/Scripts/Resources/ResourcesES.js"));

            bundles.Add(new ScriptBundle("~/bundles/notifications")
                .Include("~/Scripts/NotificationsViewModel.js"));

            bundles.Add(new ScriptBundle("~/bundles/users")
                .Include("~/Scripts/UsersViewModel.js"));

            //bundles.Add(new ScriptBundle("~/bundles/chatview")
            //    .Include("~/Scripts/ChatViewModel.js"));

            bundles.Add(new ScriptBundle("~/bundles/doc-review")
                .Include("~/Scripts/DocumentReviewViewModel.js"));

            bundles.Add(new ScriptBundle("~/bundles/spectrum")
                .Include("~/Scripts/Spectrum/spectrum.js"));

            bundles.Add(new ScriptBundle("~/bundles/magnific")
                .Include("~/Scripts/Magnific/jquery.magnific-popup.js"));

            #endregion

            #region Style bundles

            bundles.Add(new StyleBundle("~/Content/smoothDivScroll")
                .Include(
                "~/Content/smoothDivScroll.css"));

            bundles.Add(new StyleBundle("~/Content/account")
                .Include(
                "~/Content/account.css"));

            bundles.Add(new StyleBundle("~/Content/colorpicker")
                .Include(
                "~/Content/colorPicker.css"));

            bundles.Add(new StyleBundle("~/Content/global")
                .Include(
                "~/Content/Site.css",
                "~/Content/Users.css",
                "~/Content/EditUserDetails.css",
                "~/Content/Preferences.css",
                "~/Content/themes/ui-lightness/jquery-ui-1.9.1.custom.css"));

            bundles.Add(new StyleBundle("~/Content/login")
                .Include(
                "~/Content/LogIn.css"));

            bundles.Add(new StyleBundle("~/Content/signup")
                .Include(
                "~/Content/SignUp.css"));

            bundles.Add(new StyleBundle("~/Content/docedit")
                .Include(
                "~/Content/DocumentEdit.css"));

            bundles.Add(new StyleBundle("~/Content/useracc")
                .Include(
                "~/Content/UserAccount.css"));

            bundles.Add(new StyleBundle("~/Content/notifs")
                .Include(
                "~/Content/Notifications.css"));


            bundles.Add(new StyleBundle("~/Content/error")
                .Include(
                "~/Content/ErrorPages.css"));

            bundles.Add(new StyleBundle("~/Content/chosen")
                .Include("~/Scripts/chosen/chosen.css"));

            bundles.Add(new StyleBundle("~/Content/test")
                .Include("~/Content/Tests.css"));

            bundles.Add(new StyleBundle("~/Content/library")
                .Include("~/Content/CSSReset.css")
                .Include("~/Content/normalize.css")
                .Include("~/Content/Library.css"));

            bundles.Add(new StyleBundle("~/Content/font-awesome/css/fontawesome")
                .Include("~/Content/font-awesome/css/font-awesome.css"));

            bundles.Add(new StyleBundle("~/Content/doc-review")
                .Include("~/Content/DocumentReview.css"));

            bundles.Add(new StyleBundle("~/Scripts/Spectrum/spectrum")
                .Include("~/Scripts/Spectrum/spectrum.css"));

            bundles.Add(new StyleBundle("~/Scripts/Magnific/magnific")
                .Include("~/Scripts/Magnific/magnific-popup.css"));

            bundles.Add(new StyleBundle("~/Content/passrequest")
                .Include("~/Content/PaswordRequest.css"));


            #endregion

        }
    }
}