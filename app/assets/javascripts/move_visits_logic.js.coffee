$(document).ready ->
  $('.move-visits-form').dialog
    autoOpen: true
    height: 275
    width: 300
    modal: true
    resizable: false
    buttons: [
      {
        id: 'submit_move'
        text: 'Submit'
        click: ->
          submit_visit_form($(this))
          $(this).dialog('destroy').remove()
      },
      {
        id: 'cancel_move'
        text: 'Cancel'
        click: ->
          $(this).dialog('destroy').remove()
      }]

  submit_visit_form = (obj) ->
    sr_id = $("#service_request_id").val()
    arm_id = $(obj).data('arm_id')
    data =
      'arm_id': arm_id
      'tab': $(obj).data('tab')
      'service_request_id': sr_id
      'visit_to_move': $("#visit_to_move_#{arm_id}").val()
      'move_to_position': $("#move_to_position_#{arm_id}").val()
    $.ajax
      type: 'PUT'
      url: "/service_requests/#{sr_id}/service_calendars/move_visit_position"
      data: JSON.stringify(data)
      dataType: 'script'
      contentType: 'application/json; charset=utf-8'
      success: ->