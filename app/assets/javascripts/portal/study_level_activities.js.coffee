$ ->

  # Line Item Bindings

  $(document).on 'click', '.otf_details', ->
    row_index   = $(this).parents("tr").data("index")
    line_item_id = $(this).parents("table.study_level_activities").bootstrapTable("getData")[row_index].id
    $.ajax
      type: 'GET'
      url: "/portal/admin/line_items/#{line_item_id}/details"

  $(document).on 'click', "#otf_service_new", ->
    data =
      "sub_service_request_id"  : $(this).data("sub-service-request-id")
      "one_time_fee"            : true
    $.ajax
      type: 'GET'
      url: "/portal/admin/line_items/new"
      data: data

  $(document).on 'click', '.otf_edit', ->
    row_index   = $(this).parents("tr").data("index")
    line_item_id = $(this).parents("table.study_level_activities").bootstrapTable("getData")[row_index].id
    $.ajax
      type: 'GET'
      url: "/portal/admin/line_items/#{line_item_id}/edit"

  $(document).on 'click', '.otf_delete', ->
    row_index   = $(this).parents("tr").data("index")
    line_item_id = $(this).parents("table.study_level_activities").bootstrapTable("getData")[row_index].id
    if confirm "Are you sure you want to delete the selected Study Level Activity from this Sub Service Request?"
      $.ajax
        type: "DELETE"
        url: "/portal/admin/line_items/#{line_item_id}"

  $(document).on 'click', '.otf_fulfillments', ->
    selected_row = $(this).parents("tr")
    fulfillments_row = $("#fulfillments_row") #already displayed
    span = $(this).children('.glyphicon')
    line_item_id = $(this).parents("table.study_level_activities").bootstrapTable("getData")[selected_row.data("index")].id
    fulfillments_already_displayed = fulfillments_row.attr('data-line_item_id') == "#{line_item_id}"

    fulfillments_row.prev('tr').first().find('.glyphicon-chevron-down').removeClass("glyphicon-chevron-down").addClass("glyphicon-chevron-right").parents(".otf_fulfillments").attr('data-original-title', 'View Fulfillments')
    fulfillments_row.remove()
    unless fulfillments_already_displayed
      span.removeClass("glyphicon-chevron-right").addClass("glyphicon-refresh")
      $(this).parents("tr").after("<tr id='fulfillments_row'></tr>")
      $.ajax
        type: 'GET'
        url: "/portal/admin/fulfillments"
        data: "line_item_id" : line_item_id
    else
      $(this).attr('data-original-title', 'View Fulfillments')
      span.removeClass("glyphicon-chevron-down").addClass("glyphicon-chevron-right")

  # Fulfillment Bindings

  $(document).on 'click', '.otf_fulfillment_new', ->
    line_item_id = $(this).data('line-item-id')
    data = line_item_id: line_item_id
    $.ajax
      type: 'GET'
      url: "/portal/admin/fulfillments/new"
      data: data

  $(document).on 'click', '.otf_fulfillment_edit', ->
    row_index   = $(this).parents("tr").data("index")
    fulfillment_id = $(this).parents("#fulfillments-table").bootstrapTable("getData")[row_index].id
    $.ajax
      type: 'GET'
      url: "/portal/admin/fulfillments/#{fulfillment_id}/edit"

  $(document).on 'click', '.otf_fulfillment_delete', ->
    row_index   = $(this).parents("tr").data("index")
    fulfillment_id = $(this).parents("#fulfillments-table").bootstrapTable("getData")[row_index].id
    if confirm "Are you sure you want to delete the selected Fulfillment from this Study Level Activity?"
      $.ajax
        type: "DELETE"
        url: "/portal/admin/fulfillments/#{fulfillment_id}"