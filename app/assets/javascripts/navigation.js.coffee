$(document).ready ->
  $('.navigation_link').live 'click', ->
    location = $(this).attr('location')
    validates = $(this).attr('validates')
    $('#location').val(location)
    $('#validates').val(validates)
    $('#navigation_form').submit()
