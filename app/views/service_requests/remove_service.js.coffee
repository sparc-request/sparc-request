$('.line-items').html("<%= escape_javascript render :partial => 'catalogs/cart', :locals => {:service_request => @service_request} %>")

if "<%= @page %>" != 'catalog'
  $('.service-list').html("<%= escape_javascript render :partial => 'service_list', :locals => {:service_request => @service_request} %>")
