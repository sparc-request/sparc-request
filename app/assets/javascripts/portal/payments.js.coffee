$ ->
  $('#payments_list').on 'nested:fieldAdded:uploads', (event) ->
    event.field.find('input[type=file]').click()