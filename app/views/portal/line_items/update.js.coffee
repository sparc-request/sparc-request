<% unless @errors.present? %>
<% if @otf %>
$("#study-level-activities-table").bootstrapTable('refresh')
<% else %>
$("#line_item_<%= @line_item.id %> .line_item_service_name").text("<%= @line_item.service.name %>")
<% end %>
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
$("#modal_place").modal 'hide'
<% else %>
$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>");
<% end %>
