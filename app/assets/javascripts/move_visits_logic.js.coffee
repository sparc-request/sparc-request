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

$(document).ready ->
  $('.move-visits-form').dialog
    autoOpen: true
    height: 275
    width: 300
    modal: true
    resizable: false
    open: (event, ui) ->
      $('.ui-dialog-titlebar-close', ui.dialog | ui).hide()
    buttons: [
      {
        id: 'submit_move'
        text: 'Submit'
        click: ->
          $('#submit_move').attr('disabled', 'true')
          $('#cancel_move').attr('disabled', 'true')
          submit_visit_form($(this))
      },
      {
        id: 'cancel_move'
        text: 'Cancel'
        click: ->
          $(this).dialog('destroy').remove()
      }]

  submit_visit_form = (obj) ->
    sr_id = $(obj).data('service_request_id')
    arm_id = $(obj).data('arm_id')
    data =
      'arm_id': arm_id
      'tab': $(obj).data('tab')
      'service_request_id': sr_id
      'visit_to_move': $("#visit_to_move_#{arm_id}").val()
      'move_to_position': $("#move_to_position_#{arm_id}").val()
      'portal': $(obj).data('portal')
    $.ajax
      type: 'PUT'
      url: "/service_requests/#{sr_id}/service_calendars/move_visit_position"
      data: JSON.stringify(data)
      dataType: 'script'
      contentType: 'application/json; charset=utf-8'
      success: ->
        $(obj).dialog('destroy').remove()
      error: ->
        $(obj).dialog('destroy').remove()
        alert("Visit Failed to Move")
