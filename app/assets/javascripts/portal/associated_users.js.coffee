# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
      $(document).on 'click', '.associated-user-button', ->
        if $(this).data('permission')
          $('.add-associated-user-dialog').dialog('open')
          $('#add-user-form #protocol_id').val($(this).data('protocol_id'))
        else
          $('.permissions-dialog').dialog('open')
          $('.permissions-dialog .text').html('Edit.')

      $('.user_credentials').attr('name', 'user[credentials_other]') if $('.user_credentials').val() == 'other'
      $('.user_credentials').live 'change', ->
        Sparc.associated_users.redoCredentials()

      $(document).on 'change', '.add_user_dialog_box #project_role_role', ->
        role = $(this).val()
        if role == 'pi' or role == 'primary-pi' or role == 'business-grants-manager'
          $('.add_user_dialog_box #project_role_project_rights_none').attr('disabled', true)
          $('.add_user_dialog_box #project_role_project_rights_view').attr('disabled', true)
          $('.add_user_dialog_box #project_role_project_rights_request').attr('disabled', true)
          $('.add_user_dialog_box #project_role_project_rights_approve').attr('checked', true)
        else
          $('.rights input').attr('disabled', false)

      $(document).on 'change', '.edit_user_dialog_box #project_role_role', -> 
        role = $(this).val()
        if role == 'pi' or role == 'primary-pi' or role == 'business-grants-manager'
          $('.edit_user_dialog_box #project_role_project_rights_none').attr('disabled', true)
          $('.edit_user_dialog_box #project_role_project_rights_view').attr('disabled', true)
          $('.edit_user_dialog_box #project_role_project_rights_request').attr('disabled', true)
          $('.edit_user_dialog_box #project_role_project_rights_approve').attr('checked', true)
        else
          $('.rights input').attr('disabled', false)

      $(document).on 'click', '.edit-associated-user-button', ->
        if $(this).data('permission')
          protocol_id = $(this).data('protocol_id')
          pr_id = $(this).data('pr_id')
          user_id = $(this).data('user_id')
          sub_service_request_id = $(this).data('sub_service_request_id')
          $.ajax
              method: 'get'
              url: "/portal/associated_users/#{pr_id}/edit"
              data: {protocol_id: protocol_id, identity_id: user_id, sub_service_request_id: sub_service_request_id}
              success: ->
                $('.edit-associated-user-dialog').dialog('open')
              error: (request, status, error) ->
                $().toastmessage "showMessage",
                  type: "error"
                  sticky: true
                  text: error.toString()
        else
          $('.permissions-dialog').dialog('open')
          $('.permissions-dialog .text').html('Edit.')

      $(document).on 'click', '.delete-associated-user-button', ->
        if $(this).data('permission')
          adminUsersList = $(".admin#users")
          current_user_id = $('#current_user_id').val()
          current_user_role = $(this).data('current_user_role')
          protocol_id = $(this).data('protocol_id')
          sub_service_request_id = $(this).data('sub_service_request_id')
          pr_id = $(this).data('pr_id')
          user_id = $(this).data('user_id')
          user_role = $(this).data('user_role')
          confirm_message = if current_user_id == user_id then 'This action will remove you from the project. Are you sure?' else 'Are you sure?'
          alert_message1 = I18n["protocol_information"]["require_primary_pi_message"]
          cannot_remove_pi = (current_user_role == 'primary-pi' or user_role == 'primary-pi')

          if cannot_remove_pi
            alert(alert_message1)
          else
            if confirm(confirm_message)
              # Seems like the only way to pass parameters when performing a DELETE ajax
              # request is through the URL.
              $.ajax
                dataType: 'script'
                type: 'delete'
                url: if sub_service_request_id then "/portal/associated_users/#{pr_id}?sub_service_request_id=#{sub_service_request_id}" else "/portal/associated_users/#{pr_id}"
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

      $(document).on 'change', '#associated_user_role', ->
        roles_to_hide = ['', 'grad-research-assistant', 'undergrad-research-assistant', 'research-assistant-coordinator', 'technician', 'general-access-user', 'business-grants-manager', 'other']
        role = $(this).val()
        if role == 'other' then $('.role_other').show() else $('.role_other').hide()
        if roles_to_hide.indexOf(role) >= 0
          $('.commons_name').hide()
          $('.subspecialty').hide()
        else
          $('.commons_name').show()
          $('.subspecialty').show()

      Sparc.associated_users.create_edit_associated_user_dialog()
      Sparc.associated_users.create_add_associated_user_dialog()

    create_add_associated_user_dialog: () ->
      $('.add-associated-user-dialog').dialog
        autoOpen: false
        dialogClass: "add_user_dialog_box"
        title: 'Add an Authorized User'
        width: 750
        modal: true
        resizable: false
        buttons:
          'Submit':
            id: 'add_authorized_user_submit_button'
            text: 'Submit'
            click: ->
              $('#add_authorized_user_submit_button').attr('disabled', true)

              role = $('#project_role_role').val()
              primary_pi_pr_id = $('#primary_pi_pr_id').val()
              pr_id = $('#pr_id').val()

              if role == 'primary-pi' && primary_pi_pr_id != pr_id
                button = $('#add_authorized_user_submit_button')
                button_text = button.children('span')
                title_text = $('.add_user_dialog_box .ui-dialog-titlebar').children('.ui-dialog-title')
                
                if button_text.text() == 'Submit'
                  #Hide the form
                  $('.user-search-container').hide()
                  $('#add-user-form').hide()

                  #Add the new elements
                  primary_pi_full_name = $('#primary_pi_full_name').val()
                  pr_full_name = $('#full_name').val()
                  warning = I18n["protocol_information"]["change_primary_pi"]["warning"]
                  message1 = I18n["protocol_information"]["change_primary_pi"]["warning_prompt_1_1"]+
                    "(<strong>#{pr_full_name}</strong>)"+
                    I18n["protocol_information"]["change_primary_pi"]["warning_prompt_1_2"]+
                    "(<strong>#{primary_pi_full_name}</strong>)"+
                    I18n["protocol_information"]["change_primary_pi"]["warning_prompt_1_3"]
                  message2 = I18n["protocol_information"]["change_primary_pi"]["warning_prompt_2"]
                  $('.add-associated-user-dialog').append("<h1 class='change_ppi_prompt' style='color:red;'>#{warning}</h1><p class='change_ppi_prompt' style='font-size:14px;'>#{message1}</p><p class='change_ppi_prompt' style='font-size:14px;'>#{message2}</p>")

                  #Change the text
                  button_text.text('Yes')
                  button.siblings('button').children('span').text('No')
                  title_text.text('Change Primary PI')
                else
                  #Enable removing the old Primary PI
                  $('#change_primary_pi').val(true)
                  
                  #Remove the elements
                  $('.change_ppi_prompt').remove()

                  #Show the form
                  $('.user-search-container').show()
                  $('#add-user-form').show()

                  #Change the text
                  button_text.text('Submit')
                  button.siblings('button').children('span').text('Cancel')
                  title_text.text('Add an Authorized User')
                  
                  $('#new_project_role').submit()
              else
                $('#new_project_role').submit()

              $('#add_authorized_user_submit_button').attr('disabled', false)

          'Cancel':
            id: 'add_authorized_user_cancel_button'
            text: 'Cancel'
            click: ->
              button = $('#add_authorized_user_cancel_button')
              button_text = button.children('span')
              title_text = $('.add_user_dialog_box .ui-dialog-titlebar').children('.ui-dialog-title')
              
              if button_text.text() == 'Cancel'
                $(this).dialog('close')
                $('#errorExplanation').remove()
              else
                #Remove the elements
                $('.change_ppi_prompt').remove()

                #Show the form
                $('.user-search-container').show()
                $('#add-user-form').show()

                #Change the text
                button_text.text('Cancel')
                button.siblings('button').children('span').text('Submit')
                title_text.text('Add an Authorized User')
        open: ->
          Sparc.associated_users.reset_fields()
          $('.dialog-form input,.dialog-form select').attr('disabled',true)
          # $('.ui-dialog .ui-dialog-buttonpane button:contains(Submit)').filter(":visible").attr('disabled',true).addClass('button-disabled')
        close: ->
          Sparc.associated_users.reset_fields()
          $('#add_authorized_user_submit_button').children('span').text('Submit')
          $('#add_authorized_user_cancel_button').children('span').text('Cancel')
          $('.add_user_dialog_box .ui-dialog-titlebar').children('.ui-dialog-title').text('Add an Authorized User')
          $('.change_ppi_prompt').remove()
          $('.user-search-container').show()
          $('#add-user-form').show()

    create_edit_associated_user_dialog: () ->
      $('.edit-associated-user-dialog').dialog
          autoOpen: false
          dialogClass: "edit_user_dialog_box"
          title: 'Edit an Authorized User'
          width: 750
          modal: true
          resizable: false
          buttons:
            'Submit':
              id: 'edit_authorized_user_submit_button'
              text: 'Submit'
              click: ->
                $('#edit_authorized_user_submit_button').attr('disabled', true)

                role = $('#project_role_role').val()
                primary_pi_pr_id = $('#primary_pi_pr_id').val()
                pr_id = $('#pr_id').val()

                if role == 'primary-pi' && primary_pi_pr_id != pr_id
                  button = $('#edit_authorized_user_submit_button')
                  button_text = button.children('span')
                  title_text = $('.edit_user_dialog_box .ui-dialog-titlebar').children('.ui-dialog-title')
                  
                  if button_text.text() == 'Submit'
                    #Hide the form
                    $("#edit_project_role_#{pr_id}").hide()

                    #Add the new elements
                    primary_pi_full_name = $('#primary_pi_full_name').val()
                    pr_full_name = $('#full_name').val()
                    warning = I18n["protocol_information"]["change_primary_pi"]["warning"]
                    message1 = I18n["protocol_information"]["change_primary_pi"]["warning_prompt_1_1"]+
                      "(<strong>#{pr_full_name}</strong>)"+
                      I18n["protocol_information"]["change_primary_pi"]["warning_prompt_1_2"]+
                      "(<strong>#{primary_pi_full_name}</strong>)"+
                      I18n["protocol_information"]["change_primary_pi"]["warning_prompt_1_3"]
                    message2 = I18n["protocol_information"]["change_primary_pi"]["warning_prompt_2"]
                    $('.edit-associated-user-dialog').append("<h1 class='change_ppi_prompt' style='color:red;'>#{warning}</h1><p class='change_ppi_prompt' style='font-size:14px;'>#{message1}</p><p class='change_ppi_prompt' style='font-size:14px;'>#{message2}</p>")

                    #Change the text
                    button_text.text('Yes')
                    button.siblings('button').children('span').text('No')
                    title_text.text('Change Primary PI')
                  else
                    #Enable removing the old Primary PI
                    $('#change_primary_pi').val(true)
                    
                    #Remove the elements
                    $('.change_ppi_prompt').remove()

                    #Show the form
                    $("#edit_project_role_#{pr_id}").show()

                    #Change the text
                    button_text.text('Submit')
                    button.siblings('button').children('span').text('Cancel')
                    title_text.text('Edit an Authorized User')

                    $('.edit-associated-user-dialog').children('form').submit()
                else
                  $('.edit-associated-user-dialog').children('form').submit()

                $('#edit_authorized_user_submit_button').attr('disabled', false)

            'Cancel':
              id: 'edit_authorized_user_cancel_button'
              text: 'Cancel'
              click: ->
                pr_id = $('#pr_id').val()

                button = $('#edit_authorized_user_cancel_button')
                button_text = button.children('span')
                title_text = $('.edit_user_dialog_box .ui-dialog-titlebar').children('.ui-dialog-title')
                
                if button_text.text() == 'Cancel'
                  $(this).dialog('close')
                  $("#errorExplanation").remove()
                else
                  #Remove the elements
                  $('.change_ppi_prompt').remove()

                  #Show the form
                  $("#edit_project_role_#{pr_id}").show()

                  #Change the text
                  button_text.text('Cancel')
                  button.siblings('button').children('span').text('Submit')
                  title_text.text('Edit an Authorized User')
          open: ->
            $('#edit_authorized_user_submit_button').attr('disabled', false)
            $('#associated_user_role').change()
          close: ->
            Sparc.associated_users.reset_fields()
            $('#edit_authorized_user_submit_button').children('span').text('Submit')
            $('#edit_authorized_user_cancel_button').children('span').text('Cancel')
            $('.edit_user_dialog_box .ui-dialog-titlebar').children('.ui-dialog-title').text('Edit an Authorized User')
            $('.change_ppi_prompt').remove()
            $('.edit-associated-user-dialog .associated_users_form').show()

    reset_fields: () ->
      $('.errorExplanation').html('').hide()
      $('.hidden').hide()
      $('#epic_access').hide()
      $('.add-associated-user-dialog input').val('')
      $('.add-associated-user-dialog select').prop('selectedIndex', 0)
      $('.add-associated-user-dialog #epic_access input').prop('checked', false)
      $('.add-associated-user-dialog .rights input').prop('checked', false)

    createTip: (element) ->
      if $('#tip').length == 0
        $('<div>').
          html('<span>Drag and drop this item within a project to add.</span><span class="arrow"></span>').
          attr('id', 'tip').
          css({ left: element.pageX + 30, top: element.pageY - 16 }).
          appendTo('body').fadeIn(2000)
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
  }
