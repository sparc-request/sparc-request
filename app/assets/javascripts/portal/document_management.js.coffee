$(document).ready ->
  $(".document_upload_button").button()

  $(".document_upload_button").click ->
    $(".document_upload_button").hide()
    $(".document_upload").show()

  $(".document_edit").click ->
    $(".document_upload_button").hide()
    $('#new_document').replaceWith("<div id='new_document'>Loading...</div>")
    $(".document_upload").show()