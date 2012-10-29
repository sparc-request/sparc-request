$(document).ready ->
  $(".upload_button").button()
  $(".ui_close_button").button()

  $(".upload_button").click ->
    $(".upload_button").attr("disabled", "disabled");
    $(".upload_button span").html('Please Wait...');

  $(".ui_close_button").click ->
    $(".document_upload").hide() 
    $(".document_upload_button").show()
