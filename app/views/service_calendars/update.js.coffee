if "<%= @subsidy %>"
  $("#fulfillment_subsidy").html("<%= escape_javascript(render(:partial =>'portal/sub_service_requests/subsidy')) %>");
  $("#request_cost_total").html("<%= escape_javascript(render(:partial =>'portal/sub_service_requests/direct_cost_total')) %>");
unless "<%= @errors %>" == ""
  alert "<%= @errors %>"

if "<%= @errors %>" == ""
  unless "<%= @portal %>" == "true"
    if <%= @line_item.service.displayed_pricing_map.unit_factor %> > 1
      "<%= update_per_subject_subtotals(@line_items_visit) %>"

    <% @line_items_visit.visits.each do |visit| %>
      $('.visits_<%= visit.id %>').parent().data('cents', "<%= update_visit_data_cents(visit) %>")
    <% end %>
    else if "<%= @visit_td %>" != ""
      $("<%= @visit_td %>").parent().data('cents', "<%= update_visit_data_cents(@visit) %>")

    # Display for each line items total cost
    $("<%= @line_item_total_td %>").html("<%= display_visit_based_direct_cost(@line_items_visit) %>")
    $("<%= @line_item_total_study_td %>").html("<%= display_visit_based_direct_cost_per_study(@line_items_visit) %>")

    # Display for all line items max direct, indirect, and total costs per patient
    $(".pp_max_total_direct_cost<%= @arm_id %>").html("<%= display_max_total_direct_cost_per_patient(@line_items_visit.arm) %>")
    $(".pp_max_total_indirect_cost<%= @arm_id %>").html("<%= display_max_total_indirect_cost_per_patient(@line_items_visit.arm) %>")
    $(".pp_max_total<%= @arm_id %>").html("<%= display_max_total_cost_per_patient(@line_items_visit.arm) %>")

    $(".pp_total<%= @arm_id %>").html("<%= display_total_cost_per_arm(@line_items_visit.arm) %>")
    $("#fulfillment_subsidy").html("<%= escape_javascript(render(:partial =>'portal/sub_service_requests/subsidy')) %>");
    $("#request_cost_total").html("<%= escape_javascript(render(:partial =>'portal/sub_service_requests/direct_cost_total')) %>");

