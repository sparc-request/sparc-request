$(document).ready ->
  $('.navigation_link').live 'click', ->
    location = $(this).attr('location')
    $('#location').val(location)
    $('#navigation_form').submit()
