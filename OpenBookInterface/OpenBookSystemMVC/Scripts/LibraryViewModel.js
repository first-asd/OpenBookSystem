
// Combines two arrays deleting concurrent elements.
(function () {
    Array.prototype.merge = function (/* variable number of arrays */) {
        for (var i = 0; i < arguments.length; i++) {
            var array = arguments[i];
            for (var j = 0; j < array.length; j++) {
                if (this.indexOf(array[j]) === -1) {
                    this.push(array[j]);
                }
            }
        }
        return this;
    };
})();

$(document).ready(function LibraryViewMod() {
    'use strict';
    var self = {};

    self.VariablesAndMethods = function () {
        //Mockup objects
        self.PredefinedColors = ['#f00', '#ffd800', '#4cff00', '#2562e0', '#b200ff'];
        self.PredefinedLabels = ['fun', 'Sport', 'moves', 'advertisement', 'knaeckebrot']

        self.TestLabel = function() {
            var label = {
                Id: -1,
                Name: 'TestLabel',
                Color: '#123ff2',
                IsAll: false,
                FontColor: 'white',
                IsChecked: ko.observable(false)
            }
            return label;
        }

        self.TestDocument = function () {
            var doc = {
                Id: 1,
                Title: 'Document ',
                Summary: 'Test summary bla bla lorem upsum dolor et ',
                IsFavourite: ko.observable(false),
                IsChecked: ko.observable(false),
                Labels: ko.observableArray(),
                CreatedOn: '19.02.2013'
            }       
            return doc;
        };
        //--MockUp objects

        self.IsUser = ko.observable(true);
        self.UserId = 0;


        //Collection of all of the user's documents
        self.UserDocuments = [];

        self.$SearchFieldElement = $('.search-input');

        //ShowedDocuments contains the list of the documents that are currently filtered by label or search
        self.ShowedDocuments = ko.observableArray([]);

        //The list of items for the current page, these are the ones visible at a given time.
        self.CurrentPageItems = ko.observableArray([]);

        //Array with all the user labels
        self.Labels = ko.observableArray();

        self.Labels.subscribe(function (value) {
            // If only the "All" label is available, no user label is created , this - show message.
            if (value.length == 1) {
                self.NoLabelsErrorFlag(true);
            } else {
                self.NoLabelsErrorFlag(false);
            }
        });

        //Object used to fill the newly created label.
        self.NewLabel = ko.observable();

        // This is a flag indicating weather the create label dialog is on or off.
        // Used in order to monitor and prevent recreation of the dialog when the user clicks create label when the dialog is still on.
        self.IsCreateLabelDialogOn = ko.observable(false);

        //IsLabelMenuOn controls whether the menu for create/apply labels is toggled on or off
        self.IsLabelMenuOn = ko.observable(false);

        // Toggles the "no labels" display message
        self.NoLabelsErrorFlag = ko.observable(false);

        // Toggles the "no labelsa are selected" display message
        self.NoSelectedLabelsErrorFlag = ko.observable(false);

        self.NoDocSelectedLabelsErrorFlag = ko.observable(false);

        self.LabelErrorMessageToggler = ko.computed(function () {
            var result = 0;
            if (self.NoDocSelectedLabelsErrorFlag()) {
                result = 1;
            } else if (self.NoSelectedLabelsErrorFlag()) {
                result = 2;
            }

            return result;
        });

        //This is the text that is displayed when there are no filter results or user has no documents.
        self.EmptyDocsText = ko.computed(function () {
            if (self.ShowedDocuments() && self.ShowedDocuments().length == 0 && self.UserDocuments.length != 0) {
                return Localization.GetResource('Library_NoMatchesFound');
            } else if (self.UserDocuments.length == 0) {
                return Localization.GetResource('Library_NoDocuments');
            }
        });

        self.DisableLabelOperation = ko.computed(function () {
            var result = true;
            if (self.Labels().length > 1) {
                result = false;
            }
            return result;
        });

        // The size of a library page
        self.PageSize = 10;

        // Count of pages of documents, if there are no documents found, nothing appears on the pager row
        self.PageCount = ko.computed(function () {
            if (self.ShowedDocuments()) {
                return Math.ceil(self.ShowedDocuments().length / self.PageSize) - 1;
            }
        });

        // Indicates the current page number, used to color the current page button.
        self.CurrentPageIndex = ko.observable(0);

        //ID of the current label, controls which label is applied at the moment
        self.CurrentLabelId = ko.observable(0);

        // Internal method for retrieving the checked labels in the labels top menu
        self.GetCheckedLabels = function () {
            var result = [];
            for (var i = 0; i < self.Labels().length; i++) {
                if (self.Labels()[i].IsChecked()) {
                    result.push(self.Labels()[i]);
                }
            }

            return result;
        };

        // Internal method for retrieving the checked documents
        self.GetCheckedDocuments = function () {
            var result = [];
            for (var i = 0; i < self.UserDocuments.length; i++) {
                if (self.UserDocuments[i].IsChecked()) {
                    result.push(self.UserDocuments[i]);
                }
            }

            return result;
        };

        // Trigger method for selecting document page
        self.SelectDocumentPage = function (index) {
            self.CurrentPageIndex(index);
            self.CurrentPageItems(self.ShowedDocuments.slice(index * self.PageSize, index * self.PageSize + self.PageSize));
        }

        //Method is subscribed on the ShowedDocuments array, when the array changes, this function is triggered. 
        // Very convenient to always set the current page to be the first page, when searching/filtering
        self.ShowedDocuments.subscribe(function (arrData) {
            self.SelectDocumentPage(0);
        })

        // The field containing the search input string
        self.SearchValue = ko.observable('');

        // Handles the search value search
        self.ProcessSearchValue = function (txtInput) {
            if (txtInput && txtInput.trim().length > 2) {
                self.SearchDocumentsByString(txtInput);
            } else {
                self.SearchDocumentsByLabel(self.CurrentLabelId());
            }
        }

        // Event-like subscription, that processes the search request
        self.SearchValue.subscribe(self.ProcessSearchValue);


        //The method conducting the actual search and retrieve 
        self.SearchDocumentsByString = function (searchString) {
            var result = [];
            for (var i = 0; i < self.UserDocuments.length; i++) {
                if (self.UserDocuments[i].Title() && self.UserDocuments[i].Title().toLowerCase().indexOf(searchString.toLowerCase()) != -1) {
                    result.push(self.UserDocuments[i]);
                }
            }
            self.ShowedDocuments(result);
        }

        //The method searching the documents by label 
        self.SearchDocumentsByLabel = function (labelId) {
            if (labelId == -1) {
                self.ResetLibraryState();
            } else {
                var result = [];
                for (var i = 0; i < self.UserDocuments.length; i++) {
                    for (var j = 0; j < self.UserDocuments[i].Labels().length; j++) {
                        if (self.UserDocuments[i].Labels()[j].Id == labelId) {
                            result.push(self.UserDocuments[i]);
                            break;
                        }
                    }
                }
                self.ShowedDocuments(result);
            }
        }

        // CRUD functionallities for the Labels
        // Selects documents by a label
        self.SelectLabel = function (label) {
            self.CurrentLabelId(label.Id);
            if (self.SearchValue().length > 0) {
                self.SearchValue('');
            } else {
                self.SearchDocumentsByLabel(label.Id);
            }
        }

        // Applies labels to documents that have the IsChecked property
        self.ApplyLabels = function () {
            if (!self.DisableLabelOperation()) {
                var labels = self.GetCheckedLabels();
                var documents = self.GetCheckedDocuments();

                if (documents.length > 0) {
                    self.NoDocSelectedLabelsErrorFlag(false);

                    if (labels.length > 0) {
                        self.NoSelectedLabelsErrorFlag(false);

                        if (labels.length > 0 && documents.length > 0) {
                            for (var i = 0; i < documents.length; i++) {
                                documents[i].Labels(documents[i].Labels().merge(labels));
                                self.UpdateDocumentLabels(documents[i]);
                            }

                            for (var i = 0; i < labels.length; i++) {
                                labels[i].IsChecked(false);
                            }
                            self.ToggleLabelMenu(false);
                        }
                    } else {
                        self.NoSelectedLabelsErrorFlag(true);
                    }
                } else {
                    self.NoDocSelectedLabelsErrorFlag(true);
                }
            }
        }

        // Redirects to preferences.
        self.ManageLabels = function () {
            window.location = '/Account/Edit';
        }

        // Initiates removal of labels.
        self.RemoveLabel = function () {
            if (!self.DisableLabelOperation()) {
                var selectedLabels = self.GetCheckedLabels();
                var selectedDocuments = self.GetCheckedDocuments();

                if (selectedDocuments.length > 0) {
                    self.NoDocSelectedLabelsErrorFlag(false);

                    if (selectedLabels.length > 0) {
                        self.NoSelectedLabelsErrorFlag(false);

                        for (var i = 0; i < selectedDocuments.length; i++) {
                            // counter used to indicate if labels have been removed from the document.
                            var counter = 0;

                            for (var j = 0; j < selectedLabels.length; j++) {
                                counter += self.DeleteDocumentLabel(selectedDocuments[i], selectedLabels[j]);
                            }

                            if (counter > 0) {
                                self.UpdateDocumentLabels(selectedDocuments[i]);
                            }
                        }

                        self.ToggleLabelMenu();
                    } else {
                        self.NoSelectedLabelsErrorFlag(true);
                    }
                } else {
                    self.NoDocSelectedLabelsErrorFlag(true);
                }
            }            
        }

        // Closes the labels menu when clicking outside of it.
        $('body').click(function (event) {
            if ($(event.target).closest('.menu-labels-popup, .menu-labels, input[type="checkbox"]').length == 0 && self.IsLabelMenuOn()) {
                self.ToggleLabelMenu();
            }
        });

        // Internal method for deleting label from a document.
        self.DeleteDocumentLabel = function (doc, label) {
            var counter = 0;
            for (var i = 0; i < doc.Labels().length; i++) {
                if (doc.Labels()[i].Id == label.Id) {
                    doc.Labels.splice(i, 1);
                    counter++;
                    break;
                }
            }
            return counter;
        }

        self.AddUnreadClass = function (doc) {
            var result = false;
            if (!doc.IsRead()) {
                result = true;
            }

            return result;
        }

        // This method updates the status of the error message, displayed when the new label name is empty.
        self.IsLabelNameValid = ko.observable(true);


        // Creates new label
        self.CreateLabel = function () {
            if (!self.IsCreateLabelDialogOn()) {
                self.IsLabelNameValid(true);
                self.NewLabel({
                    Color: '#808080',
                    IsAll: false,
                    FontColor: '#FFFFFF',
                    IsChecked: ko.observable(false),
                    Name: ko.observable('')
                });

                var $dialog = $('.create-label-dialog');
                var dialog_options = {};
                dialog_options.title = $dialog.data('title');
                dialog_options.open = function () {
                    self.IsCreateLabelDialogOn(true);

                    $dialog.removeClass('hide');
                    //Initialize the color picker for the background color
                    //$dialog.find('.dialog-label-pickcolor').colorPicker({
                    //    pickerDefault: '808080',
                    //    onColorChange: function (id, newvalue) {
                    //        self.NewLabel().Color = newvalue;
                    //    }

                    var cpOptions = ColorPickerDefaultOptions;
                    cpOptions.change = function (color) {
                        self.NewLabel().Color = color.toHexString();
                    }
                    cpOptions.color = '#808080';

                    $dialog.find('.dialog-label-pickcolor').spectrum(cpOptions);


                    //});

                    //Initialize the color picker for the font color
                    //$dialog.find('.dialog-label-pickfontcolor').colorPicker({
                    //    pickerDefault: 'FFFFFF',
                    //    onColorChange: function (id, newvalue) {
                    //        self.NewLabel().FontColor = newvalue;
                    //    }
                    //});

                    cpOptions = ColorPickerDefaultOptions;
                    cpOptions.change = function (color) {
                        self.NewLabel().FontColor = color.toHexString();
                    }
                    cpOptions.color = '#FFFFFF';

                    $dialog.find('.dialog-label-pickfontcolor').spectrum(cpOptions);


                    // Cannot recall exactly why this was needed, but there was an issue with the custom color-picker, 
                    // supposedly fixed by this class.
                    //$dialog.find('.colorPicker-picker').addClass('fix-colorPicker-trigger');
                }
                dialog_options.close = function () {
                    self.IsCreateLabelDialogOn(false);
                }
                dialog_options.resizable = false;
                dialog_options.buttons = [{
                    text: Localization.GetResource('Library_Save'),
                    click: function () {
                        if (self.NewLabel().Name().trim().length > 0) {
                            self.SaveNewLabel();
                            $(this).dialog('close');
                        } else {
                            self.IsLabelNameValid(false);
                        }
                    }
                }, {
                    text: Localization.GetResource('Library_Cancel'),
                    click: function () {
                        $(this).dialog('close');
                    }
                }]

                $dialog.dialog(dialog_options);
            }
        }

        // The Click callback for toggling the label menu
        self.ToggleLabelMenu = function () {
            self.IsLabelMenuOn(!self.IsLabelMenuOn());
            return true;
        }

        // TODO
        self.ResetLibraryState = function () {
            //self.SearchValue('');
            self.ShowedDocuments(self.UserDocuments);
        }

        // This method is called upon to update the showed documents, after they were deleted from the view model.
        self.UpdateLibraryAfterDelete = function () {
            self.ProcessSearchValue(self.SearchValue());
        }

        // Loads all labels from the hidden field container and initializes them in the view model
        self.InitializeLabels = function () {

            var allLabel = self.TestLabel();
            allLabel.Name = Localization.GetResource('Library_AllLabel');
            allLabel.Color = 'white';
            allLabel.IsAll = true;
            allLabel.FontColor = '#5684e2';
            self.Labels.push(allLabel);
            var $labelsData = $('#library-labels-data');

            var labelsData = $labelsData.val();

            var arrUserLabels = labelsData.length == 0 ? [] : JSON.parse($labelsData.val());

            for (var i = 0; i < arrUserLabels.length; i++) {
                arrUserLabels[i].IsAll = false;
                arrUserLabels[i].IsChecked = ko.observable(false);
                self.Labels.push(arrUserLabels[i]);
            }
            self.CurrentLabelId(self.Labels()[0].Id);
            $labelsData.remove();
        }

        self.GetLabel = function (labelId) {            
            for (var i = 0; i < self.Labels().length; i++) {
                if (self.Labels()[i].Id == labelId) {
                    return self.Labels()[i];
                }
            }
        }

        // Loads documents from the hidden field, generated by the back-end.
        self.InitializeDocuments = function () {
            self.UserDocuments = ko.mapping.fromJSON($('#documents-data').val());
            $('#documents-data').remove();
            self.UserDocuments = ko.utils.unwrapObservable(self.UserDocuments);

            for (var i = 0; i < self.UserDocuments.length; i++) {
                if (self.UserDocuments[i].Labels() == undefined || self.UserDocuments[i].Labels() == null) {
                    self.UserDocuments[i].Labels([]);
                }
            }

            for (var i = 0; i < self.UserDocuments.length; i++) {
                for (var j = 0;j < self.UserDocuments[i].Labels().length; j++) {
                    self.UserDocuments[i].Labels()[j] = self.GetLabel(self.UserDocuments[i].Labels()[j]);
                }
            }

            if (self.UserDocuments) {
                self.ShowedDocuments(self.UserDocuments);
            } else {
                self.UserDocuments = [];
            }
            
        }

        // Loads and sets up additional properties.
        self.InitializeProperties = function () {
            var $isUser = $('#isUser');
            self.IsUser($isUser.val() == 'True');
            self.UserId = $('#hidden-userid').val();
        }

        // Callback for toggling favourite status of an item
        self.ToggleIsFavourite = function (item) {
            if (self.IsUser()) {
                item.IsFavourite(!item.IsFavourite());

                var ajax_options = {}
                ajax_options.type = 'POST';
                ajax_options.url = '/Documents/ToggleDocumentFavourite';
                ajax_options.data = {
                    nDocID: item.Id(),
                    IsFavourite: item.IsFavourite()
                }

                $.ajax(ajax_options);
            }
        }
        
        self.OpenDocument = function (doc) {
            if (self.IsUser()) {
                window.location = '/Documents/Edit?nDocID=' + doc.Id();
            } else {
                window.location = '/Documents/DocumentReview/' + doc.Id() + '/' + self.UserId;
            }
            
        }

        // Sens request to the app server to save the specific label
        self.SaveNewLabel = function () {
            var ajax_options = {};
            ajax_options.type = 'POST';
            ajax_options.url = '/Documents/CreateLabel';
            ajax_options.data = {
                strLabelName: self.NewLabel().Name,
                strColorName: self.NewLabel().Color,
                strFontColorName: self.NewLabel().FontColor
            }
            ajax_options.success = function (data) {
                if (data.Id) {
                    self.NewLabel().Id = data.Id;
                    self.NewLabel().Name = ko.utils.unwrapObservable(self.NewLabel().Name);
                    self.Labels.push(self.NewLabel());
                    self.ToggleLabelMenu();
                }
            }

            $.ajax(ajax_options);
        }

        // Sends request to the app server to delete the specific label
        self.DeleteLabelRecord = function (labelId) {
            var ajax_options = {};
            ajax_options.type = 'POST';
            ajax_options.url = '/Documents/DeleteLabel';
            ajax_options.data = {
                nLabelID: labelId
            }

            $.ajax(ajax_options);
        }

        //Sends request to the app server to update labels on a specific document.
        self.UpdateDocumentLabels = function (doc) {
            var arrLabels = [];
            for (var i = 0; i < doc.Labels().length; i++) {
                arrLabels.push(doc.Labels()[i].Id);
            }

            var ajax_options = {};
            ajax_options.type = 'POST';
            ajax_options.url = '/Documents/UpdateDocumentLabels';
            ajax_options.dataType = 'json';
            ajax_options.contentType = "application/json; charset=utf-8";
            ajax_options.data = JSON.stringify({
                nDocID: doc.Id(),
                labels: arrLabels
            });            

            $.ajax(ajax_options);
        }

        // Clear the search documents field
        self.ClearSearchField = function () {
            self.SearchValue('');
            self.$SearchFieldElement.focus();
        }

        // Toggle the clear search documents field icon
        self.ShowClearIcon = ko.computed(function () {
            if (self.SearchValue().length > 0) {
                return true;
            } else {
                return false;
            }
        });

        // This method deletes the selected documents
        self.DeleteDocuments = function () {
            var selectedDocs = self.GetCheckedDocuments();
            if (selectedDocs.length > 0 && confirm(Localization.GetResource('Library_ConfirmDelDocs'))) {
                var ajaxData = [];
                for (var i = 0; i < selectedDocs.length; i++) {
                    ajaxData.push(selectedDocs[i].Id());
                }

                self.DeleteDocumentRequest(ajaxData);
            }
        }

        // This method sends the array of id's of documents that are to be deleted.
        self.DeleteDocumentRequest = function (ajax_data) {
            var ajax_options = {};
            ajax_options.type = 'POST';
            ajax_options.url = '/Documents/DeleteDocuments';
            ajax_options.dataType = 'json';
            ajax_options.contentType = "application/json; charset=utf-8";
            ajax_options.data = JSON.stringify({
                arrDocuments: ajax_data
            })

            // If the documents are deleted successfully by the services, remove them from the view model.
            ajax_options.success = function () {

                // for each element in the list of id's find that particular document and delete it.
                for (var i = 0; i < ajax_data.length; i++) {
                    for (var j = 0; j < self.UserDocuments.length; j++) {
                        if (self.UserDocuments[j].Id() == ajax_data[i]) {
                            self.UserDocuments.splice(j, 1);
                            break;
                        }
                    }
                }

                // Refresh the currently displayed document list, taking into account that we might have a search/filter applied.             
                self.UpdateLibraryAfterDelete();
            }

            $.ajax(ajax_options);
        }
    }

    self.Initialization = function () {
        self.VariablesAndMethods();
        self.InitializeLabels();
        self.InitializeDocuments();
        self.InitializeProperties();

        ko.applyBindings(self, $('.selDocBody')[0]);
    }

    self.Initialization();
});