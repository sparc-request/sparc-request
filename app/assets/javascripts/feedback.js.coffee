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

  $('#errors').hide()

  $('.feedback-button').live 'click', ->
    $("#feedback-form").dialog( "open" )

  $("#feedback-form").dialog
    autoOpen: false
    height: 425
    width: 500
    modal: true
    buttons: [
      {
        id: "submit_feedback"
        text: "Submit"
        click: ->
          $("#feedback-form").submit()
      },
      {
        id: "cancel_feedback"
        text: "Cancel"
        click: ->
          $(this).dialog('close')
      }]
    close: ->
        $(this).clearForm()

  $("#feedback-form").submit ->
    data =
      'feedback':
        'message': $("#feedback_message").val()
        'email': $("#feedback_email").val()
    $.ajax
      type: 'POST'
      url: "/service_requests/feedback"
      data: JSON.stringify(data)
      dataType: "script"
      contentType: 'application/json; charset=utf-8'
      success: ->
        $('#errors').hide()
        $('#feedback-form').dialog 'close'
      error: (event) ->
        $('#errors').show()
        $('#error-text').html(I18n["feedback"]["message_error"])
