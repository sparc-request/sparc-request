ajaxDefer = null

$(document).ready ->
  ajaxDefer = $.Deferred().resolve()

  $(document).ajaxStart ->
    ajaxDefer = $.Deferred()
  .ajaxStop -> 
    ajaxDefer.resolve()

  $('.submit-request-button').on 'click', (event) ->
    defer_until_complete event, 'click', '.submit-request-button'

  $('#navigation_form').on 'submit', (event) ->
    defer_until_complete event, 'submit', '#navigation_form'

defer_until_complete = (event, action, selector) ->
  if ajaxDefer.state() == "pending"
    ajaxDefer.always ->
      if action == 'click'
        $(selector).click()
      else
        $(selector).submit()
    event.preventDefault()

