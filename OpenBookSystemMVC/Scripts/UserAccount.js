function rgb2hex(rgb) {
    var rHex = new RegExp(/^#[0-9a-f]{6}$/g);
    if (rHex.test(rgb)) {
        return rgb;
    }
    rgb = rgb.match(/^rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*(\d+))?\)$/);
    function hex(x) {
        return ("0" + parseInt(x).toString(16)).slice(-2);
    }
    return "#" + hex(rgb[1]) + hex(rgb[2]) + hex(rgb[3]);
}

function SubmitAccountChanges() {
    $('form').submit();
}

$(document).ready(function () {
    $.validator.setDefaults({
        ignore: ''
    });

    $('.tabs-text-input li').click(function () {
        SelectTab($(this));
    });

    $('#btnSubmitChanges').click(function () {
        SubmitAccountChanges();
    });

    (function () {
        var $rows = $('.langprefs-list li');
        var isContinuing = false;
        for (var i = 0; i < $rows.length; i++) {
            var $item = $($rows[i]);
            if (!isContinuing && $item.hasClass('nogroup')) {
                $item.addClass('nogroup-start');
                isContinuing = true;
            } else if (isContinuing && !$item.hasClass('nogroup')) {
                $($rows[i - 1]).addClass('nogroup-end');
                isContinuing = false;
            }
        }



    })()

});

function SelectTab(tab) {
    $('.tabs-text-input li').removeClass('selected');
    tab.addClass('selected');

    if (tab.data('id') == 'account-info') {
        $('.account-info').removeClass('hide-item');
        $('.preferences').addClass('hide-item');

    } else if (tab.data('id') == 'preferences') {
        $('.preferences').removeClass('hide-item');
        $('.account-info').addClass('hide-item');
    }

    if (IsIE8()) {
        $('.userAccBody').css('height', '100%');
    }
}

function ReInsureCorrectCheckBoxValue(label, input) {
    if (label.hasClass('label-check-selected')) {
        input.prop('checked', true);
    } else {
        input.prop('checked', false);
    }
}

function GetUrlParams(name) {
    var results = new RegExp('[\\?&amp;]' + name + '=([^&amp;#]*)', 'i').exec(window.location.href);
    return (results != undefined) ? results[1] : undefined;
}

$(function () {
    var urlPreferences = GetUrlParams('preferences');

    var $ThemeStateIcon = $('.ddlIcon');
    var $CurrentTheme = $('.currentTheme');
    var $ThemesBox = $('#selected_theme');
    var $PreviewButton = $('.previewButton');
    var $PreviewDialog = $('.previewDialog');

    if (urlPreferences == 'true') {
        SelectTab($('[data-id="preferences"]'));
    }

    $(".c_button").button();

    $(".hoverfix").mouseup(function () {
        $(this).removeClass('ui-state-focus ui-state-active');
    });

    $(document).on('click', '#selected_theme li', function () {
        $("#selected_theme li").removeClass("selected_element");
        $(this).addClass("selected_element");
        SelectTheme();
    });


    function SelectTheme() {
        var $SelectedTheme = $('#selected_theme .selected_element');
        $('#selectedThemeId').val($SelectedTheme.attr('data-id'));
        var $SelectedThemeText = $SelectedTheme.find('.theme_name');
        var fontColor = $SelectedThemeText.css('color');
        var backgroundColor = $SelectedThemeText.css('background-color');

        var $CurrentThemeIcon = $CurrentTheme.find('.color');
        $CurrentThemeIcon.css('border-left-color', fontColor);
        $CurrentThemeIcon.css('border-top-color', fontColor);
        $CurrentThemeIcon.css('border-right-color', backgroundColor);
        $CurrentThemeIcon.css('border-bottom-color', backgroundColor);


        var $CurrentThemeText = $CurrentTheme.find('.theme_name');
        $CurrentThemeText.css('color', fontColor);
        $CurrentThemeText.css('background-color', backgroundColor);
        $CurrentThemeText.data('colors', $SelectedThemeText.data('colors'));
    }

    $ThemeStateIcon.IsCollapsed = function () {
        return $(this).is('.icon-caret-down');
    }
    $ThemeStateIcon.ToggleState = function () {
        if ($ThemeStateIcon.IsCollapsed())
        {
            $ThemeStateIcon.removeClass('icon-caret-down');
            $ThemeStateIcon.addClass('icon-caret-up');
            $ThemesBox.css('display', 'block')
        } else {
            $ThemeStateIcon.removeClass('icon-caret-up');
            $ThemeStateIcon.addClass('icon-caret-down');
            $ThemesBox.css('display', 'none')
        }
    }

    $CurrentTheme.click(function () {
        $ThemeStateIcon.ToggleState();
    })

    var AdjustPreviewSetting = function () {
        var $TextContainer = $('.textWithHighlight');
        var $MagnifyContainer = $('.magnifiedText');
        var $BothContainers = $('.textWithHighlight, .magnifiedText');
        var $CurrentThemeText = $CurrentTheme.find('.theme_name');

        var fontColor = $CurrentThemeText.css('color');
        var backgroundColor = $CurrentThemeText.css('background-color');
        var colors = $CurrentThemeText.data('colors');
        var lineSpacingString = $('#lbLineSpacing').chosen().val();
        var lineSpacingAmount = '';
        var fontSize = $("#hiddenDocumentFontSize").val();
        if (fontSize == '0') {
            $BothContainers.css('text-transform', 'uppercase');
            $BothContainers.css('font-size', '1em');
        } else {
            $BothContainers.css('font-size', fontSize + 'px');
            $BothContainers.css('text-transform', 'none');
        }
        
        if (lineSpacingString == 'Small') {
            lineSpacingAmount = '1em';
        }else if (lineSpacingString == 'Medium') {
            lineSpacingAmount = '1.5em';
        }else if (lineSpacingString == 'Large') {
            lineSpacingAmount = '2em';
        }else {
            lineSpacingAmount = '1em';
        }

        
        $BothContainers.css('line-height', lineSpacingAmount);
        $BothContainers.css('font-family', $("#hiddenDocumentFontName").val());
        $BothContainers.css('color', fontColor);
        $TextContainer.css('background-color', backgroundColor);
        $TextContainer.find('.highlight').css('background-color', colors[0]);
        $MagnifyContainer.find('.highlight').first().css('background-color', colors[0]);
        //$BothContainers.find('.highlight').css('background-color', colors[0]);
        $MagnifyContainer.css('background-color', colors[1]);
        $MagnifyContainer.find('.sentence').css('background-color', backgroundColor);
    };

    $PreviewButton.click(function () {
        $PreviewDialog.dialog({
            modal: true,
            height: 'auto',
            width: 'auto',
            resizable: false,
            title: Localization.GetResource('UserAccount_PreviewTheme'),
            buttons: [{
                text: Localization.GetResource('DocumentEdit_Close'),
                click: function () {
                    $PreviewDialog.dialog('close');
                }
            }]
        });

        AdjustPreviewSetting();
    })


    $(document.body).click(function (event) {
        if ($(event.target).parents('.currentTheme').length == 0 && !$ThemeStateIcon.IsCollapsed()) {
            $ThemeStateIcon.ToggleState();
        }
    });

    SelectTheme();

    $("#btnCreateTheme").click(function () {
        $('.dlg').remove();
        //$("#dialogs").append($("<div>").attr("class", "dlg center_div"));
        $("#dialogs").append($("<div>").attr("class", "dlg"));
        $(".dlg").html(
            "<div class='centerDiv'><div class='fleft'>" + Localization.GetResource('UserAccount_FontColor') + "</div> <div class='fright'>" + CreateColorPickerField('fColor') + "</div> <div class='clear'></div></div>" +
            "<div class='centerDiv'><div class='fleft'>" + Localization.GetResource('UserAccount_BackgroundColor') + "</div> <div class='fright'>" + CreateColorPickerField('bgColor') + "</div> <div class='clear'></div></div>" +
            "<div class='centerDiv'><div class='fleft'>" + Localization.GetResource('UserAccount_HighlightColor') + "</div> <div class='fright'>" + CreateColorPickerField('hColor') + "</div> <div class='clear'></div></div>" +
            "<div class='centerDiv'><div class='fleft'>" + Localization.GetResource('UserAccount_MagnifyColor') + "</div> <div class='fright'>" + CreateColorPickerField('mColor') + "</div> <div class='clear'></div></div>" +
            "<div class='example_theme center_div centerDiv'><div class='theme-outer-box'><div class='color'></div></div><div class='fright example'>" + Localization.GetResource('UserAccount_ExampleTemplate') + "</div><div class='clear'></div></div>" +
            "<div class='center' style='margin-top: 20px;'><button type='button' id='btnCreate' class='c_button hoverfix'>" + Localization.GetResource('UserAccount_Create') + "</button>"
            );
        $(".c_button").button();

        $('#fColor').val("#FF0000");
        $('#bgColor').val("#FFF000");
        $('#hColor').val("#0000FF");
        $('#mColor').val("#00FF00");

        var cpOptions = ColorPickerDefaultOptions;
        cpOptions.change = function (color) {
            var id = $(this).attr('id');
            var colorString = color.toHexString();
            if (id == 'bgColor') {
                $('.dlg .color').css('border-right-color', colorString);
                $('.dlg .color').css('border-bottom-color', colorString);
                $('.dlg .example').css('background-color', colorString);
            }
            else if (id == 'fColor') {
                $('.dlg .color').css('border-left-color', colorString);
                $('.dlg .color').css('border-top-color', colorString);
                $('.dlg .example').css('color', colorString);
            }
        }

        //$('#bgColor, #hColor, #fColor, #mColor').spectrum(cpOptions);
        $('#fColor').spectrum(cpOptions);
        $('#bgColor').spectrum(cpOptions);
        $('#hColor').spectrum(cpOptions);
        $('#mColor').spectrum(cpOptions);


        $("#btnCreate").click(function () {
            var userId = GetUrlParams('nUserID');
            if (userId == undefined) {
                $('.dlg').dialog("close");
            }

            var jsonData = {
                bgColor: $('#bgColor').val(),
                fColor: $('#fColor').val(),
                hColor: $('#hColor').val(),
                mColor: $('#mColor').val(),
                userId: userId
            }


            $.ajax({
                type: "POST",
                url: "/Account/CreateTheme",
                data: JSON.stringify(jsonData),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    if (eval(data) != 0) {
                        //AddTheme($('#bgColor').val(), $('#fColor').val(), eval(data));
                        AddTheme(jsonData.bgColor, jsonData.fColor, jsonData.hColor, jsonData.mColor, parseInt(data));
                    }
                }
            });
            $('.dlg').dialog("close");
        });
        $('#fColor').val("#FF0000");
        $('#bgColor').val("#FFF000");
        $('#hColor').val("#0000FF");
        $('#mColor').val("#00FF00");

        $('.dlg').dialog({
            title: Localization.GetResource('UserAccount_CreateTheme'),
            modal: true,
            open: function () {
                var $themeSample = $('.dlg .color');
                $themeSample.css('border-right-color', $('#bgColor').val());
                $themeSample.css('border-bottom-color', $('#bgColor').val());

                $themeSample.css('border-left-color', $('#fColor').val());
                $themeSample.css('border-top-color', $('#fColor').val());
            }
        });

        $(".c_button").blur();
    });

    function AddTheme(bgColor, fColor, hColor, mColor, themeId) {
        var newThemeHtml =
            "<li data-id='{0}'>" +
                "<div>" +
                    "<div class='theme-outer-box' >" +
                        "<div class='color'" +
                            "style='border-left-color: {1}; border-top-color: {1}; border-right-color: {2}; border-bottom-color: {2};'>" +
                        "</div>" +
                    "</div>" +
                    "<div class='theme_name' data-colors='[\"{3}\", \"{4}\"]' style='background-color: {2}; color: {1};'>" + Localization.GetResource('UserAccount_ExampleTemplate') + "</div>" +
                "</div>" +
                "<div class='clear'></div>" +
            "</li>";
        newThemeHtml = $.validator.format(newThemeHtml, themeId, fColor, bgColor, hColor, mColor);
        var newHtml = $("#selected_theme").html() + newThemeHtml;
        $("#selected_theme").html(newHtml);
    }
    function CreateColorPickerField(fieldId) {
        var fieldHtml = '<input id="' + fieldId + '" name="' + fieldId + '" type="text" />';
        return fieldHtml;
    }

    $('#lbLineSpacing').chosen({ disable_search: true });
    $('#lbTextFont').chosen({ disable_search: true });
    $('#lbFontSize').chosen({ disable_search: true });

    setChosenTextFont($('#lbTextFont').chosen().val());
    setChosenFontSize($('#lbFontSize').chosen().val());

    $("#lbFontSize").chosen().change(function (obj, selected) {
        var newVal = eval(selected.selected);
        setChosenFontSize(newVal);
        $("#hiddenDocumentFontSize").val(newVal);
    });
    //$("#lbLineSpacing").chosen().change(function (obj, selected) {
    //    var newVal = eval(selected.selected);
    //    $("#hiddenDocumentLineSpacing").val(selected.selected);
    //});
    $("#lbTextFont").chosen().change(function (obj, selected) {
        var newVal = selected.selected;
        setChosenTextFont(newVal);
        $("#hiddenDocumentFontName").val(newVal);
    });

    function setChosenFontSize(selectedValue) {
        if (selectedValue == 0) {
            selectedValue = 18;
        }
        $('#lbFontSize_chzn span').css('font-size', selectedValue + 'px');
    }

    function setChosenTextFont(selectedValue) {
        $('#lbTextFont_chzn span').css('font-family', selectedValue);
    }

    //Creates new label
    $('#btnCreateLabel').click(function () {
        $('.dlg').remove();
        var html =
            '<div class="dlg create-label-dialog hide" data-bind="with: $root.NewLabel">' +
                '<span>' + Localization.GetResource('UserAccount_LabelName') + '</span>' +
                '<input type="text" id="create-label-input" placeholder="' + $('#hfLabelPlaceholder').val() + '"/>' +
                '<br />' +
                '<span style="float: left; margin-right: 10px;">' + Localization.GetResource('UserAccount_PickLabelColor') + '</span><div style="width: 100px; float: left;">' + CreateColorPickerField('labelColor') + '<div class="clear"></div></div>' +
                '<br />' +
                '<span style="float: left; margin-right: 10px;">' + Localization.GetResource('UserAccount_PickLabelFontColor') + '</span><div style="width: 100px; float: left;">' + CreateColorPickerField('labelFontColor') + '<div class="clear"></div></div>' +
                '<br />' +
                '<span class="error-noname">' + Localization.GetResource('UserAccount_LabelNoName') + '</span>' +
            '</div>';
        $("#dialogs").append(html);

        var cpOptions = ColorPickerDefaultOptions;
        cpOptions.color = '#808080';

        //$('#labelColor').colorPicker();
        ////set default color
        //$('#labelColor').val("#808080");
        //$("#labelColor").change();
        $('#labelColor').val('#808080');
        $('#labelColor').spectrum(cpOptions);

        cpOptions.color = "#FFFFFF";
        $('#labelFontColor').val("#FFFFFF");
        $('#labelFontColor').spectrum(cpOptions);

        //$('#labelFontColor').colorPicker();
        //$('#labelFontColor').val("#FFFFFF");
        //$('#labelFontColor').change();

       // $('#create-label-input').val('New Label');

        $('.create-label-dialog').dialog({
            buttons: [{
                text: Localization.GetResource('Library_Save'),
                click: function () {
                    if ($.trim($('#create-label-input').val()) != '') {
                        SaveNewLabel();
                        $(this).dialog('close');
                    }
                    else {
                        $('.error-noname').show();
                    }
                }
            },
            {
                text: Localization.GetResource('Library_Cancel'),
                click: function () {
                    $(this).dialog('close');
                }
            }],
            open : function () { 
                Placeholders.enable(document.getElementById("create-label-input"));
                $('#create-label-input').blur();
            },
            title: Localization.GetResource('UserAccount_CreateLabel')
        });
    });

    function SaveNewLabel() {
        var LabelName = $('#create-label-input').val();
        var LabelColor = $("#labelColor").val();
        var LabelFontColor = $("#labelFontColor").val();

        $.ajax({
            type: "POST",
            url: "/Documents/CreateLabel",
            data: '{ strLabelName:"' + LabelName + '", strColorName:"' + LabelColor + '", strFontColorName:"' + LabelFontColor + '" }',
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (data) {
                if (data.Id != '') {
                    AddLabelToList(eval(data.Id), LabelColor, LabelFontColor,LabelName);
                }
            }
        });
    }

    function UpdateLabel(id) {
        var LabelName = $('#create-label-input').val();
        var LabelColor = $("#labelColor").val();
        var LabelFontColor = $("#labelFontColor").val();

        $.ajax({
            type: "POST",
            url: "/Documents/UpdateLabel",
            data: '{ strLabelName:"' + LabelName + '", strColorName:"' + LabelColor + '",strFontColorName:"' + LabelFontColor + '", nId: ' + id + ' }',
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (data) {
                if (data.success == true) {
                    UpdateLabelListItem(id, LabelName, LabelColor, LabelFontColor);
                }
            }
        });
    }

    function UpdateLabelListItem(id, labelName, labelColor, labelFontColor) {
        $('div[data-label-edit=' + id + ']').closest('li').find('.label_name').text(labelName);
        $('div[data-label-edit=' + id + ']').closest('li').find('.label_name').css('background-color', labelColor);
        $('div[data-label-edit=' + id + ']').closest('li').find('.label_name').css('color', labelFontColor);
    }

    function AddLabelToList(id, color, font_color, name) {
        var item = $.validator.format(
            "<li data-label-id='{0}'>" +
                "<div>" +
                    "<div class='label_name' style='color: {3}; background-color: {1};'>{2}</div>" +
                    "<div class='fright'>" +
                        "<div data-label-edit='{0}' class='c_button hoverfix'>" + Localization.GetResource('UserAccount_Edit') + "</div> " +
                        "<div data-label-delete='{0}' class='c_button hoverfix'>" + Localization.GetResource('UserAccount_Delete') + "</div>" +
                    "</div>" +
                "</div>" +
                "<div class='clear'></div>" +
            "</li>", id, color, name, font_color);
        $('#labels').append(item);

        var selector = $.validator.format("div[data-label-edit={0}], div[data-label-delete={0}]", id);
        $(selector).button();
    }

    //delete and edit labels
    $(document).on('click', 'div[data-label-delete]', function () {
        var result = confirm(Localization.GetResource('UserAccount_ConfirmDeleteLabel'));
        if (result == true) {
            var self = $(this);
            var id = eval(self.attr('data-label-delete'));

            $.ajax({
                type: "POST",
                url: "/Documents/DeleteLabel",
                data: '{ nLabelID: ' + id + ' }',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    if (data.Result == true) {
                        self.closest('li').remove();
                    }
                }
            });
        }
    });

    $(document).on('click', 'div[data-label-edit]', function () {
        var self = $(this);
        var id = eval(self.attr('data-label-edit'));

        $('.dlg').remove();
        var html =
            '<div class="dlg create-label-dialog hide" data-bind="with: $root.NewLabel">' +
                '<span>' + Localization.GetResource('UserAccount_LabelName') + '</span>' +
                '<input type="text" id="create-label-input" value="' + Localization.GetResource('UserAccount_NewLabel') + '"/>' +
                '<br />' +
                '<span style="float: left; margin-right: 10px;">' + Localization.GetResource('UserAccount_PickLabelColor') + '</span><div style="width: 100px; float: left;">' + CreateColorPickerField('labelColor') + '<div class="clear"></div></div>' +
                '<br />' +
                '<span style="float: left; margin-right: 10px;">' + Localization.GetResource('UserAccount_PickLabelFontColor') + '</span><div style="width: 100px; float: left;">' + CreateColorPickerField('labelFontColor') + '<div class="clear"></div></div>' +
                '<br />' +
                '<span class="error-noname">' + Localization.GetResource('UserAccount_LabelNoName') + '</span>' +
            '</div>';
        $("#dialogs").append(html);

        var backgroundColor = rgb2hex(self.closest('li').find('.label_name').css('background-color')); //rgb2hex(
        var labelFontColor = rgb2hex(self.closest('li').find('.label_name').css('color'));

        var cpOptions = ColorPickerDefaultOptions;

        cpOptions.color = backgroundColor;
        $('#labelColor').val(backgroundColor);
        $('#labelColor').spectrum(cpOptions);
        
        cpOptions = ColorPickerDefaultOptions;
        cpOptions.color = labelFontColor;
        $('#labelFontColor').val(labelFontColor);
        $('#labelFontColor').spectrum(cpOptions);

        $('#create-label-input').val(self.closest('li').find('.label_name').text());

        $('.create-label-dialog').dialog({
            title: Localization.GetResource('UserAccount_EditLabel'),
            buttons: [{
                text: Localization.GetResource('Library_Save'),
                click: function () {
                    if ($.trim($('#create-label-input').val()) != '') {
                        UpdateLabel(id);
                        $(this).dialog('close');
                    }
                    else {
                        $('.error-noname').show();
                    }
                }
            },
            {
                text: Localization.GetResource('Library_Cancel'),
                click: function () {
                    $(this).dialog('close');
                }
            }]
        });
    });

    //$('#fileupProfilePicture').uploadifive({
    //    height: 36,
    //    formData: { 'account_id': GetUrlParams('nUserID') },
    //    //swf: '/scripts/uploadify/uploadify.swf',
    //    'uploadScript' : '/Account/UploadImage',
    //    //uploader: '/Account/UploadImage',
    //    removeCompleted: false,
    //    width: 106,
    //    buttonClass: 'signUpUploadPic',
    //    buttonText: Localization.GetResource('Browse_Dots'),
    //    uploadLimit: 1,
    //    onInit: function (instance) {
    //        //dialog = $("#fileUploadDialog");
    //        //dialog.dialog({
    //        //    //modal: true,
    //        //    zIndex: 999999,
    //        //    width: 450,
    //        //    height: 250,
    //        //    minHeigth: 400,
    //        //    close: function (event, ui) {
    //        //        $("#file_upload").uploadify('destroy');
    //        //        dialog.dialog('destroy');
    //        //    }
    //        //});
    //    },
    //    onUploadSuccess: function (file, data, response) {
    //        //var fileId = $.parseJSON(data.toString()).fileId;
    //        //$('#AcademicImages_' + $(self).data('inputid')).val("/FileManager/GetFile?id=" + fileId);
    //        //dialog.dialog('close');
    //    }
    //});

    //$('#fileupProfilePicture').change(function (event) {
    //    var input = this;

    //    if (input.files && input.files[0]) {
    //        var reader = new FileReader();

    //        reader.onload = function (e) {
    //            $('#imgSignUpProfilePic').attr('src', e.target.result);
    //        }

    //        reader.readAsDataURL(input.files[0]);
    //    } else {
    //        //FILTER: progid:DXImageTransform.Microsoft.AlphaImageLoader(sizingMethod=scale);

    //        var newPreview = document.getElementById("imgSignUpProfilePic");
    //        newPreview.filters.item("DXImageTransform.Microsoft.AlphaImageLoader").src = input.value;
    //    }
    //});

    setUpImagePreview('fileupProfilePicture', 'imgSignUpProfilePic', 'imgSignUpProfilePicIE');

});