#= require navigation

$(document).ready ->
  survey_offered = false
  route_to = "" 
  $('#participate_in_survey').dialog
    resizable: false,
    height: 220,
    modal: true,
    autoOpen: false,
    buttons:
      "Yes": ->
        $('#processing_request').show()
        survey_offered = true
        $(this).dialog("close")
        service_request_id = $('#service_request_id').val()
        $('#participate_in_survey').load "/surveys/system-satisfaction-survey", {survey_version: ""}, ->
          $('#survey_form').append("<input type='hidden' id='redirect_to' name='redirect_to' value='#{route_to}'>")
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

          $('#surveyor').dialog('open')
          $('#processing_request').hide()

        $('#welcome_msg').hide()
        $('#feedback').hide()
        $('.ask-a-question').hide()
      "No": -> 
        survey_offered = true
        $(this).dialog("close")
        window.location.href = route_to

  $('#submit_services, #get_a_quote').click ->
    route_to = $(this).attr('href')

    if survey_offered == false
      proceed_to = "#submit_services"
      $("#participate_in_survey").dialog("open")
      return false
    else
      window.location.href = route_to
