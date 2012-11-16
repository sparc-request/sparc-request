$(document).ready ->
  $(".upload_button").button()
  $(".ui_close_button").button()

  $(".upload_button").click ->
    $(".upload_button").attr("disabled", "disabled");
    $(".upload_button span").html('Wait...');

  $(".ui_close_button").click ->
    $("input#document_grouping_id").remove()
    $("table#new_document #file").replaceWith('<td id="file"><input id="document" type="file" name="document" disabled="disabled"></td>')
    $("table#new_document select#doc_type").val(0)
    $('input#process_ssr_organization_ids_').attr('checked', false);
    $(".upload_button").removeAttr("disabled")
    $(".upload_button span").html('Upload')
    $(".document_upload").hide()
    $(".document_upload_button").show()
