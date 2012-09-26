$('#welcome_message').html("<%= escape_javascript render :partial => 'catalogs/description', :locals => {:organization => @organization, :service_request => @service_request} %>")
$('.core-accordion').accordion({autoHeight: false, collapsible: true})
