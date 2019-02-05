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

class Form < Survey

  # 2 Forms can't have the same access_code, surveyable_id, and surveyable_type and both be active
  validates_uniqueness_of :active, scope: [:type, :surveyable_id, :surveyable_type, :access_code], if: -> { self.active }

  scope :for, -> (identity) {
    orgs =
      if identity.is_site_admin?
        Organization.all
      else
        Organization.authorized_for_super_user(identity.id).or(
          Organization.authorized_for_service_provider(identity.id)).or(
          Organization.authorized_for_catalog_manager(identity.id))
      end
      
    services = Service.where(organization: orgs)
    
    where(surveyable: orgs).
    or(where(surveyable: services)).
    or(where(surveyable: identity))
  }

  scope :for_super_user, -> (identity) {
    orgs      = Organization.authorized_for_super_user(identity.id)
    services  = Service.where(organization: orgs)

    where(surveyable: orgs).
    or(where(surveyable: services)).
    or(where(surveyable: identity))
  }

  scope :for_service_provider, -> (identity) {
    orgs      = Organization.authorized_for_service_provider(identity.id)
    services  = Service.where(organization: orgs)

    where(surveyable: orgs).
    or(where(surveyable: services)).
    or(where(surveyable: identity))
  }

  scope :for_catalog_manager, -> (identity) {
    orgs      = Organization.authorized_for_catalog_manager(identity.id)
    services  = Service.where(organization: orgs)

    where(surveyable: orgs).
    or(where(surveyable: services)).
    or(where(surveyable: identity))
  }

  def self.yaml_klass
    Form.name
  end
end
