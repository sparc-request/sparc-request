<% if @otf %> # study level activities line item edit
$("#modal_area").html("<%= escape_javascript(render(:partial =>'study_level_activities/study_level_activity_form', locals: {protocol: @protocol, line_item: @line_item, header_text: t(:line_item)[:edit]})) %>");
$("#date_started_field").datetimepicker(format: 'MM-DD-YYYY')
<% else %> # study schedule line item edit
$("#modal_area").html("<%= escape_javascript(render(:partial =>'study_schedule/management/manage_services/change_service_form', locals: {line_item: @line_item})) %>");
<% end %>
$(".selectpicker").selectpicker()
$("#modal_place").modal 'show'
