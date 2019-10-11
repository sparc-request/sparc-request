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

module AssociatedUsersHelper
  def new_authorized_user_button(opts={})
    unless in_dashboard? && !opts[:permission]
      url = in_dashboard? ? new_dashboard_associated_user_path(protocol_id: opts[:protocol_id]) : new_associated_user_path(srid: opts[:srid])

      link_to url, remote: true, class: 'btn btn-success' do
        icon('fas', 'plus mr-2') + t('authorized_users.new')
      end
    end
  end

  def authorized_user_actions(pr, opts={})
    content_tag :div, class: 'd-flex justify-content-center' do
      raw([
        edit_authorized_user_button(pr, opts),
        delete_authorized_user_button(pr, opts)
      ].join(''))
    end
  end

  def edit_authorized_user_button(pr, opts={})
    unless in_dashboard? && !opts[:permission]
      url = in_dashboard? ? edit_dashboard_associated_user_path(pr) : edit_associated_user_path(pr, srid: opts[:srid])

      link_to icon('far', 'edit'), url, remote: true, class: 'btn btn-warning mr-1 edit-authorized-user'
    end
  end

  def delete_authorized_user_button(pr, opts={})
    unless in_dashboard? && !opts[:permission]
      data = { id: pr.id, toggle: 'tooltip', placement: 'right', boundary: 'window' }

      if current_user.id == pr.identity_id
        if (in_dashboard? && (current_user.catalog_overlord? || opts[:admin])) || (!in_dashboard? && current_user.catalog_overlord?)
          # Warn of removing current user but won't redirect if
          # - in dashboard and current user is an overlord/admin or
          # - not in dashboard and current user is an overlord
          data[:batch_select] = {
            checkConfirm: 'true',
            checkConfirmSwalText: t('authorized_users.delete.self_remove_warning')
          }
        else
          # User will be redirected because they will no longer have
          # permission on this protocol
          data[:batch_select] = {
            checkConfirm: 'true',
            checkConfirmSwalText: t('authorized_users.delete.self_remove_redirect_warning')
          }
        end
      end

      button_tag(icon('fas', 'trash-alt'), type: 'button',
        title: pr.primary_pi? ? t(:authorized_users)[:delete][:pi_tooltip] : t(:authorized_users)[:delete][:tooltip],
        class: ["btn btn-danger actions-button delete-authorized-user", pr.primary_pi? ? 'disabled' : ''],
        data: data
      )
    end
  end

  # Generates state for portion of Authorized User form concerned with their
  # professional organizations.
  # professional_organization - Last professional organization selected in form.
  #   Pass a falsy value for initial state.
  def professional_organization_state(professional_organization)
    if professional_organization
      {
        dont_submit_selected: professional_organization.parents,
        submit_selected: professional_organization,
        dont_submit_unselected: professional_organization.children
      }
    else
      {
        dont_submit_selected: [],
        submit_selected: nil,
        dont_submit_unselected: ProfessionalOrganization.where(parent_id: nil)
      }
    end
  end

  # Generate a dropdown for choosing a professional organization.
  # choices_from - If a ProfessionalOrganization, returns a select populated
  #   with it (as selected option) and its siblings. Otherwise, choices_from
  #   should be a collection of ProfessionalOrganizations to be presented as
  #   options.
  def professional_organization_dropdown(form: nil, choices_from:)
    select_class = 'selectpicker'
    if choices_from.kind_of?(ProfessionalOrganization)
      options = options_from_collection_for_select(choices_from.self_and_siblings.order(:name), 'id', 'name', choices_from.id)
      select_id = "select-pro-org-#{choices_from.org_type}"
    else
      options = options_from_collection_for_select(choices_from.order(:name), 'id', 'name')
      select_id = "select-pro-org-#{choices_from.first.org_type}"
    end

    if form
      form.select(:professional_organization_id,
                  options,
                  { include_blank: true },
                  class: select_class,
                  id: select_id)
    else
      select_tag(nil,
                 options,
                 include_blank: true,
                 class: select_class,
                 id: select_id)
    end
  end

  # Convert ProfessionalOrganization's org_type to a label for Authorized Users
  # form.
  def org_type_label(professional_organization)
    professional_organization.org_type.capitalize
  end
end
