# Copyright © 2011-2022 MUSC Foundation for Research Development
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

$('[name=change_billing_visit]').remove()

<% if @errors %>
$("[name^='visit']:not([type='hidden'])").parents('.form-group').removeClass('is-invalid').addClass('is-valid')
$('.form-error').remove()

<% @errors.messages.each do |attr, messages| %>
<% messages.each do |message| %>
$("[name='visit[<%= attr.to_s %>]']").parents('.form-group').removeClass('is-valid').addClass('is-invalid').append("<small class='form-text form-error'><%= message.capitalize.html_safe %></small>")
<% end %>
<% end %>
<% else %>
<% if @tab == 'template' %>
# Replace checkboxes
$("#toggleColumn<%= @visit_group.id %>").replaceWith("<%= j render 'service_calendars/master_calendar/pppv/template/select_column', service_request: @service_request, sub_service_request: @sub_service_request, visit_group: @visit_group, page: @page, index: @index, editable: true %>")
$("#toggleRow<%= @line_items_visit.id %>").replaceWith("<%= j render 'service_calendars/master_calendar/pppv/template/select_row', service_request: @service_request, sub_service_request: @sub_service_request, liv: @line_items_visit, page: @page, editable: true %>")
<% elsif @tab == 'billing_strategy' %>
# $('#modalContainer').modal('hide')
$(".visit-<%= @visit.id %>").popover('dispose')
<% end %>

<% if @in_admin %>
# Replace SSR Header
$('#effectiveCost').replaceWith("<%= j render 'dashboard/sub_service_requests/effective_cost', sub_service_request: @sub_service_request %>")
$('#displayCost').replaceWith("<%= j render 'dashboard/sub_service_requests/displayed_cost', sub_service_request: @sub_service_request %>")
<% end %>

# Replace Visit
$(".visit-<%= @visit.id %>:visible").html('<%= j render "service_calendars/master_calendar/pppv/#{@tab}/#{@tab}_visit_input", service_request: @service_request, sub_service_request: @sub_service_request, visit: @visit, line_items_visit: @line_items_visit, page: @page, editable: true %>')

# Replace Per Patient / Study Totals
$(".visit-<%= @visit.id %>:visible").siblings('.total-per-patient').replaceWith("<%= j render 'service_calendars/master_calendar/pppv/total_per_patient', liv: @line_items_visit %>")
$(".visit-<%= @visit.id %>:visible").siblings('.total-per-study').replaceWith("<%= j render 'service_calendars/master_calendar/pppv/total_per_study', liv: @line_items_visit %>")

# Replace Totals
$(".arm-<%= @arm.id %>-container:visible .max-total-direct-per-patient").replaceWith("<%= j render 'service_calendars/master_calendar/pppv/totals/max_total_direct_per_patient', arm: @arm, line_items_visits: @line_items_visits, visit_groups: @visit_groups, tab: @tab, page: @page %>")
$(".arm-<%= @arm.id %>-container:visible .max-total-per-patient").replaceWith("<%= j render 'service_calendars/master_calendar/pppv/totals/max_total_per_patient', service_request: @service_request, arm: @arm, line_items_visits: @line_items_visits, visit_groups: @visit_groups, tab: @tab, page: @page %>")
$(".arm-<%= @arm.id %>-container:visible .max-total-per-study").replaceWith("<%= j render 'service_calendars/master_calendar/pppv/totals/total_cost_per_study', arm: @arm, line_items_visits: @line_items_visits, tab: @tab %>")

adjustCalendarHeaders()

# If changing the visit using the chevrons, open the new visit
# else re-focus the visit for tabbing
<% if params[:change_billing_visit].present? %>
$.ajax
  method:   'GET'
  dataType: 'script'
  url:      "<%= edit_visit_path(params[:change_billing_visit] == 'next' ? @visit.lower_item_visit(@visit.service).first : @visit.higher_item_visit(@visit.service).first, srid: @service_request.try(:id), ssrid: @sub_service_request.try(:id), tab: @tab, page: @page, pages: @pages) %>"
<% else %>
$(".visit-<%= @visit.id %>").trigger('focus')
<% end %>

$("#flashContainer").replaceWith("<%= j render 'layouts/flash' %>")
$(document).trigger('ajax:complete') # rails-ujs element replacement bug fix

<% end %>
