  # Copyright © 2011-2019 MUSC Foundation for Research Development~
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
  $('#responsesList .export button').addClass('no-caret').siblings('.dropdown-menu').addClass('d-none')

  $(document).on 'click', '#responsesList .export button', ->
    url = new URL($('#responsesTable').data('url'), window.location.origin)
    url.pathname = url.pathname.replace('json', 'xlsx')
    window.location = url


  $(document).on 'click', '.likert-group:not(.disabled) .likert-option', ->
    $(this).find('input').prop('checked', true)

  $(document).on 'change', '.option input', ->
    if $(this).prop('type') == 'checkbox' || $(this).prop('type') == 'radio'
      question_id = $(this).parents('.option').data('question-id')
      option_id = $(this).parents('.option').data('option-id')

      if $(this).prop('type') == 'radio'
        $(".dependent-for-question-#{question_id}").addClass('d-none')

      if $(this).is(":checked")
        $(".dependent-for-option-#{option_id}").removeClass('d-none')
      else
        $(".dependent-for-option-#{option_id}").addClass('d-none')

  $(document).on 'change', '.question .selectpicker:not([multiple=multiple])', ->
    question_id = $(this).data('question-id')
    option_id = $(this).find('.option:checked').data('option-id')

    $(".dependent-for-question-#{question_id}").addClass('d-none')
    $(".dependent-for-option-#{option_id}").removeClass('d-none')

  $(document).on 'change', '.question .selectpicker[multiple=multiple]', ->
    question_id = $(this).data('question-id')
    option_ids = $(this).find('.option:checked').map( ->
      $(this).data('option-id')).get()

    $(".dependent-for-question-#{question_id}").addClass('d-none')

    for option_id in option_ids
      $(".dependent-for-option-#{option_id}").removeClass('d-none')

#######################
# Filterrific Filters #
#######################

  $(document).on 'click', '#saveResponseFilters', ->
    data = {} # Grab form values

    $.each $('form#filterrific_filter:visible').serializeArray(), (i, field) ->
      data[field.name] = field.value

    if data["filterrific[with_state][]"].length
      data["filterrific[with_state][]"] = $("#filterrific_with_state").val()

    if data["filterrific[with_survey][]"].length
      data["filterrific[with_survey][]"] = $(".form-group:not(.d-none) #filterrific_with_survey").val()

    $.ajax
      type: 'GET'
      url: '/surveyor/response_filters/new'
      data: data

  $(document).on 'change', '#filterrific_of_type', ->
    selected_value = $(this).find('option:selected').val()

    if selected_value == 'Form'
      $("#for-SystemSurvey").addClass('d-none')
      $("#for-SystemSurvey .selectpicker").selectpicker('deselectAll')
      $("#for-Form").removeClass('d-none')
    else
      $("#for-Form").addClass('d-none')
      $("#for-Form .selectpicker").selectpicker('deselectAll')
      $("#for-SystemSurvey").removeClass('d-none')

  $(document).on 'change', '#filterrific_with_state', ->
    selected = $(this).find('option:selected')

    if selected.length == 1
      selected_value = selected.val()

      $(".survey-select option:not([data-active='#{selected_value}'])").prop('disabled', true)
      $('.survey-select').selectpicker('refresh')
    else
      $('.survey-select option').prop('disabled', false)
      $('.survey-select').selectpicker('refresh')

  if $('#responseStartDatePicker').length && $('#responseEndDatePicker').length
    startDate = $('#responseStartDatePicker').data().date
    endDate   = $('#responseEndDatePicker').data().date

    if startDate
      $('#responseEndDatePicker').datetimepicker('minDate', startDate)
      if !endDate
        $('#filterrific_end_date').val('')

    $('#responseStartDatePicker').on 'hide.datetimepicker', ->
      startDate = $('#filterrific_start_date').val()
      endDate   = $('#filterrific_end_date').val()

      if startDate
        $('#responseEndDatePicker').datetimepicker('minDate', startDate)
        $('#filterrific_end_date').focus()
        if !endDate
          $('#filterrific_end_date').val(startDate).blur().focus()
      else
        $('#responseEndDatePicker').datetimepicker('minDate', false)

    $(document).on 'click', '#filterrific_end_date', ->
      if (startDate = $('#filterrific_start_date').val()) && !$(this).val()
        $(this).val(startDate).blur().focus()

