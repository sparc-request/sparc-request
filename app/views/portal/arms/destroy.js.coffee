$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")
<% unless @errors %>
# $(".study_schedule.service.arm_<%= @arm.id %>").remove()
$("#per_patient_services").html("<%= escape_javascript(render(:partial =>'portal/sub_service_requests/per_patient_per_visit')) %>");
$("#modal_place").modal 'hide'
<% end %>
