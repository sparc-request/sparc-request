$('.line-items').html("<%= escape_javascript render :partial => 'catalogs/cart', :locals => {:service_request => @service_request} %>")

if "<%= @page %>" == 'protocol'
  $('.service-list').html("<%= escape_javascript render :partial => 'service_list', :locals => {:service_request => @service_request} %>")
if "<%= @page %>" == 'service_details'
  $('.one-time-fees').html("<%= escape_javascript render :partial => 'service_detail_list', :locals => {:service_request => @service_request} %>")
