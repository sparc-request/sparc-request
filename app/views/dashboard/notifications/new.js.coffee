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
<% if @errors.present? %> #Sending notification to self
$('#modal_errors').html("<%= j render 'shared/modal_errors', errors: @errors %>')
$('#user_search').val('')
$('#loading_recipient_spinner').hide()
<% else %>
<% if @message.present? %> #User has been selected
$("#modal_place").html("<%= escape_javascript(render(partial: 'dashboard/notifications/new_notification', locals: { notification: @notification, message: @message, sub_service_request_id: @sub_service_request_id })) %>");
<% else %> #No user selected
$("#modal_place").html("<%= escape_javascript(render(partial: 'dashboard/notifications/select_user_form', locals: { sub_service_request_id: @sub_service_request_id })) %>");

# Initialize Authorized Users Searcher
identities_bloodhound = new Bloodhound(
  datumTokenizer: (datum) ->
    Bloodhound.tokenizers.whitespace datum.value
  queryTokenizer: Bloodhound.tokenizers.whitespace
  remote:
    url: '/dashboard/associated_users/search_identities?term=%QUERY',
    wildcard: '%QUERY'
)
identities_bloodhound.initialize() # Initialize the Bloodhound suggestion engine
$('#user_search').typeahead(
  # Instantiate the Typeahead UI
  {
    minLength: 3,
    hint: false,
    highlight: true
  },
  {
    displayKey: 'label'
    source: identities_bloodhound.ttAdapter()
    limit: 100000
  }
)
.on 'typeahead:select', (event, suggestion) ->
  $("#loading_recipient_spinner").removeClass('hidden')
  $.ajax
    type: 'get'
    url: '/dashboard/notifications/new.js'
    data:
      identity_id: suggestion.value

<% end %>
<% end %>
$(".selectpicker").selectpicker()
$("#modal_place").modal 'show'
