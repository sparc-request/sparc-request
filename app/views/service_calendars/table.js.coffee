$('.service_calendar').replaceWith("<%= escape_javascript(render :partial => 'calendar_data', :locals => {:tab => @tab}) %>")
