$('.service_calendar').replaceWith("<%= escape_javascript(render :partial => 'service_requests/review/calendar', :locals => {:tab => @tab}) %>")
