# coding: utf-8
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

RSpec.describe "Line Item" do

  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

  describe 'applicable_rate' do
    it 'should raise an exception if it has a pricing setup but no pricing maps' do
      organization = create(:organization, pricing_setup_count: 1)
      organization.pricing_setups[0].update_attributes(display_date: Date.today - 1)
      service = build(:service, organization_id: organization.id, pricing_map_count: 0)
      service.save!(validate: false)
      project = Project.create(attributes_for(:protocol), validate: false)
      # service_request = ServiceRequest.create(attributes_for(:service_request), protocol_id: project.id, validate: false)
      service_request = ServiceRequest.create(attributes_for(:service_request, protocol_id: project.id)); service_request.save!(validate: false); service_request
      line_item = create(:line_item, service_id: service.id, service_request_id: service_request.id)
      expect(lambda { line_item.applicable_rate }).to raise_exception(ArgumentError)
    end

    it 'should raise an exception if it has a pricing map but no pricing setups' do
      organization = create(:organization, pricing_setup_count: 0)
      service = create(:service, organization_id: organization.id, pricing_map_count: 1)
      service.pricing_maps[0].update_attributes(display_date: Date.today - 1)

      project = Project.create(attributes_for(:protocol))
      service_request = ServiceRequest.create(attributes_for(:service_request, protocol_id: project.id)); service_request.save!(validate: false); service_request
      line_item = create(:line_item, service_id: service.id, service_request_id: service_request.id)
      expect(lambda { line_item.applicable_rate }).to raise_exception(ArgumentError)
    end

    it 'should call applicable_rate on the pricing map of a project with the applied percentage and rate type returned by the pricing setup' do
      # TODO: it's obvious by the complexity of this test that
      # applicable_rate() is doing too much, but I'm not sure how to
      # refactor it to be simpler.

      project = Project.create(attributes_for(:protocol))
      project.save(validate: false)

      organization = create(:organization, pricing_setup_count: 1)
      organization.pricing_setups[0].update_attributes(display_date: Date.today - 1)

      service = create(:service, organization_id: organization.id, pricing_map_count: 1)
      service.pricing_maps[0].update_attributes(display_date: Date.today)

      service_request = ServiceRequest.create(attributes_for(:service_request, protocol_id: project.id)); service_request.save!(validate: false); service_request
      service_request.save(validate: false)
      line_item = create(:line_item, service_id: service.id, service_request_id: service_request.id)
      allow(line_item.service_request.protocol).to receive(:funding_status).and_return('funded')
      allow(line_item.service_request.protocol).to receive(:funding_source).and_return('college')

      allow(line_item.service.organization.pricing_setups[0]).to receive(:rate_type).
        with('college').
        and_return('federal')
      allow(line_item.service.organization.pricing_setups[0]).to receive(:applied_percentage).
        with('federal').
        and_return(0.42)

      service.pricing_maps[0] = double(display_date: Date.today - 1)
      allow(line_item.service.pricing_maps[0]).to receive(:applicable_rate).with('federal', 0.42)

      line_item.applicable_rate
    end

    it 'should call applicable_rate on the pricing map of a study with the applied percentage and rate type returned by the pricing setup' do
      # TODO: it's obvious by the complexity of this test that
      # applicable_rate() is doing too much, but I'm not sure how to
      # refactor it to be simpler.

      study = Study.create(attributes_for(:protocol))
      study.save(validate: false)

      organization = create(:organization, pricing_setup_count: 1)
      organization.pricing_setups[0].update_attributes(display_date: Date.today - 1)

      service = create(:service, organization_id: organization.id, pricing_map_count: 1)
      service.pricing_maps[0].update_attributes(display_date: Date.today)

      service_request = build(:service_request, protocol_id: study.id)
      service_request.save(validate: false)
      line_item = create(:line_item, service_id: service.id, service_request_id: service_request.id)
      allow(line_item.service_request.protocol).to receive(:funding_source_based_on_status).and_return('college')

      allow(line_item.service.organization.pricing_setups[0]).to receive(:rate_type).
        with('college').
        and_return('federal')
      allow(line_item.service.organization.pricing_setups[0]).to receive(:applied_percentage).
        with('federal').
        and_return(0.42)

      service.pricing_maps[0] = double(display_date: Date.today - 1)
      allow(line_item.service.pricing_maps[0]).to receive(:applicable_rate).
        with('federal', 0.42)

      line_item.applicable_rate
    end

    context "admin rate" do

      before :each do
        @admin_rate = create(:admin_rate, line_item_id: line_item2.id, admin_cost: 500)
      end

      it "should return the admin rate if there is an admin_rate object with a valid cost" do
        expect(line_item2.applicable_rate).to eq(500)
      end

      it "should return the last admin cost if there are multiple admin rates" do
        admin_rate2 = create(:admin_rate, line_item_id: line_item2.id, admin_cost: 1000)
        expect(line_item2.applicable_rate).to eq(1000)
      end

      it "should return the pricing map cost if the last admin rate's cost id nil" do
        admin_rate2 = create(:admin_rate, line_item_id: line_item2.id)
        expect(line_item2.applicable_rate).to eq(3000)
      end

      it "should return the pricing map cost if there are no admin rate's" do
        @admin_rate.update_attributes(line_item_id: line_item.id)
        expect(line_item2.applicable_rate).to eq(3000)
      end
    end
  end

  context "business methods" do

    describe "per_unit_cost" do

      before(:each) do
        allow(line_item).to receive(:applicable_rate) { 100 }
      end

      it "should return the per unit cost for full quantity with no arguments" do
        expect(line_item.per_unit_cost).to eq(100)
      end

      it "should return 0 if the quantity is 0" do
        line_item.quantity = 0
        expect(line_item.per_unit_cost).to eq(0)
      end

      it "should return the per unit cost for a specific quantity from arguments" do
        line_item1 = line_item.dup
        line_item2 = line_item.dup
        line_item1.quantity = 5
        expect(line_item1.per_unit_cost).to eq(line_item2.per_unit_cost(5))
      end
    end

    describe "units per package" do

      it "should select the correct pricing map based on display date" do
        pricing_map2.update_attributes(display_date: Time.now + 1.day)
        pricing_map2.update_attributes(unit_factor: 10)
        expect(line_item.units_per_package).to eq(1)
      end

      it "should set units per package to 1 if the pricing map does not have a unit factor" do
        expect(line_item.units_per_package).to eq(1)
      end
    end

    describe "cost calculations" do

      before :each do
        add_visits
      end

      context "direct costs for one time fee" do

        it "should return the correct direct cost with a unit factor of 1" do
          service.update_attributes(one_time_fee: true)
          line_item.update_attributes(quantity: 10)
          expect(line_item.reload.direct_costs_for_one_time_fee).to eq(10000)
        end

        it "should return the correct direct cost with a unit factor other than 1" do
          pricing_map.update_attributes(unit_factor: 6)
          line_item.update_attributes(quantity: 10)
          expect(line_item.reload.direct_costs_for_one_time_fee).to eq(2000.0)
        end

        it "should return zero if quantity is nil" do
          line_item.update_attribute(:quantity, nil)
          expect(line_item.reload.direct_costs_for_one_time_fee).to eq(0)
        end
      end

      context "indirect cost rate" do

        it "should return the correct indirect cost rate related to the line item" do
          if USE_INDIRECT_COST
            expect(line_item.indirect_cost_rate).to eq(2.0)
          else
            expect(line_item.indirect_cost_rate).to eq(0)
          end
        end
      end

      context "indirect costs for one time fee" do

        it "should return the correct indirect cost" do
          service.update_attributes(one_time_fee: true)
          line_item.update_attributes(quantity: 10)
          if USE_INDIRECT_COST
            expect(line_item.indirect_costs_for_one_time_fee).to eq(400)
          else
            expect(line_item.indirect_costs_for_one_time_fee).to eq(0)
          end
        end

        it "should return zero if the displayed pricing map is excluded from indirect costs" do
          service.update_attributes(one_time_fee: true)
          pricing_map.update_attributes(exclude_from_indirect_cost: true)
          expect(line_item.indirect_costs_for_one_time_fee).to eq(0)
        end
      end

      context "direct costs for one time fees with fulfillments" do

        let!(:otf_line_item) { create(:line_item, service_request_id: service_request.id, service_id: service.id, sub_service_request_id: sub_service_request.id, quantity: 5, units_per_quantity: 1) }
        let!(:fulfillment1)  { create(:fulfillment, quantity: 5, line_item_id: otf_line_item.id, date: Date.yesterday.strftime("%m/%d/%Y"), time: 1.23) }
        let!(:fulfillment2)  { create(:fulfillment, quantity: 5, line_item_id: otf_line_item.id, date: Date.today.strftime("%m/%d/%Y"), time: 1.23) }
        let!(:fulfillment3)  { create(:fulfillment, quantity: 5, line_item_id: otf_line_item.id, date: Date.today.strftime("%m/%d/%Y"), time: 1.23) }
        let!(:pricing_map2)  { create(:pricing_map, service_id: service.id, unit_type: 'ea', effective_date: Date.today, display_date: Date.today, full_rate: 600, exclude_from_indirect_cost: 0, unit_minimum: 1)}

        it "should correctly calculate a line item's cost that has multiple fulfillments" do
          # quantity:10 * rate:(percentage:0.5 * cost:600)
          expect(otf_line_item.direct_cost_for_one_time_fee_with_fulfillments(Date.today, Date.today)).to eq(3000.0)
        end

        it "should correctly calculate a line item's cost that has a unit factor greater than one" do
          pricing_map2.update_attributes(unit_factor: 5)
          fulfillment3 = create(:fulfillment, quantity: 6, line_item_id: otf_line_item.id, date: Date.today.strftime("%m/%d/%Y"), time: 1.23)
          # ceiling(quantity:16/unit_factor:5) * rate:(percentage:0.5 * cost:600)
          expect(otf_line_item.reload.direct_cost_for_one_time_fee_with_fulfillments(Date.today, Date.today)).to eq(1200.0)
        end

        it "should correctly calculate a line item's cost for a fulfillment that has historical pricing" do
          # quantity:5 * rate:(percentage:0.5 * cost:2000)
          expect(otf_line_item.direct_cost_for_one_time_fee_with_fulfillments(Date.yesterday, Date.yesterday)).to eq(5000.0)
        end
      end
    end
  end

  context "validations for one time fees" do
    let!(:study)               { Study.create(attributes_for(:protocol)) }
    let!(:organization)        { create(:organization, :pricing_setup_count => 1) }
    let!(:service)             { create(:service, :organization_id => organization.id, :pricing_map_count => 1, one_time_fee: true) }
    let!(:service_request)     { build(:service_request_without_validations, protocol_id: study.id) }
    let!(:sub_service_request) { create(:sub_service_request, service_request_id: service_request.id, organization_id: organization.id) }
    let!(:pricing_map)         { create(:pricing_map, service_id: service.id, unit_type: 'ea', effective_date: Date.today, display_date: Date.today, full_rate: 600, exclude_from_indirect_cost: 0, unit_minimum: 1, units_per_qty_max: 10, quantity_minimum: 1) }
    let!(:otf_line_item)       { create(:line_item, service_request_id: service_request.id, service_id: service.id, sub_service_request_id: sub_service_request.id, quantity: 5, units_per_quantity: 1) }

    it 'should validate the numericality' do
      otf_line_item.quantity = 'kjhkjh'

      expect(otf_line_item.valid?).to_not be
    end

    it "should validate that it is greater than the minimum" do
      otf_line_item.quantity = 0

      expect(otf_line_item.valid?).to_not be
    end

    it "should validate that it is less than the maximum" do
      otf_line_item.quantity = 11

      expect(otf_line_item.valid?).to_not be
    end
  end

  context "service abbreviation" do
    let!(:organization) { create(:organization) }
    let!(:protocol)     { create(:study_without_validations, primary_pi: create(:identity)) }
    let!(:sr)           { create(:service_request_without_validations, protocol: protocol) }
    let!(:ssr)          { create(:sub_service_request_without_validations, service_request: sr, organization: organization) }
    let!(:service)      { create(:service, abbreviation: 'abc') }
    let!(:line_item)    { create(:line_item_without_validations, service: service, sub_service_request: ssr) }

    before :each do
      ssr.update_attribute(:ssr_id, "0001")
    end

    it "should return the abbreviation" do
      expect(line_item.display_service_abbreviation).to eq("(0001) abc")
    end

    it "should concatenate cpt code to the abbreviation if it exists" do
      service.update_attributes(cpt_code: "def")
      expect(line_item.display_service_abbreviation).to eq("(0001) abc (def)")
    end
  end
end
