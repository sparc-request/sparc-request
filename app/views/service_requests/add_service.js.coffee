line_item_count = parseInt($('#line_item_count').val())

<% @new_line_items.each do |line_item| %>
line_item_count += 1
$('.line-items').append("<%= escape_javascript render :partial => 'catalogs/cart_line_item', :locals => {:line_item => line_item} %>")
<% end %>

$('#line_item_count').val(line_item_count)
