# Copyright © 2011-2022 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

<% if @errors %>
$("[name^='line_item']:not([type='hidden'])").parents('.form-group').removeClass('is-invalid').addClass('is-valid')
$('.form-error').remove()

<% @errors.messages.each do |attr, messages| %>
<% messages.each do |message| %>
$("[name='line_item[<%= attr.to_s %>]']").parents('.form-group').removeClass('is-valid').addClass('is-invalid').append("<small class='form-text form-error'><%= message.capitalize.html_safe %></small>")
<% end %>
<% end %>
<% else %>
$('#modalContainer').modal('hide')

<% if @in_dashboard && @line_item.service.one_time_fee? %>
$('#studyLevelActivitiesTable').bootstrapTable('refresh')
<% else %>
# Replace Field Cell
$(".line-item-<%= @line_item.id %>:visible .<%= @field.dasherize %>").replaceWith('<%= j render "service_calendars/#{@field}", line_item: @line_item, service_request: @service_request, sub_service_request: @sub_service_request, merged: false, editable: true %>')

# Replace Per Study Total
$(".line-item-<%= @line_item.id %>:visible .total-per-study").replaceWith("<%= j render 'service_calendars/master_calendar/otf/total_per_study', line_item: @line_item %>")

# Replace Totals
$('.one-time-fees-container:visible .max-total-direct').replaceWith("<%= j render 'service_calendars/master_calendar/otf/totals/max_total_direct_one_time_fee', service_request: @service_request %>")
$('.one-time-fees-container:visible .max-total-per-study').replaceWith("<%= j render 'service_calendars/master_calendar/otf/totals/total_cost_per_study', service_request: @service_request %>")
<% end %>

# Re-render Admin Edit SSR header to update costs
<% if @in_dashboard %>
$("#subServiceRequestSummary").replaceWith("<%= j render 'dashboard/sub_service_requests/header', sub_service_request: @sub_service_request %>")
<% end %>

<% end %>
