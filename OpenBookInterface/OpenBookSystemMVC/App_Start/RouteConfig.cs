using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Routing;

namespace OpenBookSystemMVC
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.IgnoreRoute("PIE.htc");
            routes.IgnoreRoute("Content/PIE/PIE.htc");
            //routes.IgnoreRoute("favicon.ico"); // IF REMOVED WOULD CRASH THE SITE, AS IT IS PASSED INTO LANGUAGE CHANGE ROUTE!!!

            routes.MapRoute(
                name: "Default",
                url: "",
                defaults: new { controller = "Master", action = "Home" }
            );

            routes.MapRoute(
                name: "Unauthorized",
                url: "Not-Authorized",
                defaults: new { controller = "Master", action = "NotAuthorized" }
            );

            routes.MapRoute(
                name: "General Error",
                url: "Error",
                defaults: new { controller = "Error", action = "ServerError" }
            );

            routes.MapRoute(
                name: "SignUp",
                url: "SignUp/{SignType}",
                defaults: new { controller = "Master", action = "SignUp" }
            );            

            routes.MapRoute(
                name: "LogInRedirect",
                url: "LogIn",
                defaults: new { controller = "Master", action = "Home" }
            );

            routes.MapRoute(
                name: "SignOut",
                url: "SignOut",
                defaults: new { controller = "Master", action = "SignOut" }
            );

            routes.MapRoute(
                name: "What's new",
                url: "WhatIsNew",
                defaults: new { controller = "Master", action = "WhatIsNew" }
            );


            routes.MapRoute(
                name: "RequestPasswordRetrieve",
                url: "RequestPasswordRetrieve",
                defaults: new { controller = "Master", action = "RequestPasswordRetrieval" }
            );

            routes.MapRoute(
                name: "RetriveOperatinsLog",
                url: "GetLog",
                defaults: new { controller = "Documents", action = "GetOperationsLog" }
            );

            //routes.MapRoute(
            //    name: "Notifications general",
            //    url: "Notifications/List/{userid}",
            //    defaults: new { controller = "Notifications", action = "List", userid = 0 }
            //);

            routes.MapRoute(
                name: null,
                url: "{LanguageToken}",
                defaults: new { controller = "Master", action = "Home" }
            );

            routes.MapRoute(
                name: "Help",
                url: "Help/{strHelpPage}",
                defaults: new { controller = "Help", action = "ShowHelp" }
            );

            routes.MapRoute(
                name: "Account Activation",
                url: "Activate/{mailedGuid}",
                defaults: new { controller = "Master", action = "ActivateAccount" }
            );

            routes.MapRoute(
                name: "Get usar avatar image",
                url: "GetUserImage/{userId}",
                defaults: new { controller = "Master", action = "GetUserImage" }
            );

            routes.MapRoute(
                name: "New Document",
                url: "Documents/New/{UserID}",
                defaults: new { controller = "Documents", action = "NewDocument", UserID = UrlParameter.Optional }
            );

            routes.MapRoute(
                name: "TestController",
                url: "Test/{action}/{documentId}",
                defaults: new { controller = "Test" }
            );

            routes.MapRoute(
                name: "Test - submit answer",
                url: "Test/{action}/{answerId}",
                defaults: new { controller = "Test" }
            );

            routes.MapRoute(
                name: "Document Review enter",
                url: "Documents/DocumentReview/{docId}/{userId}",
                defaults: new { controller = "Documents", action = "DocumentReview" }
            );

            routes.MapRoute("GeneralWithID", "{controller}/{action}/{id}");
            routes.MapRoute("General", "{controller}/{action}");
        }
    }
}