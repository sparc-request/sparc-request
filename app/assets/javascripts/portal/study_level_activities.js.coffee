$ ->

  # Line Item Bindings

  $(document).on 'click', ".otf_service_new", ->
    protocol_id = $('#protocol_id').val()
    data = protocol_id: protocol_id
    $.ajax
      type: 'GET'
      url: "/line_items/new"
      data: data

  $(document).on 'change', '.components > .selectpicker', ->
    row_index   = $(this).parents("tr").data("index")
    line_item_id = $(this).parents("table.study_level_activities").bootstrapTable("getData")[row_index].id
    data = components: $(this).val(), line_item_id: line_item_id
    $.ajax
      type: 'PUT'
      url: "/components/update"
      data: data

  $(document).on 'click', '.otf_edit', ->
    row_index   = $(this).parents("tr").data("index")
    line_item_id = $(this).parents("table.study_level_activities").bootstrapTable("getData")[row_index].id
    $.ajax
      type: 'GET'
      url: "/line_items/#{line_item_id}/edit"

  $(document).on 'click', '.otf_delete', ->
    row_index   = $(this).parents("tr").data("index")
    line_item_id = $(this).parents("table.study_level_activities").bootstrapTable("getData")[row_index].id
    del = confirm "Are you sure you want to delete the selected Study Level Activity from this protocol"
    if del
      $.ajax
        type: "DELETE"
        url: "/line_items/#{line_item_id}"

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
        url: "/fulfillments"
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
      url: "/fulfillments/new"
      data: data

  $(document).on 'click', '.otf_fulfillment_edit', ->
    row_index   = $(this).parents("tr").data("index")
    fulfillment_id = $(this).parents("#fulfillments-table").bootstrapTable("getData")[row_index].id
    $.ajax
      type: 'GET'
      url: "/fulfillments/#{fulfillment_id}/edit"
