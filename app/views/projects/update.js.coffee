# /////////////////////////////////////////////
# //
# // Project - Edit.js for Editing Projects
# //
# /////////////////////////////////////////////

if <%= @protocol.valid? %>
  window.location.href = "<%= protocol_service_request_path @service_request %>"
else
  $('.edit_project').html("<%= escape_javascript(render :partial => 'projects/form', :locals => {:project => @project, :service_request => @service_request}) %>")
