<% unless @errors %>
$("#status_owner_fulfillment").html("<%= escape_javascript(render(partial: 'portal/admin/fulfillment/service_request_info/status_owner_fulfillment', locals: { sub_service_request: @sub_service_request })) %>");
$("#fulfillment_subsidy").html("<%= escape_javascript(render(partial: 'portal/admin/fulfillment/service_request_info/subsidy_info', locals: { sub_service_request: @sub_service_request, subsidy: @subsidy })) %>");
$("#request_cost_total").html("<%= escape_javascript(render(partial: 'portal/admin/fulfillment/service_request_info/direct_cost_total')) %>");

$(".selectpicker").selectpicker()
$("#flashes_container").html("<%= escape_javascript(render('shared/flash')) %>")
<% end %>