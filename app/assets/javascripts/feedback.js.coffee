$(document).ready ->

  $('#errors').hide()

  $('.feedback-button').live 'click', ->
    $("#feedback-form").dialog( "open" )

  $("#feedback-form").dialog
    autoOpen: false
    height: 425
    width: 500
    modal: true
    buttons: [
      {
        id: "submit_feedback"
        text: "Submit"
        click: ->
          $("#feedback-form").submit()
      },
      {
        id: "cancel_feedback"
        text: "Cancel"
        click: ->
          $(this).dialog('close')
      }]
    close: ->
        $(this).clearForm()

  $("#feedback-form").submit ->
    data =
      'feedback':
        'message': $("#feedback_message").val()
        'email': $("#feedback_email").val()
    $.ajax
      type: 'POST'
      url: "/service_requests/feedback"
      data: JSON.stringify(data)
      dataType: "script"
      contentType: 'application/json; charset=utf-8'
      success: ->
        $('#errors').hide()
        $('#feedback-form').dialog 'close'
      error: (event) ->
        $('#errors').show()
        $('#error-text').html("Message can't be blank")
  
