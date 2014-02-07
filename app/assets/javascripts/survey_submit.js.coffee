$(document).ready ->

  $(document).on('click', ".next_section input[type='submit']", ->
    $('#survey_form').append("<input type='hidden' id='finish' name='finish' value='Submit'>")
    $(this).attr('disabled', true)
  )
