if "<%= @error %>" != ""
  $('#user_detail_errors').html("<%= @error %>")
  $('#user_detail_errors').show()
else
  $('#user_detail_errors').hide()
  $('.authorized-users tbody').append("<%= escape_javascript(render :partial => 'shared/user_proxy_right', :locals => {:project_role => @project_role}) %>")
