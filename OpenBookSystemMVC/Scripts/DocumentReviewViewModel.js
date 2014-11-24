/// <reference path="moment/moment.min.js" />
$(document).ready(function () {
    'use strict'
    var self = {};
    self.DocumentTitle = ko.observable('');

    // Settings and static

    self.SentenceClass = 'sentence';
    self.WordClass = 'word';
    self.SelectedClass = 'selected';
    self.ObstacleOnClass = 'obstacle-on';
    self.AcceptedClass = 'accepted';
    self.SelectedImageClass = 'selected-img';
    self.UserNoteClass = 'text-node-point';
    self.CarerNoteClass = 'carer-note';
    self.ObstacleSelector = '.word.obstacle';
    self.IdiomSelector = '.word.idiom.multiword';
    self.MultiwordSelector = '.multiword';
    self.CarerAndUserNoteSelector = '.carer-note, .text-node-point';
    self.NoEditWrapClass = 'no-edit';    
    self.WrapperElementHtml = '<span contenteditable="false" class="' + self.NoEditWrapClass + '"></span>';
    self.AlternativeStructureTypes = {
        Original: 'Original',
        Delete: 'Delete',
        Split: 'Split'
    };



    self.IsAlternativeStructuresOn = ko.observable(false);
    self.IsObstaclesOn = ko.observable(false);
    self.IsAddImageDialogueOn = ko.observable(false);
    self.ImageHyperlink = ko.observable('');
    self.NewDocumentTitle = ko.observable('');
    self.IsEdited = ko.observable(false);
    self.Summary = ko.observable('');
    self.IsReprocessing = ko.observable(false);

    // Every word that is going to be selected will be cached and all it's data as well, 
    // so that repeating actions on it would be faster.
    self.WordCache = [{
        Word: '',
        Synonyms: [], // Values are of type { Text: 'Lorem', Description: 'Ipsum dolor et'}
        PictureURLs: [],
        Definitions: [],
        Anaphoras: []
    }];

    // Every sentence will be cached after it's data is retrieved, so that it could speed up transition between sentences.
    self.SentenceCache = [{
        Sentence: '',
        OriginalSentence: '',
        AlternativeStructures: [{
            Index: 0,
            Label: 'original',
            Type: 'Original',
            Text: 'Lorem ipsum',
            Html: '<span>Lorem...</span>'
        }]
    }];


    self.NavigationHandlerValues = {
        SelectNext: function ()
        {

        },
        SelectPrev: function () {

        },
        SelectSpecific: function () {

        }
    };

    self.EditSentenceModel = {
        OriginalSentence: ko.observable(''),
        UnmodifiedSentenceHtml: '', 
        TransformedSentence: ko.observable(''),
        $SelectedNote: $({}),
        $NoteTextArea: $('#note-content'),
        AlternativeStructures: ko.observableArray([]),
        ObstaclesCount: ko.observable(0),
        SelectedStructure: ko.observable(0),
        IsWordSelected: ko.observable(false),
        IsNoteSelected: ko.observable(false),
        IsAccepted: ko.observable(false),
        IsAddNoteOn: ko.observable(false),

        ToggleAddNote: function () {
            self.EditSentenceModel.IsAddNoteOn(!self.EditSentenceModel.IsAddNoteOn());
            self.LoggingModel.LogGeneralAction(self.UserOperations.AddNoteClick);
        },
        SelectStructure: function () {
            var index = self.EditSentenceModel.SelectedStructure();
            for (var i = 0; i < self.EditSentenceModel.AlternativeStructures().length; i++) {
                if (self.EditSentenceModel.AlternativeStructures()[i].Index == index) {
                    self.EditSentenceModel.TransformedSentence(self.EditSentenceModel.AlternativeStructures()[i].Html);
                    self.IsAlternativeStructuresOn(false);
                    break;
                }
            }
        },
        SelectNote: function ($note) {
            self.EditSentenceModel.IsAddNoteOn(false);
            self.EditSentenceModel.$SelectedNote = $note;
            self.EditSentenceModel.$NoteTextArea.val($note.attr('data-content'));
            self.SelectedWordModel.CloseWord();
            self.EditSentenceModel.IsNoteSelected(true);
            self.EditSentenceModel.$NoteTextArea.focus();
        },
        SaveNote: function () {
            self.EditSentenceModel.$SelectedNote.attr('data-content', self.EditSentenceModel.$NoteTextArea.val());
            self.SetUpNewNoteTooltip(self.EditSentenceModel.$SelectedNote);
            //self.EditSentenceModel.TransformedSentence(self.$SentenceEditContainer.html());
            self.EditSentenceModel.IsNoteSelected(false);
        },
        DeleteNote: function () {
            self.LoggingModel.LogSentenceAction(self.UserOperations.NoteDeleted, [self.DocumentId, $elem.parents('.' + self.SentenceClass).attr('data-id')]);
            self.EditSentenceModel.$SelectedNote.remove();
            self.EditSentenceModel.IsNoteSelected(false);

        },
        CancelNote: function () {
            self.EditSentenceModel.IsNoteSelected(false);
        }
    };

    // This object is the sub-model responsible for handling the user obstacle/word interactions
    self.SelectedWordModel = {
        $ImagesContainer: $('.images-wrapper'),
        $FeedbackBaloon: $('.feedback-baloon'),
        $FeedbackButton: $('#feedbackBtn'),
        SelectedWord: ko.observable({
            Text: ko.observable(''),
            Synonyms: ko.observableArray([]),
            Definitions: ko.observableArray([]),
            PictureURLs: ko.observableArray([]),
            Anaphoras: ko.observable([]),
            $Element: $({})
        }),
        SelectedSynonym: ko.observable(0),
        SelectedDefinition: ko.observable(0),
        SelectedImage: ko.observable(''),
        SelectedAnaphora: ko.observable(0),
        IsMenuOn: ko.observable(false),
        IsSynonymsOn: ko.observable(false),
        IsInsertImagesOn: ko.observable(false),
        IsInsertDefinitionOn: ko.observable(false),
        IsInsertAnaphorasOn: ko.observable(false),
        IsLoading: ko.observable(false),
        IsObstacle: ko.observable(false),
        BackToMenu: function () {
            self.EditSentenceModel.IsNoteSelected(false);
            self.SelectedWordModel.IsSynonymsOn(false);
            self.SelectedWordModel.IsInsertImagesOn(false);
            self.SelectedWordModel.IsInsertDefinitionOn(false);
            self.SelectedWordModel.IsInsertAnaphorasOn(false);
            self.SelectedWordModel.IsMultiwordSelectOn(false);
            self.SelectedWordModel.IsMenuOn(true);            
            self.ErrorHandlingModel.IsErrorOn(false);
            self.EditSentenceModel.IsWordSelected(true);
            
        },
        ClearWordArea: function () {
            self.SelectedWordModel.IsSynonymsOn(false);
            self.SelectedWordModel.IsInsertImagesOn(false);
            self.SelectedWordModel.IsInsertDefinitionOn(false);
            self.IsAlternativeStructuresOn(false);
            self.SelectedWordModel.IsMenuOn(false);
            self.ErrorHandlingModel.IsErrorOn(false);
            self.SelectedWordModel.IsInsertAnaphorasOn(false);
            self.SelectedWordModel.IsMultiwordSelectOn(false);
        },
        CloseWord: function () {
            self.EditSentenceModel.IsWordSelected(false);
        },
        ToggleSynonymsOn: function () {
            if (self.SelectedWordModel.IsSynonymsOn()) {
                self.SelectedWordModel.IsSynonymsOn(false);
            } else {
                self.LoggingModel.LogSentenceAction(self.UserOperations.SelectReplaceWithSynonym, [self.DocumentId, self.$CurrentSentence.attr('data-id')]);
                self.LoadSynonyms();

                //self.LoadFixtureSynonyms();
            }
        },
        ToggleImagesOn: function () {
            if (self.SelectedWordModel.IsInsertImagesOn()) {
                self.SelectedWordModel.IsInsertImagesOn(false);
            } else {
                self.LoggingModel.LogSentenceAction(self.UserOperations.SelectInsertImage, [self.DocumentId, self.$CurrentSentence.attr('data-id')]);
                self.LoadWordImages();
                //self.LoadFixtureImages();
            }
        },
        ToggleDefinitionsOn: function () {
            if (self.SelectedWordModel.IsInsertDefinitionOn()) {
                self.SelectedWordModel.IsInsertDefinitionOn(false);
            } else {
                self.LoggingModel.LogSentenceAction(self.UserOperations.SelectInsertDefinition, [self.DocumentId, self.$CurrentSentence.attr('data-id')]);
                self.LoadWordDefinitions();
                //self.LoadFixtureDefinitions();
            }
        },
        ToggleAnaphorasOn: function () {
            if (self.SelectedWordModel.IsInsertAnaphorasOn()) {
                self.SelectedWordModel.IsInsertAnaphorasOn(false);
            } else {
                self.LoggingModel.LogSentenceAction(self.UserOperations.SelectInsertAnaphora, [self.DocumentId, self.$CurrentSentence.attr('data-id')]);
                self.LoadAnaphoras();
            }
        },
        CalculateImageListWidth: ko.observable(function () {
            var result = '0px';

            if (self.SelectedWordModel.SelectedWord().PictureURLs) {
                result = self.SelectedWordModel.SelectedWord().PictureURLs().length * 110 + 'px';
            }

            return result;
        }),
        SelectImage: function (data) {
            self.SelectedWordModel.SelectedImage(data);
        },
        OpenAddUserImageDialogue: function () {
            self.IsAddImageDialogueOn(true);
            self.$AddImageDialogue.dialog(self.AddImageDialogOptions);
        },
        AddUserImage: function () {

            var $newImg = $('<img class="user-provided" src="' + self.ImageHyperlink() + '" />');

            self.SelectedWordModel.SelectedWord().$Element.after($newImg);
            self.$AddImageDialogue.dialog('close');
            self.IsAddImageDialogueOn(false);
            self.ClearOptionsArea();
        },
        InsertSelectedImage: function () {
            var $selectedImage = $('.obstacles-images').find('.' + self.SelectedImageClass);
            if ($selectedImage.length > 0) {
                var $newImage = $('<span contenteditable="false"><img src="' + $selectedImage.attr('src') + '" /></span>');
                self.SelectedWordModel.SelectedWord().$Element.after($newImage);
                //self.SetUpMagnific(self.$SentenceEditContainer);
                self.ClearOptionsArea();

                self.LoggingModel.LogSentenceAction(self.UserOperations.PerformInsertImage, [self.DocumentId, self.$CurrentSentence.attr('data-id')]);
            }
        },
        ReplaceWordWithSynonym: function () {
            var index = self.SelectedWordModel.SelectedSynonym();
            var length = self.SelectedWordModel.SelectedWord().Synonyms().length;
            for (var i = 0; i < length; i++) {
                if (self.SelectedWordModel.SelectedWord().Synonyms()[i].Index == index) {
                    var $newWord = $(self.SelectedWordModel.SelectedWord().Synonyms()[i].Html);
                    self.SelectedWordModel.SelectedWord().$Element.replaceWith($newWord);

                    self.LoggingModel.LogSentenceAction(self.UserOperations.PerformReplaceWithSynonym, [self.DocumentId, self.$CurrentSentence.attr('data-id')]);

                    self.ClearOptionsArea();
                    break;
                }
            }
        },
        InsertSelectedDefinition: function () {
            var index = self.SelectedWordModel.SelectedDefinition();

            for (var i = 0; i < self.SelectedWordModel.SelectedWord().Definitions().length; i++) {
                if (index == self.SelectedWordModel.SelectedWord().Definitions()[i].Index) {
                    var definition =
                        '<span class="word"> </span><span class="word">(</span>' +
                        self.SelectedWordModel.SelectedWord().Definitions()[i].Html +
                        '<span class="word">)</span>';
                    self.SelectedWordModel.SelectedWord().$Element.after(definition);

                    self.LoggingModel.LogSentenceAction(self.UserOperations.PerformInsertDefinition, [self.DocumentId, self.$CurrentSentence.attr('data-id')]);

                    self.ClearOptionsArea();
                    break;
                }
            }
        },
        ReplaceWordWithAnaphora: function () {
            var index = self.SelectedWordModel.SelectedAnaphora();
            var length = self.SelectedWordModel.SelectedWord().Anaphoras().length;
            for (var i = 0; i < length; i++) {
                if (self.SelectedWordModel.SelectedWord().Anaphoras()[i].Index == index) {
                    var $newWord = $(self.SelectedWordModel.SelectedWord().Anaphoras()[i].Html);
                    self.SelectedWordModel.SelectedWord().$Element.replaceWith($newWord);

                    self.LoggingModel.LogSentenceAction(self.UserOperations.PerformInsertAnaphora, [self.DocumentId, self.$CurrentSentence.attr('data-id')]);

                    self.ClearOptionsArea();
                    break;
                }
            }
        },
        GetObstacleFeedback: function () {
            var ajax_options = {};
            ajax_options.type = 'POST';
            ajax_options.contentType = 'application/json, encoding = utf-8';
            ajax_options.dataType = 'json';
            ajax_options.url = '/Documents/GetObstacleFeedback';
            ajax_options.data = JSON.stringify({
                obstacleId: self.SelectedWordModel.SelectedWord().$Element.attr('data-id')
            });
            ajax_options.success = function (data) {
                if (data.Feedback) {
                    self.SelectedWordModel.FeedbackTypes(data.Feedback);
                } else {
                    //self.SelectedWordModel.FeedbackBaloonText(Error);
                }
            }

            $.ajax(ajax_options);
        },
        FeedbackTypes: ko.observableArray([]),
        IsWordIdiom: ko.observable(false),
        AnalyzeWord: function () {
            if (self.SelectedWordModel.IsObstacle()) {
                var hasSynonyms = self.SelectedWordModel.SelectedWord().$Element.attr('data-synonym');
                var hasAnaphoras = self.SelectedWordModel.SelectedWord().$Element.attr('data-anaphora');
                //var hasDefinitions = self.SelectedWordModel.SelectedWord().$Element.attr('data-definition');
                //var hasPictures = self.SelectedWordModel.SelectedWord().$Element.attr('data-picture');

                self.SelectedWordModel.HasSynonyms(hasSynonyms === 'yes');
                self.SelectedWordModel.HasAnaphoras(hasAnaphoras === 'yes');
                //self.SelectedWordModel.HasDefinitions(hasDefinitions === 'yes');
                //self.SelectedWordModel.HasPictures(hasPictures === 'yes');

            } else {
                self.SelectedWordModel.HasSynonyms(false);
                self.SelectedWordModel.HasAnaphoras(false);
                //self.SelectedWordModel.HasDefinitions(true);
                //self.SelectedWordModel.HasPictures(true);
            }
        },
        HasAnaphoras: ko.observable(false),
        HasSynonyms: ko.observable(false),
        HasDefinitions: ko.observable(true),
        HasPictures: ko.observable(true),
        IsMultiword: ko.observable(true),
        IsMultiwordSelectOn: ko.observable(false),
        IsFeedbackBaloonOn: ko.observable(false),
        ToggleFeedbackBaloon: function () {
            self.SelectedWordModel.IsFeedbackBaloonOn(!self.SelectedWordModel.IsFeedbackBaloonOn());
            if (self.SelectedWordModel.IsFeedbackBaloonOn()) {
                $('.feedback-baloon').css('left', $('#feedbackBtn').position().left);
            }
        },
        $MultiwordInner: $([]),
        MultiwordInnerText: ko.observable(''),
        $Multiword: $([]),
        SelectInnerWord: function () {
            var newElement = self.LoadWordFromCache(self.SelectedWordModel.$MultiwordInner);
            //self.SelectedWordModel.MultiwordInnerText(self.SelectedWordModel.$MultiwordInner());
            self.SelectedWordModel.SelectedWord(newElement);
            self.SelectedWordModel.IsWordIdiom(self.SelectedWordModel.$MultiwordInner.is(self.IdiomSelector));
            self.EditSentenceModel.IsWordSelected(true);
            self.SelectedWordModel.IsObstacle(self.SelectedWordModel.SelectedWord().$Element.is(self.ObstacleSelector));
            self.SelectedWordModel.AnalyzeWord();
            self.SelectedWordModel.BackToMenu();
            if (self.SelectedWordModel.IsObstacle() || self.SelectedWordModel.IsMultiword()) {
                self.SelectedWordModel.GetObstacleFeedback();
            }

            self.SelectedWordModel.IsFeedbackBaloonOn(false);            
        }
    };

    self.AnaphoraMenuLabel = function () {
        if (self.SelectedWordModel.SelectedWord) {
            return '"' + self.SelectedWordModel.SelectedWord().Text + '"' + Localization.GetResource('DocumentReview_InsertAnaphora');
        } else {
            return '';
        }            
    }
    
    self.ErrorHandlingModel = {
        IsErrorOn: ko.observable(false),
        ErrorMessage: ko.observable(''),
        DefaultErrorMessage: Localization.GetResource('ServerCommunicationError'),
        ErrorRetryHandler: ko.observable(function () {
        }),
        ErrorBackHandler: ko.observable(function () {
    
        }),
        HandleAjaxError: function (retryCall, backCall, errorMessage) {
            self.ErrorHandlingModel.ErrorMessage(typeof errorMessage == 'undefined' ? self.ErrorHandlingModel.DefaultErrorMessage : errorMessage);
            self.ErrorHandlingModel.ErrorRetryHandler(retryCall);
            self.ErrorHandlingModel.ErrorBackHandler(backCall);
            self.ClearOptionsArea();
            self.ErrorHandlingModel.IsErrorOn(true);
        }
    };


    self.FeedbackModel = {
        $FeedbackDialog: $('#systemFeedbackContainer'),
        $FeedbackText: $('#systemFeedbackText'),
        IsDialogOpened: false,
        IsMessageSent: false,
        $MailLoader: $('.sendMailLoader'),
        LoaderClass: 'mailLoader',
        $MessageOnTopElem: $('#resultMessage'),
        MessageOnTopClass: 'putMessageOnTop',
        TimeoutId: 0,
        CloseSystemFeedbackDialog: function () {
            clearTimeout(self.FeedbackModel.TimeoutId);
            self.FeedbackModel.$FeedbackDialog.dialog('close');
            self.FeedbackModel.IsMessageSent = false;
        },
        ResetMessageDialog: function () {
            self.FeedbackModel.$MailLoader.removeClass(self.FeedbackModel.LoaderClass);
            self.FeedbackModel.$FeedbackText.val('');
            self.FeedbackModel.$MessageOnTopElem.html('');
            self.FeedbackModel.$MessageOnTopElem.removeClass(self.FeedbackModel.MessageOnTopClass);
            clearTimeout(self.FeedbackModel.TimeoutId);
        },
        OpenFeedbackDialog: function () {
            self.FeedbackModel.ResetMessageDialog();
            self.FeedbackModel.$FeedbackDialog.dialog({
                title: Localization.GetResource('Feedback_SendSentence'),
                resizable: false,
                width: 545,
                height: 565,
                modal: true,
                buttons: [{
                    text: Localization.GetResource('EditDocument_Send'),
                    click: self.FeedbackModel.SendSentenceFeedback
                }, {
                    text: Localization.GetResource('Library_Cancel'),
                    click: self.FeedbackModel.CloseFeedbackDialog
                }],
                close: function () {
                    self.FeedbackModel.IsMessageSent = false
                }
            });
        },
        SendSentenceFeedback: function () {
            if (!self.FeedbackModel.IsMessageSent) {
                var message = self.FeedbackModel.$FeedbackText.val()
                if (message.trim().length > 0) {
                    var ajax_options = {};
                    ajax_options.type = 'POST';
                    ajax_options.contentType = 'application/json, encoding = utf-8';
                    ajax_options.dataType = 'json';
                    ajax_options.url = '/Documents/SendSentenceFeedback';
                    ajax_options.data = JSON.stringify({
                        feedbackMessage: message,
                        simplifiedSentence: self.$CurrentSentence.text(),
                        documentId: self.DocumentId
                    });
                    ajax_options.success = function (data) {
                        //self.CloseSystemFeedbackDialog();
                        self.FeedbackModel.$MailLoader.removeClass(self.LoaderClass);
                        if (data.Error) {
                            self.FeedbackModel.$MessageOnTopElem.html(data.Error);
                            self.FeedbackModel.$MessageOnTopElem.addClass(self.FeedbackModel.MessageOnTopClass);
                            self.FeedbackModel.$MessageOnTopElem.css('color', 'red');
                            //self.$M
                        } else if (data.Success) {
                            self.FeedbackModel.$MessageOnTopElem.html(data.Success);
                            self.FeedbackModel.$MessageOnTopElem.addClass(self.FeedbackModel.MessageOnTopClass);
                            self.FeedbackModel.$MessageOnTopElem.css('color', 'rgb(0, 99, 0)');
                            setTimeout(self.FeedbackModel.CloseSystemFeedbackDialog, 3000);
                        }
                    }

                    $.ajax(ajax_options);
                    self.FeedbackModel.IsMessageSent = true;

                    self.FeedbackModel.$MailLoader.addClass(self.FeedbackModel.LoaderClass);
                }
            }
        },
        CloseFeedbackDialog: function () {
            self.FeedbackModel.$FeedbackDialog.dialog('close');
            clearTimeout(self.FeedbackModel.TimeoutId);
            self.FeedbackModel.IsMessageSent = false;
        }
    };

    self.ContactUserModel = {
        $ContactContainer: $('.contact-user-dialogue'),
        Subject: ko.observable(''),
        Content: ko.observable(''),
        IsLoading: ko.observable(false),
        IsFinished: ko.observable(false),
        MessageSent: function (data) {
            self.ContactUserModel.IsLoading(false);
            self.ContactUserModel.IsFinished(true);
            setTimeout(function () {
                self.ContactUserModel.$ContactContainer.dialog('close');
            }, 3000);
        },
        ClearFields: function () {
            self.ContactUserModel.Subject('');
            self.ContactUserModel.Content('');
            self.ContactUserModel.IsLoading(false);
            self.ContactUserModel.IsFinished(false);
        },
        SendNotification: function () {
            if (!self.ContactUserModel.IsLoading() && !self.ContactUserModel.IsFinished()) {
                var ajax_options = self.NewAjaxOptions();
                ajax_options.url = '/Notifications/SendNotification';
                //long docId, long receiverId, string subject, string content
                ajax_options.data = JSON.stringify({
                    docId: $('#hidDocumentId').val(),
                    receiverId: $('#hidUserId').val(),
                    subject: self.ContactUserModel.Subject(),
                    content: self.ContactUserModel.Content()
                });
                ajax_options.success = self.ContactUserModel.MessageSent;

                $.ajax(ajax_options);
                self.ContactUserModel.IsLoading(true);

                self.LoggingModel.LogGeneralAction(self.UserOperations.ContactUserClick, [self.DocumentId]);
            }
        },
        CloseDialog: function () {
            self.ContactUserModel.$ContactContainer.dialog('close');
        },
        GetDialogOptions: function () {
            return {
                width: 650,
                height: 550,
                modal: true,
                title: Localization.GetResource('DocumentReview_SendNotification'),
                buttons: [{
                    text: Localization.GetResource('EditDocument_Send'),
                    click: self.ContactUserModel.SendNotification
                }, {
                    text: Localization.GetResource('Library_Cancel'),
                    click: self.ContactUserModel.CloseDialog
                }]
            }
        }        
    }

    self.AltStructsButtonOptions = {
        OffText: '',
        OnText: '',
        Observable: self.IsAlternativeStructuresOn
    };

    self.ObstaclesButtonOptions = {
        OffText: '',
        OnText: '',
        Observable: self.IsObstaclesOn
    };

    self.UserOperations = {
        OpenDocument: 'OpenDocument',
        SaveDocument: 'SaveDocument',
        ContactUserClick: 'ContactUserClick',
        SummaryClick: 'SummaryClick',
        AddNoteClick: 'AddNoteClick',
        SentenceSelected: 'SentenceSelected',
        SentenceAccepted: 'SentenceAccepted',
        WordSelected: 'WordSelected',
        SelectInsertImage: 'SelectInsertImage',
        SelectInsertDefinition: 'SelectInsertDefinition',
        SelectInsertAnaphora: 'SelectInsertAnaphora',
        SelectReplaceWithSynonym: 'SelectReplaceWithSynonym',
        PerformInsertImage: 'PerformInsertImage',
        PerformInsertDefinition: 'PerformInsertDefinition',
        PerformInsertAnaphora: 'PerformInsertAnaphora',
        PerformReplaceWithSynonym: 'PerformReplaceWithSynonym',
        PerformSummaryEdited: 'PerformSummaryEdited',
        ThemeChanged: 'ThemeChanged',
        FontChanged: 'FontChanged',
        UnderlineClick: 'UnderlineClick',
        BoldClick: 'BoldClick',
        HighlightClick: 'HighlightClick',
        MagnifyTextActivat: 'MagnifyTextActivat',
        MagnifyTextDisabled: 'MagnifyTextDisabled',
        NoteInserted: 'NoteInserted',
        NoteDeleted: 'NoteDeleted',
        ExplainWordClick: 'ExplainWordClick',
        ExplainWithPictureClick: 'ExplainWithPictureClick',
        DocumentCheckedDone: 'DocumentCheckedDone',
        ContactCarerClick: 'ContactCarerClick'
    }

    self.LoggingModel = {
        DateTimeFormat: 'DD.MM.YYYY HH:mm:ss',
        Delimiter: ';',
        CompleteActionsLog: '',
        SentenceActionsLog: '',
        SaveSentenceLog: function () {
            self.LoggingModel.CompleteActionsLog += self.LoggingModel.SentenceActionsLog;
        },
        ClearSentenceLog: function () {
            self.LoggingModel.SentenceActionsLog = '';
        },
        LogGeneralAction: function (actionCode, params) {
            var paramsData = '';
            if (params && params.length && params.length > 0) {
                for (var i = 0; i < params.length; i++) {
                    paramsData += params[i] + ';';
                }
            }

            var logRecord = 
                 '\n' + moment().format(self.LoggingModel.DateTimeFormat) +
                self.LoggingModel.Delimiter +
                'Level2' +
                self.LoggingModel.Delimiter +
                actionCode +
                self.LoggingModel.Delimiter +
                self.$HiddenCarerId.val() +
                self.LoggingModel.Delimiter +
                'Carer' +
                self.LoggingModel.Delimiter +
                paramsData;

            self.LoggingModel.CompleteActionsLog += logRecord;
        },
        LogSentenceAction: function (actionCode, params) {
            var paramsData = '';
            if (params && params.length && params.length > 0) {
                for (var i = 0; i < params.length; i++) {
                    //var value = params[i] == true ? 1 : params[i] == false ? 0 : params[i]; // if it's true/false write 1/0 else what is usual
                    paramsData += params[i] + ';';
                }
            }

            var logRecord =
                '\n' + moment().format(self.LoggingModel.DateTimeFormat) +
                self.LoggingModel.Delimiter +
                'Level2' +
                self.LoggingModel.Delimiter +
                actionCode +
                self.LoggingModel.Delimiter +
                self.$HiddenCarerId.val() +
                self.LoggingModel.Delimiter +
                'Carer' +
                self.LoggingModel.Delimiter +
                paramsData;

            self.LoggingModel.SentenceActionsLog += logRecord;
        }
    }

    //<--------------- HTML Controls Caching --------------->

    self.$SimplifiedContentControl = $('.content-area');
    self.$CurrentSentence = self.$SimplifiedContentControl.children('.' + self.SentenceClass);
    self.$SentenceEditContainer = $('.edit-transformed-sentence');
    self.$HiddenSimplifiedContent = $('#hidSimplifiedContent');
    self.$HiddenDocumentTitle = $('#hidDocumentTitle');
    self.$HiddenCarerId = $('#hidCarerId');
    self.$HiddenDocumentId = $('#hidDocumentId');
    self.$HiddenSummary = $('#hidSummary');
    self.$HiddenActionsLog = $('#hidActionLog');
    self.$AddImageDialogue = $('.insert-image-dialogue');
    self.$EditTitleDialogue = $('.edit-title-dialogue');
    self.$EditSummaryDialogue = $('.edit-summary-dialogue');
    self.$SummaryText = $('#text-summary');
    self.$PreviewDocumentDialogue = $('.preview-document-dialogue');
    self.$ReprocessConfirmDialogue = $('.reprocess-sentence-dialogue');
    self.$ReprocessSpinner = $('.reprocess-spinner');
    self.DocumentId = self.$HiddenDocumentId.val();

    //<------------End of HTML Controls Caching ------------>



    //<--------------- Functional methods --------------->

    //http://stackoverflow.com/questions/6690752/insert-html-at-caret-in-a-contenteditable-div/6691294#6691294
    self.pasteHtmlAtCaretfunction = function (html) {
        var sel, range;
        if (window.getSelection) {
            // IE9 and non-IE
            sel = window.getSelection();
            if (sel.getRangeAt && sel.rangeCount) {
                range = sel.getRangeAt(0);
                range.deleteContents();

                // Range.createContextualFragment() would be useful here but is
                // only relatively recently standardized and is not supported in
                // some browsers (IE9, for one)
                var el = document.createElement("div");
                el.innerHTML = html;
                var frag = document.createDocumentFragment(), node, lastNode;
                while ((node = el.firstChild)) {
                    lastNode = frag.appendChild(node);
                }
                range.insertNode(frag);

                // Preserve the selection
                if (lastNode) {
                    range = range.cloneRange();
                    range.setStartAfter(lastNode);
                    range.collapse(true);
                    sel.removeAllRanges();
                    sel.addRange(range);
                }
            }
        } else if (document.selection && document.selection.type != "Control") {
            // IE < 9
            document.selection.createRange().pasteHTML(html);
        }
    }

    //inserts new line and prevents default wrapping of the element 
    if (self.$SentenceEditContainer[0].attachEvent) { // IE8
        self.$SentenceEditContainer[0].attachEvent('onkeydown', function (event) {
            if (event.keyCode === 13) {
                self.pasteHtmlAtCaretfunction('<br/>');
                if (event.preventDefault) {
                    event.preventDefault();
                }

                event.cancelBubble = true;
                event.returnValue = false;
                return false;
            }
        });
    } else { // all others
        self.$SentenceEditContainer.keydown(function (event) {
            if (event.keyCode === 13) {

                self.pasteHtmlAtCaretfunction('<br/>');
                if (event.preventDefault) {
                    event.preventDefault();
                }

                event.cancelBubble = true;
                event.returnValue = false;
                return false;
            }
        });
    }
    

    self.NewAjaxOptions = function () {
        var result = {};
        result.type = 'POST';
        result.dataType = "json";
        result.contentType = "application/json; charset=utf-8";
        result.url = '';
        result.success = function () {
    
        };
        result.data = '';
        return result;
    }

    self.CancelDocument = function () {
        window.location = '/Documents/UserList/' + $('#hidUserId').val();
    }

    self.OpenEditSummaryDialogue = function () {
        self.$EditSummaryDialogue.dialog({
            width: 650,
            height: 430,
            modal: true,
            title: Localization.GetResource('DocumentReview_EditSummary'),
            buttons: [{
                text: Localization.GetResource('Library_Save'),
                click: function () {
                    self.Summary(self.$SummaryText.val());
                    self.LoggingModel.LogGeneralAction(self.UserOperations.PerformSummaryEdited, [self.DocumentId]);
                    $(this).dialog('close');
                }
            }, {
                text: Localization.GetResource('Library_Cancel'),
                click: function () {
                    $(this).dialog('close');
                }
            }],
            open: function () {
                self.$SummaryText.val(self.Summary());
            }
        });

        self.LoggingModel.LogGeneralAction(self.UserOperations.SummaryClick, [self.DocumentId]);
    }

    self.GetNext = function ($startElem, $endElem, filter) {
        if ($startElem[0] == $endElem[0]) {
            return $startElem;
        }

        if ($startElem.children().length != 0) {
            return $startElem.children().first();
        } else {
            if ($startElem.next().length != 0) {
                return $startElem.next();
            } else {
                var $elem = $startElem.parent();
                while ($elem.next().length == 0) {
                    $elem = $elem.parent();
                }

                return $elem.next();
            }
        }
    }

    self.GetPrev = function ($startElem, $endElem, filter) {
        if ($startElem[0] == $endElem[0]) {
            return $startElem;
        }

        if ($startElem.children().length != 0) {
            return $startElem.children().last();
        } else {
            if ($startElem.prev().length != 0) {
                return $startElem.prev();
            } else {
                var $elem = $startElem.parent();
                while ($elem.prev().length == 0) {
                    $elem = $elem.parent();
                }

                return $elem.prev();
            }
        }
    }

    self.GetNextSentence = function ($startSent) {
        var $buffElem = $startSent;
        var $lastSent = self.$SimplifiedContentControl.find('.' + self.SentenceClass).last();

        do {
            $buffElem = self.GetNext($buffElem, $lastSent, '.' + self.SentenceClass);
        } while (!$buffElem.is('.' + self.SentenceClass));

        return $buffElem;
    }

    self.GetPrevSentence = function ($startSent) {
        var $buffElem = $startSent;
        var $lastSent = self.$SimplifiedContentControl.find('.' + self.SentenceClass).first();

        do {
            $buffElem = self.GetPrev($buffElem, $lastSent, '.' + self.SentenceClass);
        } while (!$buffElem.is('.' + self.SentenceClass));

        return $buffElem;
    }

    //solves IE 11 css redraw bug
    self.ForceRedrawContainer = function () {
        $('head').prepend('<style id="kk"> .sentence { opacity:0.99; } </style>');
        setTimeout(function () {
            $('#kk').remove();
        }, 100);
        
    }

    self.SelectNextSentence = function () {
        if (self.$CurrentSentence.length > 0) {
            var $nextSentence = self.GetNextSentence(self.$CurrentSentence);
            if ($nextSentence.length > 0 && !$nextSentence.is('.' +self.SelectedClass)) {
                $nextSentence.addClass(self.SelectedClass);
                self.$CurrentSentence.removeClass(self.SelectedClass);

                self.$CurrentSentence = $nextSentence;
                self.SentenceSelected();
                self.ScrollToCurrentSentence();
            }
        }
    }

    self.SelectPrevSentence = function () {
        if (self.$CurrentSentence.length > 0) {
            var $prevSentence = self.GetPrevSentence(self.$CurrentSentence);
            if ($prevSentence.length > 0 && !$prevSentence.is('.' + self.SelectedClass)) {
                $prevSentence.addClass(self.SelectedClass);
                self.$CurrentSentence.removeClass(self.SelectedClass);


                self.$CurrentSentence = $prevSentence;
                self.SentenceSelected();
                self.ScrollToCurrentSentence();
            }
        }
    }

    // This method adds contenteditable="false" on <span> word parent elements of images, so that in the sentence edit
    // container you don't have resize handles in IE. This also makes magnific work.
    self.SetContentEditableImages = function ($container) {
        $container.find('img').each(function () {
            $(this).parent().attr('contenteditable', 'false');
        });
    }

    self.RemoveContentEditableImages = function ($container) {
        $container.find('img').each(function () {
            $(this).parent().removeAttr('contentEditable', 'false');
        });
    }

    self.WrapUserNotes = function ($sentence) {
        $sentence.find(self.CarerAndUserNoteSelector).each(function () {
            var $elem = $(this);
            if (!$elem.parent().is('.' + self.NoEditWrapClass)) {
                $elem.wrap(self.WrapperElementHtml);
            }
        })
    }

    self.UnwrapUserNotes = function ($sentence) {
        $sentence.find(self.CarerAndUserNoteSelector).each(function () {
            var $elem = $(this);
            if ($elem.parent().is('.' + self.NoEditWrapClass)) {
                $elem.unwrap();
            }
        })
    }

    // This is called whenever there is a change in the current selected sentence;
    self.SentenceSelected = function () {
        self.LoggingModel.ClearSentenceLog();

        self.ClearOptionsArea();        

        var sentence = self.LoadSentenceFromCache(self.$CurrentSentence.clone().removeClass(self.SelectedClass).outerHTML());
        if (sentence == false) {
            self.RequestSentenceData();
        } else {
            self.SetSentenceModel(sentence);
            self.WrapUserNotes(self.$SentenceEditContainer);
        }

        self.ForceRedrawContainer();
        self.LoggingModel.LogSentenceAction(self.UserOperations.SentenceSelected, [self.DocumentId, self.$CurrentSentence.attr('data-id')]);
    }   

    self.ScrollToCurrentSentence = function () {
        var $scrollerElem = $('<div></div>');
        self.$CurrentSentence.before($scrollerElem);
        self.$SimplifiedContentControl.scrollTop(0);
        self.$SimplifiedContentControl.scrollTop($scrollerElem.position().top - 30);// + (self.ContainerHeight / 2));
        $scrollerElem.remove();
    }

    self.RequestSentenceData = function () {
        var ajax_options = self.NewAjaxOptions();
        ajax_options.url = '/Documents/GetSentenceData';
        ajax_options.data = JSON.stringify({
            sentence: self.$CurrentSentence.clone().removeClass(self.SelectedClass).outerHTML(),
            documentId: self.DocumentId
        });
        ajax_options.success = function (data) {
            if (typeof data.Error == 'undefined') {
                var sentObj = self.CacheSentence(data);
                self.SetSentenceModel(sentObj);
                self.WrapUserNotes(self.$SentenceEditContainer);
            }
        }
        ajax_options.error = function (jqXHR, textStatus, errorThrown) {
            self.ErrorHandlingModel.HandleAjaxError(self.RequestSentenceData, self.SelectedWordModel.BackToMenu);
        }

        $.ajax(ajax_options);
    }

    self.SetSentenceModel = function (sentence) {
        self.EditSentenceModel.AlternativeStructures(sentence.AlternativeStructures);
        self.EditSentenceModel.OriginalSentence(sentence.OriginalSentence);
        self.EditSentenceModel.TransformedSentence(sentence.Sentence);
        self.$SentenceEditContainer.html(sentence.Sentence);

        self.SetContentEditableImages(self.$SentenceEditContainer);
        //self.SetUpMagnific(self.$SentenceEditContainer);

        self.EditSentenceModel.IsAccepted($(sentence.Sentence).is('.' + self.AcceptedClass));
        self.EditSentenceModel.UnmodifiedSentenceHtml = sentence.Sentence;

        self.CalculateObstacleCount();

        self.SetUpNoteTooltips(self.$SentenceEditContainer);

        if (self.IsObstaclesOn() == true) {
            self.ColorObstacles(true);
        } else {
            self.IsObstaclesOn(true);
        }
    }

    self.CreateOriginalStructureOption = function () {
        var struct = {};
        struct.Index = ko.observable(0);
        struct.Label = Localization.GetResource('DocumentReview_Original');
        struct.Text = $(self.EditSentenceModel.OriginalSentence()).text();

        return struct;
    }

    self.CreateDeleteSentenceOption = function () {
        var struct = {};
        struct.Index = ko.observable(1);
        struct.Label = Localization.GetResource('DocumentReview_Delete');
        struct.Text = $(self.EditSentenceModel.TransformedSentence()).text();
        struct.IsDelete = true;

        return struct;
    }

    self.CreateSplitSentenceOption = function (structHTML) {
        var struct = {};
        struct.Index = ko.observable(self.EditSentenceModel.AlternativeStructures().length);
        struct.Label = Localization.GetResource('DocumentReview_Split');
        struct.Text = $(structHTML).text();
        struct.OptionValue = structHTML;

        return struct;
    }

    self.RedrawCurrentSentence = function () {
        if (self.$CurrentSentence.length > 0) {
            //self.$CurrentSentence[0].style.paddingRight = '100px';
            //var resetNode = document.createElement('span');
            //resetNode.id = 'resetNode';
            //self.$CurrentSentence.append(resetNode);            
            //self.$CurrentSentence.find('#resetNode').remove();
            //self.$CurrentSentence.removeAttr('style');

            //var $styleRenderer = $('head').find('style#styleRenderer');
            //if ($styleRenderer.length == 0) {
            //    $('head').append('<style id="styleRenderer" type="text/css"> .content-area .sentence { padding:5px; }</style>');
            //}

            //$styleRenderer = $('head').find('style#styleRenderer');
            //$styleRenderer.html('');
        }
    }

    self.SelectSpecific = function ($sentence) {
        if ($sentence.is('.' + self.SentenceClass) && !$sentence.is('.' + self.SelectedClass)) {
            self.$CurrentSentence.removeClass(self.SelectedClass);
            self.RedrawCurrentSentence();
            self.$CurrentSentence = $sentence;
            self.$CurrentSentence.addClass(self.SelectedClass);
            self.RedrawCurrentSentence(); // forced repaint of the content area in order to fix a repaint but with IE11

            self.SentenceSelected();
        }
    }

    self.AltStructuresText = function () {
        return self.EditSentenceModel.AlternativeStructures().length +
            " " + Localization.GetResource("DocumentReview_AltStructures");
    }

    self.ObstaclesDetectedText = function () {
        var obstCount = self.EditSentenceModel.ObstaclesCount();
        var bSingular = obstCount == 1;

        return obstCount.toString() + " " + (bSingular ? Localization.GetResource('DocumentReview_ObstaclesSingular') : Localization.GetResource('DocumentReview_ObstaclesSingular'));
    }

    self.ColorObstacles = function (value) {
        if (value) {
            self.$SentenceEditContainer.addClass(self.ObstacleOnClass);
        } else {
            self.$SentenceEditContainer.removeClass(self.ObstacleOnClass);
            self.EditSentenceModel.IsWordSelected(false);
        }
    }

    self.IsObstaclesOn.subscribe(self.ColorObstacles)

    //Toggles off all displayed obstacle and article areas
    self.ClearOptionsArea = function () {
        self.IsAlternativeStructuresOn(false);
        self.EditSentenceModel.IsWordSelected(false);
        self.ErrorHandlingModel.IsErrorOn(false);
    }

    self.ToggleAltStructs = function () {
        if (self.IsAlternativeStructuresOn()) {
            self.IsAlternativeStructuresOn(false);
        } else {
            self.ClearOptionsArea();
            self.IsAlternativeStructuresOn(true);
        }
    }

    self.ToggleObstacles = function () {
        self.IsObstaclesOn(!self.IsObstaclesOn());
    }

    // This method receives a jQuery word element, and searches the WordCache for an entry, 
    // if such is not found, makes an entry and sends blank object back
    self.LoadWordFromCache = function ($word) {
        var obj = {
            Text: $word.text(),
            $Element: $word,
            IsObstacle: $word.is(self.ObstacleSelector)
        };
        
        var found = false;
        var wordsLength = self.WordCache.length;
        for (var i = 0; i < wordsLength; i++) {
            if (self.WordCache[i].Word == obj.Text) {
                obj.Definitions = ko.observableArray(self.WordCache[i].Definitions);
                obj.Synonyms = ko.observableArray(self.WordCache[i].Synonyms);
                obj.PictureURLs = ko.observableArray(self.WordCache[i].PictureURLs);
                obj.Anaphoras = ko.observableArray(self.WordCache[i].Anaphoras);
                found = true;
                break;
            }
        }

        if (!found) {
            self.WordCache.push({
                Word: obj.Text,
                Synonyms: [],
                Definitions: [],
                PictureURLs: []
            });

            obj.Definitions = ko.observableArray([]);
            obj.Synonyms = ko.observableArray([]);
            obj.PictureURLs = ko.observableArray([]);
            obj.Anaphoras = ko.observableArray([]);
        }

        return obj;
    }

    //This method caches a word and it's values to the word cache
    self.CacheWord = function (word) {

        for (var i = 0; i < self.WordCache.length; i++) {
            if (self.WordCache[i].Word == word.Text) {
                self.WordCache[i].Synonyms = word.Synonyms();
                self.WordCache[i].PictureURLs = word.PictureURLs();
                self.WordCache[i].Definitions = word.Definitions();
                self.WordCache[i].Anaphoras = word.Anaphoras();
                break;
            }
        }

    }

    //This method attempts to retrieve object from the cache, if not found - retrieves 'false'
    self.LoadSentenceFromCache = function (sentenceHTML) {
        var result = false;

        for (var i = 0; i < self.SentenceCache.length; i++) {
            if (self.SentenceCache[i].Sentence == sentenceHTML) {
                result = self.SentenceCache[i];
                break;
            }
        }

        return result;
    }

    //This method receives sentence object, obtained from the services and creates a cache entry,
    //checking first for existing entry, just in case.
    self.CacheSentence = function (sentence) {
        for (var i = 0; i < self.SentenceCache.length; i++) {
            if (self.SentenceCache[i].Sentence == sentence) {
                return self.SentenceCache[i];
            }
        }

        var sentObj = {};
        sentObj.Sentence = self.$CurrentSentence.clone().removeClass(self.SelectedClass).outerHTML();
        sentObj.OriginalSentence = sentence.OriginalSentence;
        sentObj.AlternativeStructures = [];
        for (var i = 0; i < sentence.AlternativeStructures.length; i++) {
            var newObj = {};
            newObj.Index = i;
            newObj.Type = sentence.AlternativeStructures[i].Type;
            newObj.Text = $(sentence.AlternativeStructures[i].Content).text();
            newObj.Html = sentence.AlternativeStructures[i].Content;

            if (sentence.AlternativeStructures[i].Type == self.AlternativeStructureTypes.Original) {
                newObj.Label = Localization.GetResource('DocumentReview_Original');
            } else if (sentence.AlternativeStructures[i].Type == self.AlternativeStructureTypes.Delete) {
                newObj.Label = Localization.GetResource('DocumentReview_Delete');
                newObj.IsDelete = true;
            } else if (sentence.AlternativeStructures[i].Type == self.AlternativeStructureTypes.Split) {
                newObj.Label = Localization.GetResource('DocumentReview_Split');
            }

            sentObj.AlternativeStructures.push(newObj);
        }

        self.SentenceCache.push(sentObj);

        return sentObj;
    }

    self.SelectObstacleHandler = function (data, event) {
        if (self.EditSentenceModel.IsAddNoteOn()) {
            var $elem = $(event.target ? event.target : event.srcElement);
            self.AddNoteToWord($elem);
        } else {
            var $elem = $(event.target ? event.target : event.srcElement);
            if ($elem.is('.' + self.CarerNoteClass)) {
                self.EditSentenceModel.SelectNote($elem);
            } else if (!self.EditSentenceModel.IsAccepted()) {
                self.SelectWord($elem);
            }
        }
    }

    self.AddNoteToWord = function ($elem) {
        if ($elem.parent().is('.' + self.WordClass)) {
            $elem = $elem.parent();
        }
        
        var $newCarerNote = $('#newnote-container').find('label').clone(false); // class="carer-note" data-bind="click: SelectNote"
      
        $elem.after($newCarerNote);
        $newCarerNote.wrap(self.WrapperElementHtml);

        self.SetUpNewNoteTooltip($newCarerNote);
        self.EditSentenceModel.SelectNote($newCarerNote);
        self.LoggingModel.LogSentenceAction(self.UserOperations.NoteInserted, [self.DocumentId, $elem.parents('.' + self.SentenceClass).attr('data-id')]);
    }

    self.SelectWord = function ($elem) {

        var $parent = $elem.parent();

        if ($parent.is('.' + self.WordClass)) {
            if ($parent.is(self.MultiwordSelector)) {
                self.SelectedWordModel.$MultiwordInner = $elem;
                self.SelectedWordModel.$Multiword = $parent;
                self.SelectedWordModel.MultiwordInnerText($elem.text());

            } else {
                self.SelectedWordModel.IsMultiword(false);
            }

            $elem = $parent;
        }

        

        self.SelectedWordModel.IsMultiword($elem.is(self.MultiwordSelector));

        if ($elem.is('.' + self.WordClass) && $elem.text().trim().length > 0
            //&&
            //(!self.EditSentenceModel.IsWordSelected() ||
            //(self.EditSentenceModel.IsWordSelected() &&
            //$elem.text() != self.SelectedWordModel.SelectedWord().Text))
            ) {

            self.SelectedWordModel.IsObstacle($elem.is(self.ObstacleSelector));            

            self.LoggingModel.LogSentenceAction(self.UserOperations.WordSelected, 
                [self.DocumentId, self.$CurrentSentence.attr('data-id'), $elem.attr('data-id'), $elem.text(), $elem.is(self.ObstacleSelector)]);

            var newElement = self.LoadWordFromCache($elem);
            self.SelectedWordModel.SelectedWord(newElement);
            self.SelectedWordModel.IsWordIdiom($elem.is(self.IdiomSelector));           
            self.EditSentenceModel.IsWordSelected(true);

            self.SelectedWordModel.AnalyzeWord();

            if (self.SelectedWordModel.IsMultiword()) {
                self.SelectedWordModel.ClearWordArea();
                self.SelectedWordModel.IsMultiwordSelectOn(true);
            } else {
                self.SelectedWordModel.BackToMenu();
            }           
        }

        if (self.SelectedWordModel.IsObstacle() || self.SelectedWordModel.IsMultiword()) {
            self.SelectedWordModel.GetObstacleFeedback();
        } 

        self.SelectedWordModel.IsFeedbackBaloonOn(false);
    }

    self.EditSentenceModel.IsWordSelected.subscribe(function (value) {
        if (value) {
            self.IsAlternativeStructuresOn(false);
        }
    });
    
    // Dummy function, used to allow the existence of notes
    self.ShowNote = function () {

    }

    self.SaveDocumentTitle = function () {
        self.NewDocumentTitle(self.DocumentTitle());
        self.$EditTitleDialogue.dialog(self.EditTitleDialogOptions);
    }

    self.LoadSynonyms = function () {
        if (self.SelectedWordModel.SelectedWord().Synonyms().length == 0) {
            self.SelectedWordModel.ClearWordArea();
            self.SelectedWordModel.IsLoading(true);
            var ajax_options = self.NewAjaxOptions();
            ajax_options.url = '/Documents/GetWordSynonyms';
            ajax_options.data = JSON.stringify({word: self.SelectedWordModel.SelectedWord().$Element.outerHTML()});
            ajax_options.success = function (data) {
                if (data.Error) {                    
                    self.ErrorHandlingModel.HandleAjaxError(self.LoadSynonyms, self.SelectedWordModel.BackToMenu, data.Error);
                } else {
                    var synonyms = [];
                    for (var i = 0; i < data.length; i++) {
                        synonyms.push({
                            Index: i,
                            Html: data[i].Html,
                            Text: $(data[i].Html).text(),
                            Description: data[i].Description
                        });
                    }

                    self.SelectedWordModel.SelectedWord().Synonyms(synonyms);
                    self.CacheWord(self.SelectedWordModel.SelectedWord());
                    self.SelectedWordModel.IsLoading(false);
                    self.SelectedWordModel.IsSynonymsOn(true);
                }
            };
            ajax_options.error = function (jqXHR, textStatus, errorThrown) {
                self.ErrorHandlingModel.HandleAjaxError(self.LoadSynonyms, self.SelectedWordModel.BackToMenu);
            }

            $.ajax(ajax_options);
            
        } else {
            self.SelectedWordModel.ClearWordArea();
            self.SelectedWordModel.IsSynonymsOn(true);
        }
    }

    self.LoadWordImages = function () {
        if (self.SelectedWordModel.SelectedWord().PictureURLs().length == 0) {
            self.SelectedWordModel.ClearWordArea();
            self.SelectedWordModel.IsLoading(true);
            var ajax_options = new self.NewAjaxOptions();

            ajax_options.url = '/Documents/GetWordPictures';
            ajax_options.data = JSON.stringify({
                word: self.SelectedWordModel.SelectedWord().$Element.outerHTML()
            });
            ajax_options.success = function (data) {
                if (data.Error) {
                    self.ErrorHandlingModel.HandleAjaxError(self.LoadWordImages, self.SelectedWordModel.BackToMenu, data.Error);
                } else {
                    self.SelectedWordModel.SelectedWord().PictureURLs(data);
                    self.CacheWord(self.SelectedWordModel.SelectedWord());

                    self.SelectedWordModel.IsLoading(false);
                    self.SelectedWordModel.IsInsertImagesOn(true);
                }
            }
            ajax_options.error = function (jqXHR, textStatus, errorThrown) {
                self.ErrorHandlingModel.HandleAjaxError(self.LoadWordImages, self.SelectedWordModel.BackToMenu);
            }
            $.ajax(ajax_options);

        } else {
            self.SelectedWordModel.ClearWordArea();
            self.SelectedWordModel.IsInsertImagesOn(true);
        }
    }

    self.LoadWordDefinitions = function () {
        if (self.SelectedWordModel.SelectedWord().Definitions().length == 0) {
            self.SelectedWordModel.ClearWordArea();
            self.SelectedWordModel.IsLoading(true);
            var ajax_options = new self.NewAjaxOptions();

            ajax_options.url = '/Documents/GetWordDefinitions';
            ajax_options.data = JSON.stringify({
                word: self.SelectedWordModel.SelectedWord().$Element.outerHTML()
            });
            ajax_options.success = function (data) {
                if (data.Error) {

                    self.ErrorHandlingModel.HandleAjaxError(
                        self.LoadWordDefinitions,
                        self.SelectedWordModel.BackToMenu,
                        data.Error);

                } else {

                    if (data.length == 0) {

                        self.ErrorHandlingModel.HandleAjaxError(
                            self.LoadWordDefinitions,
                            self.SelectedWordModel.BackToMenu,
                            Localization.GetResource('EditDocument_NoDefinition'));

                    } else {
                        var definitions = [];
                        for (var i = 0; i < data.length; i++) {
                            definitions.push({
                                Index: i,
                                Html: data[i]
                            });
                        }

                        self.SelectedWordModel.SelectedWord().Definitions(definitions);
                        self.CacheWord(self.SelectedWordModel.SelectedWord());

                        self.SelectedWordModel.IsLoading(false);
                        self.SelectedWordModel.IsInsertDefinitionOn(true);
                    }
                }
            }
            ajax_options.error = function (jqXHR, textStatus, errorThrown) {
                self.ErrorHandlingModel.HandleAjaxError(self.LoadWordDefinitions, self.SelectedWordModel.BackToMenu);
            }

            $.ajax(ajax_options);

        } else {
            self.SelectedWordModel.ClearWordArea();
            self.SelectedWordModel.IsInsertDefinitionOn(true);
        }
    }

    self.LoadAnaphoras = function () {
        if (self.SelectedWordModel.SelectedWord().Anaphoras().length == 0) {
            self.SelectedWordModel.ClearWordArea();
            self.SelectedWordModel.IsLoading(true);

            var ajax_options = self.NewAjaxOptions();
            ajax_options.url = '/Documents/GetWordAnaphoras';
            ajax_options.data = JSON.stringify({ word: self.SelectedWordModel.SelectedWord().$Element.outerHTML() });
            ajax_options.success = function (data) {
                if (data.Error) {
                    self.ErrorHandlingModel.HandleAjaxError(self.LoadAnaphoras, self.SelectedWordModel.BackToMenu, data.Error);
                } else {
                    var anaphoras = [];
                    for (var i = 0; i < data.length; i++) {
                        anaphoras.push({
                            Index: i,
                            Html: data[i].Html,
                            Text: $(data[i].Html).text()
                        });
                    }

                    self.SelectedWordModel.SelectedWord().Anaphoras(anaphoras);
                    self.CacheWord(self.SelectedWordModel.SelectedWord());
                    self.SelectedWordModel.IsLoading(false);
                    self.SelectedWordModel.IsInsertAnaphorasOn(true);
                }
            };
            ajax_options.error = function (jqXHR, textStatus, errorThrown) {
                self.ErrorHandlingModel.HandleAjaxError(self.LoadSynonyms, self.SelectedWordModel.BackToMenu);
            }

            $.ajax(ajax_options);

        } else {
            self.SelectedWordModel.ClearWordArea();
            self.SelectedWordModel.IsInsertAnaphorasOn(true);
        }
    }

    self.SubmitSentence = function () {
        self.IsObstaclesOn(false);

        //self.IsEdited(true);
        //var newSentenceHTML = self.$SentenceEditContainer.html();
        //self.$CurrentSentence.replaceWith($(newSentenceHTML));
        //self.SelectSpecific(self.$CurrentSentence); // the first is for the case when we have split option selected      

        self.RemoveContentEditableImages(self.$SentenceEditContainer);
        self.UnwrapUserNotes(self.$SentenceEditContainer);
        self.EditSentenceModel.TransformedSentence(self.$SentenceEditContainer.html());

        var ajax_options = self.NewAjaxOptions();

        ajax_options.url = '/Documents/SubmitAcceptedSentence';
        ajax_options.data = JSON.stringify({
            newSentence: self.EditSentenceModel.TransformedSentence(),
            oldSentence: self.EditSentenceModel.UnmodifiedSentenceHtml,
            docId: self.DocumentId
        });
        ajax_options.success = function (data) {
            if (data.Sentence) {
                self.LoggingModel.LogSentenceAction(self.UserOperations.SentenceAccepted, [self.DocumentId, self.$CurrentSentence.attr('data-id')]);
                self.LoggingModel.SaveSentenceLog();

                self.IsEdited(true);
                var $newSentence = $(data.Sentence);
                self.$CurrentSentence.replaceWith($newSentence);              
                self.SelectSpecific($newSentence.first()); // the first is for the case when we have split option selected                
            } else if (data.Error) {
                self.ErrorHandlingModel.HandleAjaxError(self.SubmitSentence, self.SelectedWordModel.BackToMenu, data.Error);
            }

        }
        ajax_options.error = function (jqXHR, textStatus, errorThrown) {
            self.ErrorHandlingModel.HandleAjaxError(self.SubmitSentence, self.SelectedWordModel.BackToMenu);
        }

        $.ajax(ajax_options);
    }

    self.CancelSentenceChanges = function () {
        if (confirm(Localization.GetResource('DocumentReview_ConfirmSentCancel'))) {
            self.$SentenceEditContainer.html(self.EditSentenceModel.UnmodifiedSentenceHtml);
            self.EditSentenceModel.IsWordSelected(false);
        }
    }

    self.SetUpNoteTooltips = function ($contentControl) {
        var notes = $contentControl.find('.' + self.UserNoteClass);
        for (var i = 0; i < notes.length; i++) {
            var $item = $(notes[i]);
            $item.tooltip({ items: '[data-content]', content: $item.data('content') });
        }

        var carerNotes = $contentControl.find('.' + self.CarerNoteClass);
        for (var i = 0; i < carerNotes.length; i++) {
            var $item = $(carerNotes[i]);
            $item.tooltip({ items: '[data-content]', content: $item.data('content') });
        }
    }

    self.SetUpNewNoteTooltip = function ($note) {
        $note.tooltip({ items: '[data-content]', content: $note.attr('data-content') });
    }

    self.NotSavedMessage = function () {
        if (self.IsEdited() == true) {
            return Localization.GetResource('DocumentReview_SaveChanges');
        }
    };
     
    self.CalculateObstacleCount = function () {
        var $obstacles = self.$SentenceEditContainer.find(self.ObstacleSelector);

        self.EditSentenceModel.ObstaclesCount($obstacles.length);
    };

    self.SetUpMagnific = function ($container) {
        $container.find('img').each(function () {
            var $imgElem = $(this);
            $imgElem.magnificPopup({
                type: 'image',
                items: {
                    'src': $imgElem.attr('src')
                },
                closeOnContentClick: true,
                closeOnBgClick: true
            });
        });
    };

    self.OpenContactUserWindow = function () {
        self.ContactUserModel.ClearFields();
        self.ContactUserModel.$ContactContainer.dialog(self.ContactUserModel.GetDialogOptions());
    };

    self.OpenPreviewDialogue = function () {
        self.$PreviewDocumentDialogue.dialog({
            title: Localization.GetResource('UserAccount_Preview'),
            width: 830,
            height: 500,            
            modal: true,
            open: function () {
                self.$PreviewDocumentDialogue.find('.preview-doc-container').html(self.$SimplifiedContentControl.html());
                self.$PreviewDocumentDialogue.find('.preview-doc-container').find('.' + self.SelectedClass).removeClass(self.SelectedClass);
            },
            buttons: [{
                text: Localization.GetResource('DocumentEdit_Close'),
                click: function () {
                    self.$PreviewDocumentDialogue.dialog('close');
                }
            }]
        });
    };   

    self.ReprocessSentence = function () {
        if (!self.SelectedWordModel.IsLoading()) {
            var ajax_options = self.NewAjaxOptions();
            ajax_options.url = '/Documents/ReprocessSentence';
            ajax_options.data = JSON.stringify({
                sentence: self.$SentenceEditContainer.text()
            });
            ajax_options.success = function (data) {
                self.IsReprocessing(false);
                if (data.Error) {
                    self.ErrorHandlingModel.HandleAjaxError(self.ReprocessSentence, self.SelectedWordModel.BackToMenu, data.Error);
                } else {
                    self.SelectedWordModel.IsLoading(false);
                    self.IsEdited(false);
                    var $newSentence = $(data.Sentence);
                    self.$CurrentSentence.replaceWith($newSentence);
                    self.SelectSpecific($newSentence.first()); // the first is for the case when we have split option selected
                    self.$ReprocessConfirmDialogue.dialog('close');
                }
            }
            ajax_options.error = function (jqXHR, textStatus, errorThrown) {
                self.IsReprocessing(false);
                self.ErrorHandlingModel.HandleAjaxError(self.ReprocessSentence, self.SelectedWordModel.BackToMenu);
                self.$ReprocessConfirmDialogue.dialog('close');
                
            }

            $.ajax(ajax_options);
            self.IsReprocessing(true);
            self.$ReprocessConfirmDialogue.dialog('close');
            self.EditSentenceModel.IsWordSelected(true);
            self.SelectedWordModel.ClearWordArea();
            self.SelectedWordModel.IsLoading(true);
        }
    };

    self.ReprocessSentencePrompt = function () {
        self.$ReprocessConfirmDialogue.dialog(self.ReprocessDialogOptions);
    };

    //<------------ End of Functional methods ------------>




    //<------------ Dialog options ------------>

    self.AddImageDialogOptions = {
        width: 400,
        height: 250,
        buttons: [{
            text: Localization.GetResource('DocumentReview_Insert'),
            click: self.SelectedWordModel.AddUserImage
        }],
        title: Localization.GetResource('DocumentReview_Custom')
    };

    self.ReprocessDialogOptions = {
        width: 400,
        height: 250,
        modal: true,
        title: Localization.GetResource('DocumentReview_ReprocessDialogTitle'),
        buttons: [{
            text: Localization.GetResource('DocumentReview_Reprocess'),
            click: self.ReprocessSentence
        }, {
            text: Localization.GetResource('Library_Cancel'),
            click: function () {
                $(this).dialog('close');
            }
        }]
    };

    self.EditTitleDialogOptions = {
        width: 400,
        height: 250,
        buttons: [{
            text: Localization.GetResource('Library_Save'),
            click: function () {
                self.$HiddenDocumentTitle.val(self.NewDocumentTitle());
                self.$SimplifiedContentControl.find('.' + self.SelectedClass).removeClass(self.SelectedClass);
                self.$HiddenSimplifiedContent.val(self.$SimplifiedContentControl.html());
                self.$HiddenSummary.val(self.Summary());
                self.IsEdited(false);
                self.$HiddenActionsLog.val(self.LoggingModel.CompleteActionsLog);

                $('form').submit();
            }
        },
        {
            text: Localization.GetResource('Library_Cancel'),
            click: function () { self.$EditTitleDialogue.dialog("close"); }
        }],
        title: Localization.GetResource('Library_Save')
    };

    //<------------ End of Dialog options ------------>


    // Mockup or fixture data
    self.LoadFixtureData = function () {
        self.DocumentTitle('New Document');
        self.$SimplifiedContentControl.html('<span class="sentence"><span class="word"></span><span class="word">The</span><span class="word"> </span><span class="word">opened</span><span class="word"> </span><span class="word">half-door</span><span class="word"> </span><span class="word">was</span><span class="word"> </span><span class="word">opened</span><span class="word"> </span><span class="word">a</span><span class="word"> </span><span class="word">little</span><span class="word"> </span><span class="word">further</span><span class="word">, </span><span class="word">and</span><span class="word"> </span><span class="word">secured</span><span class="word"> </span><span class="word">at</span><span class="word"> </span><span class="word">that</span><span class="word"> </span><span class="word">angle</span><span class="word"> </span><span class="word">for</span><span class="word"> </span><span class="word">the</span><span class="word"> </span><span class="word">time</span><span class="word">. </span></span><span class="sentence obstacled"><span class="word"></span><span class="word">A</span><span class="word"> </span><span class="word" data-obstacle="broad">broad</span><span class="word"> </span><span class="word">ray</span><span class="word"> </span><span class="word">of</span><span class="word"> </span><span class="word">light</span><span class="word"> </span><span class="word">fell</span><span class="word"> </span><span class="word">into</span><span class="word"> </span><span class="word">the</span><span class="word"> </span><span data-obstacle="garret" class="word">garret</span><span class="word">, </span><span class="word">and</span><span class="word"> </span><span class="word">showed</span><span class="word"> </span><span class="word">the</span><span class="word"> </span><span class="word">workman</span><span class="word"> </span><span class="word">with</span><span class="word"> </span><span class="word">an</span><span class="word"> </span><span class="word">unfinished</span><span class="word"> </span><span class="word">shoe</span><span class="word"> </span><span class="word">upon</span><span class="word"> </span><span class="word">his</span><span class="word"> </span><span class="word">lap</span><span class="word">, </span><span class="word">pausing</span><span class="word"> </span><span class="word">in</span><span class="word"> </span><span class="word">his</span><span class="word"> </span><span class="word">labour</span><span class="word">. </span></span><span class="sentence"><span class="word"></span><span class="word">His</span><span class="word"> </span><span class="word">few</span><span class="word"> </span><span class="word">common</span><span class="word"> </span><span class="word">tools</span><span class="word"> </span><span class="word">and</span><span class="word"> </span><span class="word">various</span><span class="word"> </span><span class="word">scraps</span><span class="word"> </span><span class="word">of</span><span class="word"> </span><span class="word">leather</span><span class="word"> </span><span class="word">were</span><span class="word"> </span><span class="word">at</span><span class="word"> </span><span class="word">his</span><span class="word"> </span><span class="word">feet</span><span class="word"> </span><span class="word">and</span><span class="word"> </span><span class="word">on</span><span class="word"> </span><span class="word">his</span><span class="word"> </span><span class="word">bench</span><span class="word">. </span></span><span class="sentence"><span class="word"></span><span class="word">He</span><span class="word"> </span><span class="word">had</span><span class="word"> </span><span class="word">a</span><span class="word"> </span><span class="word">white</span><span class="word"> </span><span class="word">beard</span><span class="word">, </span><span class="word">raggedly</span><span class="word"> </span><span class="word">cut</span><span class="word">, </span><span class="word">but</span><span class="word"> </span><span class="word">not</span><span class="word"> </span><span class="word">very</span><span class="word"> </span><span class="word">long</span><span class="word">, </span><span class="word">a</span><span class="word"> </span><span class="word">hollow</span><span class="word"> </span><span class="word">face</span><span class="word">, </span><span class="word">and</span><span class="word"> </span><span class="word">exceedingly</span><span class="word"> </span><span class="word">bright</span><span class="word"> </span><span class="word">eyes</span><span class="word">. </span></span><span class="sentence"><span class="word"></span><span class="word">The</span><span class="word"> </span><span class="word">hollowness</span><span class="word"> </span><span class="word">and</span><span class="word"> </span><span class="word">thinness</span><span class="word"> </span><span class="word">of</span><span class="word"> </span><span class="word">his</span><span class="word"> </span><span class="word">face</span><span class="word"> </span><span class="word">would</span><span class="word"> </span><span class="word">have</span><span class="word"> </span><span class="word">caused</span><span class="word"> </span><span class="word">them</span><span class="word"> </span><span class="word">to</span><span class="word"> </span><span class="word">look</span><span class="word"> </span><span class="word">large</span><span class="word">, </span><span class="word">under</span><span class="word"> </span><span class="word">his</span><span class="word"> </span><span class="word">yet</span><span class="word"> </span><span class="word">dark</span><span class="word"> </span><span class="word">eyebrows</span><span class="word"> </span><span class="word">and</span><span class="word"> </span><span class="word">his</span><span class="word"> </span><span class="word">confused</span><span class="word"> </span><span class="word">white</span><span class="word"> </span><span class="word">hair</span><span class="word">, </span><span class="word">though</span><span class="word"> </span><span class="word">they</span><span class="word"> </span><span class="word">had</span><span class="word"> </span><span class="word">been</span><span class="word"> </span><span class="word">really</span><span class="word"> </span><span class="word">otherwise</span><span class="word">; </span><span class="word">but</span><span class="word">, </span><span class="word">they</span><span class="word"> </span><span class="word">were</span><span class="word"> </span><span class="word">naturally</span><span class="word"> </span><span class="word">large</span><span class="word">, </span><span class="word">and</span><span class="word"> </span><span class="word">looked</span><span class="word"> </span><span class="word">unnaturally</span><span class="word"> </span><span class="word">so</span><span class="word">. </span></span><span class="sentence"><span class="word"></span><span class="word">His</span><span class="word"> </span><span class="word">yellow</span><span class="word"> </span><span class="word">rags</span><span class="word"> </span><span class="word">of</span><span class="word"> </span><span class="word">shirt</span><span class="word"> </span><span class="word">lay</span><span class="word"> </span><span class="word">open</span><span class="word"> </span><span class="word">at</span><span class="word"> </span><span class="word">the</span><span class="word"> </span><span class="word">throat</span><span class="word">, </span><span class="word">and</span><span class="word"> </span><span class="word">showed</span><span class="word"> </span><span class="word">his</span><span class="word"> </span><span class="word">body</span><span class="word"> </span><span class="word">to</span><span class="word"> </span><span class="word">be</span><span class="word"> </span><span class="word">withered</span><span class="word"> </span><span class="word">and</span><span class="word"> </span><span class="word">worn</span><span class="word">. </span></span><span class="sentence"><span class="word"></span><span class="word">He</span><span class="word">, </span><span class="word">and</span><span class="word"> </span><span class="word">his</span><span class="word"> </span><span class="word">old</span><span class="word"> </span><span class="word">canvas</span><span class="word"> </span><span class="word">frock</span><span class="word">, </span><span class="word">and</span><span class="word"> </span><span class="word">his</span><span class="word"> </span><span class="word">loose</span><span class="word"> </span><span class="word">stockings</span><span class="word">, </span><span class="word">and</span><span class="word"> </span><span class="word">all</span><span class="word"> </span><span class="word">his</span><span class="word"> </span><span class="word">poor</span><span class="word"> </span><span class="word">tatters</span><span class="word"> </span><span class="word">of</span><span class="word"> </span><span class="word">clothes</span><span class="word">, </span><span class="word">had</span><span class="word">, </span><span class="word">in</span><span class="word"> </span><span class="word">a</span><span class="word"> </span><span class="word">long</span><span class="word"> </span><span class="word">seclusion</span><span class="word"> </span><span class="word">from</span><span class="word"> </span><span class="word">direct</span><span class="word"> </span><span class="word">light</span><span class="word"> </span><span class="word">and</span><span class="word"> </span><span class="word">air</span><span class="word">, </span><span class="word">faded</span><span class="word"> </span><span class="word">down</span><span class="word"> </span><span class="word">to</span><span class="word"> </span><span class="word">such</span><span class="word"> </span><span class="word">a</span><span class="word"> </span><span class="word">dull</span><span class="word"> </span><span class="word">uniformity</span><span class="word"> </span><span class="word">of</span><span class="word"> </span><span class="word">parchment-yellow</span><span class="word">, </span><span class="word">that</span><span class="word"> </span><span class="word">it</span><span class="word"> </span><span class="word">would</span><span class="word"> </span><span class="word">have</span><span class="word"> </span><span class="word">been</span><span class="word"> </span><span class="word">hard</span><span class="word"> </span><span class="word">to</span><span class="word"> </span><span class="word">say</span><span class="word"> </span><span class="word">which</span><span class="word"> </span><span class="word">was</span><span class="word"> </span><span class="word">which</span><span class="word">.</span></span>');
    }

    self.IE11DataPrerender = function () {
        var $sentences = self.$SimplifiedContentControl.find('.' + self.SentenceClass);
        $sentences.css('background-color', 'white');
        $sentences.removeClass('sentence');
        $sentences.addClass('sentence');
    }

    // Load user and document related data
    self.LoadData = function () {
        self.DocumentTitle(self.$HiddenDocumentTitle.val());
        self.$SimplifiedContentControl.html($(self.$HiddenSimplifiedContent.val()));
        self.Summary(self.$HiddenSummary.val());
        self.LoggingModel.CompleteActionsLog = self.$HiddenActionsLog.val();
        //setTimeout(self.IE11DataPrerender, 2000);

        self.SetUpNoteTooltips(self.$SimplifiedContentControl);
    }

    // Used to run text and form pre-processing and formatting
    self.Initialize = function () {

        self.NavigationHandlerValues.SelectNext = self.SelectNextSentence;
        self.NavigationHandlerValues.SelectPrev = self.SelectPrevSentence;
        self.NavigationHandlerValues.SelectSpecific = self.SelectSpecific;

        self.AltStructsButtonOptions.OnText = Localization.GetResource('DocumentReview_Hide');
        self.AltStructsButtonOptions.OffText = Localization.GetResource('DocumentReview_Show');
        self.ObstaclesButtonOptions.OnText = Localization.GetResource('DocumentReview_Hide');
        self.ObstaclesButtonOptions.OffText = Localization.GetResource('DocumentReview_Show');

        window.onbeforeunload = self.NotSavedMessage;

        self.SetUpMagnific(self.$SimplifiedContentControl);
    }

    self.RegisterCustomHandlers = function () {

        // This is the binding handler that attaches navigation events to the simplification container.
        ko.bindingHandlers.sentenceNavigation = {
            init: function (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
                var $elem = $(element);
                var settings = valueAccessor();
                if (settings && settings.SelectNext && settings.SelectPrev && settings.SelectSpecific) {

                    $elem.on('keydown', function (event) {
                        if (event.keyCode) {
                            // Key codes:
                            // left arrow	 37
                            // up arrow	     38
                            // right arrow	 39
                            // down arrow	 40
                            // numpad 2	     98
                            // numpad 4	    100
                            // numpad 6     102
                            // numpad 8     104

                            // Next sentence
                            if (event.keyCode == 39 || event.keyCode == 40 || event.keyCode == 98 || event.keyCode == 102) {
                                settings.SelectNext();
                                event.preventDefault();
                            } else if (event.keyCode == 37 || event.keyCode == 38 || event.keyCode == 100 || event.keyCode == 104) {
                                settings.SelectPrev();
                                event.preventDefault();
                            }
                        }
                    });

                    $elem.on('click', function (event) {

                        var $clickedSentence;
                        var $target = $(event.target ? event.target : event.srcElement);
                        if ($target.is('.' + self.SentenceClass)) {
                            $clickedSentence = $target;
                        } else {
                            $clickedSentence = $target.parentsUntil(self.$SimplifiedContentControl).filter('.' + self.SentenceClass).last();
                        }

                        settings.SelectSpecific($clickedSentence);

                    });

                    var $firstSentence = $elem.find('.' + self.SentenceClass).first();
                    if ($firstSentence.length > 0) {
                        settings.SelectSpecific($firstSentence);
                    }
                }
            }
        };

        ko.bindingHandlers.OnOffButton = {
            init: function (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
                var $elem = $(element);

                var options = valueAccessor();
                if (options && options.OnText && options.OffText && options.Observable) {
                    var toggleFunction = function (value) {
                        if (value) {
                            $elem.text(options.OnText);
                        } else {
                            $elem.text(options.OffText);
                        }
                    };

                    options.Observable.subscribe(toggleFunction);

                    toggleFunction(options.Observable());
                }
            }
        };

        ko.bindingHandlers.magnific = {
            init: function (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
                var $imgElem = $(element);
                $imgElem.magnificPopup({
                    type: 'image',
                    items: {
                        'src': valueAccessor()
                    },
                    closeOnContentClick: true,
                    closeOnBgClick: true
                });
            }
        };

    }

    // Setting up initialization, loading and binding
    self.Setup = function () {

        self.LoadData();
        //self.LoadFixtureData();
        self.Initialize();
        self.RegisterCustomHandlers();

        ko.applyBindings(self) //, $('.docreview-container')[0]
        self.$SimplifiedContentControl.focus();
    }

    self.Setup();

});