$("#modal_place").html("<%= escape_javascript(render(:partial =>'portal/line_items/new_otf_line_item_form', locals: { services: @services, page_hash: @page_hash, schedule_tab: @schedule_tab, sub_service_request: @sub_service_request, service_request: @service_request })) %>");
$("#modal_place").modal 'show'
$(".selectpicker").selectpicker()
