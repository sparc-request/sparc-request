$('.user-details').html("<%= escape_javascript(render :partial => 'shared/user_details', :locals => {:identity => @identity, :protocol => nil}) %>")
