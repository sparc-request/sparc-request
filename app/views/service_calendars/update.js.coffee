unless "<%= @errors %>" == ""
  alert "<%= @errors %>"

if "<%= @errors %>" == ""
  # Display for each line items total cost
  $("<%= @line_item_total_td %>").html("<%= display_visit_based_direct_cost(@line_item) %>")

  # Display for all line items max direct, indirect, and total costs
  $("#pp_max_total_direct_cost").html("<%= dispaly_max_total_direct_cost_per_patient(@service_request.line_items) %>")
  $("#pp_max_total_indirect_cost").html("<%= dispaly_max_total_indirect_cost_per_patient(@service_request.line_items) %>")
  $("#pp_max_total").html("<%= dispaly_max_total_cost_per_patient(@service_request.line_items) %>")

  # Display for all line items total direct, indirect, and total costs
  $("#pp_total_direct_cost").html("<%= dispaly_total_direct_cost_per_study(@service_request.line_items) %>")
  $("#pp_total_indirect_cost").html("<%= dispaly_total_indirect_cost_per_study(@service_request.line_items) %>")
  $("#pp_total_cost").html("<%= dispaly_total_cost_per_study(@service_request.line_items) %>")