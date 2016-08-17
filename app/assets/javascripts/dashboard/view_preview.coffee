$ ->
  $('#view-preview').on 'click', ->
    $('input[name=_method]').val('post')
    values = {}
    $.each $('.questionnaire-form').serializeArray(), (i, field) ->
      matchId = /\[id\]/
      unless field.name.match(matchId)
        values[field.name] = field.value
    serviceId = $('#service_id').val()
    $.ajax
      url: "/services/#{serviceId}/questionnaire/preview"
      type: 'POST'
      data: values
      success: ->
        $('.selectpicker').selectpicker()
        $('#datetimepicker').datetimepicker()
      error: (error) ->
        sweetAlert("Error", "Nothing to Preview", "error")
