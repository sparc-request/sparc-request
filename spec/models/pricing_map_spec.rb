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

require 'spec_helper'

describe 'PricingMap' do

  describe "validations" do
    let!(:core)          { FactoryGirl.create(:core) }
    let!(:service)       { FactoryGirl.create(:service, organization_id: core.id) }

    it "should not raise exception if full_rate, display_date, and effective_date are set" do
      lambda { FactoryGirl.create(:pricing_map, full_rate: 100, display_date: Date.today - 2.days,
                                  effective_date: Date.today - 2.days, service_id: service.id).save! }.should_not raise_exception
    end

    it "should validate the presence of full rate" do
      lambda { FactoryGirl.create(:pricing_map, full_rate: nil, display_date: Date.today - 2.days,
                                  effective_date: Date.today - 2.days, service_id: service.id).save! }.should raise_exception(ActiveRecord::RecordInvalid)
    end

    it "should validate the numericality of full rate" do
      lambda { FactoryGirl.create(:pricing_map, full_rate: "hello", display_date: Date.today - 2.days,
                                  effective_date: Date.today - 2.days, service_id: service.id).save! }.should raise_exception(ActiveRecord::RecordInvalid)
    end

    it "should validate the presence of display_date" do
      lambda { FactoryGirl.create(:pricing_map, full_rate: 100, display_date: nil,
                                  effective_date: Date.today - 2.days, service_id: service.id).save! }.should raise_exception(ActiveRecord::RecordInvalid)
    end

    it "should validate the presence of effective_date" do
      lambda { FactoryGirl.create(:pricing_map, full_rate: 100, display_date: Date.today - 2.days,
                                  effective_date: nil, service_id: service.id).save! }.should raise_exception(ActiveRecord::RecordInvalid)
    end
  end
  
  describe 'applicable_rate' do
    it 'should return the full rate times the given percentage if there is no override' do
      pricing_map = FactoryGirl.create(:pricing_map)
      pricing_map.full_rate = "60.0"
      pricing_map.applicable_rate('federal', 0.7).should eq 42.0
    end

    it 'should return the override rate if there is one' do
      pricing_map = FactoryGirl.create(:pricing_map)
      pricing_map.full_rate = "60.0"
      pricing_map.federal_rate = 10.0
      pricing_map.applicable_rate('federal', 0.7).should eq 10.0
    end
  end

  describe 'rate_override' do
    [
      'federal',
      'corporate',
      'member',
      'other'
    ].each do |rate_type|
      it "should return the #{rate_type} rate override if rate type is #{rate_type}" do
        pricing_map = FactoryGirl.create(:pricing_map)
        pricing_map.federal_rate = 10.0
        pricing_map.corporate_rate = 10.0
        pricing_map.other_rate = 10.0
        pricing_map.member_rate = 10.0
        eval("pricing_map.#{rate_type}_rate = 42.0")
        pricing_map.rate_override(rate_type).should eq 42.0
      end
    end
  end

  describe 'calculate_rate' do
    it 'should return the full rate times the given percentage' do
      pricing_map = FactoryGirl.create(:pricing_map)
      pricing_map.full_rate = "60.0"
      pricing_map.calculate_rate(0.7).should eq 42.0
    end
  end

  describe 'rates from full' do

    let!(:core)          { FactoryGirl.create(:core) }
    let!(:service)       { FactoryGirl.create(:service, organization_id: core.id) }
    let!(:pricing_map)   { FactoryGirl.create(:pricing_map, full_rate: 100, display_date: Date.today - 2.days,
                           effective_date: Date.today - 2.days, service_id: service.id) }
    let!(:pricing_setup) { FactoryGirl.create(:pricing_setup, display_date: Date.today - 1.day, federal: 25,
                           effective_date: Date.today - 1.day, corporate: 25, other: 25, member: 25, organization_id: core.id)}

    it 'should return a hash with the correct rates' do
      ps = PricingSetup.find(pricing_setup.id)
      hash = { federal_rate: 25, corporate_rate: 25, other_rate: 25, member_rate: 25 }
      # pricing_map.rates_from_full(ps.display_date).should eq(hash)
      PricingMap.rates_from_full(ps.display_date, core.id, 100)
    end
  end
end

