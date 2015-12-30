$ ->

  # DOCUMENTS LISTENERS BEGIN

  $(document).on 'click', "#document_new", ->
    data = "sub_service_request_id"  : $(this).data("sub-service-request-id")
    $.ajax
      type: 'GET'
      url: "/portal/documents/new"
      data: data

  $(document).on 'click', '.document_edit', ->
    row_index   = $(this).parents("tr").data("index")
    document_id = $(this).parents("table.documents_table").bootstrapTable("getData")[row_index].id
    data = 'sub_service_request_id': $("#document_new").data("sub-service-request-id")
    $.ajax
      type: 'GET'
      url: "/portal/documents/#{document_id}/edit"
      data: data

  $(document).on 'click', '.document_delete', ->
    row_index   = $(this).parents("tr").data("index")
    document_id = $(this).parents("table.documents_table").bootstrapTable("getData")[row_index].id
    data = 'sub_service_request_id': $("#document_new").data("sub-service-request-id")
    if confirm "Are you sure you want to delete the selected Document from this SubServiceRequest?"
      $.ajax
        type: "DELETE"
        url: "/portal/documents/#{document_id}"
        data: data

  $(document).on('change', '#document_doc_type', ->
    if $(this).val() == 'other'
      $('#doc_type_other_field').show()
    else
      $('#doc_type_other_field').hide()
  )

  # DOCUMENTS LISTENERS END
