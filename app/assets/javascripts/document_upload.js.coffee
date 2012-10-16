$(document).ready ->
  $(".upload_button").button()

  $(".upload_button").click ->
    $("#upload_message").dialog
      modal: true
