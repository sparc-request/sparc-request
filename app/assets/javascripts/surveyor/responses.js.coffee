# Copyright © 2011-2018 MUSC Foundation for Research Development~
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
#= require likert

$(document).ready ->
  $(document).on 'change', '.option input', ->
    question_id = $(this).parents('.option').data('question-id')
    option_id = $(this).parents('.option').data('option-id')

    $(".dependent-for-question-#{question_id}").addClass('hidden')
    
    if $(this).is(":checked")
      $(".dependent-for-option-#{option_id}").removeClass('hidden')
    else
      $(".dependent-for-option-#{option_id}").addClass('hidden')

  $(document).on 'change', '.question .selectpicker:not([multiple=multiple])', ->
    question_id = $(this).data('question-id')
    option_id = $(this).find('.option:checked').data('option-id')

    $(".dependent-for-question-#{question_id}").addClass('hidden')
    $(".dependent-for-option-#{option_id}").removeClass('hidden')

  $(document).on 'change', '.question .selectpicker[multiple=multiple]', ->
    question_id = $(this).data('question-id')
    option_ids = $(this).find('.option:checked').map( -> 
      $(this).data('option-id')).get()

    $(".dependent-for-question-#{question_id}").addClass('hidden')

    for option_id in option_ids
      $(".dependent-for-option-#{option_id}").removeClass('hidden')

  $(document).on 'click', '#save-filters', ->
    data = {} # Grab form values

    $.each $('form#filterrific_filter:visible').serializeArray(), (i, field) ->
      data[field.name] = field.value

    if data["filterrific[with_state][]"].length
      data["filterrific[with_state][]"] = $("#filterrific_with_state").val()

    if data["filterrific[with_survey][]"].length
      data["filterrific[with_survey][]"] = $(".form-group:not(.hidden) #filterrific_with_survey").val()

    $.ajax
      type: 'GET'
      url: '/surveyor/response_filters/new'
      data: data

  $(document).on 'change', '#filterrific_of_type', ->
    selected_value = $(this).find('option:selected').val()

    if selected_value == 'Form'
      $("#for-SystemSurvey").addClass('hidden')
      $("#for-SystemSurvey .selectpicker").selectpicker('deselectAll')
      $("#for-Form").removeClass('hidden')
    else
      $("#for-Form").addClass('hidden')
      $("#for-Form .selectpicker").selectpicker('deselectAll')
      $("#for-SystemSurvey").removeClass('hidden')

  $(document).on 'change', '#filterrific_with_state', ->
    selected = $(this).find('option:selected')

    if selected.length == 1
      selected_value = selected.val()

      $(".survey-select option:not([data-active='#{selected_value}'])").prop('disabled', true)
      $('.survey-select').selectpicker('refresh')
    else
      $('.survey-select option').prop('disabled', false)
      $('.survey-select').selectpicker('refresh')

  $('#responses-panel .export button').removeClass('dropdown-toggle').removeAttr('data-toggle')
  $('#responses-panel .export button .caret').remove()
  $('#responses-panel .export .dropdown-menu').remove()

  $(document).on 'click', '#responses-panel .export button', ->
    $(this).parent().removeClass('open')
    window.location = '/surveyor/responses.xlsx'
