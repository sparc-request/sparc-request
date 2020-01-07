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

<% if @errors %>
$("[name^='arm']:not([type='hidden'])").parents('.form-group').removeClass('is-invalid').addClass('is-valid')
$('.form-error').remove()

<% @errors.messages.each do |attr, messages| %>
<% messages.each do |message| %>
$("[name='arm[<%= attr.to_s %>]']").parents('.form-group').removeClass('is-valid').addClass('is-invalid').append("<small class='form-text form-error'><%= message.capitalize.html_safe %></small>")
<% end %>
<% end %>
<% else %>
if $('#serviceCalendar .one-time-fees-container:visible').length
  # Render the new arm before OTF services on Step 3
  $('#serviceCalendar .one-time-fees-container:visible').before("<%= j render '/service_calendars/master_calendar/pppv/pppv_calendar', tab: @tab, arm: @arm, service_request: @service_request, sub_service_request: @sub_service_request, page: @page, pages: @pages, merged: false, consolidated: false %>")
else
  # Render the new arm at the end of the list in the Admin Dashboard
  $('#serviceCalendar .tab-pane.active').append("<%= j render '/service_calendars/master_calendar/pppv/pppv_calendar', tab: @tab, arm: @arm, service_request: @service_request, sub_service_request: @sub_service_request, page: @page, pages: @pages, merged: false, consolidated: false %>")

# After creating a second arm, the first arm should be deletable
<% if @service_request.arms.length == 2 %>
<% first_arm = @service_request.arms.first %>
$(".arm-<%= first_arm.id %>-container .calendar-links-container").html("<%= j render 'arms/actions', service_request: @service_request, sub_service_request: @sub_service_request, arm: first_arm, tab: @tab, page: @pages[first_arm.id], pages: @pages %>")
<% end %>

adjustCalendarHeaders()

$("#modalContainer").modal('hide')
$("#flashContainer").replaceWith("<%= j render 'layouts/flash' %>")
<% end %>
