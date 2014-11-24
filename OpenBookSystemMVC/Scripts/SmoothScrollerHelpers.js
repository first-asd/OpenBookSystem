nScrollImageCount = 0;
nScrollStep = 2;

function scrollPrevious() {
    var eShopSlider = $('.SmoothscrollDiv');
    if (isNaN(eShopSlider.data('currentElement'))) {
        eShopSlider.data('currentElement', 1);
    }

    var currentScrollPos = eShopSlider.data('currentElement');

    if (currentScrollPos <= nScrollStep) {
        eShopSlider.smoothDivScroll("scrollToElement", "number", 1);
        eShopSlider.data('currentElement', 1);
    }
    else {
        var itemCount = $('.scrollableArea').children().length;
        var backStep = Math.floor(eShopSlider.width() / 100);
        if ((backStep - itemCount) > 0 ) {
            backStep = nScrollStep;
        }
        if (itemCount == currentScrollPos) {
            eShopSlider.smoothDivScroll("scrollToElement", "number", itemCount - backStep);
            eShopSlider.data('currentElement',itemCount - backStep);
        }
        else {
            eShopSlider.smoothDivScroll("scrollToElement", "number", currentScrollPos - nScrollStep);
            eShopSlider.data('currentElement', currentScrollPos - nScrollStep);
        }        
    }
}

function scrollNext() {
    var eShopSlider = $('.SmoothscrollDiv');

    if (isNaN(eShopSlider.data('currentElement'))) {
        eShopSlider.data('currentElement', 1);
    }

    var currentScrollPos = eShopSlider.data('currentElement');

    if ((currentScrollPos + nScrollStep) >= nScrollImageCount) {
        eShopSlider.smoothDivScroll("scrollToElement", "number", nScrollImageCount);
        eShopSlider.data('currentElement', nScrollImageCount);
    }
    else {
        eShopSlider.smoothDivScroll("scrollToElement", "number", currentScrollPos + nScrollStep);
        eShopSlider.data('currentElement', currentScrollPos + nScrollStep);
    }
}

$(document).ready(function () {
    var eShopSlider = $(".SmoothscrollDiv");
    eShopSlider.smoothDivScroll({ hotSpotScrolling: false });
    nScrollImageCount = $('.scrollableArea img').length;
    $('.scrollingHotSpotLeft').remove();
    $('.scrollingHotSpotRight').remove();
    $('[data-delete="1"]').removeAttr("href");
    $('.scrollableArea img').first().click();

});

function SelectImage(img) {
    $('.docImg').attr('src', '/Images/docIcon.png');
    img.attr('src', '/Images/docSlctdIcon.png');

    if ($('#txtNoDocSelected').css('display') == 'block') {
        $('#txtNoDocSelected').css('display', 'none');
    }

    $('#btnPrint').attr('href', '/Documents/Print?nDocID=' + img.data('documentid'));
    $('#btnPrint').attr('target','_blank');
}

function CheckPatSelected() {
    var result = true;
    if ($('.patSelImg').length == 0) {
        $('#txtNoDocSelected').css('display', 'inline');
        result = false;
    }
    return result;
}


function EditPatient() {
    window.location = '/Account/Edit?nUserID=' + $('.patSelImg').data('userid');
}

function AddPatient() {
    window.location = '/Account/Create';
}

function EditDocument() {
    window.location = '/Documents/Edit?nDocID=' + $('img[src="/Images/docSlctdIcon.png"]').data('documentid');
}

function AddDocument() {
    window.location = '/Documents/New';
}

function SelectPatient(img) {
    $('.patSelImg').removeClass('patSelImg');
    img.addClass('patSelImg');

    if ($('#txtNoDocSelected').css('display') == 'block') {
        $('#txtNoDocSelected').css('display', 'none');
    }

}

function CheckSelected() {
    var result = true;
    if ($('img[src="/Images/docSlctdIcon.png"]').length == 0) {
        $('#txtNoDocSelected').css('display', 'inline');
        result = false;
    }
    return result;
}

function DeleteDocument() {
    if (confirm("Confirm deletion of the selected document!")) {
        var logdata = $('[src="/Images/docSlctdIcon.png"]').data('documentid');
        $.ajaxSetup({ async: false });
        $.ajax({
            type: "POST",
            url: "/Documents/DeleteDocument",
            data: JSON.stringify({ nDocID: logdata }) ,
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (data) {
                if (data) {
                    var error = '<li>' + data + '</li>';
                    $('#documents-error-summary ul').append($(error));
                    $('#documents-error-summary').css('display', 'block');
                } else {
                    $('[src="/Images/docSlctdIcon.png"]').parent().remove();
                    nScrollImageCount = $('.scrollableArea img').length;
                    $(".SmoothscrollDiv").smoothDivScroll("recalculateScrollableArea");
                }
            }
        });
    }
}

function DeletePatient() {
    if (confirm("Confirm deletion of the selected patient!")) {
        var logdata = $('.patSelImg').data('userid');
        $.ajaxSetup({ async: false });
        $.ajax({
            type: "POST",
            url: "/Patients/Delete",
            data: JSON.stringify({ PatientID: logdata }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (data) {
                if (data) {
                    var error = '<li>' + data + '</li>';
                    $('#patients-error-summary ul').append($(error));
                    $('#patients-error-summary').css('display', 'block');
                } else {
                    $('.patSelImg').parent().remove();
                    nScrollImageCount = $('.scrollableArea img').length;
                    $(".SmoothscrollDiv").smoothDivScroll("recalculateScrollableArea");
                }
            }
        });
    }
}
