$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")
<% unless @errors %>
$("#modal_place").modal 'hide'
$("#per_patient_services").html("<%= escape_javascript(render(:partial =>'portal/sub_service_requests/per_patient_per_visit')) %>");
# $("#arm-name-display-<%= @arm.id %>").html("<%= @arm.name %>")
<% end %>
