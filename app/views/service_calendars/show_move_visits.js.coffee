$(".move-visits").html("<%= escape_javascript(render :partial => 'show_move_visits', :locals => {:tab => @tab, :arm => @arm, :service_request => @service_request}) %>")
