unless "<%= @errors %>" == ""
  alert "<%= @errors %>"

if "<%= @errors %>" == ""
  unless "<%= @portal %>" == "true"
    if <%= @line_item.service.displayed_pricing_map.unit_factor %> > 1
      "<%= update_per_subject_subtotals(@visit_grouping) %>"

    <% @visit_grouping.visits.each do |visit| %>
      $('.visits_<%= visit.id %>').parent().data('cents', "<%= update_visit_data_cents(visit) %>")
    <% end %>
    else if "<%= @visit_td %>" != ""
      $("<%= @visit_td %>").parent().data('cents', "<%= update_visit_data_cents(@visit) %>")

    # Display for each line items total cost
    $("<%= @line_item_total_td %>").html("<%= display_visit_based_direct_cost(@visit_grouping) %>")

    # Display for all line items max direct, indirect, and total costs per patient
    $(".pp_max_total_direct_cost<%= @arm_id %>").html("<%= display_max_total_direct_cost_per_patient(@visit_grouping.arm) %>")
    $(".pp_max_total_indirect_cost").html("<%= display_max_total_indirect_cost_per_patient(@service_request, @line_items) %>")
    $(".pp_max_total").html("<%= display_max_total_cost_per_patient(@service_request, @line_items) %>")

    # Display for all line items total direct, indirect, and total costs per study
    $(".pp_total_direct_cost").html("<%= display_total_direct_cost_per_study_pppvs(@service_request, @line_items) %>")
    $(".pp_total_indirect_cost").html("<%= display_total_indirect_cost_per_study_pppvs(@service_request, @line_items) %>")
    $(".pp_total_cost").html("<%= display_total_cost_per_study_pppvs(@service_request, @line_items) %>")

    # Displays the grand totals for the entire service service_request
    $(".grand_total_direct").html("<%= display_grand_total_direct_costs(@service_request, @line_items) %>")
    $(".grand_total_indirect").html("<%= display_grand_total_indirect_costs(@service_request, @line_items) %>")
    $(".grand_total").html("<%= display_grand_total(@service_request, @line_items) %>")
