$(document).ready ->

  $('.notification_dialog').dialog
    autoOpen: false
    title: 'Notification'
    width: 720
    height: 495
    modal: true
    buttons:
      "Submit": () ->
        disableSubmitButton("Submit", "Please wait...")
        $('.notification-dialog-form').bind('ajax:success', (data) ->
          enableSubmitButton("Please wait...", "Submit")
          $('.notification_dialog').dialog('close')
          $().toastmessage('showSuccessToast', "Message has been sent.");
        ).submit()
      "Cancel": () ->
        enableSubmitButton("Please wait...", "Submit")
        $(this).dialog('close')

  $(document).on('click', 'tr.notification_row td.notification_icon, td.from_column, td.subject_column, td.body_column, td.received_column', ->
    id = $(this).data('notification_id')
    sub_service_request_id = $(this).data('sub_service_request_id')
    # The following data hash assembly refuses to work on one line -_-
    data = {'sub_service_request_id': sub_service_request_id}
    data['notifications'] = {}
    data['notifications'][id] = true
    $.ajax
      type: 'PUT'
      url: "/portal/notifications/mark_as_read"
      data: JSON.stringify(data)
      dataType: "script"
      contentType: 'application/json; charset=utf8'

    $('.notification_dialog').dialog('open')
    if sub_service_request_id
      $.ajax({ type: 'GET', url: "/portal/notifications/#{id}?sub_service_request_id=#{sub_service_request_id}" })
    else
      $.ajax({ type: 'GET', url: "/portal/notifications/#{id}" })
  )

  $('.hidden-message').live('click', ->
    message_id = $(this).data('message_id')
    message_header = $(this).children('.message-header')
    $(this).removeClass('hidden-message').addClass('shown-message')
    message_header.children('.message_recipients').removeClass('hidden').addClass('shown')
    $(this).children('.truncated-message-body').addClass('shown-message-body').removeClass('truncated-message-body')
    $(this).children('.message-header').addClass('clickable-message-header')
    $(".gray_arrow_down_#{message_id}").hide()
    $(".white_arrow_up_#{message_id}").show()
  )

  $('.clickable-message-header').live('click', ->
    message = $(this).parent('.shown-message')
    message_id = message.data('message_id')
    message.children('message-header').removeClass('clickable-message-header')
    message.removeClass('shown-message').addClass('hidden-message')
    $(this).children('.message_recipients').removeClass('shown').addClass('hidden')
    message.children('.shown-message-body').addClass('truncated-message-body').removeClass('shown-message-body')
    $(".gray_arrow_down_#{message_id}").show()
    $(".white_arrow_up_#{message_id}").hide()
  )

  $('.new_notification_dialog').dialog({
    autoOpen: false
    title: 'Send notification'
    width: 700
    height: 300
    modal: true
    buttons: {
      "Submit": () ->
        disableSubmitButton("Submit", "Please wait...")
        $('.notification_notification_form').bind('ajax:success', (data) ->
          enableSubmitButton("Please wait...", "Submit")
          $('.new_notification_dialog').dialog('close')
        ).submit()
      "Cancel": () ->
        enableSubmitButton("Please wait...", "Submit")
        $(this).dialog('close')
    }
  })

  $(document).on('click', '.new_notification', ->
    sub_service_request_id = $(this).data('sub_service_request_id')
    identity_id = $(this).data('identity_id')
    $('.new_notification_dialog').dialog('open')
    $.ajax
      type: 'GET'
      url:  "/portal/notifications/new?sub_service_request_id=#{sub_service_request_id}&identity_id=#{identity_id}"
  )

  disableSubmitButton = (containing_text, change_to) ->
    button = $(".ui-dialog .ui-dialog-buttonpane button:contains(#{containing_text})")
    button.html("<span class='ui-button-text'>#{change_to}</span>")
      .attr('disabled',true)
      .addClass('button-disabled')

  enableSubmitButton = (containing_text, change_to) ->
    button = $(".ui-dialog .ui-dialog-buttonpane button:contains(#{containing_text})")
    button.html("<span class='ui-button-text'>#{change_to}</span>")
      .attr('disabled',false)
      .removeClass('button-disabled')
    button.attr('disabled',false)


  # Form functions

  $(document).on('click', '.new-portal-notification-button', ->
    ssr_id = $(this).attr('data-ssr_id')
    sr_id = $(this).attr('data-sr_id')
    if $(this).hasClass('active')
      $(this).removeClass('active')
    else
      $(this).addClass('active')

    $("#portal_notifications_#{ssr_id}_#{sr_id}").slideToggle()
  )

  $(document).on('click', '.select_all', ->
    $('td.mark_unread input').prop('checked', true)
  )

  $(document).on('click', '.deselect_all', ->
    $('td.mark_unread input').prop('checked', false)
  )

  $(document).on('click', '.read_unread_link', ->
    read = $(this).data('read')
    data = {}
    checkbox_tds = $('td.mark_unread')
    for checkbox_td in checkbox_tds
      if $(checkbox_td).children().first().is(':checked')
        data[$(checkbox_td).data('notification_id')] = read
    data = {notifications: data}
    data['sub_service_request_id'] = $(this).data('sub_service_request_id')
    $.ajax
      type: "PUT"
      url:  "/portal/notifications/mark_as_read"
      data: JSON.stringify(data)
      dataType: "script"
      contentType: 'application/json; charset=utf8'
  )


