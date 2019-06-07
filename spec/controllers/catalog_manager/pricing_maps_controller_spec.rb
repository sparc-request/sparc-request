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

RSpec.describe CatalogManager::PricingMapsController, type: :controller do

  before :each do
    log_in_catalog_manager_identity(obj: build_stubbed(:identity, catalog_overlord: true))
  end

  describe '#create' do
    it 'should create a Pricing Map' do
      provider  = create(:provider)
      program   = create(:program, parent: provider)
      service   = create(:service, organization: program)

      expect{
        post :create,
          params: { pricing_map: attributes_for(:pricing_map).merge({ service_id: service.id }) },
          xhr: true
        }.to change(PricingMap, :count).by(1)
    end
  end

  describe '#update' do
    it 'should update an existing Pricing Map' do
      map = create(:pricing_map, federal_rate: 1234)
      expect{
        put :update,
          params: { id: map.id, pricing_map: { federal_rate: 567.8 } },
          xhr: true
        map.reload
      }.to change(map, :federal_rate).to(567.8.to_d * 100)
    end
  end
end
