#= require navigation

$(document).ready ->
  $(".document_delete").button()
  $(".document_edit").button()
  $(".document_upload_button").button()

  $(".document_upload_button").click ->
    $(".hidden_document_ssrs").attr('disabled', 'disabled')
    $(".document_upload_button").hide()
    $(".document_upload").show()

  $(".document_edit").click ->
    $(".hidden_document_ssrs").removeAttr('disabled')
    $(".document_upload_button").hide()
    $(".document_upload").show()
