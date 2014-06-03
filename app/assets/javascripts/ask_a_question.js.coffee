$(document).ready ->

  $('.ask-a-question-button').live 'click', ->
    $("#ask-a-question-form").dialog( "open" )

  $("#ask-a-question-form").dialog
    autoOpen: false
    height: 425
    width: 500
    modal: true
    buttons: [
      {
        id: "submit_question"
        text: "Submit"
        click: ->
          send_question()
      },
      {
        id: "cancel_question"
        text: "Cancel"
        click: ->
          $(this).dialog('close')
      }]
    close: ->
        $(this).clearForm()

  $("#ask-a-question-form form").submit (event)->
    send_question()
    event.preventDefault()
    return false

send_question = ->
  email_input = $('#quick_question_email').val()
  email_regex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/i

  if (email_input == "") || (!email_regex.test(email_input))
    $('.quick_question_email_error').show()
  else
    $('.quick_question_email_error').hide()
    data =
      'quick_question':
        'body': $("#quick_question_body").val()
        'email': $("#quick_question_email").val()
    $.ajax
      type: 'POST'
      url: "/service_requests/ask_a_question"
      data: JSON.stringify(data)
      dataType: "script"
      contentType: 'application/json; charset=utf-8'
      success: ->
        $('#ask-a-question-form').dialog 'close'

