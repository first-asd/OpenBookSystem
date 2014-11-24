(function ($, undefined) {
    'use strict'
    var self = {};

    self.$AnswerResponseArea = $('#answer-response-area');
    self.AllNotifications = ko.observableArray([]);
    self.IsCarer = ko.observable(true);
    self.Users = ko.observableArray();
    self.CurrentUser = ko.observable();
    self.NoNotifications = ko.observable(true);
    self.DisplayedNotifications = ko.observableArray([]);
    self.CurrentNotification = ko.observable();
    self.IsFromSortedDown = ko.observable(true);
    self.IsDateSortedDown = ko.observable(true);
    self.IsViewNotificationToggled = ko.observable(false);
    self.IsAnswerNotificationToggled = ko.observable(false);
    self.IconSortDown = 'icon-caret-down';
    self.IconSortUp = 'icon-caret-up';
    self.CurrentUserId = ko.observable(0);
    self.NewLineSymbol = '\n';
    self.CustomMessage = ko.observable('');
    self.IsCustomMessageOn = ko.observable(false);

    self.AnswerNotificationModel = ko.observable({
        SenderId: 0,
        Subject: ko.observable(''),
        Content: ko.observable(''),
        TextFocus: ko.observable(true)
    })

    //self.IsAnswerNotificationToggled.subscribe(function (value) {
    //    if (value == true) {
    //        //self.$AnswerResponseArea.focus();
    //        self.AnswerNotificationModels().TextFocus(true);
    //    }
    //})

    self.NewAjaxOptions = function () {
        var result = {};
        result.type = 'POST';
        result.dataType = "json";
        result.contentType = "application/json; charset=utf-8";

        return result;
    }

    self.ToggleFromSort = function () {
        self.IsFromSortedDown(!self.IsFromSortedDown());
    }

    self.ToggleDateSort = function () {
        self.IsDateSortedDown(!self.IsDateSortedDown());
    }

    self.SortFromDesc = function (left, right) {
        var leftName = self.GetUserName(left.SenderId);
        var rightName = self.GetUserName(right.SenderId);

        if (leftName == rightName) {
            return 0;
        } else if (leftName < rightName) {
            return 1;
        } else {
            return -1;
        }
    }

    self.SortFromAsc = function (left, right) {
        var leftName = self.GetUserName(left.SenderId);
        var rightName = self.GetUserName(right.SenderId);

        if (leftName == rightName) {
            return 0;
        } else if (leftName > rightName) {
            return 1;
        } else {
            return -1;
        }
    }

    self.SortDateAsc = function (left, right) {
        var result = left.Date.diff(right.Date);
        if (result == 0) {
            return 0;
        } else if (result > 0) {
            return 1;
        } else {
            return -1;
        }
    }

    self.SortDateDesc = function (left, right) {
        var result = left.Date.diff(right.Date);
        if (result == 0) {
            return 0;
        } else if (result < 0) {
            return 1;
        } else {
            return -1;
        }
    }

    self.IsFromSortedDown.subscribe(function (value) {
        if (value == true) {
            self.DisplayedNotifications.sort(self.SortFromAsc);
        } else if (value == false) {
            self.DisplayedNotifications.sort(self.SortFromDesc);
        }
    })

    self.IsDateSortedDown.subscribe(function (value) {
        if (value == true) {
            self.DisplayedNotifications.sort(self.SortDateAsc);
        } else if (value == false) {
            self.DisplayedNotifications.sort(self.SortDateDesc);
        }
    })

    self.GetUserName = function (userId) {
        var result = 'UserNotFound';

        for (var i = 0; i < self.Users().length; i++) {
            if (self.Users()[i].Id == userId) {
                result = self.Users()[i].UserName;
            }
        }
        return result;
    }

    self.CurrentUserId.subscribe(function (value) {
        self.FilterNotificationsByUser(value);
    })

    self.NavigateToDocument = function (notif) {
        if (self.IsCarer()) {
            window.location = '/Documents/DocumentReview/' + notif.DocumentId + '/' + notif.SenderId;
        } else {
            window.location = '/Documents/Edit?nDocId=' + notif.DocumentId;
        }
    }

    self.SelectNotification = function (notif) {
        self.ClearOperationAreas();

        for (var i = 0; i < self.DisplayedNotifications().length; i++) {
            if (self.DisplayedNotifications()[i].IsSelected) {
                self.DisplayedNotifications()[i].IsSelected(false);
            }
        }
        notif.IsSelected(true);
        self.CurrentNotification(notif);
        self.IsViewNotificationToggled(true);
        self.MarkNotificationAsRead(notif);
    }

    self.MarkNotificationAsRead = function (notif) {
        var ajax_options = self.NewAjaxOptions();
        ajax_options.data = JSON.stringify({ notifId: notif.Id });
        ajax_options.url = '/Notifications/MarkNotificationAsRead';
        ajax_options.success = function (data) {
            if (data.Success) {
                notif.IsRead(true);
            } else {
                //TODO display error
            }
        }

        $.ajax(ajax_options);
    }

    self.DeleteSelectedNotification = function () {
        if (self.CurrentNotification()) {
            if (confirm(Localization.GetResource('Notifications_ConfirmDelete'))) {
                var ajax_options = self.NewAjaxOptions();
                ajax_options.url = '/Notifications/DeleteNotification';
                ajax_options.data = JSON.stringify({ notifId: self.CurrentNotification().Id });
                ajax_options.success = function (data) {
                    if (data.Success) {
                        for (var i = 0; i < self.DisplayedNotifications().length; i++) {
                            if (self.DisplayedNotifications()[i].Id == self.CurrentNotification().Id) {
                                self.DisplayedNotifications.splice(i, 1);                                
                            }
                        }

                        self.ClearOperationAreas();
                        self.CustomMessage(Localization.GetResource('Notification_DeleteDone'));
                        self.IsCustomMessageOn(true);
                    } else {
                        // TODO error message
                    }
                }

                $.ajax(ajax_options);
            }
        } else {
            self.CustomMessage(Localization.GetResource('Notifications_PleaseSelect'));
            self.IsCustomMessageOn(true);
        }
    }

    self.FilterNotificationsByUser = function (userId) {
        if (userId == -1) { // All users, basically reset the filtering.
            self.DisplayedNotifications(self.AllNotifications());
        } else {
            var filteredResult = [];
            for (var i = 0; i < self.AllNotifications().length; i++) {
                if (self.AllNotifications()[i].SenderId == userId) {
                    filteredResult.push(self.AllNotifications()[i]);
                }
            }

            self.DisplayedNotifications(filteredResult);
        }
    }

    self.FormatFromLabel = function () {
        return Localization.GetResource('EditDocument_NotificationFrom') + ':' + self.GetUserName(self.CurrentNotification().SenderId);
    }

    self.FormatRelatedLabel = function () {
        return Localization.GetResource('EditDociment_NotificationRelatedDocument') + ': ' + (self.CurrentNotification() ? self.CurrentNotification().DocumentTitle : '');
    }

    self.FormatSubjectLabel = function () {
        return Localization.GetResource('EditDocument_NotificationSubject') + ': ' + (self.CurrentNotification() ? self.CurrentNotification().Subject : '');
    }

    self.FormatToLabel = function () {
        return Localization.GetResource('Notifications_AnswerTo') + ': ' + self.GetUserName(self.CurrentNotification() ? self.CurrentNotification().SenderId : 0);
    }

    self.FormatSentLabel = function () {
        return Localization.GetResource('Notifications_SentOn') + ': ' + (self.CurrentNotification() ? self.CurrentNotification().DateText : '');
    }

    self.FormatMessageLabel = function () {
        return Localization.GetResource('Notifications_Message') + ': ' + (self.CurrentNotification() ? self.CurrentNotification().Content : '');
    }

    // This method sets the toggling to false of all operation areas like prview, send and etc
    self.ClearOperationAreas = function () {
        self.IsAnswerNotificationToggled(false);
        self.IsViewNotificationToggled(false);
        self.IsCustomMessageOn(false);
    }

    // Updates the ui to display the "no notifications" message
    self.DisplayedNotifications.subscribe(function (value) {
        self.NoNotifications(value.length == 0);
    });

    self.SetInitialPreSelectedUser = function () {
        // Set the drop box of the menu for the currently selected user.
        if (self.CurrentUserId && self.CurrentUserId > 0) {
            for (var i = 0; i < self.Users().length; i++) {
                if (self.Users()[i].Id == self.CurrentUserId) {
                    self.CurrentUser(self.Users()[i]);
                    break;
                }
            }
        }
    }

    // When Replaying to message 
    self.CreateResponseMessage = function (content) {
        var result = '';
        //Add two new lines for for margin between the quoted reply and the new message
        result += self.NewLineSymbol + self.NewLineSymbol;

        // Sent On: 14/03/2014 
        result += self.FormatSentLabel() + self.NewLineSymbol;
        // From: John Doe
        result += self.FormatFromLabel() + self.NewLineSymbol;
        // Related Document: The Hanging Gardens
        result += self.FormatRelatedLabel() + self.NewLineSymbol;
        // Subject: How could a garden hang?
        result += self.FormatSubjectLabel() + self.NewLineSymbol;
        // Message: I cannot understand this whole idea .... 
        result += self.FormatMessageLabel() + self.NewLineSymbol;

        return result;
    }   

    self.MessageNotSent = function () {
        if (self.IsAnswerNotificationToggled() && self.AnswerNotificationModel().Content().trim().length > 0) {
            return Localization.GetResource('Notifications_LeaveMsg');
        }
    }



    self.OpenAnswerToNotification = function () {
        if (self.CurrentNotification()) {
            self.ClearOperationAreas();
            self.AnswerNotificationModel().SenderId = self.CurrentNotification().SenderId;
            self.AnswerNotificationModel().Content(self.CreateResponseMessage());
            self.AnswerNotificationModel().Subject(self.CreateSubjectText());

            self.IsAnswerNotificationToggled(true);
            self.AnswerNotificationModel().TextFocus(true);
            //setTimeout(function () {

            //}, 500);
        } else {
            self.CustomMessage(Localization.GetResource('Notifications_PleaseSelect'));
            self.IsCustomMessageOn(true);
        }
    }

    self.CreateSubjectText = function () {
        var result = '';

        result += 'Re: ';
        result += self.CurrentNotification().Subject;

        return result;
    }

    self.SubmitAnswer = function () {
        if (self.IsAnswerNotificationToggled()) {

            //Validate model values
            if ($.trim(self.AnswerNotificationModel().Subject().length) && $.trim(self.AnswerNotificationModel().Content().length)) {
                var ajax_options = self.NewAjaxOptions();
                ajax_options.url = '/Notifications/SendNotification';
                ajax_options.data = JSON.stringify({
                    docId: self.CurrentNotification().DocumentId,
                    receiverId: self.CurrentNotification().SenderId,
                    subject: self.AnswerNotificationModel().Subject(),
                    content: self.AnswerNotificationModel().Content()
                });
                ajax_options.success = function (data) {
                    if (data.Success) {
                        self.ClearOperationAreas();
                        self.CustomMessage(Localization.GetResource('Notification_ReplySent'));
                        self.IsCustomMessageOn(true);
                    }
                }

                $.ajax(ajax_options);
            }
        }
    }

    // Initialize the Mockup Data
    self.LoadMockupData = function () {
        var users = [];
        users.push({ Id: -1, UserName: 'All' });
        for (var i = 1; i < 6; i++) {
            users.push({
                Id: i,
                UserName: 'User ' + i
            });
        }
        self.Users(users);

        var notifs = []

        for (var i = 1; i < 6; i++) {
            notifs.push({
                Id: i,
                SenderId: i,
                DateText: moment().days(moment().days() + i).format('DD/MM/YYYY'),
                Date: moment().days(moment().days() + i),
                Subject: 'Subject ' + i,
                DocumentTitle: 'Document ' + i,
                DocumentId: i,
                Content: 'Document ' + i + ' ' + moment().toString(),
                IsRead: ko.observable(i < 3),
                IsSelected: ko.observable(false)
            });
        }

        self.AllNotifications(notifs);
    }

    self.LoadData = function () {
        var data = JSON.parse($('#hidJasonData').val());
        self.IsCarer(data.IsCarer);

        self.Users([{ Id: -1, UserName: 'All' }].concat(data.Users));

        self.AllNotifications(data.Notifications);

        for (var i = 0; i < self.AllNotifications().length; i++) {
            self.AllNotifications()[i].Date = moment(self.AllNotifications()[i].InternalDateText, 'DD-MM-YYYY HH:mm:ss');
            self.AllNotifications()[i].DateText = self.AllNotifications()[i].Date.format('DD/MM/YYYY'),
            self.AllNotifications()[i].IsSelected = ko.observable(false);
            self.AllNotifications()[i].IsRead = ko.observable(self.AllNotifications()[i].IsRead);
        }

        self.CurrentUserId(data.CurrentUserId);

        //self.SetInitialPreSelectedUser();
        //$('#hidJasonData').val('')

    }

    self.Initialize = function () {

        //self.LoadMockupData();
        self.LoadData();        
        ko.applyBindings(self);//self, $('.notificationsBody')[0]);// temp for intelli-se

        window.onbeforeunload = self.MessageNotSent;
        //self.SetInitialPreSelectedUser();

        self.IsDateSortedDown(false);
    }    

    self.Initialize();
})(jQuery)