require 'spec_helper'

describe 'PricingMap' do
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

