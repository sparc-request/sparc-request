# Copyright © 2011-2019 MUSC Foundation for Research Development
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

$("#modalContainer").html("<%= j render 'associated_users/user_form', protocol: @protocol, protocol_role: @protocol_role, identity: @identity, service_request: @service_request, epic_user: @epic_user %>")
$("#modalContainer").modal('show')

if ['pi', 'primary-pi', 'business-grants-manager'].includes("<%= @protocol_role.role %>")
  $('#project_role_project_rights_none, #project_role_project_rights_view').attr('disabled', true)

primaryPiConfirmed = false
rightsChangeConfirmed = false
$('#authorizedUserForm').on 'submit', (event) ->
  form = document.getElementById('authorizedUserForm')
  if "<%= @protocol_role.role %>" != 'primary-pi' && $('#project_role_role').val() == 'primary-pi' && !primaryPiConfirmed
    event.preventDefault()
    event.stopImmediatePropagation()
    ConfirmSwal.fire(
      title: I18n.t('authorized_users.form.primary_pi_change.title', protocol_type: "<%= @protocol.model_name.human %>")
      html: I18n.t('authorized_users.form.primary_pi_change.text', new_pi_name: "<%= @protocol_role.identity.full_name %>", current_pi_name: "<%= @protocol.primary_pi.full_name %>")
    ).then (result) ->
      if result.value
        primaryPiConfirmed = true
        Rails.fire(form, 'submit')
  else if "<%= @identity == current_user %>" == 'true' && "<%= current_user.catalog_overlord? %>" == 'false' && ['view', 'member'].includes($('input[name="project_role[project_rights]"]:checked').val()) && !rightsChangeConfirmed
    event.preventDefault()
    event.stopImmediatePropagation()
    ConfirmSwal.fire(
      title: I18n.t('authorized_users.form.user_rights_change.title')
      html: I18n.t('authorized_users.form.user_rights_change.proper_text')
    ).then (result) ->
      if result.value
        rightsChangeConfirmed = true
        Rails.fire(form, 'submit')
  else
    primaryPiConfirmed = false
    rightsChangeConfirmed = false
    return true
