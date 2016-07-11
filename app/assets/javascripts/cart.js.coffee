# Copyright © 2011 MUSC Foundation for Research Development
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

addService = (srid, id) ->
  $.ajax
    type: 'POST'
    url: "/service_requests/#{srid}/add_service/#{id}"

removeService = (srid, id, move_on) ->
  $.ajax
    type: 'POST'
    url: "/service_requests/#{srid}/remove_service/#{id}"
    success: (data, textStatus, jqXHR) ->
      if move_on
        window.location = '/dashboard'

requestSubmittedDialog = (srid, id) ->
  options = {
    resizable: false,
    height: 220,
    modal: true,
    autoOpen: false,
    buttons:
      "Yes": ->
        $("#services .line-items").remove()
        $("#services").append('<span class="spinner"><img src="/assets/spinner.gif"/></span>')
        removeService(srid, id, false)
        $(this).dialog("close")
      "No": ->
        $(this).dialog("close")
  }
  $('#request_submitted_dialog').dialog(options).dialog("open").prev('.ui-dialog-titlebar').css('background', 'red')

$(document).ready ->

  $(document).on 'click', '.add-service', ->
    id = $(this).data('id')
    srid = $(this).data('srid')
    from_portal = $(this).data('from-portal')
    li_count = parseInt($('#line_item_count').val())

    if from_portal == 0 && li_count == 0
      options = {
        resizable: false,
        height: 220,
        modal: true,
        autoOpen: false,
        buttons:
          "Yes": ->
            addService(srid, id)
            $(this).dialog("close")
          "No": ->
            window.location = "/dashboard"
            $(this).dialog("close")
      }
      $('#new-request-dialog').dialog(options).dialog("open")
    else
      addService(srid, id)

  $(document).on 'click', '.remove-button', ->
    id = $(this).data('id')
    srid = $(this).data('srid')
    ssrid = $(this).data('ssrid')
    li_count = parseInt($('#line_item_count').val())
    has_fulfillments = $(this).data('has-fulfillments')
    request_submitted = $(this).data('request-submitted')

    if has_fulfillments == 1
      alert(I18n['proper']['catalog']['cart']['has_fulfillments'])
    else if request_submitted == 1
      requestSubmittedDialog(srid, id)
    else
      if li_count == 1 and ssrid != ''
        if confirm(I18n['proper']['catalog']['cart']['remove_request_confirm'])
          $("#services .line-items").remove()
          $("#services").append('<span class="spinner"><img src="/assets/spinner.gif"/></span>')
          $(this).hide()
          removeService(srid, id, true)
      else
        $("#services .line-items").remove()
        $("#services").append('<span class="spinner"><img src="/assets/spinner.gif"/></span>')
        $(this).hide()
        removeService(srid, id, false)
