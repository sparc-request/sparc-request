# Copyright © 2011-2019 MUSC Foundation for Research Development
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
$("#toggleColumn<%= @visit_group.id %>").replaceWith("<%= j render 'service_calendars/master_calendar/pppv/template/select_column', service_request: @service_request, sub_service_request: @sub_service_request, visit_group: @visit_group, page: @page, editable: true %>")

# Replace Row checkboxes
<% @line_items_visits.each do |liv| %>
$("#toggleRow<%= liv.id %>").replaceWith("<%= j render 'service_calendars/master_calendar/pppv/template/select_row', service_request: @service_request, sub_service_request: @sub_service_request, liv: liv, page: @page, editable: true %>")
<% end %>

<% if @in_admin %>
# Replace SSR Header
$('#effectiveCost').replaceWith("<%= j render 'dashboard/sub_service_requests/effective_cost', sub_service_request: @sub_service_request %>")
$('#displayCost').replaceWith("<%= j render 'dashboard/sub_service_requests/displayed_cost', sub_service_request: @sub_service_request %>")
<% end %>

<% @visits.each do |visit| %>
# Replace visits
$(".visit-<%= visit.id %>:visible").html('<%= j render "service_calendars/master_calendar/pppv/template/template_visit_input", visit: visit, tab: @tab, page: @page, editable: true %>')

# Replace Per Patient / Study Totals
$(".visit-<%= visit.id %>:visible").siblings('.total-per-patient').replaceWith("<%= j render 'service_calendars/master_calendar/pppv/total_per_patient', liv: visit.line_items_visit %>")
$(".visit-<%= visit.id %>:visible").siblings('.total-per-study').replaceWith("<%= j render 'service_calendars/master_calendar/pppv/total_per_study', liv: visit.line_items_visit %>")
<% end %>

# Replace Totals
$(".arm-<%= @arm.id %>-container:visible .max-total-direct-per-patient").replaceWith("<%= j render 'service_calendars/master_calendar/pppv/totals/max_total_direct_per_patient', arm: @arm, visit_groups: @visit_groups, line_items_visits: @line_items_visits, tab: @tab, page: @page %>")
$(".arm-<%= @arm.id %>-container:visible .max-total-per-patient").replaceWith("<%= j render 'service_calendars/master_calendar/pppv/totals/max_total_per_patient', arm: @arm, visit_groups: @visit_groups, line_items_visits: @line_items_visits, tab: @tab, page: @page %>")
$(".arm-<%= @arm.id %>-container:visible .max-total-per-study").replaceWith("<%= j render 'service_calendars/master_calendar/pppv/totals/total_cost_per_study', arm: @arm, line_items_visits: @line_items_visits, tab: @tab %>")

$(document).one 'ajax:complete', ->
  adjustCalendarHeaders()

$(document).trigger('ajax:complete') # rails-ujs element replacement bug fix
