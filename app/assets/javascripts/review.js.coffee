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
        survey_offered = true
        $(this).dialog("close")
        service_request_id = $('#service_request_id').val()
        $('#content').load "/surveys/system-satisfaction-survey", {survey_version: 0}, ->
          $('#survey_form').append("<input type='hidden' id='redirect_to' name='redirect_to' value='/service_requests/#{service_request_id}/confirmation'>")

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
