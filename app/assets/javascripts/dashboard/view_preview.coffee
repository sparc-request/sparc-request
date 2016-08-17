$ ->
  $('#view-preview').on 'click', ->
    values = {}
    $.each $('.questionnaire-form').serializeArray(), (i, field) ->
      matchId = /\[id\]/
      unless field.name.match(matchId) || field.name == '_method'
        values[field.name] = field.value
    serviceId = $('#service_id').val()
    $.ajax
      url: "/services/#{serviceId}/additional_details/questionnaire/preview"
      type: 'POST'
      data: values
      success: ->
        $('.selectpicker').selectpicker()
        $('#datetimepicker').datetimepicker()
      error: (error) ->
        sweetAlert("Error", "Nothing to Preview", "error")
