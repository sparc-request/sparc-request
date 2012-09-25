$(document).ready ->
  $(document).ajaxError (event, request, settings) ->
      alert("An error happened processing your request: " + settings.url)
