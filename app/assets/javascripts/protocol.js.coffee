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

#= require cart
#= require navigation

$(document).ready ->
  $("input[name=protocol]:radio").change ->
    if $(this).val() == 'Research Study'
      $('.existing-study').show()
      $('.edit-study').show() unless $('.edit_study_id').val() == ""
      $('.existing-project').hide()
      $('#study-select #service_request_protocol_id').removeAttr('disabled')
      $('#project-select #service_request_protocol_id').attr('disabled', 'disabled')
    else
      $('.existing-project').show()
      $('.edit-project').show() unless $('.edit_project_id').val() == ""
      $('.existing-study').hide()
      $('#project-select #service_request_protocol_id').removeAttr('disabled')
      $('#study-select #service_request_protocol_id').attr('disabled', 'disabled')

  $("input[name=protocol]:radio:checked").change()

  $('.edit-study').hide() unless $('.edit_study_id').val() != ""
  $('.edit-project').hide() unless $('.edit_project_id').val() != ""

  $('.edit_study_id').change ->
    if ($(this).val() == "")
      $('.edit-study').hide()
    else
      $('.edit-study').show()

  $('.edit_project_id').change ->
    if ($(this).val() == "")
      $('.edit-project').hide()
    else
      $('.edit-project').show()

  $('.edit-study').click ->
    study_id = $('.edit_study_id').val()
    service_request_id = $('#service_request_id').val()
    window.location.href = "/service_requests/#{service_request_id}/studies/#{study_id}/edit"
    return false

  $('.edit-project').click ->
    project_id = $('.edit_project_id').val()
    service_request_id = $('#service_request_id').val()
    window.location.href = "/service_requests/#{service_request_id}/projects/#{project_id}/edit"
    return false

  $('#infotip').qtip
    content: 'Research Study: An individual research study with defined aims and outcomes'
    position:
      corner:
        target: "topRight"
        tooltip: "bottomLeft"
        
    style:
      tip: true
      border:
        width: 0
        radius: 4

      name: "light"
      width: 250

  $('#ctrc_dialog').dialog
    modal: true
    width: 375
    height: 200

  $('#redirect').button()