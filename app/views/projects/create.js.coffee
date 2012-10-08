# /////////////////////////////////////////////
# //
# // PROJECT - Create.js for New/Editing Projects
# //
# /////////////////////////////////////////////

if <%= @project.valid? %>
  console.log "way to go"
else
  $('.new_project').html("<%= escape_javascript(render :partial => 'projects/form', :locals => {:project => @project, :service_request => @service_request}) %>")
