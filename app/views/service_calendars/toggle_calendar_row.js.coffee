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
# Replace checkbox
$("#check-all-row-<%=@line_items_visit.id%>").replaceWith("<%= j render 'service_calendars/master_calendar/pppv/template/select_row', service_request: @service_request, sub_service_request: @sub_service_request, liv: @line_items_visit, page: @page, admin: @admin, locked: @locked %>")

# Replace Column checkboxes
<% @visit_groups.each do |vg| %>
$("#check-all-column-<%=vg.id%>").replaceWith("<%= j render 'service_calendars/master_calendar/pppv/template/select_column', service_request: @service_request, sub_service_request: @sub_service_request, visit_group: vg, page: @page, admin: @admin %>")
<% end %>

<% if @admin %>
# Replace SSR Header
$('#sub_service_request_header').html("<%= j render 'dashboard/sub_service_requests/header', sub_service_request: SubServiceRequest.eager_load(line_items: [:admin_rates, line_items_visits: :arm, service: [:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, parent: :pricing_setups]]]], service_request: :protocol]).find(@sub_service_request.id) %>")
$('.selectpicker').selectpicker()
<% end %>

# Replace visits
<% @visits.paginate(page: @page.to_i, per_page: Visit.per_page).ordered.each do |visit| %>
$(".visit-<%=visit.id%>:visible").html('<%= j render "service_calendars/master_calendar/pppv/template/template_visit_input", visit: visit, tab: @tab, page: @page, admin: @admin, locked: @locked %>')
<% end %>

# Replace Per Patient / Study Totals
$("#check-all-row-<%=@line_items_visit.id%>").parent().siblings('.pppv-per-patient-line-item-total').replaceWith("<%= j render 'service_calendars/master_calendar/pppv/total_per_patient', liv: @line_items_visit %>")
$("#check-all-row-<%=@line_items_visit.id%>").parent().siblings('.pppv-per-study-line-item-total').replaceWith("<%= j render 'service_calendars/master_calendar/pppv/total_per_study', liv: @line_items_visit %>")

# Replace Totals
$(".arm-<%=@arm.id%>.maximum-total-direct-cost-per-patient").replaceWith("<%= j render 'service_calendars/master_calendar/pppv/totals/max_total_direct_per_patient', arm: @arm, visit_groups: @visit_groups, line_items_visits: @line_items_visits, tab: @tab, page: @page %>")
$(".arm-<%=@arm.id%>.maximum-total-per-patient").replaceWith("<%= j render 'service_calendars/master_calendar/pppv/totals/max_total_per_patient', arm: @arm, visit_groups: @visit_groups, line_items_visits: @line_items_visits, tab: @tab, page: @page %>")
$(".arm-<%=@arm.id%>.total-per-patient-per-visit-cost-per-study").replaceWith("<%= j render 'service_calendars/master_calendar/pppv/totals/total_cost_per_study', arm: @arm, line_items_visits: @line_items_visits, tab: @tab %>")
