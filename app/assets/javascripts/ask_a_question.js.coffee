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

$(document).ready ->

  $('.ask-a-question-button').live 'click', ->
    $("#ask-a-question-form").dialog( "open" )

  $("#ask-a-question-form").dialog
    autoOpen: false
    height: 425
    width: 500
    modal: true
    buttons: [
      {
        id: "submit_question"
        text: "Submit"
        click: ->
          send_question()
      },
      {
        id: "cancel_question"
        text: "Cancel"
        click: ->
          $(this).dialog('close')
      }]
    close: ->
        $(this).clearForm()

  $("#ask-a-question-form form").submit (event)->
    send_question()
    event.preventDefault()
    return false

send_question = ->
  email_input = $('#quick_question_email').val()
  email_regex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/i

  if (email_input == "") || (!email_regex.test(email_input))
    $('.quick_question_email_error').show()
  else
    $('.quick_question_email_error').hide()
    data =
      'quick_question':
        'body': $("#quick_question_body").val()
        'email': $("#quick_question_email").val()
    $.ajax
      type: 'POST'
      url: "/service_requests/ask_a_question"
      data: JSON.stringify(data)
      dataType: "script"
      contentType: 'application/json; charset=utf-8'
      success: ->
        $('#ask-a-question-form').dialog 'close'

