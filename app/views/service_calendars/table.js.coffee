$(".arm_id_<%= @arm.id %>.service_calendar").replaceWith("<%= escape_javascript(render :partial => 'calendar_data', :locals => {:tab => @tab, :arm => @arm, :service_request => @service_request}) %>")
