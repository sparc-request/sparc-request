$(document).ready ->
  $(document).ajaxError (event, request, settings) ->
    if request.statusText != 'abort'
      alert("An error happened processing your request: " + settings.url)
