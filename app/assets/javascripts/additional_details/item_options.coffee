$ ->
  needOptions = ['radio_button', 'checkbox', 'dropdown', 'multiple_dropdown']

  showOptions = (selection, array) ->
    $.inArray(selection, array) > -1

  $('.select-type').on 'change', ->
    itemId = $(this).data('item-form-id')
    if showOptions($(this).val(), needOptions)
      $(".item-options[data-item-form-id=#{itemId}]").removeClass('hidden')
    else
      $(".item-options[data-item-form-id=#{itemId}]").addClass('hidden')

  $(document).on 'fields_added.nested_form_fields', (event, param) ->
    $('.select-type').on 'change', ->
      itemId = $(this).data('item-form-id')
      if showOptions($(this).val(), needOptions)
        $(".item-options[data-item-form-id=#{itemId}]").removeClass('hidden')
      else
        $(".item-options[data-item-form-id=#{itemId}]").addClass('hidden')


  $.each $('.select-type :selected'), (key, value) ->
    itemFormId = $(value).parent().data('item-form-id')
    if showOptions($(value).val(), needOptions)
      $(".item-options[data-item-form-id=#{itemFormId}]").removeClass('hidden')

  $('#datetimepicker').datetimepicker()

  $('.selectpicker').selectpicker()

