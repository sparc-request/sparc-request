current_index = $("#service_calendar").tabs("option", "active")
$("#service_calendar").tabs('load', current_index)
$("#fulfillment_subsidy").html("<%= escape_javascript(render(:partial =>'portal/sub_service_requests/subsidy')) %>");
$("#request_cost_total").html("<%= escape_javascript(render(:partial =>'portal/sub_service_requests/direct_cost_total')) %>");
if "<%= @errors %>"
  alert "<%= raw(@errors) %>"
