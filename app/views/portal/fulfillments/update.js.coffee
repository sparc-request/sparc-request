$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>");
if $("#modal_errors > .alert.alert-danger > p").length == 0
  $("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
  $("#fulfillments-table").bootstrapTable('refresh')
  $("#fulfillments_row").prev('tr').find('.qty_rem').text("<%= @line_item.quantity_remaining %>")
  $("#fulfillments_row").prev('tr').find('.last_fulfillment').text("<%= format_date(@line_item.last_fulfillment) %>")
  $("#modal_place").modal 'hide'
