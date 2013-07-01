# /////////////////////////////////////////////
# //
# // PROJECT - Create.js for New/Editing Projects
# //
# /////////////////////////////////////////////

if <%= @protocol.valid? %>
  window.location.href = "<%= protocol_service_request_path @service_request %>"
else
  $('.new_project').html("<%= escape_javascript(render :partial => 'projects/form', :locals => {:project => @project, :service_request => @service_request}) %>")
