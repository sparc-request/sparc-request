-# Copyright © 2011-2022 MUSC Foundation for Research Development
-# All rights reserved.

-# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

-# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

-# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
-# disclaimer in the documentation and/or other materials provided with the distribution.

-# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
-# derived from this software without specific prior written permission.

-# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
-# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
-# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
-# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
-# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

$('#modalContainer').modal('hide')

$("#<%= @tab.camelize(:lower) %>Tab").html("<%= j render 'service_calendars/table', service_request: @service_request, sub_service_request: nil, tab: @tab, merged: false, consolidated: false, pages: @pages, page: @page %>").addClass('active show')
<% @service_request.arms.joins(:visit_groups).distinct.eager_load(:visit_groups, :protocol).select{ |arm| arm.visit_groups.any? }.each do |arm| %>
<% page = @pages[arm.id.to_s] %>
<% visit_groups = arm.visit_groups.page(page).includes(visits: { line_items_visit: [:visits, line_item: [:admin_rates, :protocol, service: [:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, :parent]]]]] ] }) %>
$(".arm-<%= arm.id %>-service-calendar-tbody").html("<%= j render "service_calendars/master_calendar/pppv/#{@tab}/#{@tab}_line_items", service_request: @service_request, sub_service_request: nil, arm: arm, tab: @tab, pages: @pages, page: page, merged: false, consolidated: false, visit_groups: visit_groups %>")
<% end %>
