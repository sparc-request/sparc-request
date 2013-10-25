require 'date'
require 'spec_helper'

describe 'Service' do
  let_there_be_lane
  let_there_be_j
  build_service_request_with_project

  describe 'parents' do

    it 'should return an array with only the organization if there are no parents' do
      service.update_attributes(organization_id: institution.id)      
      service.parents.should eq [ institution ]
    end

    it 'should return an array with the organization and its parent if there is a parent' do
      service.parents.should include(program, provider, institution)
    end
  end

  describe "organization" do
    
    let!(:core) { FactoryGirl.create(:core, parent_id: program.id) }
    
    context 'core' do

      it 'should return nil if the organization is not a core' do
        service.core.should eq(nil)
      end

      it 'should return the organization if the organization is a core' do
        service.update_attributes(organization_id: core.id)
        service.core.should eq(core)
      end
    end

    context 'program' do

      it 'should return nil if the organization is neither a core nor a program' do
        service.update_attributes(organization_id: institution.id)
        service.program.should eq(nil)
      end

      it 'should return the program if the organization is a program' do
        service.program.should eq(program)
      end

      it 'should return the program the core belongs to if the organization is a core' do
        service.update_attributes(organization_id: core.id)
        service.program.should eq(program)
      end
    end

    context 'provider' do

      it "should return nil if the organization is an insitution" do
        service.update_attributes(organization_id: institution.id)
        service.provider.should eq nil
      end

      it "should return the provider if the organization is a provider" do
        service.update_attributes(organization_id: provider.id)
        service.provider.should eq(provider)
      end

      it "should return the provider if the organization is a program" do
        service.update_attributes(organization_id: program.id)
        service.provider.should eq(provider)
      end

      it "should return the provider the core belongs to if the organization is a core" do
        service.update_attributes(organization_id: core.id)
        service.provider.should eq(provider)
      end
    end

    context 'institution' do

      it "should return the institution is the organization is an institution" do
        service.update_attributes(organization_id: institution.id)
        service.institution.should eq(institution)
      end

      it "should return the institution if the organization is a provider" do
        service.update_attributes(organization_id: provider.id)
        service.institution.should eq(institution)
      end

      it "should return the institution is the organization is a program" do
        service.update_attributes(organization_id: program.id)
        service.institution.should eq(institution)
      end

      it "should return the insitution if the organization is a core" do
        service.update_attributes(organization_id: core.id)
        service.institution.should eq(institution)
      end
    end
  end

  describe 'dollars_to_cents' do

    it "should return the correct cents for a given dollar amount" do

      amount = 0
      
      1000.times do
        Service.dollars_to_cents("#{amount / 100.00}").should eq(amount)
        amount = amount + 1
      end
    end
  end

  describe 'cents_to_dollars' do
    it 'should return nil given nil' do
      Service.cents_to_dollars(nil).should eq nil
    end

    it 'should return 1 dollar given 100 cents' do
      Service.cents_to_dollars(100).should eq 1
    end

    it 'should return 2.5 dollars given 250 cents' do
      Service.cents_to_dollars(250).should eq 2.5
    end
  end

    describe "is one time fee" do

    let!(:service) { FactoryGirl.create(:service) }
    let!(:pricing_map) { service.pricing_maps[0] }

    it "should return false if the pricing map is not a one time fee" do
      service.is_one_time_fee?.should eq(false)
    end

    it "should return true if the pricing map is a one time fee" do
      pricing_map.update_attributes(is_one_time_fee: true)
      service.is_one_time_fee?.should eq(true)
    end
  end

  describe "display attribute" do

    let!(:service) { FactoryGirl.create(:service, name: "Foo", abbreviation: "abc") }

    context "service name" do
      
      it "should return the service name" do
        service.display_service_name.should eq("Foo")
      end

      it "should concatenate cpt code to the name if it exists" do
        service.update_attributes(cpt_code: "Bar")
        service.display_service_name.should eq("Foo (Bar)")
      end
    end

    context "service abbreviation" do

      it "should return the abbreviation" do
        service.display_service_abbreviation.should eq("abc")
      end

      it "should concatenate cpt code to the abbreviation if it exists" do
        service.update_attributes(cpt_code: "def")
        service.display_service_abbreviation.should eq("abc (def)")
      end
    end
  end

  describe "displayed pricing map" do

    let!(:service) { FactoryGirl.create(:service) }

    it "should raise an exception if there are no pricing maps" do
      service.pricing_maps.delete_all
      lambda { service.displayed_pricing_map }.should raise_exception(ArgumentError)
    end

    it "should raise an exception if there are no current pricing maps" do
      service.pricing_maps.delete_all
      pricing_map = FactoryGirl.create(:pricing_map, service_id: service.id, display_date: Date.today + 1)
      lambda { service.displayed_pricing_map }.should raise_exception(ArgumentError)
    end

    it "should raise an exception if the display date is nil" do
      pricing_map = service.pricing_maps[0]
      pricing_map.update_attributes(display_date: nil)
      lambda { service.displayed_pricing_map }.should raise_exception(TypeError)
    end
  end

  describe 'current_pricing_map' do

    it 'should raise an exception if there are no pricing maps' do
      service = FactoryGirl.create(:service)
      service.pricing_maps.delete_all
      lambda { service.current_pricing_map }.should raise_exception(ArgumentError)
    end

    it 'should return the only pricing map if there is one pricing map and it is in the past' do
      service = FactoryGirl.create(:service, :pricing_map_count => 1)
      service.pricing_maps[0].display_date = Date.today - 1
      service.current_pricing_map.should eq service.pricing_maps[0]
    end

    it 'should return the most recent pricing map in the past if there is more than one' do
      service = FactoryGirl.create(:service, :pricing_map_count => 2)
      service.pricing_maps[0].display_date = Date.today - 1
      service.pricing_maps[1].display_date = Date.today - 2
      service.current_pricing_map.should eq service.pricing_maps[0]
    end

    it 'should return the pricing map in the past if one is in the past and one is in the future' do
      service = FactoryGirl.create(:service, :pricing_map_count => 2)
      service.pricing_maps[0].display_date = Date.today + 1
      service.pricing_maps[1].display_date = Date.today - 1
      service.current_pricing_map.should eq service.pricing_maps[1]
    end
  end

  describe 'pricing_map_for_date' do

    it 'should raise an exception if there are no pricing maps' do
      service = FactoryGirl.create(:service)
      service.pricing_maps.delete_all
      lambda { service.current_pricing_map }.should raise_exception(ArgumentError)
    end

    it 'should return the pricing map for the given date if there is a pricing map with a display date of that date' do
      service = FactoryGirl.create(:service, :pricing_map_count => 5)
      base_date = Date.parse('2012-01-01')
      service.pricing_maps[0].display_date = base_date + 1
      service.pricing_maps[1].display_date = base_date
      service.pricing_maps[2].display_date = base_date - 1
      service.pricing_maps[3].display_date = base_date - 2
      service.pricing_maps[4].display_date = base_date - 3
      service.pricing_map_for_date(base_date).should eq service.pricing_maps[1]
    end

    # most of these tests would be duplicates of those for
    # current_pricing_map
  end

  describe 'current_effective_pricing_map' do

    it 'should raise an exception if there are no pricing maps' do
      service = FactoryGirl.create(:service)
      service.pricing_maps.delete_all
      lambda { service.current_effective_pricing_map }.should raise_exception(ArgumentError)
    end

    it 'should return the only pricing map if there is one pricing map and it is in the past' do
      service = FactoryGirl.create(:service, :pricing_map_count => 1)
      service.pricing_maps[0].effective_date = Date.today - 1
      service.current_effective_pricing_map.should eq service.pricing_maps[0]
    end

    it 'should return the most recent pricing map in the past if there is more than one' do
      service = FactoryGirl.create(:service, :pricing_map_count => 2)
      service.pricing_maps[0].effective_date = Date.today - 1
      service.pricing_maps[1].effective_date = Date.today - 2
      service.current_effective_pricing_map.should eq service.pricing_maps[0]
    end

    it 'should return the pricing map in the past if one is in the past and one is in the future' do
      service = FactoryGirl.create(:service, :pricing_map_count => 2)
      service.pricing_maps[0].effective_date = Date.today + 1
      service.pricing_maps[1].effective_date = Date.today - 1
      service.current_effective_pricing_map.should eq service.pricing_maps[1]
    end
  end

  describe 'effective_pricing_map_for_date' do
    it 'should raise an exception if there are no pricing maps' do
      service = FactoryGirl.create(:service)
      service.pricing_maps.delete_all
      lambda { service.current_effective_pricing_map }.should raise_exception(ArgumentError)
    end

    it 'should return the pricing map for the given date if there is a pricing map with a effective date of that date' do
      service = FactoryGirl.create(:service, :pricing_map_count => 5)
      base_date = Date.parse('2012-01-01')
      service.pricing_maps[0].effective_date = base_date + 1
      service.pricing_maps[1].effective_date = base_date
      service.pricing_maps[2].effective_date = base_date - 1
      service.pricing_maps[3].effective_date = base_date - 2
      service.pricing_maps[4].effective_date = base_date - 3
      service.effective_pricing_map_for_date(base_date).should eq service.pricing_maps[1]
    end

    # most of these tests would be duplicates of those for
    # current_effective_pricing_map
  end
  
  describe "can_edit_historical_data_on_new" do

    it "should return whether or not the user can edit historical data" do
      identity = FactoryGirl.create(:identity)
      parent = FactoryGirl.create(:organization)

      catalog_manager = FactoryGirl.create(:catalog_manager, :can_edit_historic_data, identity: identity, :organization => parent)
      
      child = FactoryGirl.create(:organization, :parent_id => parent.id)
      
      service = FactoryGirl.create(:service, organization: child)

      service.can_edit_historical_data_on_new?(identity).should eq(true)

    end

    it "should return whether or not the user can edit historical data" do
      identity = FactoryGirl.create(:identity)
      parent = FactoryGirl.create(:organization)

      catalog_manager = FactoryGirl.create(:catalog_manager, identity: identity, :organization => parent)
      
      child = FactoryGirl.create(:organization, :parent_id => parent.id)
      
      service = FactoryGirl.create(:service, organization: child)

      service.can_edit_historical_data_on_new?(identity).should eq(false)

    end
  end
  
  describe "get rate maps" do

    let!(:core) { FactoryGirl.create(:core) }
    let!(:service) { FactoryGirl.create(:service, organization_id: core.id) }
    let!(:pricing_map) { service.pricing_maps[0] }
    let!(:pricing_setup) { FactoryGirl.create(:pricing_setup, display_date: Date.today - 1, federal: 25,
                           corporate: 25, other: 25, member: 25, organization_id: core.id)}

    before(:each) do
      pricing_map.update_attributes(
          full_rate: 100,
          display_date: Date.today - 1)
    end
                                                          
    it "should return a hash with the correct rates" do
      pm = PricingMap.find(pricing_map.id)
      hash = { "federal_rate" => "0.25", "corporate_rate" => "0.25", "other_rate" => "0.25", "member_rate" => "0.25" }
      PricingMap.stub(:rates_from_full).and_return({ federal_rate: 25, corporate_rate: 25, other_rate: 25, member_rate: 25 })
      Service.stub(:fix_service_rate).and_return("0.25")
      service.get_rate_maps(pm.display_date, pm.full_rate).should eq(hash)
    end
  end

  describe "available surveys" do
    let!(:program) { FactoryGirl.create(:program)}
    let!(:core)    { FactoryGirl.create(:core, parent_id: program.id) }
    let!(:service) { FactoryGirl.create(:service, organization_id: core.id) }
    let!(:survey)  { FactoryGirl.create(:survey, title: "System Satisfaction survey", description: nil, access_code: "system-satisfaction-survey", reference_identifier: nil, survey_version: 0) }
    let!(:survey1) { FactoryGirl.create(:survey, title: "System Satisfaction survey", description: nil, access_code: "system-satisfaction-survey", reference_identifier: nil, survey_version: 1) }
    let!(:survey2) { FactoryGirl.create(:survey, title: "System Satisfaction survey", description: nil, access_code: "system-satisfaction-survey", reference_identifier: nil, survey_version: 2) }

    it "should return an array of available surveys for the service" do
      # should find at the program level if this is the only one
      program.associated_surveys.create :survey_id => survey2.id
      service.available_surveys.should include(survey2)

      # now that program and core both have an associated survey it should find the core one
      core.associated_surveys.create :survey_id => survey1.id
      service.reload
      service.available_surveys.should include(survey1)

      # lastly, if the service has an associated survey it should be returned
      service.associated_surveys.create :survey_id => survey.id
      service.reload
      service.available_surveys.should include(survey)
    end
  end
end

