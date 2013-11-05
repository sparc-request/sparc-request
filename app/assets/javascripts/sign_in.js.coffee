$(document).ready ->
  $('#sign_in').dialog
    modal: true
    title: "Please select one of the options below:"
    width: 800
    height: 400
    dialogClass: 'no-close'

  $('.proceed_with_shib').click ->
    $('#sign_in').dialog('close')

  $('.create_new_account').click ->
    $('#signup_form').dialog('open')

  $('#signup_form').dialog
    autoOpen: false
    modal: true
    width: 700
    dialogClass: 'signup_form'

