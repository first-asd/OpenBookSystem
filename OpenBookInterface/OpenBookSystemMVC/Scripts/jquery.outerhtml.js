/*! Copyright (c) 2006 Brandon Aaron (brandon.aaron@gmail.com || http://brandonaaron.net)
 * Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php) 
 * and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
 */

(function($){
  var div;
  
  $.fn.outerHTML = function() {
      var elem = this[0],
        tmp, result = '';
    
    for (var i = 0; i < this.length; i++) {
        result += !this[i] ? '' : typeof (tmp = this[i].outerHTML) === 'string' ? tmp
      : (div = div || $('<div/>')).html(this.eq(i).clone()).html();
    }

    return result;

    //return !elem ? null
    //  : typeof ( tmp = elem.outerHTML ) === 'string' ? tmp
    //  : ( div = div || $('<div/>') ).html( this.eq(0).clone() ).html();
  };
  
})(jQuery);