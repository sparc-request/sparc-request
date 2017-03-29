# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~
$(document).ready ->
  ### Survey Table ###
  $(document).on 'click', '.edit-survey', ->
    survey_id = $(this).data('survey-id')

    $.ajax
      type: 'get'
      url: "/surveyor/surveys/#{survey_id}"

  $(document).on 'click', '.delete-survey', ->
    survey_id = $(this).data('survey-id')

    swal {
      title: I18n['swal']['swal_confirm']['title']
      text: I18n['swal']['swal_confirm']['text']
      type: 'warning'
      showCancelButton: true
      confirmButtonColor: '#DD6B55'
      confirmButtonText: 'Delete'
      closeOnConfirm: true
    }, ->
      $.ajax
        type: 'delete'
        url: "/surveyor/surveys/#{survey_id}.js"

  $(document).on 'click', '.preview-survey', ->
    survey_id = $(this).data('survey-id')

    $.ajax
      type: 'get'
      url: "/surveyor/surveys/#{survey_id}/preview.js"

  ### Survey Form ###
  options = {
    text: 'text', email: 'text', zipcode: 'text', time: 'time', phone: 'text',
    textarea: 'textarea', yes_no: 'yes_no', state: 'dropdown', country: 'dropdown',
    date: 'date', number: 'number'
  }

  $(document).on 'change', '.select-question-type', ->
    send_update_request($(this), $(this).val())

    question_id = $(this).data('question-id')

    if options[$(this).val()]
      option_type = options[$(this).val()].replace('_', '-')
      $(".question-options[data-question-id=#{question_id}]").addClass('hidden')
      $(".question-options.#{option_type}-options[data-question-id=#{question_id}]").removeClass('hidden')
    else
      $(".question-options[data-question-id=#{question_id}]").addClass('hidden')
      $(".question-options.customize-options[data-question-id=#{question_id}]").removeClass('hidden')

  $(document).on 'change', '.select-depender', ->
    send_update_request($(this), $(this).val())

  $(document).on 'focusout', '#survey-modal input[type="text"], #survey-modal textarea', ->
    send_update_request($(this), $(this).val())

  $(document).on 'change', '#survey-modal input[type="checkbox"]', ->
    send_update_request($(this), $(this).prop('checked'))

  $(document).on 'change', '.is-dependent', ->
    question = $(this).parents('.question')
    container = $(question).find('.dependent-dropdown-container')

    if $(container).hasClass('hidden')
      $(container).removeClass('hidden')
    else
      $(container).addClass('hidden')

  $(document).on 'click', '.add-option, .delete-option', ->
    survey_id = $(this).parents('.survey').data('survey-id')
    build_dependents_selectpicker(survey_id)

send_update_request = (obj, val) ->
  field_data  = $(obj).attr('id').split('-')
  klass       = field_data[0]
  attribute   = field_data[1]
  id          = $(obj).parents(".#{klass}").data("#{klass}-id")

  $.ajax
    type: 'put'
    url: "/surveyor/survey_updater/#{id}.js"
    data:
      klass: klass
      "#{klass}":
        "#{attribute}": val

build_dependents_selectpicker = (survey_id) ->
  $.ajax
    type: 'get'
    url: "/surveyor/surveys/#{survey_id}/update_dependents_list"
    success: (data) ->
      $.each data, (question_id, dropdown) ->

        question = $(".question-#{question_id}")
        select = $(question).find('select.select-depender')
        $(select).html(dropdown)
        $(select).selectpicker('refresh')

      return false
