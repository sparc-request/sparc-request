<% if @submission.save %>
swal("Success!", "Submission saved", "success")
$('#submissionModal').modal('hide')
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
