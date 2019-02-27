# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

require 'rails_helper'

RSpec.describe CatalogManager::ClinicalProvidersController, type: :controller do

  before :each do
    @identity = create(:identity, catalog_overlord: true)
    @organization_id = create(:provider).id
    log_in_catalog_manager_identity(obj: @identity)
  end

  describe '#create' do
    it 'should create a Clinical Provider' do
      old_count = ClinicalProvider.count
      post :create,
        params: { clinical_provider: { identity_id: @identity.id, organization_id: @organization_id } },
        xhr: true

      expect(ClinicalProvider.count).to eq(old_count + 1)
    end
  end

  describe '#destroy' do
    it 'should delete an existing Clinical Provider' do
      cm = create(:clinical_provider, identity_id: @identity.id, organization_id: @organization_id)
      old_count = ClinicalProvider.count
      delete :destroy,
        params: { clinical_provider: { identity_id: @identity.id, organization_id: @organization_id } },
        xhr: true

      expect(ClinicalProvider.count).to eq(old_count - 1)
    end
  end

end
