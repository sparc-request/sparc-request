$("#modal_area").html("<%= escape_javascript(render(:partial =>'portal/visit_groups/add_visit_form', locals: {protocol: @protocol, visit_group: @visit_group, arm: @arm, schedule_tab: @schedule_tab, current_page: @current_page, service_request: @service_request, sub_service_request: @sub_service_request, study_tracker: @study_tracker})) %>");
$("#modal_place").modal 'show'
