$ ->
  $('#payments_list').on 'nested:fieldAdded:uploads', (event) ->
    event.field.find('input[type=file]').click()

  $('#payments_list .remove_nested_fields.payments').qtip
    content:
      text: "Remove this payment"
    position:
        corner:
          target: "topMiddle"
          tooltip: "bottomMiddle"

  $('#payments_list .remove_nested_fields.uploads').qtip
    content:
      text: "Remove this document"
    position:
      corner:
        target: "topMiddle"
        tooltip: "bottomMiddle"

