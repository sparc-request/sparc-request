$("#modal_errors").html("<%= escape_javascript(render(partial: 'shared/modal_errors', locals: {errors: @errors})) %>")
<% unless @errors %>
$("#modal_place").modal 'hide'
# $(".study_schedule_container").append("<%= escape_javascript(render(partial: 'study_schedule/arm', locals: {arm: @arm, page: 1, tab: @schedule_tab})) %>")
$("#per_patient_services").html("<%= escape_javascript(render(:partial =>'portal/sub_service_requests/per_patient_per_visit')) %>");
<% end %>
