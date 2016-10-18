<% if @submission.destroy %>
<% if params[:protocol_id] && params[:sr_id] %>
$('.additional-details-submissions-panel').html("<%= j render 'submissions_panel', protocol: @protocol %>")
$(".complete-additional-details").html("<%= j render 'additional_details/dashboard_complete_additional_details', service_request: @service_request %>")
<% else %>
$('.submissions-index-table').html("<%= j render 'additional_details/submissions/submission_index_table', submissions: @submissions %>")
<% end %>
<% else %>
swal("Error", "Submission could not be deleted", "error")
<% end %>
