$('#welcome_message').html("<%= escape_javascript render :partial => 'catalog/description', :locals => {:organization => @organization} %>")
$('.core-accordion').accordion({autoHeight: false, collapsible: true})
