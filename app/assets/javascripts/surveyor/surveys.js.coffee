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
$(document).ready ->
  $("[data-toggle='tooltip']").tooltip()

  ### Survey Table ###
  $(document).on 'change', '.survey-actions', ->
    $selected = $(this).find('option:selected')
    $(this).selectpicker('deselectAll')

    if $selected.data('url')
      $.ajax
        type: $selected.data('method') || 'get'
        dataType: 'script'
        url: $selected.data('url')
    else if $selected.hasClass('delete-survey')
      survey_id = $selected.data('survey-id')
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
          dataType: 'script'
          url: "/surveyor/surveys/#{survey_id}"

  $(document).on 'load-success.bs.table', '.survey-table, .form-table', ->
    $('.selectpicker').selectpicker()

  ### Survey Modal ###
  $(document).on 'hide.bs.modal', '#modal_place', ->
    if $(this).children("#survey-modal").length > 0
      $('.survey-table').bootstrapTable('refresh')
    else if $(this).children("#form-modal").length > 0
      $('.form-table').bootstrapTable('refresh')

  $(document).on 'click', '.add-section', ->
    $.ajax
      type: 'post'
      url: '/surveyor/sections'
      data:
        survey_id: $('.survey').data('survey-id')
      success: ->
        build_dependents_selectpicker($('.survey').data('survey-id'))

  $(document).on 'click', '.delete-section', ->
    $.ajax
      type: 'delete'
      url: "/surveyor/sections/#{$(this).parents('.section').data('section-id')}"
      success: ->
        build_dependents_selectpicker($('.survey').data('survey-id'))

  $(document).on 'click', '.add-question', ->
    $.ajax
      type: 'post'
      url: '/surveyor/questions'
      data:
        section_id: $(this).parents('.section').data('section-id')
      success: ->
        build_dependents_selectpicker($('.survey').data('survey-id'))

  $(document).on 'click', '.delete-question', ->
    $.ajax
      type: 'delete'
      url: "/surveyor/questions/#{$(this).parents('.question').data('question-id')}"
      success: ->
        build_dependents_selectpicker($('.survey').data('survey-id'))

  $(document).on 'click', '.add-option', ->
    $.ajax
      type: 'post'
      url: '/surveyor/options'
      data:
        question_id: $(this).parents('.question').data('question-id')
      success: ->
        build_dependents_selectpicker($('.survey').data('survey-id'))

  $(document).on 'click', '.delete-option', ->
    $.ajax
      type: 'delete'
      url: "/surveyor/options/#{$(this).parents('.option').data('option-id')}"
      success: ->
        build_dependents_selectpicker($('.survey').data('survey-id'))

  $(document).on 'change', '.select-depender, .select-question-type', ->
    send_update_request($(this), $(this).val())

  $(document).on 'focusout', '#survey-modal input[type="text"], #form-modal input[type="text"]:not([id$="-surveyable"]), #survey-modal textarea, #form-modal textarea', ->
    send_update_request($(this), $(this).val())

  $(document).on 'change', '#survey-modal input[type="checkbox"], #form-modal input[type="checkbox"]', ->
    send_update_request($(this), $(this).prop('checked'))

  $(document).on 'change', '.is-dependent', ->
    question = $(this).parents('.question')
    container = $(question).find('.dependent-dropdown-container')

    if $(container).hasClass('hidden')
      $(container).removeClass('hidden')
    else
      $(container).addClass('hidden')

send_update_request = (obj, val) ->
  field_data  = $(obj).attr('id').split('-')
  klass       = field_data[0]
  id          = field_data[1]
  attribute   = field_data[2]

  $.ajax
    type: 'put'
    url: "/surveyor/survey_updater/#{id}.js"
    data:
      klass: klass
      "#{klass}":
        "#{attribute}": val
    success: ->
      if attribute == 'question_type' || attribute == 'content'
        build_dependents_selectpicker($('.survey').data('survey-id'))

build_dependents_selectpicker = (survey_id) ->
  $.ajax
    type: 'get'
    url: "/surveyor/surveys/#{survey_id}/update_dependents_list.js"
