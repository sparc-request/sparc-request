$(document).ready ->

  $(".upload_button").click ->
    $(".upload_button").attr("disabled", "disabled")
    $(".upload_button span").html('Wait...')

    #TODO code below is duplicated from app/assets/javascripts/navigation.js.coffee because for some reason it doesn't work otherwise
    location = $(this).attr('location')
    validates = $(this).attr('validates')
    $('#location').val(location)
    $('#validates').val(validates)
    $('#navigation_form').submit()

  $(".ui_close_button").click ->
    $("input#document_grouping_id").remove()
    $("table#new_document #file").replaceWith('<td id="file"><input id="document" type="file" name="document" disabled="disabled"></td>')
    $("table#new_document select#doc_type").val(0)
    $('input#process_ssr_organization_ids_').attr('checked', false)
    $(".upload_button").removeAttr("disabled")
    $(".upload_button span").html('Upload')
    $(".document_upload").hide()
    $(".document_upload_button").show()
