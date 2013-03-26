$(document).ready ->

  $('#feedback').live 'click', ->
    $("#feedback-form").dialog( "open" )


  $("#feedback-form").dialog
    autoOpen: false
    height: 425
    width: 500
    modal: true
    buttons:
      Submit: ->
        $(this).submit()
      Cancel: ->
        $(this).dialog "close"
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
        $('#feedback-form').dialog 'close'
      error: ->
        console.log 'test'