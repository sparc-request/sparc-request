<% if @questionnaire.save %>
swal("Success", "Questionnaire status updated", "success")
$('.questionnaires-index-table').html("<%= j render 'additional_details/questionnaires_index_table', questionnaires: @questionnaires %>")
<% else %>
swal("Error", "Questionnaire status not updated", "error")
<% end %>
