<% if @submission.save %>
swal("Success!", "Submission saved", "success")
$("#submissionModal").modal('hide')
$(".additional-details-submissions-panel").html("<%= j render 'submissions_panel', protocol: @protocol, submissions: @submissions %>")
$('.document-management-submissions').html("<%= j render 'additional_details/document_management_submissions', service_request: @service_request %>")
$("#service-requests-panel").html("<%= j render 'dashboard/service_requests/service_requests', protocol: @protocol, permission_to_edit: @permission_to_edit, user: @user, view_only: false, show_view_ssr_back: false %>")
$('.service-requests-table').bootstrapTable()

$('.service-requests-table').on 'all.bs.table', ->
  $(this).find('.selectpicker').selectpicker()
<% else %>
swal("Error", "Submission did not save, check the form for errors", "error")
<% @submission.questionnaire_responses.each do |qr| %>
<% if qr.errors.any? %>
$(".item-<%= qr.item_id %>").addClass('has-error')
<% end %>
<% qr.errors.full_messages.each do |message| %>
$(".item-<%= qr.item_id %>").append("<span class='help-block'><%= message %></span>")
<% end %>
<% end %>
<% end %>
