$ ->
  $('#submissionModal').on 'shown.bs.modal', ->
    $('.create-submission').on 'click', ->
      $('.form-group').removeClass('has-error')
      $('span.help-block').remove()
      values = {}
      $.each $('.new_submission').serializeArray(), (i, field) ->
        values[field.name] = field.value
      serviceId = values["submission[service_id]"]
      $.ajax
        url: "/services/#{serviceId}/additional_details/submissions"
        type: 'POST'
        data: values

