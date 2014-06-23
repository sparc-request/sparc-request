# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  Sparc.associated_users = {
    display_dependencies :
      '#project_role_role' :
        'primary-pi'              : ['.era_commons_name', '.subspecialty']
        pi                        : ['.era_commons_name', '.subspecialty']
        'co-investigator'         : ['.era_commons_name', '.subspecialty']
        'faculty-collaborator'    : ['.era_commons_name', '.subspecialty']
        consultant                : ['.era_commons_name', '.subspecialty']
        "staff-scientist"         : ['.era_commons_name', '.subspecialty']
        postdoc                   : ['.era_commons_name', '.subspecialty']
        mentor                    : ['.era_commons_name', '.subspecialty']
        other                     : ['.role_other']
      '#identity_credentials' :
        other          : ['.credentials_other']

    ready: ->
        
      $('.associated-user-button').live('click', ->
        if $(this).data('permission')
          $('.add-associated-user-dialog').dialog('open')
          $('#add-user-form #protocol_id').val($(this).data('protocol_id'))
        else
          $('.permissions-dialog').dialog('open')
          $('.permissions-dialog .text').html('Edit.')

      )

      $('.user_credentials').attr('name', 'user[credentials_other]') if $('.user_credentials').val() == 'other'
      $('.user_credentials').live('change', ->
        Sparc.associated_users.redoCredentials()
      )

      $(document).on 'click', '.epic_access', ->
        Sparc.associated_users.showEpicRights($(this).val())

      # Set the rights if the role is 'pi' or 'business-grants-manager'
      # and disable all other radio buttons if 'pi'
      $('#project_role_role').live('change', ->
        role = $(this).val()
        if role == 'pi' or role == 'business-grants-manager' or role == 'primary-pi'
          $('#project_role_project_rights_approve').attr('checked', true)
          if role == 'pi' or role == 'primary-pi'
            $('#project_role_project_rights_request').attr('disabled', true)
            $('#project_role_project_rights_view').attr('disabled', true)
            $('#project_role_project_rights_none').attr('disabled', true)
          else
            $('#project_role_project_rights_request').attr('disabled', false)
            $('#project_role_project_rights_view').attr('disabled', false)
            $('#project_role_project_rights_none').attr('disabled', false)

      )

      $(document).on('click', '.edit-associated-user-button', ->
        if $(this).data('permission')
          protocol_id = $(this).data('protocol_id')
          pr_id = $(this).data('pr_id')
          user_id = $(this).data('user_id')
          sub_service_request_id = $(this).data('sub_service_request_id')
          $.ajax({
              method: 'get'
              url: "/portal/associated_users/#{pr_id}/edit"
              data: {protocol_id: protocol_id, identity_id: user_id, sub_service_request_id: sub_service_request_id}
              success: ->
                $('.edit-associated-user-dialog').dialog('open')
                Sparc.associated_users.showEpicRights($('.epic_access:checked').val())
              error: (request, status, error) ->
                $().toastmessage("showMessage", {
                  type: "error"
                  sticky: true
                  text: error.toString()
                  })
            })
        else
          $('.permissions-dialog').dialog('open')
          $('.permissions-dialog .text').html('Edit.')
      )

      $('.delete-associated-user-button').live('click', ->
        if $(this).data('permission')
          adminUsersList = $(".admin#users")
          current_user_id = $('#current_user_id').val()
          current_user_role = $(this).data('current_user_role')
          protocol_id = $(this).data('protocol_id')
          sub_service_request_id = $(this).data('sub_service_request_id')
          pr_id = $(this).data('pr_id')
          user_id = $(this).data('user_id')
          user_role = $(this).data('user_role')
          pi_count = parseInt($("#pi_count_#{protocol_id}").val(), 10)
          confirm_message = if current_user_id == user_id then 'This action will remove you from the project. Are you sure?' else 'Are you sure?'
          alert_message1 = 'Projects require a PI. Please add a new one before continuing.'
          cannot_remove_pi = (current_user_role == 'pi' or user_role == 'pi') and pi_count == 1

          if cannot_remove_pi
            alert(alert_message1)
          else
            if confirm(confirm_message)
              $.ajax
                dataType: 'script'
                type: 'delete'
                data: {sub_service_request_id: sub_service_request_id}
                url: "/portal/associated_users/#{pr_id}/"
                success: ->
                  if sub_service_request_id
                    # Nothing
                  else
                    if parseInt(current_user_id, 10) == parseInt(user_id, 10)
                      $(".blue-provider-#{protocol_id}").fadeOut(1500)
                      $(".protocol-information-#{protocol_id}").fadeOut(1500)
                    else
                      Sparc.protocol.renderProtocolAccordionTab(protocol_id)

        else
          $('.permissions-dialog').dialog('open')
          $('.permissions-dialog .text').html('Edit.')
      )

      $('#associated_user_role').live('change', ->
        roles_to_hide = ['', 'grad-research-assistant', 'undergrad-research-assistant', 'research-assistant-coordinator', 'technician', 'general-access-user', 'business-grants-manager', 'other']
        role = $(this).val()
        if role == 'other' then $('.role_other').show() else $('.role_other').hide()
        # if role == '' then Sparc.associated_users.validateRolePresence(role) else Sparc.associated_users.noProblems()
        if roles_to_hide.indexOf(role) >= 0
          $('.commons_name').hide()
          $('.subspecialty').hide()
        else
          $('.commons_name').show()
          $('.subspecialty').show()
      )

      Sparc.associated_users.create_edit_associated_user_dialog()
      Sparc.associated_users.create_add_associated_user_dialog()

    create_add_associated_user_dialog: () ->
      $('.add-associated-user-dialog').dialog({
        autoOpen: false
        dialogClass: "add_user_dialog_box"
        title: 'Add an Authorized User'
        width: 750
        modal: true
        resizable: false
        buttons: [
          {
            id: "add_authorized_user_submit_button"
            text: "Submit"
            click: ->
              $("#new_project_role").submit()
              $("#user_search").val('')
          },
          {
            id: "add_authorized_user_cancel_button"
            text: "Cancel"
            click: ->
              $(this).dialog('close')
              $("#user_search").val('')
              $("#errorExplanation").remove()
          }]
        open: ->
          $('.dialog-form input,.dialog-form select').attr('disabled',true)
          # $('.ui-dialog .ui-dialog-buttonpane button:contains(Submit)').filter(":visible").attr('disabled',true).addClass('button-disabled')
      })

    create_edit_associated_user_dialog: () ->
      $('.edit-associated-user-dialog').dialog({
          dialogClass: "edit_user_dialog_box"
          autoOpen: false
          dialogClass: "edit_user_dialog_box"
          title: 'Edit an Authorized User'
          width: 750
          modal: true
          resizable: false
          buttons: [
            {
              id: 'edit_authorized_user_submit_button'
              text: 'Submit'
              click: ->
                form = $(".edit-associated-user-dialog").children('form')
                form.submit()
            },
            {
              id: 'edit_authorized_user_cancel_button'
              text: 'Cancel'
              click: ->
                $(this).dialog("close")
                $("#errorExplanation").remove()
            }
          ]
          open: ->
            $('#associated_user_role').change()
      })

    createTip: (element) ->
      if ($('#tip').length == 0) then $('<div>')
        .html('<span>Drag and drop this item within a project to add.</span><span class="arrow"></span>')
        .attr('id', 'tip')
        .css({ left: element.pageX + 30, top: element.pageY - 16 })
        .appendTo('body').fadeIn(2000)
      else null

    disableSubmitButton: (containing_text, change_to) ->
      button = $(".ui-dialog .ui-dialog-buttonpane button:contains(#{containing_text})")
      button.html("<span class='ui-button-text'>#{change_to}</span>")
        .attr('disabled',true)
        .addClass('button-disabled')

    enableSubmitButton: (containing_text, change_to) ->
      button = $(".ui-dialog .ui-dialog-buttonpane button:contains(#{containing_text})")
      button.html("<span class='ui-button-text'>#{change_to}</span>")
        .attr('disabled',false)
        .removeClass('button-disabled')
      button.attr('disabled',false)

    validatePiPresence: (role) ->
      pi_count = parseInt($('.edit-user #pi_count').val(), 10)
      pi_validation_message = $('.edit-user #pi-validation-message')
      pi_count -= 1 if role != 'primary-pi'
      if pi_count <= 0
        pi_validation_message.show()
        Sparc.associated_users.disableSubmitButton("Submit", "Submit")
      else
        pi_validation_message.hide()
        Sparc.associated_users.enableSubmitButton("Submit", "Submit")

    validateRolePresence: (role) ->
      role_validation = $('#user-role-validation-message')
      role_validation.show()
      Sparc.associated_users.disableSubmitButton("Submit", "Submit")

    noProblems: ->
      role_validation = $('#user-role-validation-message')
      pi_validation_message = $('.edit-user #pi-validation-message')
      role_validation.hide()
      pi_validation_message.hide()
      Sparc.associated_users.enableSubmitButton("Submit", "Submit")

    redoCredentials: ->
      if $('.user_credentials').val() == 'other'
        $('#credentials_other').remove();
        $('.user_credentials').attr('name', 'user[other_credentials]')
        $('#add-user-form .left').append('<div id="credentials_other">
          <input type="text" value="" name="user[credentials]" id="user_credentials_other">
        </div>')
      else
        $('.user_credentials').attr('name', 'user[credentials]')
        $('#credentials_other').remove()

    showEpicRights: (display) ->
      if display == "true"
        $('.epic_access_rights').show()
      else
        $('.epic_access_rights').hide()

  }
