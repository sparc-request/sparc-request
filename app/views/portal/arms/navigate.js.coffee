$("#modal_place").html("<%= escape_javascript(render(:partial =>'/portal/arms/navigate_arm_form', locals: {intended_action: @intended_action, arm: @arm, protocol_arms: @protocol.arms, sub_service_request: @sub_service_request, service_request: @service_request})) %>");
$("#modal_place").modal 'show'
$(".selectpicker").selectpicker()
