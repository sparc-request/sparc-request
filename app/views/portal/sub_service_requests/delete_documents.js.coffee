$("<%= @tr_id %>").remove()
if $(".document-table tr").size() == 1
  $(".document-table").replaceWith("<div>No documents found</div>")
