require 'spec_helper'

describe 'PricingSetup' do
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
        pricing_setup = FactoryGirl.build(:pricing_setup)
        eval("pricing_setup.#{funding_source}_rate_type = 'foobarbaz'")
        pricing_setup.rate_type(funding_source).should eq 'foobarbaz'
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
        pricing_setup = FactoryGirl.build(:pricing_setup)
        pricing_setup.federal = 10.0
        pricing_setup.corporate = 10.0
        pricing_setup.other = 10.0
        pricing_setup.member = 10.0
        eval("pricing_setup.#{rate_type} = 42")
        pricing_setup.applied_percentage(rate_type).should eq 0.42
      end
    end

    it 'should return 100% if the applied percentage is nil' do
      pricing_setup = FactoryGirl.build(:pricing_setup)
      pricing_setup.federal = nil
      pricing_setup.applied_percentage('federal').should eq 1.0
    end
  end

  describe "create pricing maps" do

    let!(:program)       { FactoryGirl.create(:program) }
    let!(:service)       { FactoryGirl.create(:service, organization_id: program.id) }
    let!(:pricing_setup) { FactoryGirl.create(:pricing_setup,
                           organization_id: program.id,
                           display_date: Time.now,
                           effective_date: Time.now) }
    
    it "should return pricing maps with correct effective and display dates" do
      pricing_setup.create_pricing_maps
      service.reload
      service.pricing_maps[1].display_date.to_date.should eq(pricing_setup.display_date.to_date)
      service.pricing_maps[1].effective_date.to_date.should eq(pricing_setup.effective_date.to_date)
    end

    it "should return nil if there is no organization" do
      pricing_setup.update_attributes(organization_id: nil)
      pricing_setup.create_pricing_maps.should eq(nil)
    end
  end
end

