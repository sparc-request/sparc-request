//With the Rails asset pipeline or other asset packagers, you usually include
//the JS for your entire application in one bundle, while individual scripts
//should be run only on certain pages.
//
//jquery.readyselector extends .ready() to provide a nice syntax for
//page-specific script

//https://github.com/Verba/jquery-readyselector

(function ($) {
  var ready = $.fn.ready;
  $.fn.ready = function (fn) {
    if (this.context === undefined) {
      // The $().ready(fn) case.
      ready(fn);
    } else if (this.selector) {
      ready($.proxy(function(){
        $(this.selector, this.context).each(fn);
      }, this));
    } else {
      ready($.proxy(function(){
        $(this).each(fn);
      }, this));
    }
  }
})(jQuery);
