#= require navigation

$(document).ready ->
  $(".document_delete").button()
  $(".document_edit").button()
  $(".document_upload_button").button()

  $(".document_upload_button").click ->
    $(".document_upload_button").hide()
    $(".document_upload").show()

  $(".document_edit").click ->
    $(".document_upload_button").hide()
    $(".document_upload").show()