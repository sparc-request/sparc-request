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

require 'date'
require 'rails_helper'

RSpec.describe Service, type: :model do

  let_there_be_lane
  let_there_be_j
  build_service_request_with_project

  context 'callbacks' do

    context '#around_update' do

      describe '#notify_remote_around_update', delay: true do

        before do
          research_nexus_program  = create(:program, name: 'Research Nexus')
          organization            = create(:core, name: 'Core 1', parent_id: research_nexus_program.id)
          service                 = create(:service, organization: organization)

          work_off

          service.update_attribute :components, 'Test'
        end

        it 'should create a RemoteServiceNotifierJob' do
          expect(Delayed::Job.where("handler LIKE '%RemoteServiceNotifierJob%'").one?).to be
        end
      end
    end
  end

  describe 'parents' do

    it 'should return an array with only the organization if there are no parents' do
      service.update_attributes(organization_id: institution.id)
      expect(service.parents).to eq [ institution ]
    end

    it 'should return an array with the organization and its parent if there is a parent' do
      expect(service.parents).to include(program, provider, institution)
    end
  end

  describe "organization" do

    let!(:core) { create(:core, parent_id: program.id) }

    context 'core' do

      it 'should return nil if the organization is not a core' do
        expect(service.core).to eq(nil)
      end

      it 'should return the organization if the organization is a core' do
        service.update_attributes(organization_id: core.id)
        expect(service.core).to eq(core)
      end
    end

    context 'program' do

      it 'should return nil if the organization is neither a core nor a program' do
        service.update_attributes(organization_id: institution.id)
        expect(service.program).to eq(nil)
      end

      it 'should return the program if the organization is a program' do
        expect(service.program).to eq(program)
      end

      it 'should return the program the core belongs to if the organization is a core' do
        service.update_attributes(organization_id: core.id)
        expect(service.program).to eq(program)
      end
    end

    context 'provider' do

      it "should return nil if the organization is an insitution" do
        service.update_attributes(organization_id: institution.id)
        expect(service.provider).to eq nil
      end

      it "should return the provider if the organization is a provider" do
        service.update_attributes(organization_id: provider.id)
        expect(service.provider).to eq(provider)
      end

      it "should return the provider if the organization is a program" do
        service.update_attributes(organization_id: program.id)
        expect(service.provider).to eq(provider)
      end

      it "should return the provider the core belongs to if the organization is a core" do
        service.update_attributes(organization_id: core.id)
        expect(service.provider).to eq(provider)
      end
    end

    context 'institution' do

      it "should return the institution is the organization is an institution" do
        service.update_attributes(organization_id: institution.id)
        expect(service.institution).to eq(institution)
      end

      it "should return the institution if the organization is a provider" do
        service.update_attributes(organization_id: provider.id)
        expect(service.institution).to eq(institution)
      end

      it "should return the institution is the organization is a program" do
        service.update_attributes(organization_id: program.id)
        expect(service.institution).to eq(institution)
      end

      it "should return the insitution if the organization is a core" do
        service.update_attributes(organization_id: core.id)
        expect(service.institution).to eq(institution)
      end
    end
  end

  describe 'dollars_to_cents' do

    it "should return the correct cents for a given dollar amount" do

      amount = 0

      1000.times do
        expect(Service.dollars_to_cents("#{amount / 100.00}")).to eq(amount)
        amount = amount + 1
      end
    end
  end

  describe 'cents_to_dollars' do
    it 'should return nil given nil' do
      expect(Service.cents_to_dollars(nil)).to eq nil
    end

    it 'should return 1 dollar given 100 cents' do
      expect(Service.cents_to_dollars(100)).to eq 1
    end

    it 'should return 2.5 dollars given 250 cents' do
      expect(Service.cents_to_dollars(250)).to eq 2.5
    end
  end

  describe "display attribute" do

    let!(:service)    { create(:service, name: "Foo", abbreviation: "abc") }

    context "service name" do

      it "should return the service name" do
        expect(service.display_service_name).to eq("Foo")
      end

      it "should concatenate cpt code to the name if it exists" do
        service.update_attributes(cpt_code: "Bar")
        expect(service.display_service_name).to eq("Foo (Bar)")
      end
    end
  end

  describe "displayed pricing map" do

    let!(:service) { create(:service) }

    it "should raise an exception if there are no pricing maps" do
      service.pricing_maps.delete_all
      expect(lambda { service.displayed_pricing_map }).to raise_exception(ArgumentError)
    end

    it "should raise an exception if there are no current pricing maps" do
      service.pricing_maps.delete_all
      pricing_map = create(:pricing_map, service_id: service.id, display_date: Date.today + 1)
      expect(lambda { service.displayed_pricing_map }).to raise_exception(ArgumentError)
    end

    it "should raise an exception if the display date is nil" do
      pricing_map = service.pricing_maps[0]
      pricing_map.update_attributes(display_date: nil)
      expect(lambda { service.displayed_pricing_map }).to raise_exception(TypeError)
    end
  end

  # This method is only used for the service pricing report
  describe 'pricing map for date' do

    it 'should return false if there are no pricing maps' do
      service = create(:service)
      expect(service.pricing_map_for_date('1999-04-14')).to eq(false)
    end

    it 'should return the most current pricing map with a display date on or after a given date' do
      service = create(:service)
      new_map = create(:pricing_map_without_validations, display_date: '2014-04-12', service: service)
      expect(expect(service.pricing_map_for_date('2014-04-14')).to eq(service.pricing_maps.first))
    end
  end

  describe 'current_effective_pricing_map' do

    it 'should raise an exception if there are no pricing maps' do
      service = create(:service)
      service.pricing_maps.delete_all
      expect(lambda { service.current_effective_pricing_map }).to raise_exception(ArgumentError)
    end

    it 'should return the only pricing map if there is one pricing map and it is in the past' do
      service = create(:service, pricing_map_count: 1)
      service.pricing_maps[0].effective_date = Date.today - 1
      expect(service.current_effective_pricing_map).to eq service.pricing_maps[0]
    end

    it 'should return the most recent pricing map in the past if there is more than one' do
      service = create(:service, pricing_map_count: 2)
      service.pricing_maps[0].effective_date = Date.today - 1
      service.pricing_maps[1].effective_date = Date.today - 2
      expect(service.current_effective_pricing_map).to eq service.pricing_maps[0]
    end

    it 'should return the pricing map in the past if one is in the past and one is in the future' do
      service = create(:service, pricing_map_count: 2)
      service.pricing_maps[0].effective_date = Date.today + 1
      service.pricing_maps[1].effective_date = Date.today - 1
      expect(service.current_effective_pricing_map).to eq service.pricing_maps[1]
    end
  end

  describe 'effective_pricing_map_for_date' do
    it 'should raise an exception if there are no pricing maps' do
      service = create(:service)
      service.pricing_maps.delete_all
      expect(lambda { service.current_effective_pricing_map }).to raise_exception(ArgumentError)
    end

    it 'should return the pricing map for the given date if there is a pricing map with a effective date of that date' do
      service = create(:service, pricing_map_count: 5)
      base_date = Date.parse('2012-01-01')
      service.pricing_maps[0].effective_date = base_date + 1
      service.pricing_maps[1].effective_date = base_date
      service.pricing_maps[2].effective_date = base_date - 1
      service.pricing_maps[3].effective_date = base_date - 2
      service.pricing_maps[4].effective_date = base_date - 3
      expect(service.effective_pricing_map_for_date(base_date)).to eq service.pricing_maps[1]
    end

    # most of these tests would be duplicates of those for
    # current_effective_pricing_map
  end

  describe "can_edit_historical_data_on_new" do

    it "should return whether or not the user can edit historical data" do
      identity = create(:identity)
      parent = create(:organization)

      catalog_manager = create(:catalog_manager, :can_edit_historic_data, identity: identity, organization: parent)

      child = create(:organization, parent_id: parent.id)

      service = create(:service, organization: child)

      expect(service.can_edit_historical_data_on_new?(identity)).to eq(true)

    end

    it "should return whether or not the user can edit historical data" do
      identity = create(:identity)
      parent = create(:organization)

      catalog_manager = create(:catalog_manager, identity: identity, organization: parent)

      child = create(:organization, parent_id: parent.id)

      service = create(:service, organization: child)

      expect(service.can_edit_historical_data_on_new?(identity)).to eq(false)

    end
  end

  describe "get rate maps" do

    let!(:core) { create(:core) }
    let!(:service) { create(:service, organization_id: core.id) }
    let!(:pricing_map) { service.pricing_maps[0] }
    let!(:pricing_setup) { create(:pricing_setup, display_date: Date.today - 1, federal: 25,
                           corporate: 25, other: 25, member: 25, organization_id: core.id)}

    before(:each) do
      pricing_map.update_attributes(
          full_rate: 100,
          display_date: Date.today - 1)
    end

    it "should return a hash with the correct rates" do
      pm    = PricingMap.find(pricing_map.id)
      hash  = { "federal_rate" => "0.25", "corporate_rate" => "0.25", "other_rate" => "0.25", "member_rate" => "0.25" }

      allow(PricingMap).to receive(:rates_from_full).and_return({ federal_rate: 25, corporate_rate: 25, other_rate: 25, member_rate: 25 })
      allow(Service).to receive(:fix_service_rate).and_return("0.25")

      expect(service.get_rate_maps(pm.display_date, pm.full_rate)).to eq(hash)
    end
  end

  describe "available surveys" do
    # let!(:program) { create(:program)}
    # let!(:core)    { create(:core, parent_id: program.id) }
    # let!(:service) { create(:service, organization_id: core.id) }
    let!(:survey)  { create(:survey, title: "System Satisfaction survey", description: nil, access_code: "system-satisfaction-survey", reference_identifier: nil, survey_version: 0) }
    let!(:survey1) { create(:survey, title: "System Satisfaction survey", description: nil, access_code: "system-satisfaction-survey", reference_identifier: nil, survey_version: 1) }
    let!(:survey2) { create(:survey, title: "System Satisfaction survey", description: nil, access_code: "system-satisfaction-survey", reference_identifier: nil, survey_version: 2) }

    it "should return an array of available surveys for the service" do
      service.update_attributes(organization_id: core.id)
      service.reload
      # should find at the program level if this is the only one
      program.associated_surveys.create survey_id: survey2.id
      expect(service.available_surveys).to include(survey2)

      # now that program and core both have an associated survey it should find the core one
      core.associated_surveys.create survey_id: survey1.id
      service.reload
      expect(service.available_surveys).to include(survey1)

      # lastly, if the service has an associated survey it should be returned
      service.associated_surveys.create survey_id: survey.id
      service.reload
      expect(service.available_surveys).to include(survey)
    end
  end

  describe "#remotely_notify", delay: true do
    context "around_update" do

      it "should create a Delayed::Job" do
        service = FactoryGirl.create(:service_with_components)
        work_off
        service.update_attribute(:components, "dum,spiro,spero,")

        expect(Delayed::Job.where(queue: "remote_service_notifier").count).to eq(1)
      end
    end
  end
end
