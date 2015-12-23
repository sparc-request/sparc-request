$("#modal_place").html("<%= escape_javascript(render(:partial =>'portal/multiple_line_items/add_line_items_form', locals: { services: @services, page_hash: @page_hash, schedule_tab: @schedule_tab, sub_service_request: @sub_service_request, service_request: @service_request })) %>");
$("#modal_place").modal 'show'
$(".selectpicker").selectpicker()
