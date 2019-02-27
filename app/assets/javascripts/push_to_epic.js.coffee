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
$(document).ready ->
  $('#push-to-epic-status').text(I18n['proper']['confirmation']['push_to_epic']['message'])
  get_epic_push_status()

get_epic_push_status = () ->
  protocol_id = $('#push-to-epic-status').data('protocol-id')
  
  $.ajax
    method: 'GET'
    url: "/protocols/#{protocol_id}/push_to_epic_status.json"
    contentType: 'application/json; charset=utf-8'
    success: (data, text, request) ->
      status = data['last_epic_push_status']
      if status == 'started' || status == 'sent_study'
        window.setTimeout(get_epic_push_status, 5000)
      else
        status_text = data['last_epic_push_status_text']

        if status_text == null
          $('#push-to-epic-status').text('')
        else
          $('#push-to-epic-status').text(data['last_epic_push_status_text'])
    error:
      $('push-to-epic-status').text(I18n['proper']['confirmation']['push_to_epic']['failed'])