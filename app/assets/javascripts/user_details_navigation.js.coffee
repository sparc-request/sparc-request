$ ->
  $(document).on 'click', 'a.continue_button', ->
    $('.continue-spinner').show()
    $('form').submit()