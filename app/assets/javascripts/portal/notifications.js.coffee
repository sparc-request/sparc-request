$(document).ready ->
  Sparc.notifications = {
    ready: ->
      all_selected = ''
      $('.mark_notification').live('click', ->
        notification_id = $(this).data('notification_id')
        if $(this).is(':checked') || all_selected == "all"
          $("#notification_#{notification_id}").val(notification_id)
        else
          $("#notification_#{notification_id}").val(null)

        unread_checked_count = $('.unread .mark_notification_hidden[value!=""]').length
        read_checked_count = $('.read .mark_notification_hidden[value!=""]').length
        if unread_checked_count > 0 || read_checked_count > 0
          if unread_checked_count > 0
            $('#read_or_unread_link').html('Mark as Read')
            $('.read_or_unread_field').val("read")
          else
            $('#read_or_unread_link').html('Mark as Unread')
            $('.read_or_unread_field').val("unread")
      )

      $('#read_or_unread_link').live('click', ->
        unread_checked = $('.unread .mark_notification_hidden[value!=""]')
        read_checked = $('.read .mark_notification_hidden[value!=""]')

        unread_checked_count = unread_checked.length
        read_checked_count = read_checked.length

        if unread_checked_count > 0 || read_checked_count > 0
          if unread_checked_count > 0
            unread_checked.parent().parent().removeClass('unread').addClass('read')
          else
            read_checked.parent().parent().removeClass('read').addClass('unread')

          $('.notifications-form').submit()
        $('.mark_notification').attr('checked', false)
        $('.mark_notification_hidden').val('')
      )

      $('.select_all').live('click', ->
        all_selected = 'all'
        $('.mark_notification').not(':checked').click()
        all_selected = ''
      )

      $('.deselect_all').live('click', ->
        $('.mark_notification').attr('checked', false)
        $('.mark_notification_hidden').val('')
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

      $('.notification_dialog').dialog({
        autoOpen: false
        title: 'Notification'
        width: 720
        height: 495
        modal: true
        buttons: {
          "Submit": () ->
            disableSubmitButton("Submit", "Please wait...")
            $('.notification-dialog-form').bind('ajax:success', (data) ->
              enableSubmitButton("Please wait...", "Submit")
              $('.notification_dialog').dialog('close')
            ).submit()
          "Cancel": () ->
            enableSubmitButton("Please wait...", "Submit")
            $(this).dialog('close')
        }
      })

      $('.icon-column, .from-column, .message-count, .subject-column, .preview-column, .received-column').live('click', ->
        notification_id = $(this).data('notification_id')
        friendly_id = $(this).data('friendly_id') or ''
        ssr_id = $(this).data('ssr_id') or ''
        from_user_id = $(this).data('from_user_id')
        user_id = $(this).data('user_id')
        random_number = Math.floor(Math.random()*10101010101)

        $(".notification_#{notification_id}").removeClass('unread').addClass('read') unless from_user_id is user_id

        $('.notification_dialog').html("<img class='notification_spinner' alt='Loading...' src='/assets/portal/spinner.gif'>")
        $('.notification_dialog').dialog('open')

        if ssr_id isnt '' and friendly_id isnt ''
          $.ajax({method: 'get', url: "/portal/notifications/#{notification_id}?friendly_id=#{friendly_id}&ssr_id=#{ssr_id}"})
        else
          $.ajax({method: 'get', url: "/portal/notifications/#{notification_id}"})
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
  }
