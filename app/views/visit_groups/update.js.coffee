# Copyright © 2011-2020 MUSC Foundation for Research Development
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

$('[name=change_visit]').remove()

<% if @errors %>
$("[name^='visit_group']:not([type='hidden'])").parents('.form-group').removeClass('is-invalid').addClass('is-valid')
$('.form-error').remove()

<% @errors.messages.each do |attr, messages| %>
<% messages.each do |message| %>
$("[name='visit_group[<%= attr.to_s %>]']").parents('.form-group').removeClass('is-valid').addClass('is-invalid').append("<small class='form-text form-error'><%= message.capitalize.html_safe %></small>")
<% end %>
<% end %>
<% else %>
$(".visit-group-<%= @visit_group.id %>").popover('dispose')

# Change the page up if moving to previous page of visits
<% if @visit_group.position % VisitGroup.per_page == 0 && params[:change_visit] == 'next' %>
<% @page += 1 %>
<% @pages[@arm.id] = @page %>
<% session[:service_calendar_pages][@arm.id.to_s] = @page %>
$(".arm-<%= @arm.id %>-container").replaceWith("<%= j render '/service_calendars/master_calendar/pppv/pppv_calendar', tab: @tab, arm: @arm, service_request: @service_request, sub_service_request: @sub_service_request, page: @page, pages: @pages, merged: false, consolidated: false %>")
# Change the page down if moving to previous page of visits
<% elsif @visit_group.position % VisitGroup.per_page == 1 && params[:change_visit] == 'previous' %>
<% @page -= 1 %>
<% @pages[@arm.id] = @page %>
<% session[:service_calendar_pages][@arm.id.to_s] = @page %>
$(".arm-<%= @arm.id %>-container").replaceWith("<%= j render '/service_calendars/master_calendar/pppv/pppv_calendar', tab: @tab, arm: @arm, service_request: @service_request, sub_service_request: @sub_service_request, page: @page, pages: @pages, merged: false, consolidated: false %>")
# Update the whole calendar if the position changed
<% else %>
$(".arm-<%= @arm.id %>-container").replaceWith("<%= j render '/service_calendars/master_calendar/pppv/pppv_calendar', tab: @tab, arm: @arm, service_request: @service_request, sub_service_request: @sub_service_request, page: @page, pages: @pages, merged: false, consolidated: false %>")
<% end %>
adjustCalendarHeaders()

# If changing the visit using the chevrons, open the new visit
# else re-focus the visit for tabbing
<% if params[:change_visit].present? %>
$.ajax
  method:   'GET'
  dataType: 'script'
  url:      "<%= edit_visit_group_path(params[:change_visit] == 'next' ? @visit_group.lower_item : @visit_group.higher_item, srid: @service_request.try(:id), ssrid: @sub_service_request.try(:id), tab: @tab, page: @page, pages: @pages) %>"
<% else %>
$(".visit-group-<%= @visit_group.id %>").trigger('focus')
<% end %>

$("#flashContainer").replaceWith("<%= j render 'layouts/flash' %>")
$(document).trigger('ajax:complete') # rails-ujs element replacement bug fix
<% end %>
