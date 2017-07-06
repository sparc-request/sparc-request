# Copyright © 2011-2016 MUSC Foundation for Research Development
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
  $(document).on 'click', '#new-associated-user-button', ->
    $.ajax
      type: 'get'
      url: '/associated_users/new.js'
      data:
        protocol_id: $(this).data('protocol-id')
        service_request_id: getSRId()
    return false

  $(document).on 'click', '.edit-associated-user-button', (event) ->
    project_role_id = $(this).data('project-role-id')
    $.ajax
      type: 'get'
      url: "/associated_users/#{project_role_id}/edit.js"
      data:
        service_request_id: getSRId()
      success: ->
        if $('#project_role_role').val() == 'other'
          $('.role_dependent.other').show()
        if $('#project_role_identity_attributes_credentials').val() == 'other'
          $('.credentials_dependent.other').show()
    return false

  $(document).on 'click', '.delete-associated-user-button', ->
    project_role_id        = $(this).data('project-role-id')
    current_user_id        = parseInt($('#current_user_id').val(), 10)
    pr_identity_role       = $(this).data('identity-role')
    pr_identity_id         = $(this).data('identity-id')

    if current_user_id == pr_identity_id
      confirm_message = I18n['authorized_users']['delete']['self_remove_warning']
    else
      confirm_message = I18n['authorized_users']['delete']['remove_warning']

    if pr_identity_role == 'primary-pi'
      alert I18n['authorized_users']['delete']['pi_warning']
    else if current_user_id == pr_identity_id
      alert I18n['proper']['protocol']['authorized_users']['remove_self_warning']
    else
      if confirm(confirm_message)
        $.ajax
          type: 'delete'
          url: "/associated_users/#{project_role_id}?service_request_id=#{getSRId()}"
    return false
