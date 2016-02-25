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

module Dashboard::AssociatedUsersHelper
  GLYPH_EDIT = 'glyphicon glyphicon-edit'.freeze()
  GLYPH_REMOVE = 'glyphicon glyphicon-remove'.freeze()
  BTN_WARNING = 'btn btn-warning'.freeze()
  BTN_DANGER = 'btn btn-danger'.freeze()

  def associated_users_edit_button(pr, permission_to_edit)
    btn_classes = [BTN_WARNING, disabled_unless(permission_to_edit),
      'actions-button', 'edit-associated-user-button'].join(' ')

    content_tag(:button,
      raw(content_tag(:span, '', class: GLYPH_EDIT, aria: { hidden: 'true' })),
      type: 'button', data: { project_role_id: pr.id, permission: 'true' },
      class: btn_classes)
  end

  def associated_users_delete_button(pr, permission_to_edit)
    btn_classes = "#{BTN_DANGER} actions-button delete-associated-user-button #{disabled_unless(permission_to_edit)}"
    btn_data = { project_role_id: pr.id, identity_role: pr.role,
      identity_id: pr.identity_id, permission: 'true' }

    content_tag(:button,
      raw(content_tag(:span, '', class: GLYPH_REMOVE, aria: { hidden: 'true' })),
      type: 'button', data: btn_data, class: btn_classes)
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

  private
  def disabled_unless(permission_to_edit)
    permission_to_edit ? '' : 'disabled'
  end
end
