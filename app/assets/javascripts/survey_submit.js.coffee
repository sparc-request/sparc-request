$(document).ready ->

  $(document).on('click', ".next_section input[type='submit']", ->
    $(this).attr('disabled', true).delay(1000).attr('disabled', false)
  )