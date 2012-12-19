$(document).ready ->
  $(".upload_button").button()
  $(".ui_close_button").button()

  $(".upload_button").click ->
    $(".upload_button").attr("disabled", "disabled");
    $(".upload_button span").html('Wait...');
    $('#new_document_form').submit()

  $(".ui_close_button").click ->
    $("input#document_grouping_id").remove()
    $("table#new_document #file").replaceWith('<td id="file"><input id="document" type="file" name="document"></td>')
    $("table#new_document select#doc_type").val(0)
    $("table#new_document .upload_button span.ui-button-text").text("Upload")
    $(".document_upload").hide()
    $(".document_upload_button").show()
