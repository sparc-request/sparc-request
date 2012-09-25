$('.line-items').html("<%= escape_javascript render :partial => 'catalogs/cart', :locals => {:service_request => @service_request} %>")
