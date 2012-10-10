if $(".project_role_<%= @project_role.identity.id %>").length > 0 and "<%= @project_role.new_record? %>" == "true"
  #if $("#<%= @protocol_type %>_project_roles_attributes_<%= @project_role.identity.id %>_identity_id").length > 0
  alert "<%= @project_role.identity.display_name %> has already been added to this project. Click edit in the table below to make changes to this user." 
else if $(".project_role_<%= @project_role.identity.id %>").length > 0 and "<%= @project_role.new_record? %>" == "false"
  $('#user_detail_errors').hide()
  $(".project_role_<%= @project_role.identity.id %>").replaceWith("<%= escape_javascript(render :partial => 'shared/user_proxy_right', :locals => {:project_role => @project_role}) %>")
  $('.user_added_message p').html('User updated!  See table below to set proxy rights.')
  $('.user_added_message').show().fadeOut(2500, 'linear')
  $('.add-user-details').hide()
else if "<%= @error %>" != ""
  $('#user_detail_errors').html("<h2>1 error prohibited this user from being added</h2><p>There were problems with the following fields:</p><ul><li><%= @error %></li></ul>")

  # add error fields depending on error received
  if "<%= @error_field %>" == "role"
    $('.user_role label').wrap("<div class='field_with_errors' />")
    $('.user_role_other field_with_errors label').unwrap()
  else
    $('.user_role field_with_errors label').unwrap()

  $('#user_detail_errors').show()
  $('.user_info').show()
else
  $('#user_detail_errors').hide()
  $('.authorized-users tbody').append("<%= escape_javascript(render :partial => 'shared/user_proxy_right', :locals => {:project_role => @project_role}) %>")
  $('.user_added_message p').html('User added!  See table below to set proxy rights.')
  $('.user_added_message').show().fadeOut(2500, 'linear')
  $('.add-user-details').hide()
