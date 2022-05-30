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

# $('#modalContainer').html("<%= j render 'form', service_request: @service_request, sub_service_request: @sub_service_request, visit: @visit %>")
# $('#modalContainer').modal('show')

$visit    = $(".billing-strategy-visit.visit-<%= @visit.id %>")
$content  = $("<%= j render 'form', visit: @visit, arm: @arm, service_request: @service_request, sub_service_request: @sub_service_request, page: @page, pages: @pages %>")

# If a different visit popover is already open, close it first
if $('.visit-popover') && !$("form#edit_visit_<%= @visit.id %>").length
  $('.visit-popover').popover('hide')
  $('.visit.active').removeClass('active')

# If the visit is already ope
# else open the visit as a popover
if $(".visit-<%= @visit.id %>-popover").length
  # Close the popover if clicking the same visit to close it
  $visit.removeClass('active').popover('dispose')
else
  $visit.popover(
    content:    $content
    template:   '<div class="popover visit-popover visit-<%= @visit.id %>-popover" role="tooltip"><div class="arrow"></div><h3 class="popover-header"></h3><div class="popover-body"></div></div>'
    html:       true
    trigger:    'manual'
    placement:  'top'
  )

  # Logic for smoother closing of visit group popovers
  $visit.on 'shown.bs.popover', ->
    $(document).one 'hide.bs.popover', 'body', ->
      $visit.removeClass('active').trigger('focus')
  $visit.addClass('active').trigger('focus').popover('show')

$(document).trigger('ajax:complete') # rails-ujs element replacement bug fix

