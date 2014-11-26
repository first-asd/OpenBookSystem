(function ($, undefined) {
    'use strict'
    var Model = {};

    Model.$DeleteUserButton = $('#users-delete');
    Model.$UsersList = $('.usersList');
    Model.$CurrentElem = $('.selected');

    Model.MessageHandling = {
        $Container: $('.users-messages'),
        $DeleteSuccess: $('.users-message-success'),
        $DeleteError: $('.users-message-error'),
        $NoUserSelected: $('.users-message-noselect')
    };

    Model.MessageHandling.Hide = function () {
        Model.MessageHandling.$Container.addClass('hide');
    }
    Model.MessageHandling.Show = function () {
        Model.MessageHandling.$Container.removeClass('hide');
    }
    Model.MessageHandling.ShowDeleteSuccess = function () {
        Model.MessageHandling.Show();
        Model.MessageHandling.$Container.children().addClass('hide');
        Model.MessageHandling.$DeleteSuccess.removeClass('hide');
    }
    Model.MessageHandling.ShowDeleteError = function () {
        Model.MessageHandling.Show();
        Model.MessageHandling.$Container.children().addClass('hide');
        Model.MessageHandling.$DeleteError.removeClass('hide');
    }
    Model.MessageHandling.ShowNoUserSelected = function () {
        Model.MessageHandling.Show();
        Model.MessageHandling.$Container.children().addClass('hide');
        Model.MessageHandling.$NoUserSelected.removeClass('hide');
    }

    Model.SelectUserClick = function (eventData) {
        var $elem = $(eventData.srcElement ? eventData.srcElement : eventData.target);
        if ($elem.hasClass('patListItem')) {
            Model.SelectUser($elem);
        } else {
            var $parentElem = $elem.parents('.patListItem');
            if ($parentElem.length > 0) {
                Model.SelectUser($parentElem);
            }
        }
    }
    Model.DeleteUserClick = function (eventData) {
        if (Model.$CurrentElem.length > 0) {

            if (confirm(Localization.GetResource('Users_DeleteConfirm'))) {

                var userId = Model.$CurrentElem.attr('data-id');
                var ajax_options = {};
                ajax_options.type = 'POST';
                ajax_options.dataType = "json";
                ajax_options.contentType = "application/json; charset=utf-8";
                ajax_options.data = JSON.stringify({ userId: userId });
                ajax_options.url = '/Users/Delete';
                ajax_options.success = function (data) {
                    debugger;
                    if (data.length == 0) {
                        Model.$CurrentElem.remove();
                        Model.MessageHandling.ShowDeleteSuccess();
                    } else {
                        Model.MessageHandling.ShowDeleteError();
                    }
                }

                $.ajax(ajax_options);

            }
        } else {
            Model.MessageHandling.ShowNoUserSelected();
        }
    }

    Model.SelectUser = function ($elem) {
        var $prevSelected = $('.selected');
        if ($prevSelected.length == 0) {
            $elem.addClass('selected');
        } else {
            $prevSelected.removeClass('selected');
            $elem.addClass('selected');
        }

        Model.$CurrentElem = $elem;
    }

    Model.SetupEvents = function () {
        Model.$UsersList.click(Model.SelectUserClick);
        Model.$DeleteUserButton.click(Model.DeleteUserClick);
    }

    Model.Initialize = function () {

        Model.SetupEvents();

    }

    Model.Initialize();
})(jQuery)