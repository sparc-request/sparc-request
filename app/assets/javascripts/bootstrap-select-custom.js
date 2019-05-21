(function($) {
  $.extend($.fn.selectpicker.Constructor.Defaults, { counter: false });

  var render = $.fn.selectpicker.Constructor.prototype.render;

  $.fn.selectpicker.Constructor.prototype.render = function() {
    if (this.options.counter && this.$button.find('.bootstrap-select-badge').length === 0) {
      this.$button.find('.filter-option-inner').append("<span class='badge bootstrap-select-badge'>" + this.$element.find("option:not([value=''])").length + "</span>")
    }

    render.apply(this);
  };

})(jQuery);
