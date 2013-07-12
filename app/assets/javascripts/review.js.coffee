#= require navigation

$(document).ready ->
  survey_offered = false
  $('#participate_in_survey').dialog
    resizable: false,
    height: 140,
    modal: true,
    autoOpen: false,
    buttons:
      "Yes": ->
        $('#processing_request').show()
        survey_offered = true
        $(this).dialog("close")
        service_request_id = $('#service_request_id').val()
        $('#participate_in_survey').load "/surveys/system-satisfaction-survey", {survey_version: ""}, ->
          $('#survey_form').append("<input type='hidden' id='redirect_to' name='redirect_to' value='/service_requests/#{service_request_id}/confirmation'>")
          $('#surveyor').dialog
            position: 
              my: "left top"
              at: "left bottom"
              of: $('#sparc_logo_header')
            autoOpen: false
            modal: true
            width: 920
            title: 'SPARC Request Satisfaction Survey'
            closeOnEscape: false
            open: -> $('.grid_12').hide()

          $('#surveyor').dialog('open')
          $('#processing_request').hide()

        $('#welcome_msg').hide()
        $('#feedback').hide()
        $('.ask-a-question').hide()
      "No": -> 
        survey_offered = true
        $(this).dialog("close")
        $('#submit_services').click()

  $('#submit_services').click ->
    if survey_offered == false
      $("#participate_in_survey").dialog("open")
      return false
    else
      window.location.href = $(this).attr('href')
