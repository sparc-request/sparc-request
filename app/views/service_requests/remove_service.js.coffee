$("#services").append("<%= escape_javascript render :partial => 'catalogs/cart' %>")
$("#services .spinner").remove()

if "<%= @page %>" == 'protocol'
  $('.service-list').html("<%= escape_javascript render :partial => 'service_list' %>")
