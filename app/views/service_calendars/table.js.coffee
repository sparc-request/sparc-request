<% @service_request.arms.each do |arm| %>
  $(".<%= arm.id %>.service_calendar").replaceWith("<%= escape_javascript(render :partial => 'calendar_data', :locals => {:tab => @tab, :arm => arm}) %>")
<% end %>