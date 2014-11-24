$(document).ready(function () {
    var self = {};
    self.$OpenFeedbackButton = $('.icon-envelope');
    self.$FeedbackDialog = $('#systemFeedbackContainer');
    self.$FeedbackText = $('#systemFeedbackText');
    self.IsDialogOpened = false;
    self.IsMessageSent = false;
    self.$MailLoader = $('.sendMailLoader');
    self.LoaderClass = 'mailLoader';
    self.$MessageOnTopElem = $('#resultMessage');
    self.MessageOnTopClass = 'putMessageOnTop';
    self.TimeoutId = {};
    
    self.SendSystemFeedback = function () {
        if (!self.IsMessageSent) {
            var message = self.$FeedbackText.val()
            if (message.trim().length > 0) {
                var ajax_options = {};
                ajax_options.type = 'POST';
                ajax_options.contentType = 'application/json, encoding = utf-8';
                ajax_options.dataType = 'json';
                ajax_options.url = '/Master/SubmitFeedback';
                ajax_options.data = JSON.stringify({
                    feedbackMessage: message
                });
                ajax_options.success = function (data) {
                    //self.CloseSystemFeedbackDialog();
                    self.$MailLoader.removeClass(self.LoaderClass);
                    if (data.Error) {
                        self.$MessageOnTopElem.html(data.Error);
                        self.$MessageOnTopElem.addClass(self.MessageOnTopClass);
                        self.$MessageOnTopElem.css('color', 'red');
                    } else if (data.Success) {
                        self.$MessageOnTopElem.html(data.Success);
                        self.$MessageOnTopElem.addClass(self.MessageOnTopClass);
                        self.$MessageOnTopElem.css('color', 'rgb(0, 99, 0)');
                        setTimeout(self.CloseSystemFeedbackDialog, 3000);
                    }
                }

                $.ajax(ajax_options);
                self.IsMessageSent = true;

                self.$MailLoader.addClass(self.LoaderClass);
            }
        }
    }

    self.CloseSystemFeedbackDialog = function () {
        clearTimeout(self.TimeoutId);
        self.$FeedbackDialog.dialog('close');
        self.IsMessageSent = false;
    }

    self.ResetMessageDialog = function () {
        clearTimeout(self.TimeoutId);
        self.$MailLoader.removeClass(self.LoaderClass);
        self.$FeedbackText.val('');
        self.$MessageOnTopElem.html('');
        self.$MessageOnTopElem.removeClass(self.MessageOnTopClass);
    }

    self.OpenSystemNotification = function () {
        if (!self.IsDialogOpened) {           
            self.ResetMessageDialog();

            self.$FeedbackDialog.dialog({
                title: Localization.GetResource('Layout_WholeSystemTitle'),
                resizable: false,
                width:545,
                height: 565,
                modal: true,
                buttons: [{
                    text: Localization.GetResource('EditDocument_Send'),
                    click: self.SendSystemFeedback
                }, {
                    text: Localization.GetResource('Library_Cancel'),
                    click: self.CloseSystemFeedbackDialog
                }],
                close: function () {
                    self.IsDialogOpened = false,
                    self.IsMessageSent = false;
                    clearTimeout(self.TimeoutId);
                }
            });



            self.$FeedbackText.focus();
            self.IsDialogOpened = true;
        }
    }

    self.Initialize = function () {
        self.$OpenFeedbackButton.click(self.OpenSystemNotification);        
    }

    self.Initialize();
});