$(document).ready ->
  $('#signed_up_but_not_approved').dialog
    modal: true
    title: "New account created:"
    width: 800
    height: 150
    dialogClass: 'no-close'

  $('.acknowledge_approval_status').click ->
    $('#signed_up_but_not_approved').dialog('close')
