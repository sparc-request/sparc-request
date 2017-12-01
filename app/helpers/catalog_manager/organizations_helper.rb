# Copyright © 2011-2017 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

module CatalogManager::OrganizationsHelper
  def org_tree_header organization
    parents = organization.parents.map(&:name).reverse
    header = content_tag :span do
      parents.each do |p|
        concat(content_tag(:span, p))
        concat(content_tag(:span, '', class: 'inline-glyphicon glyphicon glyphicon-triangle-right'))
      end
    concat(content_tag(:span, organization.name)) unless organization.type == 'Institution'
    end
    header
  end

  def organization_type_header organization
    content_tag(:span, organization.type, class: "text-#{organization.type.downcase}")
  end

  def user_rights organization
    include_service_providers = organization.type != 'Institution'
    inclued_clinical_rpoviders = include_service_providers && organization.tag_list.include?("clinical work fulfillment")
    organization.all_user_rights(include_service_providers, inclued_clinical_rpoviders)
  end

  def can_edit_historic_data?(organization, identity)
    identity.is_catalog_manager_for?(organization) && CatalogManager.find_by(identity_id: identity.id, organization_id: organization.id).edit_historic_data
  end

  def is_primary_contact?(organization, identity)
    identity.is_service_provider_for?(organization) && ServiceProvider.find_by(identity_id: identity.id, organization_id: organization.id).is_primary_contact
  end

  def hold_emails?(organization, identity)
    identity.is_service_provider_for?(organization) && ServiceProvider.find_by(identity_id: identity.id, organization_id: organization.id).hold_emails
  end
end
