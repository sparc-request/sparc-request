# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

$("#request_cost_total").html("<%= escape_javascript(render(:partial =>'portal/sub_service_requests/direct_cost_total')) %>")
if "<%= @subsidy %>"
  $("#fulfillment_subsidy").html("<%= escape_javascript(render(:partial =>'portal/sub_service_requests/subsidy')) %>")
  $("#request_cost_total").html("<%= escape_javascript(render(:partial =>'portal/sub_service_requests/direct_cost_total')) %>")
unless "<%= @errors %>" == ""
  alert "<%= @errors %>"

if "<%= @errors %>" == ""
  unless "<%= @portal %>"
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
    $(".pp_max_total_direct_cost<%= @arm_id %>").html("<%= display_max_total_direct_cost_per_patient(@line_items_visit.arm, @line_items_visits) %>")
    $(".pp_max_total_indirect_cost<%= @arm_id %>").html("<%= display_max_total_indirect_cost_per_patient(@line_items_visit.arm, @line_items_visits) %>")
    $(".pp_max_total<%= @arm_id %>").html("<%= display_max_total_cost_per_patient(@line_items_visit.arm, @line_items_visits) %>")

    $(".pp_total<%= @arm_id %>").html("<%= display_total_cost_per_arm(@line_items_visit.arm, @line_items_visits) %>")
    $("#fulfillment_subsidy").html("<%= escape_javascript(render(:partial =>'portal/sub_service_requests/subsidy')) %>")
    $("#request_cost_total").html("<%= escape_javascript(render(:partial =>'portal/sub_service_requests/direct_cost_total')) %>")

