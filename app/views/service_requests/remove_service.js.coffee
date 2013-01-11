line_item_count = parseInt($('#line_item_count').val())
line_item_count -= 1
$('#line_item_count').val(line_item_count)
$("#line_item-<%= @line_item.id %>").parent().remove()

if "<%= @page %>" == 'protocol'
  $('.service-list').html("<%= escape_javascript render :partial => 'service_list' %>")
if "<%= @page %>" == 'service_details'
  $('.one-time-fee-details').html("<%= escape_javascript render :partial => 'service_detail_list' %>")
  if <%= @service_request.one_time_fee_line_items.size %> == 0
    $('#show-one-time-fee').hide()
  if <%= @service_request.per_patient_per_visit_line_items.size %> == 0
    $('#show-visit-calendar-details').hide()
  if (<%= @service_request.one_time_fee_line_items.size %> == 0 && <%= @service_request.per_patient_per_visit_line_items.size %> == 0)
    $('.visit-calendar-details').show()
