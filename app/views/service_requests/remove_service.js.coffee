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
unless window.confirmedSSRs?
  window.confirmedSSRs = []

<% if @confirm_previously_submitted %>
if !window.confirmedSSRs.includes(<%= @remove_service.sub_service_request.id %>)
  ConfirmSwal.fire(
    title: I18n.t('proper.cart.request_submitted.header')
    html: I18n.t('proper.cart.request_submitted.warning', protocol_type: "<%= 'Study' %>")
  ).then (result) ->
    if result.value
      window.confirmedSSRs.push(<%= @remove_service.sub_service_request.id %>)
      $.ajax
        type: 'delete'
        dataType: 'script'
        url: '/service_request/remove_service'
        data:
          srid: getSRId()
          line_item_id: "<%= params[:line_item_id] %>"
          confirmed: "true"
else
  $.ajax
    type: 'delete'
    dataType: 'script'
    url: '/service_request/remove_service'
    data:
      srid: getSRId()
      line_item_id: "<%= params[:line_item_id] %>"
      confirmed: "true"
<% elsif @confirm_last_service %>
ConfirmSwal.fire(
  title: I18n.t('proper.cart.last_service.header')
  text: I18n.t('proper.cart.last_service.warning')
  confirmButtonText: I18n.t('proper.cart.last_service.confirm')
  cancelButtonText: I18n.t('proper.cart.last_service.cancel')
).then (result) ->
  if result.value
    $.ajax
      type: 'delete'
      dataType: 'script'
      url: '/service_request/remove_service'
      data:
        srid: getSRId()
        line_item_id: "<%= params[:line_item_id] %>"
        confirmed: "true"
<% elsif @service_request.line_items.empty? && @page != 'catalog' %>
window.location = "<%= catalog_service_request_path(srid: @service_request.id) %>"
<% else %>

$('#stepsNav').replaceWith("<%= j render 'service_requests/navigation/steps' %>")
$('#cart').replaceWith("<%= j render 'service_requests/cart/cart', service_request: @service_request %>")

<% if request.referrer.split('/').last == 'protocol' %>
$('.service-list').html("<%= j render 'service_requests/protocol/service_list', service_request: @service_request %>")
<% end %>

$("#flashContainer").replaceWith("<%= j render 'layouts/flash' %>")

$(document).trigger('ajax:complete') # rails-ujs element replacement bug fix
<% end %>
