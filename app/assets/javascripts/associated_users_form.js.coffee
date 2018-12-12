# Copyright © 2011-2018 MUSC Foundation for Research Development
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
  # Role - Dropdown
  $(document).on 'changed.bs.select', '#project_role_role', ->
    $('.role_dependent').addClass('hidden')
    switch $('#project_role_role').val()
      when 'other'
        $('.role_dependent.other').removeClass('hidden')
      when 'business-grants-manager'
        $('#project_role_project_rights_none').attr('disabled', true)
        $('#project_role_project_rights_view').attr('disabled', true)
        $('#project_role_project_rights_approve').attr('checked', true)
      when 'pi', 'primary-pi'
        $('#project_role_project_rights_none').attr('disabled', true)
        $('#project_role_project_rights_view').attr('disabled', true)
        $('#project_role_project_rights_approve').attr('checked', true)
        $('.role_dependent.commons_name').removeClass('hidden')
        $('.role_dependent.subspecialty').removeClass('hidden')
      when '', 'grad-research-assistant', 'undergrad-research-assistant', 'research-assistant-coordinator', 'technician', 'general-access-user'
      else
        $('input[name="project_role[project_rights]"]').attr('disabled', false).attr('checked', false)
        $('.role_dependent.commons_name').removeClass('hidden')
        $('.role_dependent.subspecialty').removeClass('hidden')

  $(document).on 'keydown', '#project_role_identity_attributes_orcid', (event) ->
    key = event.keyCode || event.charCode
    val = $(this).val()
    isDelete = [8, 46].includes(key)

    # Key must be numerical OR key must be X and last character of ID
    if !((key >= 96 && key <= 105) || (key >= 48 && key <= 57)) && !(key == 88 && val.length == 18) && !isDelete
      event.stopImmediatePropagation()
      return false
    else if isDelete && [6, 11, 16].includes(val.length)
      $(this).val(val.substr(0, val.length - 1))
    if !isDelete && [4, 9, 14].includes(val.length)
      $(this).val(val + "-")
    else if !isDelete && [5, 10, 15].includes(val.length) && val[val.length-1] != "-"
      $(this).val(val.substr(0, val.length - 1) + "-" + val.substr(val.length - 1, val.length))
    else if key == 88 && val.length == 18
      event.stopImmediatePropagation()
      $(this).val(val.substr(0, val.length) + String.fromCharCode(key).toUpperCase())

  $(document).on 'keyup', '#project_role_identity_attributes_orcid', (event) ->
    key = event.keyCode || event.charCode
    val = $(this).val()
    isDelete = [8, 46].includes(key)

    if !isDelete && [4, 9, 14].includes(val.length)
      $(this).val(val + "-")

  # Credentials - Dropdown
  $(document).on 'changed.bs.select', '#project_role_identity_attributes_credentials', ->
    if $(this).val() == 'other'
      $('.credentials_dependent.other').removeClass('hidden')
    else
      $('.credentials_dependent.other').addClass('hidden')

  # Show/Hide Warning when changing project rights that will redirect user to Dashboard
  $(document).on 'change', 'input[name="project_role[project_rights]"]', ->
    if ($(this).val() == 'view' && !$(this).data('dashboard')) || $(this).val() == 'none'
      $('.project-rights-redirect-warning').removeClass('hidden')
    else
      $('.project-rights-redirect-warning').addClass('hidden')

  # Renders warning when changing Primary PI
  $(document).on 'click', '#protocol-role-save', ->
    identity_id = parseInt($('#project_role_identity_id').val())
    pi_id       = $('#change-primary-pi-warning').data('pi-id')
    if $("select[name='project_role[role]']").val() == 'primary-pi' && identity_id != pi_id && !$('.protocol-role-form').hasClass('hidden')
      $(".protocol-role-form").addClass('hidden')
      $('#change-primary-pi-warning').removeClass('hidden')
    else
      $(".protocol-role-form").submit()

  $(document).on 'click', '#protocol-role-close', ->
    if $(".protocol-role-form").hasClass('hidden')
      $('#change-primary-pi-warning').addClass('hidden')
      $(".protocol-role-form").removeClass('hidden')
    else
      $(this).closest('.modal').modal('hide')

  $(document).on 'changed.bs.select', '.professional-organization-form select', ->
    last_selected = $(this).val()
    $.ajax
      type: 'get'
      url: '/dashboard/associated_users/update_professional_organization_form_items.js'
      data:
        last_selected_id: last_selected
  #**************** Add Authorized User Form End ****************
