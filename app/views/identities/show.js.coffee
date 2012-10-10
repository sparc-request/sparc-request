$('.user-details').html("<%= escape_javascript(render :partial => 'shared/user_details', :locals => {:identity => @identity, :project_role => @project_role, :can_edit => @can_edit}) %>")
$('.user-details').show()
