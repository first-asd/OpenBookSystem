// Pattern used as seen in Darin Dimitrov's example : http://stackoverflow.com/questions/10985878/jquery-validation-add-custom-method-to-validate-on-submit

(function ($) {
    $.validator.unobtrusive.adapters.add('imgonly', ['acceptedtypes'], function (options) {
        options.rules['imgonly'] = options.params;
        if (options.message) {
            options.messages['imgonly'] = options.message;
        }
    });

    $.validator.addMethod('imgonly', function (value, element, params) {
        if ($.browser.msie) {
            return true;
        }
        else {

            var fileTypes = JSON.parse($('<div/>').html(params.acceptedtypes).text());   // HTML Decodes the JSON sent from the server-side
            var $element = $(element);
            var file = $element.closest('form').find(':file[name=' + $element.attr('name') + ']')[0].files[0];

            var extension = '';
            var result = true;

            if (file && file.name) {
                result = false;
                extension = file.name.split('.').pop().toLowerCase();
                if (extension) {
                    extension = '.' + extension;
                    for (var i = 0; i < fileTypes.length; i++) {
                        if (fileTypes[i] == extension) {
                            result = true;
                            break;
                        }
                    }
                }
            }
        }
        return result;
    }, '');
})(jQuery);