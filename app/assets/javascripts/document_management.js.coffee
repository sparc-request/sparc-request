#= require navigation

$(document).ready ->
  $(".document_delete").button()
  $(".document_edit").button()
  $(".document_upload_button").button()

  $(".document_upload_button").click ->
    $("#process_ssr_organization_ids").removeAttr('disabled')
    $("#document").removeAttr('disabled')
    $(".document_upload_button").hide()
    $(".document_upload").show()

  $(".document_edit").click ->
    $("#process_ssr_organization_ids").removeAttr('disabled')
    $("#document").removeAttr('disabled')
    $(".document_upload_button").hide()
    $('.document_edit span').html('Loading...')

  $("#cancel_upload").live 'click', ->
    $("#process_ssr_organization_ids").attr('disabled', 'disabled')
    $("#document").attr('disabled', 'disabled')

