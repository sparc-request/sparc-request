$ ->
  $('.select-type').on 'change', ->
    itemId = $(this).data('item-form-id')
    if $(this).val() == 'radio_button'
      $(".item-options[data-item-form-id=#{itemId}]").removeClass('hidden')
    else if $(this).val() == 'checkbox'
      $(".item-options[data-item-form-id=#{itemId}]").removeClass('hidden')
    else if $(this).val() == 'dropdown'
      $(".item-options[data-item-form-id=#{itemId}]").removeClass('hidden')
    else if $(this).val() == 'multiple_dropdown'
      $(".item-options[data-item-form-id=#{itemId}]").removeClass('hidden')
    else
      $(".item-options[data-item-form-id=#{itemId}]").addClass('hidden')


