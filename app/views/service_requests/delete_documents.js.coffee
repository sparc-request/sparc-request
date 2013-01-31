$("<%= @tr_id %>").remove()
if $(".document-table tr").size() == 1
  $(".document-table").replaceWith("<%= escape_javascript(t("documents.no_documents")) %>")

