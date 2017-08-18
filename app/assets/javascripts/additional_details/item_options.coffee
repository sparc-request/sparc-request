# Copyright © 2011-2017 MUSC Foundation for Research Development~
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

#= require 'likert'

$ ->
  needOptions = ['radio_button', 'checkbox', 'dropdown', 'multiple_dropdown', 'likert']

  showOptions = (selection, array) ->
    $.inArray(selection, array) > -1

  $(document).on 'change', '.select-type', ->
    itemId = $(this).data('item-form-id')
    if showOptions($(this).val(), needOptions)
      $(".item-options[data-item-form-id=#{itemId}]").removeClass('hidden')
      $.each $(".set-validate-content[data-item-form-id=#{itemId}]"), (key, value) ->
        $(value).val('true')
    else
      $(".item-options[data-item-form-id=#{itemId}]").addClass('hidden')
      $.each $(".set-validate-content[data-item-form-id=#{itemId}]"), (key, value) ->
        $(value).val('false')

  $(document).on 'fields_added.nested_form_fields', (event, param) ->
    $('.select-type').trigger('change')
    $('.select-type').on 'change', ->
      itemId = $(this).data('item-form-id')
      if showOptions($(this).val(), needOptions)
        $(".item-options[data-item-form-id=#{itemId}]").removeClass('hidden')
      else
        $(".item-options[data-item-form-id=#{itemId}]").addClass('hidden')

  $(document).on 'fields_removed.nested_form_fields', (event, param) ->
    $('.select-type').trigger('change')


  $.each $('.select-type :selected'), (key, value) ->
    itemFormId = $(value).parent().data('item-form-id')
    if showOptions($(value).val(), needOptions)
      $(".item-options[data-item-form-id=#{itemFormId}]").removeClass('hidden')


  $('#datetimepicker').datetimepicker()

  $('.selectpicker').selectpicker()

$('.questionnaires.create').ready ->
  $.each $('.option-content:visible'), (key, value) ->
    $(value).parents('.option-input').find('.set-validate-content').val('true')
