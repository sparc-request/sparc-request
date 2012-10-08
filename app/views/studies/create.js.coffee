# /////////////////////////////////////////////
# //
# // STUDY - Create.js for New/Editing Studies
# //
# /////////////////////////////////////////////

if <%= @study.valid? %>
  console.log "way to go"
else
  $('.new_study').html("<%= escape_javascript(render :partial => 'studies/form', :locals => {:study => @study, :service_request => @service_request}) %>")
  
