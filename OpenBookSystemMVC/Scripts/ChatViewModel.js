//This code bellow is the implementation of a chat box which persists it's chat session.
//It was to be removed so I commented it, just in case a decision from above to reinstate the chat is received.
/// <reference path="~/Scripts/jquery-1.8.2.js" />
(function ($, undefined) {
    'use strict'

    var self = {};

    self.UserId = 0;
    self.CarerId = 0;
    self.FirstName = '';
    self.IsChatWindowOn = ko.observable(false);
    self.IsCarerOnline = ko.observable(true);
    self.$MessageInput = $('.chatbox-input');
    self.$ChatMessagesElement = $('.chatbox-messages');

    self.ChatMessages = ko.observableArray([]);
    self.IsReadyToSendBack = true;
    self.PredefinedCarerResponses = ['Hello', 'How are you?', 'Wie gehts?', 'How may I help you?', 'Do you need assistance?', 'Is there anything I can do for you?', 'How are you feeling right now?', 'We are glad to be of service!', 'Was this text helpful?', 'I am not so sure I can help you with this.'];


    //---------------------Send/Receive Chat messages ---------------------
    // Checks if the previous message was by the same user
    self.IsFirstMessage = function (userId) {
        if (self.ChatMessages().length == 0 || self.ChatMessages()[self.ChatMessages().length - 1].UserId != userId) {
            return true;
        } else {
            return false;
        }
    }

    // Composes the message and pushes it to the messages stack
    self.SendChatMessage = function (msgContent, senderId, receiverId) {

        if (!senderId) {
            senderId = self.UserId;
        }

        if (!receiverId) {
            receiverId = self.CarerId;
        }

        var newMessage = {};
        newMessage.UserId = senderId;
        newMessage.Content = msgContent;
        newMessage.DateStamp = moment().format('DD.MM.YYYY');
        newMessage.TimeStamp = moment().format('HH.mm');
        newMessage.IsFirst = self.IsFirstMessage(newMessage.UserId);

        var ajax_options = {};
        ajax_options.type = 'POST';
        ajax_options.url = '/Chat/SendMessage';
        ajax_options.data = {
            msgContent: msgContent,
            senderId: senderId,
            receiverId: receiverId
        };
        ajax_options.success = function (data) {
            // TODO eventually icon notification for when the message has arrived
        }

        $.ajax(ajax_options);

        self.ChatMessages.push(newMessage);
        // HTML DOM scrollHeight has support for IE8+ including, Firefox 3 and Chrome/Safari 4
        self.$ChatMessagesElement.scrollTop(self.$ChatMessagesElement[0].scrollHeight);
    }

    // Get the participant name by his id
    self.GetUserName = function (message) {
        if (message.UserId == self.UserId) {
            return self.FirstName;
        } else {
            return 'Carer';
        }
    }


    // MockUp carer response
    self.SendCarerReply = function () {
        self.SendChatMessage(self.PredefinedCarerResponses[Math.floor(Math.random() * 10)], self.CarerId, self.UserId);
        self.IsReadyToSendBack = true;
    }


    //---------------------Chat window interaction ---------------------
    // Toggles the chat window display
    self.ToggleChatWindow = function () {
        self.IsChatWindowOn(!self.IsChatWindowOn());
        if (self.IsChatWindowOn()) {
            self.$MessageInput.focus();
        }
    }


    //---------------------Loading and initialization ---------------------
    // Ajax loading of essential data, like user name, Id's and such.
    self.LoadChatData = function () {
        var ajax_options = {}; // Ajax request options

        ajax_options.type = 'GET';
        ajax_options.url = '/Chat/LoadChatData';
        ajax_options.success = function (data) {            
            if (data) {
                self.UserId = data.UserId;
                self.CarerId = data.CarerId;
                self.FirstName = data.FirstName;
                var chatHistory = data.MessageHistory;
                if (data.MessageHistory && data.MessageHistory.length > 0) {
                    for (var i = 0; i < data.MessageHistory.length; i++) {
                        self.ChatMessages.push({
                            UserId: data.MessageHistory[i].UserId,
                            Content: data.MessageHistory[i].Content,
                            TimeStamp: data.MessageHistory[i].TimeStamp,
                            IsFirst: self.IsFirstMessage(data.MessageHistory[i].UserId)
                        });
                    }
                }
            }
            ko.applyBindings(self, $('.chatbox-etiquette')[0]);
            $('.chatbox-etiquette').removeClass('hide');
        }

        $.ajax(ajax_options);
    }

    // Setting up custom handlers
    self.InitializeCustomHandlers = function () {

        // Binding that performs the text message submitting
        ko.bindingHandlers.returnKey = {
            init: function (element, valueAccessor, allBindingsAccessor, viewModel) {
                ko.utils.registerEventHandler(element, 'keydown', function (evt) {
                    if (evt.keyCode === 13) {
                        if ($(element).val().trim().length > 0) {
                            evt.preventDefault();
                            valueAccessor().call(viewModel, $(element).val(), viewModel.UserId);
                            $(element).val('');
                            if (self.IsReadyToSendBack) {
                                viewModel.IsReadyToSendBack = false;
                                setTimeout(viewModel.SendCarerReply, (Math.floor(Math.random() * 10) + 1) * 1000);
                            }
                        }
                    }
                });
            }
        };
    }

    // Performs initializing of data and binding
    self.InitializeModel = function () {

        self.InitializeCustomHandlers();
        self.LoadChatData();
    }
    
    self.InitializeModel();

})(jQuery)