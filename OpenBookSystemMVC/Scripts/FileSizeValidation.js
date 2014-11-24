// Pattern used as seen in Darin Dimitrov's example : http://stackoverflow.com/questions/10985878/jquery-validation-add-custom-method-to-validate-on-submit
/// <reference path="~/Scripts/jquery-1.8.2.js" />
(function ($) {
    $.validator.unobtrusive.adapters.add('maxsize', ['maxsize'], function (options) {
        options.rules['maxsize'] = options.params;
        if (options.message) {
            options.messages['maxsize'] = options.message;
        }
    });

    $.validator.addMethod('maxsize', function (value, element, params) {
        if ($.browser.msie) {
            return true;
        }
        else {
            var maxSize = params.maxsize;
            var $element = $(element);
            var fileInput = $element.closest('form').find(':file[name=' + $element.attr('name') + ']')[0];
            if (fileInput.files) {
                var file = fileInput.files[0];
                var FileSize = 0;

                if (file && file.size) {
                    FileSize = file.size;
                }

                return FileSize < maxSize;
            }
        }

    }, '');
})(jQuery);