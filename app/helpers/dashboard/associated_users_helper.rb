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

module Dashboard::AssociatedUsersHelper
  
  def associated_users_edit_button(pr, permission_to_edit)
    content_tag(:button,
      raw(
        content_tag(:span, '', class: 'glyphicon glyphicon-edit', aria: { hidden: 'true' })
      ),
      type: 'button', data: { project_role_id: pr.id, permission: permission_to_edit.to_s },
      class: "btn btn-warning actions-button edit-associated-user-button #{permission_to_edit ? '' : 'disabled'}"
    )
  end

  def associated_users_delete_button(pr, permission_to_edit)
    content_tag(:button,
      raw(
        content_tag(:span, '', class: 'glyphicon glyphicon-remove', aria: { hidden: 'true' })
      ),
      type: 'button', data: { project_role_id: pr.id, identity_role: pr.role, identity_id: pr.identity_id, permission: permission_to_edit.to_s }, 
      class: "btn btn-danger actions-button delete-associated-user-button #{permission_to_edit ? '' : 'disabled'}"
    )
  end

  def pre_select_user_credentials(credentials)
    unless credentials.blank?
      selected =  USER_CREDENTIALS.map {|k,v| {pretty_tag(v) => k}}.select{|obj| obj unless obj[pretty_tag(credentials)].blank? }
      selected.blank? ? 'other' : selected.first.try(:keys).try(:first)
    else
      ''
    end
  end

  def reverse_user_credential_hash
    USER_CREDENTIALS.each{|k, v| [v, k]}
  end
end
