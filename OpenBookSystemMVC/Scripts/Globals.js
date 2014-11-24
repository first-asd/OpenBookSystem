if (typeof String.prototype.trim !== 'function') {
    String.prototype.trim = function () {
        return this.replace(/^\s\s*/, '').replace(/\s\s*$/, ''); // gotta love IE8
    }
}


if (typeof Array.prototype.indexOf !== 'function') {
    Array.prototype.indexOf = function (obj, start) {
        for (var i = (start || 0), j = this.length; i < j; i++) {
            if (this[i] === obj) { return i; }
        }
        return -1;
    }
}

var docCookies = {
    getItem: function (sKey) {
        return decodeURIComponent(document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + encodeURIComponent(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1")) || null;
    },
    setItem: function (sKey, sValue, vEnd, sPath, sDomain, bSecure) {
        if (!sKey || /^(?:expires|max\-age|path|domain|secure)$/i.test(sKey)) { return false; }
        var sExpires = "";
        if (vEnd) {
            switch (vEnd.constructor) {
                case Number:
                    sExpires = vEnd === Infinity ? "; expires=Fri, 31 Dec 9999 23:59:59 GMT" : "; max-age=" + vEnd;
                    break;
                case String:
                    sExpires = "; expires=" + vEnd;
                    break;
                case Date:
                    sExpires = "; expires=" + vEnd.toUTCString();
                    break;
            }
        }
        document.cookie = encodeURIComponent(sKey) + "=" + encodeURIComponent(sValue) + sExpires + (sDomain ? "; domain=" + sDomain : "") + (sPath ? "; path=" + sPath : "") + (bSecure ? "; secure" : "");
        return true;
    },
    removeItem: function (sKey, sPath, sDomain) {
        if (!sKey || !this.hasItem(sKey)) { return false; }
        document.cookie = encodeURIComponent(sKey) + "=; expires=Thu, 01 Jan 1970 00:00:00 GMT" + (sDomain ? "; domain=" + sDomain : "") + (sPath ? "; path=" + sPath : "");
        return true;
    },
    hasItem: function (sKey) {
        return (new RegExp("(?:^|;\\s*)" + encodeURIComponent(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=")).test(document.cookie);
    },
    keys: /* optional method: you can safely remove it! */ function () {
        var aKeys = document.cookie.replace(/((?:^|\s*;)[^\=]+)(?=;|$)|^\s*|\s*(?:\=[^;]*)?(?:\1|$)/g, "").split(/\s*(?:\=[^;]*)?;\s*/);
        for (var nIdx = 0; nIdx < aKeys.length; nIdx++) { aKeys[nIdx] = decodeURIComponent(aKeys[nIdx]); }
        return aKeys;
    }
};

function setUpImagePreview(fileInputId, previewImageId, previewImageIdIE) {
    var $imgPreview = $('#' + previewImageId);
    var $imgPreviewIE = $('#' + previewImageIdIE).css('display', 'none');

    $('#' + fileInputId).change(function (event) {
        var input = this;

        if (input.files && input.files[0]) {
            var reader = new FileReader();

            reader.onload = function (e) {
                $('#' + previewImageId).attr('src', e.target.result);
            }

            reader.readAsDataURL(input.files[0]);
        } else {
            ////FILTER: progid:DXImageTransform.Microsoft.AlphaImageLoader(sizingMethod=scale);
            $imgPreview.css('display', 'none');
            $imgPreviewIE.css({
                'filter': 'progid:DXImageTransform.Microsoft.AlphaImageLoader(sizingMethod=scale)',
                '-ms-filter': 'progid:DXImageTransform.Microsoft.AlphaImageLoader(sizingMethod=scale)'
            });
            $imgPreviewIE.css('display', 'block');

            $imgPreviewIE[0].filters.item("DXImageTransform.Microsoft.AlphaImageLoader").src = input.value;
        }
    });
}

function BrowserCheck() {
    function isNumber(o) {
        return ! isNaN(o - 0);
    }

    var BrowserObject = $.browser;
    var version = BrowserObject.version;
    var current_version = 0;

    if (BrowserObject.chrome) {
        current_version = parseInt(version.slice(0, 2));
        if (!isNumber(current_version)) {
            window.location = '/Error/BrowserNotSupported';
        }
        else if (current_version < 20) {
            window.location = '/Error/BrowserNotSupported';
        }
    } else if (BrowserObject.msie) {
        if (version.length > 3) {
            current_version = parseInt(version.slice(0, 2));
        } else {
            current_version = parseInt(version.slice(0, 1));
        }
        if (!isNumber(current_version)) {
            window.location = '/Error/BrowserNotSupported';
        }
        else if (current_version < 8) {
            window.location = '/Error/BrowserNotSupported';
        }
    } else if (BrowserObject.mozilla) {
        if (version.length > 3) {
            current_version = parseInt(version.slice(0, 2));
        } else {
            current_version = parseInt(version.slice(0, 1));
        }
        if (!isNumber(current_version)) {
            window.location = '/Error/BrowserNotSupported';
        }
        else if (current_version < 10) {
            window.location = '/Error/BrowserNotSupported';
        }
    }
}

BrowserCheck();

$(document).ready(function () {

    if (IsIE8() || $.browser.mozilla) {
        var selects = $('select');
        if (selects.length > 0) {
            selects.css('padding-left', '5px');
            selects.css('padding-top', '5px');
            selects.css('padding-bottom', '5px');
        }
    }

    if (IsIE8()) {
        var FixInputsForIE8 = function (elem) {
            elem.css('line-height', '30px');
            elem.val(elem.val());
        }

        $('input[type="text"]').each(function () { FixInputsForIE8($(this)); });
        $('input[type="password"]').each(function () { FixInputsForIE8($(this)); });
    }

});

function IsIE8() {
    var result = false;
    if ($.browser.msie) {
        var current_version;
        var version = $.browser.version;
        if ($.browser.version.length > 3) {
            current_version = parseInt(version.slice(0, 2));
        } else {
            current_version = parseInt(version.slice(0, 1));
        }

        if (current_version == 8) {
            result = true;
        }
    }

    return result;
}

$(document).ajaxError(function (e, xhr, settings, exception) {
    if (xhr.status == 401) {
        window.location = "/Home";
    }
});

if (typeof String.prototype.trim !== 'function') {
    String.prototype.trim = function () {
        return this.replace(/^\s+|\s+$/g, '');
    }
}

//Localization.GetResource
(function () {
    // Init global localization object
    if (typeof window.Localization == 'undefined') {
        window.Localization = {};
    }

    // The method that retrievs the resource value
    window.Localization.GetResource = function (res_key) {
        var result = 'No resource found';

        // Check if the associate culture exists and load it's value
        if (typeof window.Localization.resourcesBG != 'undefined') {
            result = window.Localization.resourcesBG[res_key];
        } else if (typeof window.Localization.resourcesEN != 'undefined') {
            result = window.Localization.resourcesEN[res_key];
        } else if (typeof window.Localization.resourcesES != 'undefined') {
            result = window.Localization.resourcesES[res_key];
        }

        if (typeof result == 'undefined') {
            result = '';
        }

        return result;
    }

})();

ColorPickerDefaultOptions = {
    showPalette: true,
    //palette: [
    //    ['000000', '993300', '333300', '4D4D4D', '333399', '333333', '800000', 'FF6600', '808000', '008000'],
    //    ['008080', '0000FF', '666699', '808080', 'FF0000', 'FF9900', '99CC00', '339966', '33CCCC', '3366FF'],
    //    ['800080', '999999', 'FF00FF', 'FFCC00', 'FFFF00', '00FF00', '00FFFF', '00CCFF', '993366', 'E6E6E6'],
    //    ['FF99CC', 'FFCC99', 'FFFF99', 'CCFFFF', '99CCFF', 'FFFFFF']
    //],
    palette: [
    ["rgb(0, 0, 0)", "rgb(67, 67, 67)", "rgb(102, 102, 102)", /*"rgb(153, 153, 153)","rgb(183, 183, 183)",*/
    "rgb(204, 204, 204)", "rgb(217, 217, 217)", /*"rgb(239, 239, 239)", "rgb(243, 243, 243)",*/ "rgb(255, 255, 255)"],

    ["rgb(152, 0, 0)", "rgb(255, 0, 0)", "rgb(255, 153, 0)", "rgb(255, 255, 0)", "rgb(0, 255, 0)",
    "rgb(0, 255, 255)", "rgb(74, 134, 232)", "rgb(0, 0, 255)", "rgb(153, 0, 255)", "rgb(255, 0, 255)"],

    ["rgb(230, 184, 175)", "rgb(244, 204, 204)", "rgb(252, 229, 205)", "rgb(255, 242, 204)", "rgb(217, 234, 211)",
    "rgb(208, 224, 227)", "rgb(201, 218, 248)", "rgb(207, 226, 243)", "rgb(217, 210, 233)", "rgb(234, 209, 220)",
    "rgb(221, 126, 107)", "rgb(234, 153, 153)", "rgb(249, 203, 156)", "rgb(255, 229, 153)", "rgb(182, 215, 168)",
    "rgb(162, 196, 201)", "rgb(164, 194, 244)", "rgb(159, 197, 232)", "rgb(180, 167, 214)", "rgb(213, 166, 189)",
    "rgb(204, 65, 37)", "rgb(224, 102, 102)", "rgb(246, 178, 107)", "rgb(255, 217, 102)", "rgb(147, 196, 125)",
    "rgb(118, 165, 175)", "rgb(109, 158, 235)", "rgb(111, 168, 220)", "rgb(142, 124, 195)", "rgb(194, 123, 160)",
    "rgb(166, 28, 0)", "rgb(204, 0, 0)", "rgb(230, 145, 56)", "rgb(241, 194, 50)", "rgb(106, 168, 79)",
    "rgb(69, 129, 142)", "rgb(60, 120, 216)", "rgb(61, 133, 198)", "rgb(103, 78, 167)", "rgb(166, 77, 121)",
    /*"rgb(133, 32, 12)", "rgb(153, 0, 0)", "rgb(180, 95, 6)", "rgb(191, 144, 0)", "rgb(56, 118, 29)",
    "rgb(19, 79, 92)", "rgb(17, 85, 204)", "rgb(11, 83, 148)", "rgb(53, 28, 117)", "rgb(116, 27, 71)",*/
    "rgb(91, 15, 0)", "rgb(102, 0, 0)", "rgb(120, 63, 4)", "rgb(127, 96, 0)", "rgb(39, 78, 19)",
    "rgb(12, 52, 61)", "rgb(28, 69, 135)", "rgb(7, 55, 99)", "rgb(32, 18, 77)", "rgb(76, 17, 48)"]
    ],
    clickoutFiresChange: true,
    showInitial: true,
    showButtons: true,
    preferredFormat: "hex",
    change: function (color) {
        $(this).val(color.toHexString());
    },
    chooseText: Localization.GetResource('EditDocument_Done'),
    cancelText: Localization.GetResource('Library_Cancel')
}


