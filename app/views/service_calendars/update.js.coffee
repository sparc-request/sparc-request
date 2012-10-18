unless "<%= @errors %>" == ""
  alert "<%= @errors %>"

if "<%= @errors %>" == ""
  $("<%= @line_item_total_td %>").html("<%= display_visit_based_direct_cost(@line_item) %>")