if <%= @study.valid? %>
  console.log "way to go"
else
  $('.new_study').html("<%= escape_javascript(render :partial => 'form', :locals => {:study => @study, :service_request => @service_request}) %>")
  
