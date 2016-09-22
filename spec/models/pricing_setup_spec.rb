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

require 'rails_helper'

RSpec.describe 'PricingSetup' do
  describe 'rate_type' do
    [
      'college',
      'federal',
      'foundation',
      'industry',
      'investigator',
      'internal',
    ].each do |funding_source|
      it "should return the #{funding_source} rate type when funding source is #{funding_source}" do
        pricing_setup = build(:pricing_setup)
        eval("pricing_setup.#{funding_source}_rate_type = 'foobarbaz'")
        expect(pricing_setup.rate_type(funding_source)).to eq 'foobarbaz'
      end
    end
  end

  describe 'applied_percentage' do
    [
      'federal',
      'corporate',
      'other',
      'member',
    ].each do |rate_type|
      it "should return the #{rate_type} rate when rate type is #{rate_type}" do
        pricing_setup = build(:pricing_setup)
        pricing_setup.federal = 10.0
        pricing_setup.corporate = 10.0
        pricing_setup.other = 10.0
        pricing_setup.member = 10.0
        eval("pricing_setup.#{rate_type} = 42")
        expect(pricing_setup.applied_percentage(rate_type)).to eq 0.42
      end
    end

    it 'should return 100% if the applied percentage is nil' do
      pricing_setup = build(:pricing_setup)
      pricing_setup.federal = nil
      expect(pricing_setup.applied_percentage('federal')).to eq 1.0
    end
  end

    it 'should return zero if the applied percentage is zero' do
      pricing_setup = build(:pricing_setup)
      pricing_setup.federal = 0
      expect(pricing_setup.applied_percentage('federal')).to eq 0.0
    end

  describe "create pricing maps" do

    let!(:program)       { create(:program) }
    let!(:service)       { create(:service, organization_id: program.id) }
    let!(:pricing_setup) { create(:pricing_setup,
                           organization_id: program.id,
                           display_date: Time.now,
                           effective_date: Time.now) }

    it "should return pricing maps with correct effective and display dates" do
      pricing_setup.create_pricing_maps
      service.reload
      expect(service.pricing_maps[1].display_date.to_date).to eq(pricing_setup.display_date.to_date)
      expect(service.pricing_maps[1].effective_date.to_date).to eq(pricing_setup.effective_date.to_date)
    end

    it "should return nil if there is no organization" do
      pricing_setup.update_attributes(organization_id: nil)
      expect(pricing_setup.create_pricing_maps).to eq(nil)
    end
  end
end
