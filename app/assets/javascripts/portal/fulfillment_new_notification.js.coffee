$(document).ready ->
  Sparc.fulfillment_new_notification = {
    ready: ->
      $('.new_notification').live('click', ->
        friendly_id = $(this).data('friendly_id')
        ssr_id = $(this).data('ssr_id')
        $.ajax
          method: 'get'
          url: $(this).data('url') + "&friendly_id=#{friendly_id}&ssr_id=#{ssr_id}"
          success: ->
            $('.new_notification_dialog').dialog('open')
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
