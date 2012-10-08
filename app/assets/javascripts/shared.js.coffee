$(document).ready ->
  $(document).ajaxError (event, request, settings) ->
    if request.statusText != 'abort'
      alert("An error happened processing your request: " + settings.url)

  $('.add-user button').live 'click', ->
    $.ajax
      url: '/identities/add_to_protocol'
      type: 'POST'
      data: $('#identity_details :input').serialize()
    return false
