$(document).ready ->
  $('.navigation_link').live 'click', ->
    if $(this).parent('div.exit').size() >= 1
      $('#processing_request').show()
    location = $(this).attr('location')
    validates = $(this).attr('validates')
    $('#location').val(location)
    $('#validates').val(validates)
    $('#navigation_form').submit()
