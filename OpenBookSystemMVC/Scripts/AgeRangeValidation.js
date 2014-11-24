// Pattern used as seen in Darin Dimitrov's example : http://stackoverflow.com/questions/10985878/jquery-validation-add-custom-method-to-validate-on-submit
/// <reference path="~/Scripts/jquery-1.8.2.js" />
(function ($) {
    $.validator.unobtrusive.adapters.add('agevalid', ['validfromage', 'validtoage'], function (options) {
        options.rules['agevalid'] = options.params;
        if (options.message) {
            options.messages['agevalid'] = options.message;
        }
    });

    $.validator.addMethod('agevalid', function (value, element, params) {
        var result = false;
        var nFromAge = parseInt(params.validfromage);
        var nToAge = parseInt(params.validtoage);
        var $element = $(element);
        var value = $element.val().toString();
        value.trim();

        if (value.length == 0) {
            result = true;
        }
        else if ((nFromAge <= value) && (value <= nToAge)) {
            result = true;
        }

        return result;
    }, '');
})(jQuery);