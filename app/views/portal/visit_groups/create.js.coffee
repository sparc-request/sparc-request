$("#modal_errors").html("<%= escape_javascript(render(partial: 'shared/modal_errors', locals: {errors: @errors})) %>")
<% unless @errors %>
$("#per_patient_services").html("<%= escape_javascript(render(:partial =>'portal/sub_service_requests/per_patient_per_visit', locals: {sub_service_request: @sub_service_request, service_request: @service_request})) %>");
$("#modal_place").modal 'hide'
<% end %>