$(function () {
    $('.c_button').button();

    $("#btnToTheTest").click(function () {
        var id = $(this).attr('data-document-id');
        window.location = '/Documents/Edit?nDocID=' + id;
    });

    var testData = null;

    //Load questions
    var qa = $('#qiuestionArea');
    var currentQuestion = 0;
    if (qa.length !== 0) {
        $.ajax({
            type: "POST",
            url: "/Test/LoadQuestions",
            data: '{ documentId:"' + 221 + '" }',
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (data) {
                testData = data;
                LoadQuestion(data);
            }
        });
    }

    function LoadQuestion(data) {
        if (data.length > 0) {
            if (data.length > 1) {
                $('#btnNextQuestion').show();
            }
            else {
                $('#btnFinishTheTest').show();
            }
            $('#questionNumber').text($.validator.format('{0} {1}', Localization.GetResource("DocumentTest_Question"), currentQuestion + 1));
            $('#questionContent').html(data[currentQuestion].Content);
            var answerTemplate = '<div class="answer"><input type="radio" id="a_q_{1}" name="{0}" value="{1}" class="fleft" /><div class="fleft answer_content"><label for="a_q_{1}">{2}</label></div><div class="clear"></div></div>';
            var htmlAnswers = '';
            var answers = data[currentQuestion].Answers;
            for (var i = 0; i < answers.length; i++) {
                htmlAnswers += $.validator.format(answerTemplate, data[currentQuestion].Id, answers[i].Id, answers[i].Content);
            }
            $('#questionAnswers').html(htmlAnswers);
        }
        else {
            $('#qiuestionArea').html(Localization.GetResource('Tests_NoQuestions'));
        }
    }

    function GetNextQuestion() {
        if (currentQuestion < testData.length - 1) {
            currentQuestion++;
            LoadQuestion(testData);

            if (currentQuestion == testData.length - 1) {
                $('#btnNextQuestion').hide();
                $('#btnFinishTheTest').show();
            }
        }
    }

    function FinishTheTest() {
        $('.dlg').remove();
        var dialogHtml = $.validator.format("<div class='dlg'>{0}</div>", Localization.GetResource('DocumentTest_FinishText'));
        $('.selDocBody').append(dialogHtml);


        $('#btnFinishTheTest').button('disable');

        //open dialog
        $('.dlg').dialog({
            title: Localization.GetResource('DocumentTest_FinishDialogTitle'),
            buttons: [{
                text: 'OK',
                click: function () {
                    $('.dlg').dialog('close');
                    window.location = '/Documents/List';
                }
            }],
            close: function () {
                $('.dlg').dialog('close');
                window.location = '/Documents/List';
            },
            resizable: false
        });

        $(".ui-button").blur();
    }

    $('#btnNextQuestion').click(function () {
        var currentQuestionId = testData[currentQuestion].Id;
        var answer = $('input[name="' + currentQuestionId + '"]:checked').val();
        if (answer != undefined) {
            $.ajax({
                type: "POST",
                url: "/Test/SubmitTestAnswer",
                data: '{ answerId:' + answer + ' }',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    GetNextQuestion();
                }
            });
        }
        else {
            GetNextQuestion();
        }
    });

    $('#btnFinishTheTest').click(function () {
        var currentQuestionId = testData[currentQuestion].Id;
        var answer = $('input[name="' + currentQuestionId + '"]:checked').val();
        if (answer != undefined) {
            $.ajax({
                type: "POST",
                url: "/Test/SubmitTestAnswer",
                data: '{ answerId:' + answer + ' }',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    FinishTheTest();
                }
            });
        }
        else {
            FinishTheTest();
        }
    });
});