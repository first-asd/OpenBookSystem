DocumentEditSelection = new Object();

DocumentEditSelection.Text = "";
DocumentEditSelection.Range = {};

function VerifySubmitDocument() {

    if ($('#ddlSelectPatient option:selected').val()) {
        return true;
    }
    else {
        $('#lblSelectPatient').css('display', 'block');
        return false;
    }

}

function SelectTab(tab) {
    $('.tabs-text-input li').removeClass('selected');
    tab.addClass('selected');

    $('.document-input-container').children('.show-area').removeClass('show-area');

    $('.document-input-container').children('[data-id=' + tab.data('id') + ']').addClass("show-area");

    if (tab.data('id') == 'orig') {
        $('.edit-document-toolbar').addClass('make-invisible');
        $('#button-submit-text').addClass('make-invisible');
        $('.check-container').addClass('make-invisible');

    } else if ((tab.data('id') == 'conv') && ($('.edit-document-toolbar').hasClass('make-invisible'))) {
        $('.edit-document-toolbar').removeClass('make-invisible');
        $('#button-submit-text').removeClass('make-invisible');
        $('.check-container').removeClass('make-invisible');
    }
}

function InitSaveTitleDialog() {
    var options = {};
    options.buttons = [
        {
            text: Localization.GetResource('Library_Save'),
            click: SubmitDocument
        },
        {
            text: Localization.GetResource('Library_Cancel'),
            click: function () { $('#dialog-title-content').dialog("close"); }
        }
    ];

    options.modal = true;
    options.resizable = false;
    options.dialogClass = 'dialog-hide-close';
    options.title = Localization.GetResource('Library_Save');

    $('#dialog-title-content').removeClass('hide-item');
    $('#dialog-title-content input').val($('#hidTitle').val());
    $('#dialog-title-content input').bind('keyup', function (event) {
        if (event.keyCode == 13) {
            SubmitDocument();
        }
    });

    $('#dialog-title-content').dialog(options);
}

function SubmitDocument() {
    $('#hidTitle').val($('.input-doc-title').val());
    $('#result-simplified').find('.magnified').css('background-color', '');
    $('#result-simplified').find('.magnified').removeClass('magnified');
    $('#hidden-simplified-content').val($('#result-simplified').html());
    $('#hidNotSaved').val(false);
    if (IsIE8()) {
        document.forms['formDocument'].submit();
    }
    else {
        $('#formDocument').submit();
    }
}

$(document).ready(function () {
    $('.c_button').button();

    $('#button-convert-text').click(function () {
        var selectedTab = $(".tabs-text-input").children("li[class='selected']").attr('data-id');
        $('#editdoc-error-summary ul').html('');
        $('#editdoc-error-summary ul').append('<li style="display:none"></li>');
        $('.validation-summary-valid').hide();

        var $selContainer = $(".tabs-text-input").children("li[class='selected']");

        if (selectedTab == 'text' && $.trim($('#input-text').val()) == '') {
            $('#editdoc-error-summary ul').append('<li>' + Localization.GetResource('EditDocument_NoText') + '</li>'); //EditDocument_NotText
            $('.validation-summary-valid').show();
            $('#editdoc-error-summary').show();
            return false;
        }
        else if (selectedTab == 'url' && $.trim($('#input-url').val()) == '') {
            $('#editdoc-error-summary ul').append('<li>' + Localization.GetResource('EditDocument_NoUrl') + '</li>');
            $('.validation-summary-valid').show();
            $('#editdoc-error-summary').show();
            return false;
        }

            // трябва да се гледа по лейбъла
        else if (selectedTab == 'file' && $.trim($('#input-file-upload').val()) == '') {
            $('#editdoc-error-summary ul').append('<li>' + Localization.GetResource('EditDocument_NoFile') + '</li>');
            $('.validation-summary-valid').show();
            $('#editdoc-error-summary').show();
            return false;
        } else {
            var $loader = $('.simplifying-loader');
            $loader.css('display', 'block');

            var opts = {
                lines: 13, // The number of lines to draw
                length: 20, // The length of each line
                width: 10, // The line thickness
                radius: 30, // The radius of the inner circle
                corners: 1, // Corner roundness (0..1)
                rotate: 0, // The rotation offset
                direction: 1, // 1: clockwise, -1: counterclockwise
                color: '#000', // #rgb or #rrggbb or array of colors
                speed: 1, // Rounds per second
                trail: 60, // Afterglow percentage
                shadow: false, // Whether to render a shadow
                hwaccel: false, // Whether to use hardware acceleration
                className: 'spinner', // The CSS class to assign to the spinner
                zIndex: 2e9, // The z-index (defaults to 2000000000)
                top: 'auto', // Top position relative to parent in px
                left: 'auto' // Left position relative to parent in px
            };
            
            var spinner = new Spinner(opts).spin($loader[0]);
            
            //return false;
            //var $loaderImg = $loader.find('img');
            //$loaderImg.attr('data-imgsrc', $loaderImg.attr('src'));
        }

        if (IsIE8()) {
            document.forms["formDocument"].submit();
        }

    });

    $('.tabs-text-input li').click(function () {
        SelectTab($(this));
    });

    if ($('.tabs-text-input li[data-id="text"]').hasClass('hide-item')) {
        $('.tabs-text-input li[data-id="conv"]').click();
    }
    else {
        $('.tabs-text-input li[data-id="text"]').click();
    }

    var FontSize = $('#ddlFontSize').data('selected');  

    $('#ddlFontSize option[value="' + FontSize + '"]').attr("selected", "selected");

    //$('#label_check_done_container').click(function () {
    //    //ApproveText($(this));
    //    ToggleCheckButton($("#label-check-done"));
    //});

    //$('#label-check-done').click(function () {
    //    ToggleCheckButton($("#label-check-done"));
    //    return false;
    //});

    $('#button-select-file').click(function () {
        $('#input-file-upload').click();
    });

    $('#ddlFontColor').colorPicker({
        pickerDefault: $('#ddlFontColor').data('color'),
        onColorChange: function (id, newvalue) {
            $('#result-simplified').css('color', newvalue);
        }
    });

    $('#button-submit-text').click(function () {
        InitSaveTitleDialog();
    });

    $('#ddlBackgrColor').colorPicker({
        pickerDefault: $('#ddlBackgrColor').data('color'),
        onColorChange: function (id, newvalue) {
            $('#result-simplified').css('background-color', newvalue);
        }
    });

    $('#result-simplified').html($('#hidden-simplified-content').val());

    $('#input-file-upload').change(function () {
        $('#input-file-name').text(document.getElementById('input-file-upload').value.split(/(\\|\/)/g).pop());
        $('#input-file-upload').validate();
    });

    if ($('#Role').val() == 'Patient') {
        $('#result-original').attr('disabled', 'disabled');
    }

    $('#documents-hide-original').click(function () {
        ToggleShowHide($(this));
    });


    //Because there is no better way, that I've found...
    if (/Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent)) {
        $('.document-button-bar').removeClass('document-button-bar-inedit');
        $('#button-print-document').remove();
    }

    $('#ddlFontSize').chosen({ disable_search: true });    

    $('.close-result-button').button({
        text: false,
        icons: {
            secondary: 'ui-icon-close'
        }
    });

    //$('.close-result-button').click(function () {
    //    $('.dialog-explain-wrapper').css('display', 'none');
    //});

    window.onbeforeunload = function () {
        if ($('#hidNotSaved').val() == "true") {

            var formElem = document.getElementById('formDocument');
            if (formElem && ko.contextFor(formElem).IsDownloadClicked) {
                ko.contextFor(formElem).IsDownloadClicked = false;
            } else {
                return Localization.GetResource('EditDocument_NotSaved');
            }           
        }

        //var $loaderImg = $('.simplifying-loader').find('img');
        //$loaderImg.removeAttr('src');
        //$loaderImg.attr('src', $loaderImg.attr('data-imgsrc'));

    };

    $('.delete-highlight-button').button({
        icons: {
            secondary: 'ui-icon-close'
        }
    });

    $('#result-simplified').css('line-height', $('#hidLineSpacing').val());

    //KNOCKOUT SECTION
    (function () {
        'use strict'
        var self = {};

        self.InitializeVariables = function () {
            // List with all the user's themes.
            self.Themes = {};
            self.CurrentTheme = ko.observable();
            self.ThemesMenuShow = ko.observable(false);
            self.IsMagnifyOn = ko.observable(false);
            self.IsNoteOn = ko.observable(false);
            self.IsDelHighlightOn = ko.observable(false);
            self.IsMultiwordOn = ko.observable(false);
            self.IsObstaclesOn = ko.observable(false);
            self.$SimplifiedContainer = $('#result-simplified');
            self.$NotSavedHidden = $('#hidNotSaved');
            self.SelectedHighlights = [];
            self.$DocumentOperationResult = $('.document-operation-result');
            self.$DialogExplainWrapper = $('.dialog-explain-wrapper');
            self.HideAnimationEffect = 'highlight';
            self.IsPendingClosing = false;
            self.CancelBubble = false;
            self.IsDownloadClicked = false;
            self.IsNewDocument = false;
            self.IsNotificationOn = ko.observable(false);
            self.ImagePath = '/Content/wordPictures/';
            self.NoImagePath = 'AllOtherWords.png';
            self.$NoteShowArea = $('#note-result');
            self.ContainerHeight = self.$SimplifiedContainer.height();
            self.IdiomSelector = '.word.idiom.multiword';
            self.currentLanguage = '';
            self.carerNoteSelector = '.carer-note';
            self.userNoteSelector = '.text-node-point';


            self.UserLineHeight = $('#hidLineSpacing').val();

            self.UserId = $('#hidden-user-id').val();
            self.CarerId = $('#hidden-carer-id').val();
            self.UserFirstName = $('#hidden-user-fname').val();
            self.$HiddenActionsLog = $('#hidUserActionsLog');
            self.$DocumentDoneInput = $('#input-check-done');
            self.$DocumentDoneContainer = $('#label_check_done_container');
            self.DocumentTitle = '';
            self.DocumentId = $('#hidden-document-id').val();
            self.UserName = '';
            self.IsDocumentDone = ko.observable(false);
            self.FromLabel = function () {
                return Localization.GetResource('EditDocument_NotificationFrom') + ':' + self.UserName;
            };
            self.RelatedLabel = function () {
                return Localization.GetResource('EditDociment_NotificationRelatedDocument') + ':' + self.DocumentTitle;
            };

            //self.ChatSession = ko.observableArray([]);
            //self.IsReadyToSendBack = true;
            //self.PredefinedCarerResponses = ['Hello', 'How are you?', 'Wie gehts?', 'How may I help you?', 'Do you need assistance?', 'Is there anything I can do for you?', 'How are you feeling right now?', 'We are glad to be of service!', 'Was this text helpful?', 'I am not so sure I can help you with this.'];
            //self.$ChatMessagesElement = $('.chatbox-messages');

            // The selection object that is going to contain and be referenced when handling selections.
            self.Selection = {
                Text: '',
                Range: {},
                $SelectedWords: []
            };
            self.HighlightClass = 'highlight';

            self.ElementUnderlineClass = 'underline';
            self.ElementBoldClass = 'bold';
            self.ElementHighlightClass = 'highlight';
            self.CssValidForMarking = '.word , .' + self.ElementUnderlineClass + ', .' + self.ElementBoldClass + ', .' + self.ElementHighlightClass;

            self.IsBoldSelected = ko.observable(false);
            self.IsHighlightSelected = ko.observable(false);
            self.IsUnderlineSelected = ko.observable(false);
            
            self.ClearResultArea = function () {
                self.IsNotificationOn(false);
                self.IsCustomMessageOn(false);
                self.IsExplainWordOn(false);
                self.IsExplainWithPictureOn(false);
                self.IsShowNoteOn(false);
                self.ReadSummaryModel.IsShown(false);
            }

            self.ShowNotification = ko.observable(false);

            // Creates new Notification object
            self.CreateNewNotification = function () {
                var newNotification = {};
                newNotification.Subject = ko.observable('');
                newNotification.Message = ko.observable('');
                return newNotification;
            }
            self.Notification = ko.observable({ Subject: '', Message: '' });
            self.CancelNotification = function () {
                self.IsNotificationOn(false);
            };

            // Flag controling the visibility of the custom message result box.
            self.IsCustomMessageOn = ko.observable(false);
            self.CustomMessage = ko.observable('');

            self.SendNotification = function () {
                var ajax_options = {};
                ajax_options.type = 'POST';
                ajax_options.url = '/Documents/AskCarer';
                ajax_options.contentType = "application/json; charset=utf-8";
                ajax_options.dataType = "json";
                ajax_options.data = JSON.stringify({
                    subject: self.Notification().Subject(),
                    message: self.Notification().Message(),
                    documentId: self.DocumentId
                });
                ajax_options.success = function (data) {
                    if (data.Result) {
                        self.IsNotificationOn(false);
                        self.CustomMessage(Localization.GetResource('EditDocument_AskCarerSent'));
                        self.IsCustomMessageOn(true);                        
                    }
                }

                $.ajax(ajax_options);  
                
                self.LoggingModel.LogGeneralAction(self.UserOperations.ContactUserClick, [self.DocumentId]);
            }

            self.UserOperations = function () {
                return {
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
                    MagnifyTextActivate: 'MagnifyTextActivate',
                    MagnifyTextDisabled: 'MagnifyTextDisabled',
                    NoteInserted: 'NoteInserted',
                    NoteDeleted: 'NoteDeleted',
                    ExplainWordClick: 'ExplainWordClick',
                    ExplainWithPictureClick: 'ExplainWithPictureClick',
                    DocumentCheckedDone: 'DocumentCheckedDone'
                }
            }()

            self.LoggingModel = {
                DateTimeFormat: 'DD.MM.YYYY HH:mm:ss',
                Delimiter: ';',
                CompleteActionsLog: '',
                SaveLogData: function () {
                    self.$HiddenActionsLog.val(self.LoggingModel.CompleteActionsLog);
                },
                LoadLogData: function () {
                    self.LoggingModel.CompleteActionsLog = self.$HiddenActionsLog.val();
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
                        self.UserId +
                        self.LoggingModel.Delimiter +
                        'User' +
                        self.LoggingModel.Delimiter +
                        paramsData;

                    self.LoggingModel.CompleteActionsLog += logRecord;
                }
            };

            self.WrapPlainTextWord = function (word) {
                return '<span data-id="0" class="word" lang="' + self.currentLanguage + '" xml:lang="' + self.currentLanguage + '" >' + word + '</span>';
            };

            // Enum emulating object used to flag different selection oppperations
            self.HLCommand = {}
            self.HLCommand.FromStart = 1; // Apply highlight from the start container to the end of the end of the provided parent.
            self.HLCommand.ToEnd = 2; // Apply highlight from the beginning of the provided container to the provided child element.
            self.HLCommand.All = 0; // Apply highlighting to the entire element.
            self.HLCommand.PointToPoint = 3; //Apply highlighting from one element to another, both contained within single supplied parent.

            //The top element in which the text selection is limited.
            self.$TopParent = $('#result-simplified');

            //Properly working recursive method, that discovers if an element is contained within outher element.
            self.Contains = function (parent, child) {
                if (child.parentNode == parent) {
                    return true;
                } else if (child.parentNode == null) {
                    return false;
                } else {
                    return self.Contains(parent, child.parentNode);
                }

            }

            // Called when user clicks on theme button, toggles the menu for picking themes.
            self.ToggleThemeMenu = function () {
                self.ThemesMenuShow(!self.ThemesMenuShow());
            }

            self.CloseResultDialog = function ($element) {
                self.IsPendingClosing = true;
                setTimeout(function () {
                    if (self.IsPendingClosing) {
                        $element.hide(self.HideAnimationEffect, { color: '#ffffff' });
                    }
                }, 3000);
            }

            // Switches the magnigication status on and off and adjusts visibility.
            self.ToggleMagnify = function () {
                self.IsMagnifyOn(!self.IsMagnifyOn()); //toggling
                if (self.IsMagnifyOn()) {
                    self.LoggingModel.LogGeneralAction(self.UserOperations.MagnifyTextActivate, [self.DocumentId]);
                }else {
                    self.LoggingModel.LogGeneralAction(self.UserOperations.MagnifyTextDisabled, [self.DocumentId]);
                }

                self.$SimplifiedContainer.focus();

                if (self.IsMagnifyOn()) {
                    // clear highlight color
                    self.$SimplifiedContainer.find('.' + self.ElementHighlightClass).css('background-color', '');

                    self.MagnifySentence(self.$TopParent.find('.sentence').first());

                    // set background to the blurred color
                    self.$SimplifiedContainer.css('background-color', self.CurrentTheme().MagnificationColor);

                } else {
                    //clear currently magnified sentence
                    self.$SimplifiedContainer.find('.magnified').css('background-color', '');
                    self.$SimplifiedContainer.find('.magnified').removeClass('magnified');

                    self.$SimplifiedContainer.css('background-color', self.CurrentTheme().BackgroundColor);

                    //bring back the highlight color
                    self.$SimplifiedContainer.find('.' + self.ElementHighlightClass).css('background-color', self.CurrentTheme().HighlightColor);
                }
            }

            // Toggles note placing mode
            self.ToggleNote = function () {
                self.IsNoteOn(!self.IsNoteOn());
                if (self.IsNoteOn()) {
                    self.LoggingModel.LogGeneralAction(self.UserOperations.AddNoteClick, [self.DocumentId]);
                }
            }

            //Adjusts correct title corresponding to the state of the button
            self.IsNoteOn.subscribe(function (value) {
                var $notesButton = $('#notes-button');
                if (value) {
                    $notesButton.attr('title', $notesButton.data('noteson'))
                } else {
                    $notesButton.attr('title', $notesButton.data('notesoff'))
                }
            })

            self.ToggleMultiwords = function () {
                self.IsMultiwordOn(!self.IsMultiwordOn());
            };

            self.ToggleObstacles = function () {
                self.IsObstaclesOn(!self.IsObstaclesOn());
            };

            // Select theme event, triggered when user clicks on a theme.
            self.SelectTheme = function (theme) {
                self.CurrentTheme(theme);
                self.ToggleThemeMenu();
                
                self.LoggingModel.LogGeneralAction(self.UserOperations.ThemeChanged, [self.DocumentId, theme.Id]);

                self.$SimplifiedContainer.focus();                
            }

            // Re-visualize the adjusted selection
            self.ReApplySelection = function () {
                if (document.getSelection) {
                    var selection = document.getSelection();
                    selection.removeAllRanges();
                    try {
                        selection.addRange(self.Selection.Range);
                    } catch (e) {

                    }
                    self.Selection.Text = selection.toString();
                    try {
                        self.Selection.Range = selection.getRangeAt(0);
                    } catch (e) {
                        return;
                    }
                    self.HandleButtonToggleOnSelect();
                }
            }

            // Performs check on a node to discover if it is "highlightable"
            self.IsValidSelectionNode = function (node) {
                if ($(node).parentsUntil(self.$TopParent).last().length > 0) {
                    //if ($(node).parentsUntil(self.$TopParent).last().is('.sentence, .' + self.HighlightClass)) {
                    return true;
                } else {
                    return false;
                }
            }

            self.TurnOffButtons = function () {
                self.IsBoldSelected(false);
                self.IsUnderlineSelected(false);
                self.IsHighlightSelected(false);
            }

            // Triggered when the user leaves the content, used to store the selected text
            self.SaveSelection = function () {
                var select;
                var result = true;
                if (document.getSelection) {
                    select = document.getSelection();
                    if (select.rangeCount == 0) {
                        result = false;
                        self.Selection.Text = '';
                    }
                    else {
                        self.Selection.Text = select.toString();
                        self.Selection.Range = select.getRangeAt(0);

                        //Check if selection contains valid start and end points
                        if (self.Selection.Range.startContainer == self.Selection.Range.endContainer &&
                            !self.IsValidSelectionNode(self.Selection.Range.startContainer) &&
                            !self.IsValidSelectionNode(self.Selection.Range.endContainer)) {

                            // The user has selected shadowy space element rendered by the browser between the sentences.
                            self.ClearSelection();
                        }
                            // The start container is invalid, it must be moved to the next element, which is suposed to be valid.
                        else {
                            var isStartMoved = false;
                            var isEndMoved = false;

                            if (!self.IsValidSelectionNode(self.Selection.Range.startContainer)) {
                                if (self.Selection.Range.startContainer.nextSibling) {
                                    self.Selection.Range.setStart(self.Selection.Range.startContainer.nextSibling, 0);
                                    isStartMoved = true;
                                }
                            }

                            // Since DOM previousSibling retrieves next element, up the DOM tree, meaning, if you have 
                            // <div id="1"></div><div><div id="2"></div></div> and call previousSibling on $('#2')[0] you will get $('#1')[0],
                            // which is unexpected behavior. jQuery prev() does not work that way, would return null.
                            if (!self.IsValidSelectionNode(self.Selection.Range.endContainer)) {
                                var prevSibling = self.Selection.Range.endContainer.previousSibling;

                                if (prevSibling) {
                                    if ($(prevSibling).is('.sentence, .' + self.HighlightClass)) {
                                        var deepAndLast = self.GetDeepestAndLast(prevSibling);
                                        self.Selection.Range.setEnd(deepAndLast, $(deepAndLast).text().length)
                                    } else {

                                        // If the node ,which will be the new end of the selection, is of type Text, then
                                        // the second parameter of setEnd is the textcontent offset, if it is any other node,
                                        // then the second parameter should be be index of it's child nodes to which the selection should be moved.
                                        if (prevSibling.nodeType == 3) {
                                            self.Selection.Range.setEnd(prevSibling, $(prevSibling).text().length);
                                        } else {
                                            self.Selection.Range.setEnd(prevSibling, prevSibling.childNodes.length);
                                        }

                                        isEndMoved = true;
                                    }
                                }
                            }


                            if (self.Selection.Text.length > 0) {
                                // Extend the start of the selection to the beginning of the starting word.
                                if (!isStartMoved) {
                                    self.Selection.Range.setStart(self.Selection.Range.startContainer, 0);
                                }

                                // Extend the end of the selection to the end of the ending word.
                                if (!isEndMoved) {
                                    self.Selection.Range.setEnd(self.Selection.Range.endContainer, $(self.Selection.Range.endContainer).text().length);
                                }
                            } else {
                                self.TurnOffButtons();
                            }
                        }
                    }
                }

                    // Pseudo-Shamanism at work here.
                    // This is a IE8 support section. IE8 does not support the W3C Selection-Range API, 
                    // so I am creating W3C Range object using the Microsoft selection support.
                    // I am retrieving the absolute position of the selection's start and end in the text, then
                    // I use dom traversing to extract the container elements and inner text offsets of the selection's start and end.

                else if (document.selection) {
                    select = document.selection;
                    var range = select.createRange();
                    var parentElement = range.parentElement();
                    self.Selection.Text = range.text;
                    self.Selection.Range = {};

                    var sRange = range.duplicate();
                    sRange.setEndPoint('EndToStart', range);
                    sRange.moveToElementText(parentElement);
                    sRange.setEndPoint('EndToStart', range);
                    var startOffset = sRange.text.length == 0 ? 0 : sRange.text.length;
                    var elemResult = {};
                    elemResult.innerOffset = 0;
                    self.FindElementByPos(parentElement, startOffset, elemResult);
                    self.Selection.Range.startOffset = elemResult.innerOffset;
                    self.Selection.Range.startContainer = elemResult.element;

                    sRange = range.duplicate();
                    sRange.setEndPoint('StartToEnd', range);
                    sRange.moveToElementText(parentElement);
                    sRange.setEndPoint('EndToEnd', range);
                    var endOffset = sRange.text.length == 0 ? 0 : sRange.text.length;
                    elemResult = {};
                    elemResult.innerOffset = 0;
                    self.FindElementByPos(parentElement, endOffset, elemResult);

                    // If the selection ends at the beginning of an element, then that whole element should be excluded.
                    if (self.Selection.Range.startContainer != elemResult.element && elemResult.innerOffset == 0) {
                        var prevNode = elemResult.element.previousSibling;

                        // Means that prevNode is inside "word" element
                        if (prevNode == null) {
                            prevNode = elemResult.element.parentNode.previousSibling;
                        }

                        if ($(prevNode).is('.sentence, .' + self.HighlightClass)) {
                            prevNode = self.GetDeepestAndLast(prevNode);
                        }

                        self.Selection.Range.endContainer = prevNode;
                        self.Selection.Range.endOffset = $(prevNode).text().length - 1;
                    } else {
                        self.Selection.Range.endContainer = elemResult.element;
                        self.Selection.Range.endOffset = elemResult.innerOffset;
                    }

                    if (!self.IsSelectionInside(self.Selection)) {
                        result = false;
                    }

                    if (self.Selection.Text.length == 0) {
                        self.TurnOffButtons();
                    }
                }               

                self.ReApplySelection();

                return result;
            }

            // depending on the selection , toggles the buttons 
            self.HandleButtonToggleOnSelect = function () {
                if (self.Selection.Text.length > 0) {
                    var $selectedWords = self.GetSelectedWords(self.Selection.Range.startContainer, self.Selection.Range.endContainer);
                    if ($selectedWords.length > 0 && $selectedWords.filter('.' + self.ElementHighlightClass).length == $selectedWords.length) {
                        self.IsHighlightSelected(true);
                    } else {
                        self.IsHighlightSelected(false);
                    }
                    if ($selectedWords.length > 0 && $selectedWords.filter('.' + self.ElementUnderlineClass).length == $selectedWords.length) {
                        self.IsUnderlineSelected(true);
                    } else {
                        self.IsUnderlineSelected(false);
                    }
                    if ($selectedWords.length > 0 && $selectedWords.filter('.' + self.ElementBoldClass).length == $selectedWords.length) {
                        self.IsBoldSelected(true);
                    } else {
                        self.IsBoldSelected(false);
                    }
                    self.Selection.$SelectedWords = $selectedWords;

                } else {
                    self.TurnOffButtons();
                }
            }

            // Get the last leaf in the "node" parameter branch.
            self.GetDeepestAndLast = function (node) {
                if (node.childNodes.length == 0) {
                    return node;
                } else {
                    return self.GetDeepestAndLast(node.childNodes[node.childNodes.length - 1]);
                }
            }

            // Internal DOM traversing operation, which retrieves an element by a global text offset in a parent element.
            // Used for IE8 selection support.
            self.FindElementByPos = function (node, offset, result) {
                for (var i = 0; i < node.childNodes.length && !result.found; i++) {
                    if (node.childNodes[i].nodeType == 3) {
                        if (offset < $(node.childNodes[i]).text().length + result.innerOffset) {
                            result.found = true;
                            result.innerOffset = offset - result.innerOffset;
                            result.element = node.childNodes[i];
                            break;
                        } else {
                            result.innerOffset += node.childNodes[i].length;
                        }
                    } else if (node.childNodes[i].nodeType == 3) {
                        result.innerOffset += $(node.childNodes[i]).text().length;
                    } else {
                        self.FindElementByPos(node.childNodes[i], offset, result);
                    }
                }
            }

            // Checks if the selection is inside the parent element.
            self.IsSelectionInside = function (selection) {
                if ($(selection.Range.startContainer).parents(self.$TopParent).length > 0 &&
                    $(selection.Range.endContainer).parents(self.$TopParent).length > 0) {
                    return true;
                } else {
                    return false;
                }
            }

            self.HighlightTextAction = function () {
                self.HighlightClass = self.ElementHighlightClass;
                if (self.Selection.Text.length <= 0) {
                    self.CustomMessage(Localization.GetResource('DocumentEdit_SelectText'));
                    self.IsCustomMessageOn(true);
                }
                else {
                    self.ClearResultArea();
                    self.HighlightText(self.Selection);
                    self.IsCustomMessageOn(false);

                    self.LoggingModel.LogGeneralAction(self.UserOperations.HighlightClick, [self.DocumentId]);
                }
                self.$SimplifiedContainer.focus();
                self.ReApplySelection();
                self.CancelBubble = true;                
            }

            // Initiates the underlining of selected text
            self.UnderlineTextAction = function () {
                self.HighlightClass = self.ElementUnderlineClass;
                if (self.Selection.Text.length <= 0) {
                    self.CustomMessage(Localization.GetResource('DocumentEdit_SelectText'));
                    self.IsCustomMessageOn(true);
                }
                else {
                    self.ClearResultArea();
                    self.HighlightText(self.Selection);
                    self.IsCustomMessageOn(false);

                    self.LoggingModel.LogGeneralAction(self.UserOperations.UnderlineClick, [self.DocumentId]);
                }

                self.$SimplifiedContainer.focus();
                self.ReApplySelection();
                self.CancelBubble = true;                
            }

            // Initiates the boldening of selected text
            self.BoldTextAction = function () {
                self.HighlightClass = self.ElementBoldClass;
                if (self.Selection.Text.length <= 0) {
                    self.CustomMessage(Localization.GetResource('DocumentEdit_SelectText'));
                    self.IsCustomMessageOn(true);
                }
                else {
                    self.ClearResultArea();
                    self.HighlightText(self.Selection);
                    self.IsCustomMessageOn(false);
                    self.LoggingModel.LogGeneralAction(self.UserOperations.BoldClick, [self.DocumentId]);
                }
                self.$SimplifiedContainer.focus();
                self.ReApplySelection();
                self.CancelBubble = true;                
            }

            self.GetSelectedWords = function (startContainer, endContainer) {
                var $startWord = $(startContainer).parent();
                var $endWord = $(endContainer).parent();

                var elements = [];
                self.GetNodes($startWord, $endWord, elements, '.word');

                return $(elements);
            }

            // The major method detecting and initiating the highlighting process.
            self.HighlightText = function (Selection) {
                if (Selection.Text.length > 0) {
                    if (Selection.Range.startContainer) {
                        var startContainer = Selection.Range.startContainer;
                        var endContainer = Selection.Range.endContainer;

                        if (self.HighlightClass == self.ElementHighlightClass) {
                            if (self.IsHighlightSelected()) {
                                Selection.$SelectedWords.removeClass(self.ElementHighlightClass);
                                Selection.$SelectedWords.css('background-color', '');
                            } else {
                                Selection.$SelectedWords.addClass(self.ElementHighlightClass);
                            }
                            self.IsHighlightSelected(!self.IsHighlightSelected());
                        } else if (self.HighlightClass == self.ElementUnderlineClass) {
                            if (self.IsUnderlineSelected()) {
                                Selection.$SelectedWords.removeClass(self.ElementUnderlineClass);
                            } else {
                                Selection.$SelectedWords.addClass(self.ElementUnderlineClass);
                            }
                            self.IsUnderlineSelected(!self.IsUnderlineSelected());
                        } else if (self.HighlightClass == self.ElementBoldClass) {
                            if (self.IsBoldSelected()) {
                                Selection.$SelectedWords.removeClass(self.ElementBoldClass);
                            } else {
                                Selection.$SelectedWords.addClass(self.ElementBoldClass);
                            }
                            self.IsBoldSelected(!self.IsBoldSelected());
                        }
                        self.ApplyHighlightColor();

                        self.$NotSavedHidden.val(true);
                    }
                    else {
                        self.$DocumentOperationResult.html($.validator.format('<span>{0}</span>', Localization.GetResource('EditDocument_NoTextSelected')));
                        $('.dialog-explain-wrapper').css('display', 'block');
                    }
                }
            }

            self.IsEligibleForHighlight = function ($elem) {
                return $elem.is(self.CssValidForMarking) || $elem[0].nodeType == 3;
            }

            // Cleares text selection, used after highlighting.
            self.ClearSelection = function () {
                if (document.getSelection) {

                    if (!document.getSelection().isCollapsed) {
                        document.getSelection().collapseToStart();
                    }

                } else if (document.selection) {
                    document.selection.empty();
                }

                self.Selection.Text = '';
                self.Selection.Range = {};
                self.Selection.$SelectedWords = $([]);

                self.TurnOffButtons();
            }

            // Applies the css background-color style propery, taken from the currently selected theme
            self.ApplyHighlightColor = function () {
                if (self.IsMagnifyOn()) {
                    self.$SimplifiedContainer.find('.' + self.ElementHighlightClass).css('background-color', '');
                    var $magnifiedSentence = self.$TopParent.find('.magnified');
                    if ($magnifiedSentence.length > 0) {
                        if ($magnifiedSentence.hasClass(self.HighlightClass)) {
                            $magnifiedSentence.css('background-color', self.CurrentTheme().HighlightColor);
                        } else {
                            $magnifiedSentence.find('.' + self.HighlightClass).css('background-color', self.CurrentTheme().HighlightColor);
                        }
                    }
                    // apply highlight color only if the current operation is highlight text
                } else if (self.HighlightClass == self.ElementHighlightClass) {
                    self.$TopParent.children().removeAttr('style');
                    self.$TopParent.children().children().removeAttr('style');
                    self.$TopParent.find('.' + self.HighlightClass).css('background-color', self.CurrentTheme().HighlightColor);
                }
            }

            // Applies correct tooltip depending on the state of the button.
            self.IsMagnifyOn.subscribe(function (value) {
                var $notesButton = $('#magnify-button');
                if (value) {
                    $notesButton.attr('title', $notesButton.data('magnifyon'))
                } else {
                    $notesButton.attr('title', $notesButton.data('magnifyoff'))
                }
            });

            // Applies changes to the layout, corresponding to the new theme.
            self.AdjustThemeChanges = function () {
                if (self.IsMagnifyOn()) {
                    self.$TopParent.css('background-color', self.CurrentTheme().MagnificationColor);
                    self.$TopParent.find('.magnified').css('background-color', self.CurrentTheme().BackgroundColor);
                } else {
                    self.$TopParent.css('background-color', self.CurrentTheme().BackgroundColor);
                }
                self.ApplyHighlightColor();
            }

            // Helper method, inserts highlight in a text node.
            self.InsertHighlight = function (beginPos, endPos, textNode) {
                var fragment = document.createDocumentFragment();
                var selectedText = $(textNode).text();
                selectedText = selectedText.substring(beginPos, endPos);
                fragment.appendChild(document.createTextNode($(textNode).text().substring(0, beginPos)));
                fragment.appendChild($($.validator.format('<span class="{0}">{1}</span>', self.HighlightClass, selectedText))[0]);
                fragment.appendChild(document.createTextNode($(textNode).text().substring(endPos, $(textNode).text().length)));
                $(textNode).after(fragment);
                $(textNode).remove();
            }

            // Recursive method which highlights it's child nodes.
            self.HighlightParent = function (command, element, startElem, startPos, endElem, endPos) {

                // If we need to highlight the entire element
                if (command == self.HLCommand.All) {

                    $(element).children('.word').addClass(self.HighlightClass);
                }
                    // We need to highlight the element from a specifict "startElem" inside it to the end of the "element".
                else if (command == self.HLCommand.FromStart) {

                    var $wordElem = $(startElem).parentsUntil('.sentence').last();

                    if ($wordElem.length == 0) {
                        $wordElem = $(startElem);
                    }

                    $wordElem.nextAll().andSelf().addClass(self.HighlightClass);
                }
                    // We need to highlight the element from it's beginning to an end specified by the "endElem" property, which is inside it.
                else if (command == self.HLCommand.ToEnd) {

                    var $wordElem = $(startElem).parentsUntil('.sentence').last();

                    if ($wordElem.length == 0) {
                        $wordElem = $(startElem);
                    }

                    $wordElem.prevAll().andSelf().addClass(self.HighlightClass);
                }
                    // When we need to highlight text starting and ending in two elements, both child to the "element"
                else if (command = self.HLCommand.PointToPoint) {



                    var $startWord = $(startElem).parentsUntil('.sentence').last();

                    if ($startWord.length == 0) {
                        $startWord = $(startElem);
                    }

                    var $endWord = $(endElem).parentsUntil('.sentence').last();

                    if ($endWord.length == 0) {
                        $endWord = $(endElem);
                    }

                    $startWord.nextUntil($endWord).andSelf().add($endWord).addClass(self.HighlightClass);
                }
            }

            // Since jQuery DOES NOT consider Text nodes as living human beings and ignores them when using 'next', 'nextUntil' and etc. 
            // I have to do it manually by myself in DOM level.
            self.GetNodesBetween = function (startNode, endNode) {
                var result = [];
                if (startNode == endNode) {
                    //result.push(startNode);
                    return result;
                } else {
                    var shift = startNode.nextSibling;
                    while (shift && shift != endNode) {
                        result.push(shift);
                        shift = shift.nextSibling;
                    }
                }

                return result;
            }

            self.GetNodesAfter = function (startNode) {
                var result = [];
                var shift = startNode.nextSibling;
                while (shift) {
                    result.push(shift);
                    shift = shift.nextSibling;
                }

                return result;
            }

            self.GetNodesBefore = function (startNode) {
                var result = [];
                var shift = startNode.previousSibling;
                while (shift) {
                    result.push(shift);
                    shift = shift.previousSibling;
                }

                result.reverse();

                return result;
            }

            self.GetNodesBetweenIncluding = function (startNode, endNode) {
                var result = [];
                result.push(startNode);

                if (startNode == endNode) {
                    return result;
                } else {
                    var shift = startNode.nextSibling;
                    while (shift && shift.endNode != endNode) {
                        result.push(shift);
                        shift = shift.nextSibling;
                    }

                    if (shift) {
                        result.push(shift);
                    }

                    return result
                }



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

            self.GetNodes = function ($startElem, $endElem, container, filter) {
                var $buffElem = $startElem;
                if ($buffElem.is(filter)) {
                    container.push($buffElem[0]);
                }

                while ($buffElem[0] != $endElem[0]) {
                    $buffElem = self.GetNext($buffElem, $endElem, filter);
                    if($buffElem.is(filter)) {
                        container.push($buffElem[0]);
                    }	
                }
            }


            // Wrapps a text node with highligh class span.
            self.HLReplaceTextNode = function (node) {
                var span = $($.validator.format('<span class="{0}">{1}</span>', self.HighlightClass, $(node).text()));
                $(node).before(span);
                $(node).remove();
            }

            // Applies highlight class to a node
            self.HighlightNode = function (node) {
                if (node.nodeType == 3) {
                    self.HLReplaceTextNode(node);
                } else if (self.IsHighlightable(node)) {
                    $(node).addClass(self.HighlightClass);
                }
            }

            // Calls HighlightNode on a list of nodes.
            self.HighlightNodeList = function (nodelist) {
                for (var i = 0; i < nodelist.length; i++) {
                    self.HighlightNode(nodelist[i]);
                }
            }

            // This method is used to determine whether highlighting should be applied to an element.
            self.IsHighlightable = function (node) {
                var jqNode = node instanceof jQuery ? node : $(node);
                var result = true;

                result = !jqNode.is('.' + self.HighlightClass) && $(node).text().length > 0;

                return result;
            }

            // Magnified sentence on mouse click event.
            self.ApplyDocumentOperations = function (data, event) {
                if (self.IsMagnifyOn() && $(event.target).parents('#result-simplified').length > 0) {

                    var clickedSentence;
                    if ($(event.target).is('.sentence')) {
                        clickedSentence = $(event.target);
                    } else {
                        clickedSentence = $(event.target).parentsUntil(self.$TopParent).filter('.sentence').last();
                    }


                    self.MagnifySentence(clickedSentence);

                    self.$TopParent.focus();

                    if (self.IsNoteOn() && $(event.target).parents('.magnified').length > 0 && $(event.target).parents('.word').addBack().length > 0) {
                        var $clickedWord = $(event.target).parents('.word').addBack().first();
                        self.InsertNote($clickedWord, event);
                    }

                } else if (self.IsNoteOn() && $(event.target).parents('.word').addBack().length > 0) {
                    var $clickedWord = $(event.target).parents('.word').addBack().first();
                    self.InsertNote($clickedWord, event);
                }

                return true;
            }

            self.GetNextSentence = function ($startSent) {
                var $buffElem = $startSent;
                var $lastSent = self.$TopParent.find('.sentence').last();

                do {
                    $buffElem = self.GetNext($buffElem, $lastSent, '.sentence');
                } while (!$buffElem.is('.sentence'));

                return $buffElem;
            }

            self.GetPrevSentence = function ($startSent) {
                var $buffElem = $startSent;
                var $lastSent = self.$TopParent.find('.sentence').first();

                do {
                    $buffElem = self.GetPrev($buffElem, $lastSent, '.sentence');
                } while (!$buffElem.is('.sentence'));

                return $buffElem;
            }

            // Magnifies sentece on pressing keys
            self.MagnifySentenceOnPress = function (event) {
                if (self.IsMagnifyOn() && event.keyCode) {
                    // Key codes:
                    // left arrow	 37
                    // up arrow	     38
                    // right arrow	 39
                    // down arrow	 40
                    // numpad 2	     98
                    // numpad 4	    100
                    // numpad 6     102
                    // numpad 8     104

                    // Move to next sentence
                    if (event.keyCode == 39 || event.keyCode == 40 || event.keyCode == 98 || event.keyCode == 102) {
                        var $magnifiedSentence = self.$TopParent.find('.magnified');
                        if ($magnifiedSentence.length > 0) {

                            var $nextSentence = self.GetNextSentence($magnifiedSentence);

                            if ($nextSentence.length > 0) {
                                self.MagnifySentence($nextSentence);
                            }
                        }
                        event.preventDefault();
                    } else if (event.keyCode == 37 || event.keyCode == 38 || event.keyCode == 100 || event.keyCode == 104) {
                        var $magnifiedSentence = self.$TopParent.find('.magnified');
                        if ($magnifiedSentence.length > 0) {

                            var $prevSentence = self.GetPrevSentence($magnifiedSentence);

                            if ($prevSentence.length > 0) {
                                self.MagnifySentence($prevSentence);
                            }
                        }
                        event.preventDefault();
                    }
                }
            }

            //solves IE 11 css redraw bug
            self.ForceRedrawContainer = function () {
                //$('head').prepend('<style id="kk"> .sentence { padding-top:1px; } </style>');
                $('head').prepend('<style id="kk"> .sentence { opacity:0.99; } </style>');
                setTimeout(function () {
                    $('#kk').remove();
                }, 100);
            }

            self.DocumentDoneChanged = function (event, data) {
                debugger;
            }

            // Private internal method to apply highlighting
            self.MagnifySentence = function ($element) {
                if (!$element.is('.magnified') && !self.IsNoteOn() && $element.length > 0) {
                    var $prevMagnified = self.$SimplifiedContainer.find('.magnified');
                    if ($prevMagnified.length > 0) {
                        $prevMagnified.removeClass('magnified');
                        $prevMagnified.removeAttr('style');
                        //$prevMagnified.css('background-color', '');
                    }

                    $element.addClass('magnified');
                    $element.css('background-color', self.CurrentTheme().BackgroundColor);
                    var $scrollerElem = $('<div></div>');
                    $element.before($scrollerElem);
                    self.$SimplifiedContainer.scrollTop(0);
                    self.$SimplifiedContainer.scrollTop($scrollerElem.position().top - 30);// + (self.ContainerHeight / 2));
                    $scrollerElem.remove();
                    //self.$SimplifiedContainer.scrollTop($element.position().top);

                    self.ApplyHighlightColor();
                    self.ForceRedrawContainer();

                }
            }

            self.UnwrapJQueryElements = function ($elements) {
                if ($elements) {
                    for (var i = 0; i < $elements.length; i++) {
                        $($elements[i].childNodes).unwrap();
                    }
                }
            }

            // Internal method which checks if the user has selected text.
            self.IsTextSelection = function () {
                if (document.selection && document.selection.createRange().text.length > 0) {
                    return true;
                } else if (document.getSelection && document.getSelection().rangeCount > 0) {
                    var range = document.getSelection().getRangeAt(0);
                    if (range.startContainer == range.endContainer && range.startOffset == range.endOffset) {
                        return false;
                    } else {
                        return true;
                    }
                } else {
                    return false;
                }
            }

            self.CurrentTheme.subscribe(self.AdjustThemeChanges);
            self.$TopParent.keydown(self.MagnifySentenceOnPress);
            if (/Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent)) {
                self.$TopParent.on('touchend', self.SaveSelection);
                self.$TopParent.addClass('touch-enabled');
            } else {
                self.$TopParent.mouseup(self.SaveSelection);
            }
            
            

            // Toggles off Themes menu and delete highlight button off if you click outside the respected zones.
            $('body').click(function (event) {
                //debugger;
                var $target = $(event.target);
                if ($target.parents('.theme-button').length == 0 && self.ThemesMenuShow()) {
                    self.ThemesMenuShow(false);
                }

                if ($target.parents('#result-simplified').length == 0 && self.IsDelHighlightOn()) {
                    self.IsDelHighlightOn(false);
                }

                // Since IE refuses to support 'blur' or 'onfocusout' events on div elements, that are not 'contenteditable',
                // I must cancel selection when clicked on places on the screen which are not part of the selection interaction.
                if (!$target.is('.document-input-container') &&
                    $target.parents('.document-input-container').length == 0 && 
                    $target.parents('.notificationDialog').length == 0 &&
                    !$target.is('.highlight-button, .explainWord-button, .explainPicture-button, .askCarer-button, .input-doc-title, textarea, .chatbox-input, .edit-document-toolbar > li')) {
                    
                    self.ClearSelection();

                    if (self.CancelBubble) {
                        self.CancelBubble = false;
                    } else {
                        self.TurnOffButtons();
                    }
                }

                return true;
            });

            self.ChangeFontSize = function() {
                var input = document.getElementById('result-simplified');
                var value = $('#ddlFontSize option:selected').val();
                var textTransform = 'none';
                if (value == '0') {
                    value = 18;
                    textTransform = 'uppercase';
                }
                input.style.textTransform = textTransform;
                $('.chzn-single > span').css('text-transform', textTransform);
                $('.dialog-explain-wrapper textarea').css('text-transform', textTransform);

                input.style.fontSize = value + "px";
                $('.chzn-single > span').css('font-size', input.style.fontSize);
                $('.dialog-explain-wrapper textarea, .dialog-explain-wrapper input').css('font-size', value + "px");

                self.LoggingModel.LogGeneralAction(self.UserOperations.FontChanged, [self.DocumentId, value + 'px']);
            }

            self.NoteModel = {
                Text: ko.observable(''),
                FontSize: ko.observable(''),
                IsUserNote: ko.observable(true)
            };
            self.IsShowNoteOn = ko.observable(false);

            self.SaveNote = function (button) {
                var $SaveButton = $(button);
                $('.current-note').attr('data-content', self.NoteModel.Text());
                $('#hidNotSaved').val(true);
                $SaveButton.attr("title", "");
                $SaveButton.tooltip({ content: Localization.GetResource('EditDocument_ContentSaved'), position: { my: "left-160", at: "left center" } });
                $SaveButton.tooltip("open");
                $('.note-text').val(Localization.GetResource('EditDocument_NoteSaved'));
                $SaveButton.tooltip("disable");
                //self.IsShowNoteOn(false);
                self.CloseResultDialog(self.$NoteShowArea);
            }

            self.DeleteNote = function (button) {
                $('.current-note').remove();
                self.IsPendingClosing = true;
                //self.IsShowNoteOn(false);
                self.CloseResultDialog(self.$NoteShowArea);
                $('#hidNotSaved').val(true);

                self.LoggingModel.LogGeneralAction(self.UserOperations.NoteDeleted, [self.DocumentId]);
            }

            // Shows the content of the note in the result panel.
            self.ShowNote = function (element) {

                self.ClearResultArea();
                var $element = element instanceof jQuery ? element : $(element);
                
                self.NoteModel.IsUserNote($element.is(self.userNoteSelector));

                self.NoteModel.Text($element.attr('data-content'));
                self.NoteModel.FontSize($('#ddlFontSize').children('[selected="selected"]').val() + "px");

                self.IsPendingClosing = false;

                if (!$element.hasClass('current-note')) {
                    $('.current-note').removeClass('current-note');
                    $element.addClass('current-note');
                }
                
                //if ($textField.val() == $textField.attr('placeholder')) {
                //    $textField.text('');
                //}               
                
                self.IsShowNoteOn(true);
            };

            // Insert the note in the text and process cases and displaying.
            self.InsertNote = function ($word, event) {

                // This outer 'if' fixes a bug when you can actually click and append point into another point, rare but possible.
                if (!$word.is('.text-node-point') && $word.parents('.text-node-point').length == 0 && $word.parents('#result-simplified').length > 0) {
                    var $newNoteElem = $('.text-node-point').filter('.hide-item').clone(false);
                    $newNoteElem.click(self.ShowNote.bind(event, $newNoteElem));
                    $newNoteElem.on('touchend', self.ShowNote.bind(event, $newNoteElem));

                    var isInserted = false;

                    // This first 'if' case addresses an issue with IE, where when you click on a text node, which is direct child to the sentence
                    // the event.target object is the 'sentence', rather than the text node.
                    if ($word.is('.sentence, .' + self.HighlightClass)) {
                        var innerElement = self.Selection.Range.startContainer;
                        if (innerElement.nodeType == 3 && !$(innerElement).next().is('.text-node-point')) {
                            $(innerElement).after($newNoteElem);
                            $newNoteElem.removeClass('hide-item');
                            self.ShowNote($newNoteElem);
                            $('#hidNotSaved').val(true);
                            isInserted = true;
                        } else if ($(innerElement).find('.text-node-point').length == 0) {
                            $(innerElement).after($newNoteElem);
                            $newNoteElem.removeClass('hide-item');
                            self.ShowNote($newNoteElem);
                            $('#hidNotSaved').val(true);
                            isInserted = true;
                        } else {
                            self.ShowNote($(innerElement).find('.text-node-point').first());
                        }


                    } else {
                        // You shouldn't be able to place the note if there is one already in the same word.
                        if ($word.find('.text-node-point').length == 0) {
                            $word.after($newNoteElem);
                            $newNoteElem.removeClass('hide-item');
                            self.ShowNote($newNoteElem);
                            $('#hidNotSaved').val(true);
                            isInserted = true;
                        } else {
                            self.ShowNote($word.find('.text-node-point').first());
                        }
                    }

                    if (isInserted) {
                        self.LoggingModel.LogGeneralAction(self.UserOperations.NoteInserted, [self.DocumentId]);
                    }

                    self.ToggleNote();
                }

            };

            self.IsExplainWordOn = ko.observable(false);

            self.ExplainWordModel = {
                IsHavingExplanations: ko.observable(false),
                Pictures: ko.observableArray([]),
                Word: ko.observable(''),
                Description: ko.observable(''),
                IsLoading: ko.observable(false),
                IsError: ko.observable(false),
                IsReady: ko.observable(false),
                ErrorMessage: ko.observable(''),
                SearchText: ko.observable(''),
                GetSearchExplain: function () {
                    if (self.ExplainWordModel.SearchText().trim().length > 0) {
                        self.IsExplainWordOn(true);
                        self.ExplainWordModel.ClearExplainResult();
                        self.ExplainWordModel.Word(self.ExplainWordModel.SearchText().trim());

                        var ajax_options = {};
                        ajax_options.type = 'POST';
                        ajax_options.url = "/Documents/ExplainWord";
                        ajax_options.contentType = "application/json; charset=utf-8";
                        ajax_options.dataType = 'json';
                        ajax_options.data = JSON.stringify({ word: self.WrapPlainTextWord(self.ExplainWordModel.SearchText().trim()) });
                        ajax_options.success = function (data) {
                            self.ExplainWordModel.ClearExplainResult();
                            if (data.Error) {
                                self.ExplainWordModel.IsError(true);
                                self.ExplainWordModel.ErrorMessage(data.Error);
                            } else {
                                self.ExplainWordModel.Pictures(data.PictureURLs == null ? [] : data.PictureURLs);
                                self.ExplainWordModel.Description($(data.Description).text());
                                self.ExplainWordModel.IsReady(true);
                            }
                        }
                        ajax_options.error = function () {
                            self.ExplainWordModel.ClearExplainResult();
                            self.ExplainWordModel.IsError(true);
                            self.ExplainWordModel.ErrorMessage('');
                        }
                        self.ExplainWordModel.IsLoading(true);
                        $.ajax(ajax_options);
                    }
                },
                ClearExplainResult: function () {
                    self.ExplainWordModel.IsLoading(false);
                    self.ExplainWordModel.IsReady(false);
                    self.ExplainWordModel.IsError(false);
                }
            };

            self.GetFirstSelectedWord = function () {
                var result = undefined;
                //var rxTestWord = /[a-zA-Z]/;
                for (var i = 0; i < self.Selection.$SelectedWords.length; i++) {
                    //if (rxTestWord.test($(self.Selection.$SelectedWords[i]).text())) {
                    //    result = $(self.Selection.$SelectedWords[i]);
                    //    break;
                    //}
                    if ($(self.Selection.$SelectedWords[i]).text().trim().length > 0) {
                        result = $(self.Selection.$SelectedWords[i]);
                        break;
                    }
                }

                return result;
            }

            self.InitializeMagnific = function ($container) {
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
            }

            // Calls the service for Explain Word and inserts result in the output panel           
            self.ExplainWord = function () {
                self.ClearResultArea();                

                //var $word = self.GetFirstSelectedWord();
                var $word = self.Selection.$SelectedWords;

                if ($word.length > 0) {
                    var $multiwordParent = $word.parents(self.IdiomSelector);
                    var $multyChildren = $multiwordParent.children()
                    if ($multiwordParent.length > 0 && $multyChildren.length === $word.length) {
                        var isEntireMulty = true;
                        for (var i = 0; i < $multyChildren.length; i++) {
                            if ($multyChildren[i] != $word[i]) {
                                isEntireMulty = false;
                                break;
                            }
                        }
                    }

                    if (isEntireMulty) {
                        $word = $multiwordParent.eq(0);
                    } else {
                        $word = $(self.WrapPlainTextWord($word.text().trim()));
                    }

                    if ($word == undefined || $word.length == 0) {
                        self.CustomMessage(Localization.GetResource('EditDocument_SelectAWord'));
                        self.IsCustomMessageOn(true);
                    } else {
                        self.IsExplainWordOn(true);
                        self.ExplainWordModel.ClearExplainResult();
                        self.ExplainWordModel.Word($word.text());
                        self.ExplainWordModel.SearchText($word.text());
                        var ajax_options = {};
                        ajax_options.type = 'POST';
                        ajax_options.url = "/Documents/ExplainWord";
                        ajax_options.contentType = "application/json; charset=utf-8";
                        ajax_options.dataType = 'json';
                        ajax_options.data = JSON.stringify({ word: $word.outerHTML() });
                        ajax_options.success = function (data) {
                            self.ExplainWordModel.ClearExplainResult();
                            if (data.Error) {
                                self.ExplainWordModel.IsError(true);
                                self.ExplainWordModel.ErrorMessage(data.Error);
                            } else {
                                self.ExplainWordModel.Pictures(data.PictureURLs == null ? [] : data.PictureURLs);
                                self.ExplainWordModel.Description($(data.Description).text());
                                self.ExplainWordModel.IsReady(true);
                            }
                        }
                        ajax_options.error = function () {
                            self.ExplainWordModel.IsError(true);
                            self.ExplainWordModel.ErrorMessage('');
                        }
                        self.ExplainWordModel.IsLoading(true);
                        $.ajax(ajax_options);

                        self.LoggingModel.LogGeneralAction(self.UserOperations.ExplainWordClick, [self.DocumentId, $word.parents('.sentence').attr('data-id'), $word.attr('data-id'), $word.text()]);
                    }
                }
            };

            self.IsExplainWithPictureOn = ko.observable(false);

            self.ToggleCheckButton = function () {
                if (self.$DocumentDoneContainer.hasClass('label-check-deselected')) {
                    self.$DocumentDoneContainer.removeClass('label-check-deselected');
                    self.$DocumentDoneContainer.addClass('label-check-selected');
                    self.$DocumentDoneInput[0].checked = true;
                    
                    self.LoggingModel.LogGeneralAction(self.UserOperations.DocumentCheckedDone, [self.DocumentId]);
                }
                else {
                    self.$DocumentDoneInput[0].checked = false;
                    self.$DocumentDoneContainer.removeClass('label-check-selected');
                    self.$DocumentDoneContainer.addClass('label-check-deselected');
                }
            }


            self.ExplainWordWithPictureModel = {
                IsHavingPictures: ko.observable(false),
                Pictures: ko.observableArray([]),
                Word: ko.observable(''),
                Container: $('.document-operation-result'),
                IsLoading: ko.observable(false),
                IsError: ko.observable(false),
                IsReady: ko.observable(false),
                ErrorMessage: ko.observable(''),
                SearchText: ko.observable(''),
                GetSearchExplain: function () {
                    if (self.ExplainWordWithPictureModel.SearchText() == undefined || self.ExplainWordWithPictureModel.SearchText().length == 0) {
                        self.CustomMessage(Localization.GetResource('EditDocument_SelectAWord'));
                        self.IsCustomMessageOn(true);
                    } else {
                        self.ExplainWordWithPictureModel.ClearExplainResult();
                        self.ExplainWordWithPictureModel.Word(self.ExplainWordWithPictureModel.SearchText());
                        self.IsExplainWithPictureOn(true);
                        var ajax_options = {};
                        ajax_options.type = 'POST';
                        ajax_options.url = "/Documents/ExplainWordWithPictures";
                        ajax_options.contentType = "application/json; charset=utf-8";
                        ajax_options.dataType = 'json';
                        ajax_options.data = JSON.stringify({ word: self.WrapPlainTextWord(self.ExplainWordWithPictureModel.SearchText()) });
                        ajax_options.success = function (data) {
                            self.ExplainWordWithPictureModel.ClearExplainResult();
                            if (data.Error) {
                                self.ExplainWordWithPictureModel.IsError(true);
                                self.ExplainWordWithPictureModel.ErrorMessage(data.Error);
                            } else {
                                self.ExplainWordWithPictureModel.IsHavingPictures(true);
                                self.ExplainWordWithPictureModel.Pictures(data);
                                self.ExplainWordWithPictureModel.IsReady(true);
                                self.InitializeMagnific(self.ExplainWordWithPictureModel.Container);
                            }
                        }
                        ajax_options.error = function () {
                            self.ExplainWordWithPictureModel.IsError(true);
                            self.ExplainWordWithPictureModel.ErrorMessage('');
                        }

                        self.ExplainWordWithPictureModel.IsLoading(true);
                        $.ajax(ajax_options);

                    }
                    self.ExplainWordWithPictureModel.IsLoading(true);
                    $.ajax(ajax_options);
                },
                ClearExplainResult: function () {
                    self.ExplainWordWithPictureModel.IsLoading(false);
                    self.ExplainWordWithPictureModel.IsReady(false);
                    self.ExplainWordWithPictureModel.IsError(false);
                }
            };           

            self.ReadSummaryModel = {
                IsShown: ko.observable(false),
                ToggleReadSummary: function () {
                    self.ClearResultArea();                    
                    self.ReadSummaryModel.IsShown(!self.ReadSummaryModel.IsShown());
                    self.LoggingModel.LogGeneralAction(self.UserOperations.SummaryClick, [self.DocumentId, self.ReadSummaryModel.IsShown()]);
                }
            }

            // Calls the service for and inserts result in the output panel
            self.ExplainWordWithPictures = function () {
                self.ClearResultArea();

                //var $word = self.GetFirstSelectedWord();
                var $word = self.Selection.$SelectedWords;

                if ($word.length > 0) {
                    var $multiwordParent = $word.parents(self.IdiomSelector);
                    var $multyChildren = $multiwordParent.children()
                    if ($multiwordParent.length > 0 && $multyChildren.length === $word.length) {
                        var isEntireMulty = true;
                        for (var i = 0; i < $multyChildren.length; i++) {
                            if ($multyChildren[i] != $word[i]) {
                                isEntireMulty = false;
                                break;
                            }
                        }
                    }

                    if (isEntireMulty) {
                        $word = $multiwordParent.eq(0);
                    } else {
                        $word = $(self.WrapPlainTextWord($word.text().trim()));
                    }

                    if ($word == undefined || $word.length == 0) {
                        self.CustomMessage(Localization.GetResource('EditDocument_SelectAWord'));
                        self.IsCustomMessageOn(true);
                    } else {
                        self.ExplainWordWithPictureModel.ClearExplainResult();
                        self.ExplainWordWithPictureModel.Word($word.text());
                        self.ExplainWordWithPictureModel.SearchText($word.text());
                        self.IsExplainWithPictureOn(true);
                        var ajax_options = {};
                        ajax_options.type = 'POST';
                        ajax_options.url = "/Documents/ExplainWordWithPictures";
                        ajax_options.contentType = "application/json; charset=utf-8";
                        ajax_options.dataType = 'json';
                        ajax_options.data = JSON.stringify({ word: $word.outerHTML() });
                        ajax_options.success = function (data) {
                            self.ExplainWordWithPictureModel.ClearExplainResult();
                            if (data.Error) {
                                self.ExplainWordWithPictureModel.IsError(true);
                                self.ExplainWordWithPictureModel.ErrorMessage(data.Error);
                            } else {
                                self.ExplainWordWithPictureModel.IsHavingPictures(true);
                                self.ExplainWordWithPictureModel.Pictures(data);
                                self.ExplainWordWithPictureModel.IsReady(true);
                                self.InitializeMagnific(self.ExplainWordWithPictureModel.Container);
                            }
                        };
                        ajax_options.error = function () {
                            self.ExplainWordWithPictureModel.IsError(true);
                            self.ExplainWordWithPictureModel.ErrorMessage('');
                        };

                        self.ExplainWordWithPictureModel.IsLoading(true);
                        $.ajax(ajax_options);

                        self.LoggingModel.LogGeneralAction(self.UserOperations.ExplainWithPictureClick, [self.DocumentId, $word.parents('.sentence').attr('data-id'), $word.attr('data-id'), $word.text()]);
                    }
                }
            };

            // Calls the service and inserts result in the output panel
            self.AskCarer = function () {
                self.ClearResultArea();
                self.Notification(self.CreateNewNotification());
                self.IsNotificationOn(true);

            };

            self.InitializeCustomHandlers = function () {

                // Binding that sets up the carer online etiquette
                ko.bindingHandlers.carerOnlineToggle = {
                    init: function (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
                        var $element = $(element);
                        var isCarerOn = false;

                        // Sniff if the supplied value is knockout observable or plain boolean
                        if (valueAccessor() && typeof valueAccessor() == "function") {
                            isCarerOn = valueAccessor();
                        } else if (valueAccessor() && typeof valueAccessor() == "boolean") {
                            isCarerOn = valueAccessor();
                        }

                        if (isCarerOn) {
                            $element.html($element.data('on'));
                            $element.css('display', 'block');
                        } else {
                            $element.css('display', 'none');
                        }

                        $('body').css('position', 'relative');
                        //$('body').append($('.chatbox-container'));

                    },
                    update: function (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
                    }
                };

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
            };

            self.LoadData = function () {
                self.Themes = JSON.parse($('#hidden-user-themes').val());
                var $jsonData = $('#hidden-jsondata');
                if ($jsonData.length > 0 && $jsonData.val().length > 0) {
                    var data = JSON.parse($jsonData.val());
                    self.UserName = data.UserName;
                    self.DocumentId = data.DocumentId;
                    self.DocumentTitle = data.DocumentTitle;
                    self.IsNewDocument = false;
                } else {
                    self.IsNewDocument = true;
                }

                for (var i = 0; i < self.Themes.length; i++) {
                    if (self.Themes[i].IsCurrent) {
                        self.CurrentTheme(self.Themes[i]);
                        break;
                    }
                }

                if (!self.CurrentTheme()) {
                    self.CurrentTheme(self.Themes[0]);
                }

                $('.button-delete-note').button();
                $('.button-save-note').button();
                $('.askcarerButtonbar a').button();

                self.LoggingModel.LoadLogData();
                var language = docCookies.getItem('LanguageCookie');
                if (language.toLowerCase().search('en') != -1) {
                    self.currentLanguage = 'en';
                } else if (language.toLowerCase().search('es') != -1) {
                    self.currentLanguage = 'es';
                } else if (language.toLowerCase().search('bg') != -1) {
                    self.currentLanguage = 'bg';
                } else {
                    self.currentLanguage = 'en';
                }

                self.$SimplifiedContainer.find(self.carerNoteSelector).each(function (element) {
                    var elem = this;
                    $(elem).click(self.ShowNote.bind(this, this));
                })
            }

            self.CreateDialog = function (title, message) {
                var headerHtml = '<div class="notificationHeader">' + title + '</div>';
                if (self.Selection.Text === '') {
                    self.$DocumentOperationResult.html(headerHtml + '<span class="red">' + message + '</span>');
                    $('.dialog-explain-wrapper').css('display', 'block');
                    return;
                }
            }
        }

        self.InitializeVariables();
        self.InitializeCustomHandlers();
        self.LoadData();

        self.InitializeMagnific(self.$SimplifiedContainer);

        ko.applyBindings(self, $('form')[0]);
    })();
});

$('#btnDownload').click(function () {
    var options = {};
    options.modal = true;
    options.resizable = false;
    options.width = 300;
    options.height = 280;

    options.title = dictionary['SaveDocument'];
    var btnOk = {};
    btnOk.text = "OK";
    btnOk.click = function () {
        var selected = $("input[name='downloadType']:checked").attr("id");

        var formElem = document.getElementById('formDocument');
        ko.contextFor(formElem).IsDownloadClicked = true;

        switch (selected) {
            case 'rbTxt': {
                document.location = "/Documents/ExportTxt?DocumentId=" + documentId;
                break;
            }
            case 'rbPdf': {
                document.location = "/Documents/ExportPdf?DocumentId=" + documentId;
                break;
            }
            case 'rbHtml': {
                document.location = "/Documents/ExportHtml?DocumentId=" + documentId;
                break;
            }
        }

        $(this).dialog("close");
    };
    options.buttons = [btnOk]
    $('#rbTxt').attr("checked", true);
    $('#dlgDownload').dialog(options);
});

function ConvertUrlInput(userId) {
    var j = { strUrl: $('#input-url').val(), strUserID: userId };
    $.ajaxSetup({ async: false });
    $.ajax({
        type: "POST",
        url: "/Documents/SimplifyWebSite",
        data: JSON.stringify(j),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (data) {
            if (data) {
                TransformToConvertedMode();
                $('#result-original').val($('#input-url').val());
                $('#result-simplified').text(data.Result);
                DocumentEditSelection.StartPos = 0;
                DocumentEditSelection.EndPos = 0;
                DocumentEditSelection.Text = "";
                $('#lblErrorMessage').val($('#lblErrorMessage').val() + data.Error);
            }
        }
    });
}

function InsertCarerChoice() {
    var textToInsert = $('.list-word-choices li.selected').text();
    InsertText(textToInsert);
}

function trim(str) {
    return str.replace(/^\s+|\s+$/g, "");
}

function InitDialog(title, content) {
    $('#message-dialog').remove();

    var options = {};
    options.modal = true;
    options.resizable = false;
    options.width = 300;
    options.height = 140;
    options.open = function (event, ui) {
        setTimeout("$('#message-dialog').dialog('close')", 3000);
    }

    var dialog = document.createElement('div');
    dialog.title = title;
    dialog.id = 'message-dialog';
    //dialog.innerText = content; //not working on mozilla oO
    dialog.innerHTML = content;
    $(dialog).dialog(options);

}

function ToggleShowHide(button) {
    if (button.val() == button.data('hide')) {
        $('#result-simplified').children().each(function () {
            if ($(this).css('text-decoration') == 'line-through') {
                $(this).css('display', 'none');
            }
        });

        button.val(button.data('show'));
    } else if (button.val() == button.data('show')) {
        $('#result-simplified').children().each(function () {
            if ($(this).css('text-decoration') == 'line-through') {
                $(this).css('display', 'inline');
            }
        });

        button.val(button.data('hide'));
    }
}
