# line_item_count = parseInt($('#line_item_count').val())
# line_item_count -= 1
# $('#line_item_count').val(line_item_count)
# $("#line_item-<%= @line_item.id %>").parent().remove()

$("#services").append("<%= escape_javascript render :partial => 'catalogs/cart' %>")
$("#services .spinner").remove()

if "<%= @page %>" == 'protocol'
  $('.service-list').html("<%= escape_javascript render :partial => 'service_list' %>")
