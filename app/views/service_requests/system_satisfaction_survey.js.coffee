# Copyright © 2011-2022 MUSC Foundation for Research Development
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

ConfirmSwal.fire(
  type:   'question'
  title:  I18n.t('proper.survey.header')
  text:   I18n.t('proper.survey.participate')
  confirmButtonText: I18n.t('constants.yes_select')
  cancelButtonText: I18n.t('constants.no_select')
).then (result) ->
  $('#submitRequest').removeClass('disabled')
  if result.value
    $.ajax
      method: 'get'
      dataType: 'script'
      url: '/surveyor/responses/new'
      data:
        respondable_id:   "<%= @service_request.id %>"
        respondable_type: "<%= ServiceRequest.name %>"
        survey_id:        "<%= @survey.id %>"
        type:             "<%= SystemSurvey.name %>"
      success: ->
        $(document).one 'hidden.bs.modal', ->
          # When previously subbmited show the SSRs resubmission modal
          <% if @service_request.has_ssrs_for_resubmission? && @forward.include?('confirmation') %>
          $.ajax
            method: 'get'
            dataType: 'script'
            url: "<%= confirmation_service_request_path(srid: @service_request.id) %>"
          <% else %>
          window.location = "<%= @forward %>"
          <% end %>
  else
    # When previously submited show the SSRs resubmission modal
    <% if @service_request.has_ssrs_for_resubmission? && @forward.include?('confirmation') %>
    $.ajax
      method: 'get'
      dataType: 'script'
      url: "<%= confirmation_service_request_path(srid: @service_request.id) %>"
    <% else %>
    window.location = "<%= @forward %>"
    <% end %>
