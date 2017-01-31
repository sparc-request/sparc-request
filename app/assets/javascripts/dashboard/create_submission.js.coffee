$ ->
  $('#submissionModal').on 'shown.bs.modal', ->
    $('.selectpicker').selectpicker()
    $('#datetimepicker').datetimepicker()
    $('.create-submission').on 'click', ->
      $('.form-group').removeClass('has-error')
      $('span.help-block').remove()
      rawFormValues = $('.new_submission').serializeArray()
      # rawFormValues is an array of [name, value] pairs from the form.
      # Values from a multiselect share the same input name.
      # Rails always passes a "" value with options selected from a multiselect.
      # We only want this empty value when the user does not select anything
      # from the multiselect. So processedFormValues is rawFormValues without
      # these extra blank options.
      processedFormValues = (i for i in rawFormValues when i.value != "" or (j for j in rawFormValues when j.name == i.name and j.value != "").length == 0)
      serviceId = (i.value for i in rawFormValues when i.name == "submission[service_id]")[0]

      $.ajax
        url: "/services/#{serviceId}/additional_details/submissions"
        type: 'POST'
        data: processedFormValues
