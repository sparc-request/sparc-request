$(document).ready ->
  $('#sign_in').dialog
    modal: true
    title: "Please select one of the options below:"
    width: 800
    height: 400
    dialogClass: 'no-close'

  $('.proceed_with_shib').click ->
    $('#sign_in').dialog('close')
