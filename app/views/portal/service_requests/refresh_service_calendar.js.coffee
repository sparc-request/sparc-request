$('.service_calendar').replaceWith("<%= escape_javascript(render :partial => 'portal/service_requests/calendar', :locals => {:tab => @tab}) %>")
