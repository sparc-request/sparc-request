# Add goTo method for jquery objects.
# Writing: $('.selector').goTo() will scroll page
# so that element is at the top of the page and visible
$(document).ready ->
  $.fn.goTo = () ->
    $('html, body').animate({ scrollTop: $(this).offset().top + 'px' }, 'fast')
    this
