$ ->
  $('#submissionModal').on 'shown.bs.modal', ->
    $('.selectpicker').selectpicker()
    $('#datetimepicker').datetimepicker()
    $('.create-submission').on 'click', ->
      $('.form-group').removeClass('has-error')
      $('span.help-block').remove()
      rawFormValues = $('.new_submission').serializeArray()
      processedFormValues = (i for i in rawFormValues when i.value != "" or (j for j in rawFormValues when j.name == i.name and j.value != "").length == 0)
      serviceId = (i.value for i in rawFormValues when i.name == "submission[service_id]")[0]
      $.ajax
        url: "/services/#{serviceId}/additional_details/submissions"
        type: 'POST'
        data: processedFormValues
