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
$(document).ready ->

  #**************** Add Authorized User Form Begin ****************

  window.update_disabled_hidden_form_items = () ->
    $('.role_dependent').addClass('hidden')
    switch $('#project_role_role').val()
      when 'other'
        $('.role_dependent.other').removeClass('hidden')
      when 'business-grants-manager'
        $('#project_role_project_rights_none').attr('disabled', true)
        $('#project_role_project_rights_view').attr('disabled', true)
        $('#project_role_project_rights_request').attr('disabled', true)
        $('#project_role_project_rights_approve').attr('checked', true)
      when 'pi', 'primary-pi'
        $('#project_role_project_rights_none').attr('disabled', true)
        $('#project_role_project_rights_view').attr('disabled', true)
        $('#project_role_project_rights_request').attr('disabled', true)
        $('#project_role_project_rights_approve').attr('checked', true)
        $('.role_dependent.commons_name').removeClass('hidden')
        $('.role_dependent.subspecialty').removeClass('hidden')
      when '', 'grad-research-assistant', 'undergrad-research-assistant', 'research-assistant-coordinator', 'technician', 'general-access-user'
      else
        $('input[name="project_role[project_rights]"]').attr('disabled', false).attr('checked', false)
        $('.role_dependent.commons_name').removeClass('hidden')
        $('.role_dependent.subspecialty').removeClass('hidden')

  # Credentials - Dropdown
  $(document).on 'changed.bs.select', '#project_role_identity_attributes_credentials', ->
    if $(this).val() == 'other'
      $('.credentials_dependent.other').removeClass('hidden')
    else
      $('.credentials_dependent.other').addClass('hidden')

  # Role - Dropdown
  $(document).on 'changed.bs.select', '#project_role_role', ->
    window.update_disabled_hidden_form_items()

  # Renders warning when changing Primary PI
  $(document).on 'click', '#save_protocol_rights_button', ->
    form = $("form.protocol_role_form")
    primary_pi_id = $('#protocol_role_data').data("pi-id")
    protocol_role_id = $('#protocol_role_data').data("pr-id")
    if form.is(":hidden")
      form.submit()
    else if $("select[name='project_role[role]']").val() == 'primary-pi' and primary_pi_id != protocol_role_id
      primary_pi_full_name = $('#protocol_role_data').data("pi-name")
      pr_full_name = $('#protocol_role_data').data("pr-name")
      protocol_id = $('#project_role_protocol_id').val()

      warning = I18n["protocol_information"]["change_primary_pi"]["warning"]
      message1 = I18n["protocol_information"]["change_primary_pi"]["warning_prompt_1_1"]+
        "(<strong>#{pr_full_name}</strong>)"+
        I18n["protocol_information"]["change_primary_pi"]["warning_prompt_1_2"]+
        "(<strong>#{primary_pi_full_name}</strong>)"+
        I18n["protocol_information"]["change_primary_pi"]["warning_prompt_1_3"]+
        "(<strong>#{protocol_id}</strong>)."
      message2 = I18n["protocol_information"]["change_primary_pi"]["warning_prompt_2"]

      form.hide()
      $('.modal-body').append("<h1 class='change_ppi_prompt text-center' style='color:red;'>#{warning}</h1><p class='change_ppi_prompt text-center' style='font-size:14px;'>#{message1}</p><p class='change_ppi_prompt text-center' style='font-size:14px;'>#{message2}</p>")
    else
      form.submit()

  $(document).on 'click', '#cancel_protocol_rights_button', (event) ->
    $form = $("form.protocol_role_form")
    if $form.is(':hidden')
      # on a warning modal, show form again
      $('.change_ppi_prompt').remove()
      $form.show()
    else
      # cancel
      $(this).closest('.modal').modal('hide')

  $(document).on 'changed.bs.select', '.professional-organization-form select', ->
    last_selected = $(this).val()
    $.ajax
      type: 'get'
      url: '/dashboard/associated_users/update_professional_organization_form_items.js'
      data:
        last_selected_id: last_selected
  #**************** Add Authorized User Form End ****************
