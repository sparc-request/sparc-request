$ ->
  needOptions = ['radio_button', 'checkbox', 'dropdown', 'multiple_dropdown']

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
