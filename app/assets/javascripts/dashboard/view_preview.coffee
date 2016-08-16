$ ->
  $('#view-preview').on 'click', ->
    values = {}
    $.each $('#new_questionnaire').serializeArray(), (i, field) ->
      values[field.name] = field.value
    serviceId = $('#service_id').val()
    $.ajax
      type: 'GET'
      url: "/services/#{serviceId}/questionnaire/preview"
      data: values
      error: (error) ->
        sweetAlert("Error", "Nothing to Preview", "error")
