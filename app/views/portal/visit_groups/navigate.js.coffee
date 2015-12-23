$("#modal_place").html("<%= escape_javascript(render(:partial =>'portal/visit_groups/navigate_visit_form', locals: {intended_action: @intended_action, protocol: @protocol, arm: @arm, visit_group: @visit_group, service_request: @service_request, sub_service_request: @sub_service_request})) %>")
$("#modal_place").modal 'show'
$(".selectpicker").selectpicker()
