<% if @questionnaire.valid? %>
$('#modal_place').html("<%= j render 'modal_partial' %>")
$('#modal_place').modal('show')
<% else %>
sweetAlert("Error", "Nothing to Preview", "error")
<% end %>
