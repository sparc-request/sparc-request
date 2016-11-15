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

module AssociatedUsersHelper
  def user_form_group(form: nil, name:, classes: [], label: nil)
    name_sym = name.to_sym
    content_tag(:div,
      form ?
        (form.label(name, label || t(:authorized_users)[:form_fields][name_sym], class: 'col-lg-3 control-label') +
          content_tag(:div, class: 'col-lg-9') { yield })
      :
        (content_tag(:label, label || t(:authorized_users)[:form_fields][name_sym], class: 'col-lg-3 control-label') +
          content_tag(:div, class: 'col-lg-9') { yield }),
      class: %w(row form-group) + [classes])
  end

  def professional_organization_state(professional_organization)
    if professional_organization
      {
        prev_selected: professional_organization.parents,
        last_selected: professional_organization,
        not_selected: professional_organization.children
      }
    else
      {
        prev_selected: [],
        last_selected: nil,
        not_selected: ProfessionalOrganization.where(parent_id: nil)
      }
    end
  end

  def org_type_label(professional_organization)
    professional_organization.org_type.capitalize + ":"
  end

  def authorized_users_edit_button(project_role)
    content_tag(:button,
      raw(
        content_tag(:span, '', class: 'glyphicon glyphicon-edit', aria: { hidden: 'true' })
      ),
      type: 'button', data: { project_role_id: project_role.id },
      class: "btn btn-warning actions-button edit-associated-user-button"
    )
  end

  def authorized_users_delete_button(project_role, current_user)
    content_tag(:button,
      raw(
        content_tag(:span, '', class: 'glyphicon glyphicon-remove', aria: { hidden: 'true' })
      ),
      type: 'button', data: { project_role_id: project_role.id, identity_role: project_role.role, identity_id: project_role.identity_id },
      class: "btn btn-danger actions-button delete-associated-user-button",
      disabled: project_role.identity_id == current_user.id
    )
  end
end
