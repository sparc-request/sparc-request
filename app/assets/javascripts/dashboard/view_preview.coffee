$ ->
  $('#view-preview').on 'click', ->
    values = {}
    $.each $('.questionnaire-form').serializeArray(), (i, field) ->
      matchId = /\[id\]/
      unless field.name.match(matchId)
        values[field.name] = field.value
    serviceId = $('#service_id').val()
    $.ajax
      type: 'GET'
      url: "/services/#{serviceId}/questionnaire/preview"
      data: values
      error: (error) ->
        sweetAlert("Error", "Nothing to Preview", "error")
