unless "<%= @errors %>" == ""
  alert "<%= @errors %>"

if "<%= @errors %>" == ""
  # Display for each line items total cost
  $("<%= @line_item_total_td %>").html("<%= display_visit_based_direct_cost(@line_item) %>")

  # Display for all line items max direct, indirect, and total costs per patient
  $(".pp_max_total_direct_cost").html("<%= display_max_total_direct_cost_per_patient(@service_request) %>")
  $(".pp_max_total_indirect_cost").html("<%= display_max_total_indirect_cost_per_patient(@service_request) %>")
  $(".pp_max_total").html("<%= display_max_total_cost_per_patient(@service_request) %>")

  # Display for all line items total direct, indirect, and total costs per study
  $(".pp_total_direct_cost").html("<%= display_total_direct_cost_per_study_pppvs(@service_request) %>")
  $(".pp_total_indirect_cost").html("<%= display_total_indirect_cost_per_study_pppvs(@service_request) %>")
  $(".pp_total_cost").html("<%= display_total_cost_per_study_pppvs(@service_request) %>")

  # Displays the grand totals for the entire service service_request
  $(".grand_total_direct").html("<%= display_grand_total_direct_costs(@service_request) %>")
  $(".grand_total_indirect").html("<%= display_grand_total_indirect_costs(@service_request) %>")
  $(".grand_total").html("<%= display_grand_total(@service_request) %>")

  if "<%= @visit_td %>" != ""
    $("<%= @visit_td %>").parent().data('cents', "<%= update_visit_data_cents(@visit) %>")

