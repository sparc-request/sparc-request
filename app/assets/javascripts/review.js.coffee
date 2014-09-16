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

#= require navigation

$(document).ready ->
  survey_offered = false
  route_to = "" 
  $('#participate_in_survey').dialog
    resizable: false,
    height: 220,
    modal: true,
    autoOpen: false,
    buttons:
      "Yes": ->
        $('#processing_request').show()
        survey_offered = true
        $(this).dialog("close")
        service_request_id = $('#service_request_id').val()
        $('#participate_in_survey').load "/surveys/system-satisfaction-survey", {survey_version: ""}, ->
          $('#survey_form').append("<input type='hidden' id='redirect_to' name='redirect_to' value='#{route_to}'>")
          $('#surveyor').dialog
            position: 
              my: "left top"
              at: "left bottom"
              of: $('#sparc_logo_header')
            autoOpen: false
            modal: true
            width: 980
            title: 'SPARC Request Satisfaction Survey'
            closeOnEscape: false

          $('#surveyor').dialog('open')
          $('#processing_request').hide()

        $('#welcome_msg').hide()
        $('#feedback').hide()
        $('.ask-a-question').hide()
      "No": -> 
        survey_offered = true
        $(this).dialog("close")
        $('#submit_services1, #submit_services2, #get_a_quote').unbind('click')
        $('#submit_services1, #submit_services2, #get_a_quote').click ->
          return false
        window.location.href = route_to

  $('#submit_services1, #submit_services2, #get_a_quote').click (event)->
    event.preventDefault()
    route_to = $(this).attr('href')

    if survey_offered == false
      $("#participate_in_survey").dialog("open")
      return false
    else
      # this should never be the case but just in case some browser allows it let's just redirect to confirmation page
      $(this).unbind('click')
      $(this).click ->
        return false
      window.location.href = route_to
