(function($) {
  $.extend($.fn.selectpicker.Constructor.Defaults, { counter: false });

  var render = $.fn.selectpicker.Constructor.prototype.render;

  $.fn.selectpicker.Constructor.prototype.render = function() {
    if (this.options.counter && this.$button.find('.bootstrap-select-badge').length === 0) {
      var badgeContext  = this.$button.hasClass('btn-light') ? 'badge-secondary' : 'badge-light';
      var count         = this.$element.find("option:not([value=''])").length
      this.$button.find('.filter-option-inner').append(`<span class='badge badge-pill ${badgeContext} ml-1'>${count}</span>`)
    }

    render.apply(this);
  };

})(jQuery);
