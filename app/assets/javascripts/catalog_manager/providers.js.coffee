$(document).ready ->
  $('input.edit_historical_data_checkbox').live('change', ->
    if $(this).attr('checked')
      $(this).val('true')
    else
      $(this).val('false')
  )