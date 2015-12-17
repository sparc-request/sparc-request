$("#modal_area").html("<%= escape_javascript(render(:partial =>'portal/multiple_line_items/remove_line_items_form', locals: { arms: @arms, all_services: @all_services, service: @service, protocol: @protocol, sub_service_request: @sub_service_request, service_request: @service_request })) %>");
$("#modal_place").modal 'show'
$(".selectpicker").selectpicker()
