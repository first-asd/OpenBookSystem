/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

$(document).ready(function() {
//    $('#params_conf').submit(function(){
//        validateParamConf();
//    });         
});

function validateParamConf () {
    // Validation
    $("#params_conf").validate({
        rules:{
            path_bn: {
                required: true
            }
        },
        messages:{
            path_bn:{
                required:"Esooiiil"
            }
        }
    });
}
