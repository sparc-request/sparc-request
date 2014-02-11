$(document).ready ->

  $(document).on('click', ".next_section input[type='submit']", (event)->
    event.preventDefault()
    $('#survey_form').append("<input type='hidden' id='finish' name='finish' value='Submit'>")
    $(this).attr('disabled', true)
    $('#survey_form').submit()
  )
