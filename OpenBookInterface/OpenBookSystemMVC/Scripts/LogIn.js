$(document).ready(function () {
    $('#btnSignUpPatient').click(function () {
        //window.location = 'SignUp/1';
    });

    $('.signCarersA').click(function () {
        //window.location = 'SignUp/2';
    });
    $('form').unbind('submit');
    $('form').submit(function () {
        var isValid = true;
        if ($.trim($('#UserName').val()) == '') {
            $('[data-valmsg-for="UserName"]').html('*');
            isValid = false;
        }
        else {
            $('[data-valmsg-for="UserName"]').html('');
        }
        if ($.trim($('#Password').val()) == '') {
            $('[data-valmsg-for="Password"]').html('*');
            isValid = false;
        }
        else {
            $('[data-valmsg-for="Password"]').html('');
        }

        return isValid;
    });
});