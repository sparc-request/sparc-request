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

  # Returns all Identities that have at least one user rights role
  def user_rights_identities organization
    include_service_providers = organization.type != 'Institution'
    inclued_clinical_rpoviders = include_service_providers && organization.tag_list.include?("clinical work fulfillment")
    organization.all_user_rights(include_service_providers, inclued_clinical_rpoviders)
  end

  # Returns a hash of all user rights grouped by type of user right
  def all_user_rights organization
    { super_users: SuperUser.where(organization_id: organization.id),
      catalog_managers: CatalogManager.where(organization_id: organization.id),
      service_providers: ServiceProvider.where(organization_id: organization.id),
      clinical_providers: ClinicalProvider.where(organization_id: organization.id) }
  end

  # Returns the first instance an identity's user rights from the given hash of all user rights,
  # nil if the identity has no user rights in the hash
  def get_user_rights all_user_rights, identity_id
    all_user_rights.detect{ |ur| ur.identity_id == identity_id }
  end
end
