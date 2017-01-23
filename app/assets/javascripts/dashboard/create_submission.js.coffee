$ ->
  $('#submissionModal').on 'shown.bs.modal', ->
    $('.selectpicker').selectpicker()
    $('#datetimepicker').datetimepicker()
    $('.create-submission').on 'click', ->
      $('.form-group').removeClass('has-error')
      $('span.help-block').remove()
      values = {}
      $.each $('.new_submission').serializeArray(), (i, field) ->
        values[field.name] = field.value
      unless values["submission[questionnaire_responses_attributes][0][content][]"] == undefined
        if values["submission[questionnaire_responses_attributes][0][content][]"].length
          values["submission[questionnaire_responses_attributes][0][content][]"] = $('#submission_questionnaire_responses_attributes_0_content').val()
      serviceId = values["submission[service_id]"]
      $.ajax
        url: "/services/#{serviceId}/additional_details/submissions"
        type: 'POST'
        data: values

