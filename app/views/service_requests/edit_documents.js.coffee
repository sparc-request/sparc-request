$('#new_document').replaceWith("<%= escape_javascript(render :partial => 'document_form', :locals => {:grouping => @grouping, :service_list => @service_list}) %>")
$(".document_upload").show()
$('.document_edit span').html('Edit')