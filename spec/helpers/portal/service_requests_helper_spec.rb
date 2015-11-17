# coding: utf-8
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

require 'rails_helper'

RSpec.describe Portal::ServiceRequestsHelper do
  let_there_be_lane
  let_there_be_j
  build_study
  build_service_request_with_study

  include Portal::ApplicationHelper
  include Portal::ServiceRequestsHelper

  context '#service_selected' do
    it 'should return whether or not an option is selected' do
      expect(service_selected('Test', 'Thing')).to be_falsey
    end

    it 'should return whether or not an option is selected' do
      expect(service_selected('Test', 'Test')).to be_truthy
    end
  end

  context '#timeframe_selected' do
    it 'should return whether or not an option is selected' do
      expect(timeframe_selected('Test', 'Thing')).to be_falsey
    end

    it 'should return whether or not an option is selected' do
      expect(timeframe_selected('Test', 'Test')).to be_truthy
    end
  end

  context '#populate_fulfillment_time' do
    it 'should convert time from minutes to whatever timeframe is selected' do
      fulfillment = {'timeframe' => 'Days', 'time' => '1440'}
      expect(populate_fulfillment_time(fulfillment)).to eq 1.0
    end

    it 'should return accept image if boolean is true' do
      fulfillment = {'timeframe' => 'Hours', 'time' => '120'}
      expect(populate_fulfillment_time(fulfillment)).to eq 2.0
    end

    it 'should return accept image if boolean is true' do
      fulfillment = {'timeframe' => 'Min', 'time' => '200'}
      expect(populate_fulfillment_time(fulfillment)).to eq '200'
    end
  end

  context '#default_display' do
    it "should be shown when it's the selected status" do
      expect(default_display('submitted', 'submitted')).to eq('')
    end

    it "should be hidden when it's not the selected status" do
      expect(default_display('submitted', 'draft')).to eq("display:none;")
    end
  end

  context '#calculate_status_quantity' do
    it "should display the status quantity" do
      srq = [
        double('ServiceRequest', status: 'Submitted'),
        double('ServiceRequest', status: 'Submitted'),
        double('ServiceRequest', status: 'Submitted'),
        double('ServiceRequest', status: 'Submitted'),
      ]
      expect(calculate_status_quantity(srq, "Submitted")).to eq(4)
    end

    it "should display the status quantity" do
      expect(calculate_status_quantity([], '')).to eq(0)
    end
  end

  context '#display_requester' do
    it "should combine first and last names into a string" do
      requester = {'first_name' => "Duke", 'last_name' => "Ellington"}
      expect(display_requester(requester)).to eq("Duke Ellington")
    end
  end

  context '#display_pi' do
    let(:roles) { [{'role' => 'pi', 'first_name' => "Roberto", 'last_name' => "Pearce"}, {'role' => 'BAMF', 'first_name' => "Nick", 'last_name' => "B"}] }

    it "should display the first and last name of the person with the PI role" do
      expect(display_pi(roles)).to eq("Roberto Pearce")
    end
  end

  # Method not being used anywhere -rp
  # context :max_visit_count do
  #   pending "Test this method when you get to fulfillment"
  # end

  context '#pre_select_billing_type' do
    it "should preselect the billing type" do
      expect(pre_select_billing_type("dude", "sup")).to be_falsey
    end

    it "should preselect the billing type" do
      expect(pre_select_billing_type("dude", "dude")).to be_truthy
    end
  end

  context '#display_visit_quantity' do
    let(:li)      { double('LineItem', service_id: '1234', visits: [{"quantity"=>1, "billing"=>"R"}]) }
    let(:service) { double('Service', id: '1234') }
    let(:html)    { '<td class="visit_quantity" id="quantity_1234_column_1">$0.01</td>' }

    module Business
      module Pricing
      end
    end

    before do
      allow(li).to receive(:service).and_return(service)
      @visits_array = [{:values=>[{:quantity=>1, :service_id=>"1234"}]}]
      expect(self).to receive(:determine_package_cost).and_return(1000)
      expect(self).to receive(:sub_totals).and_return([1, 2, 3])
    end

    it 'should return html for the visits table' do
      expect(display_visit_quantity(li)).to include(html)
    end

    it "should return td's with unique id's" do
      id = /id="quantity_\d+_column_(\d+)"/
      expect(display_visit_quantity(li).scan(id)).to eq [["1"], ["2"], ["3"], ["4"], ["5"]]
    end

    it 'should render remaining 4 columns even if there is only 1 visit' do
      expect(display_visit_quantity(li).scan(/<td/).count).to eq 5
    end
  end

  context '#create_quantity_content_tag' do
    it 'should create a visit header td content tag' do
      expect(self).to receive(:content_tag).with(:td, 'asdf', {class: 'visit_quantity', id: "quantity_1234_column_12345"}).and_return('<td>')
      expect(create_quantity_content_tag('asdf', 1234, 12345)).to eq('<td>')
    end
  end

  context '#display_cost_per_service' do
    let(:quantity)  { '2' }
    let(:full_rate) { '50000' }

    it 'should return a correct cost given a quantity and a pricing rate' do
      expect(display_cost_per_service(quantity, full_rate)).to eq('$1000.00')
    end
  end

  context '#display_service_total' do
    let(:li)  { LineItem.new("service_id"=>"123", "quantity"=>0, "optional"=>true) }
    let(:li2) { LineItem.new("service_id"=>"321", "quantity"=>6, "optional"=>true, "sub_service_request_id"=>"0003") }

    before do
      lis = [li, li2]
      lis.each { |l| allow(l).to receive(:service).and_return(1) }
      expect(self).to receive(:sub_totals).and_return([1, 2, 3])
    end

    it 'should return a string of html with the correct amount for per-patient-per-visit' do
      expect(self).to receive(:determine_package_cost).and_return(100)
      expect(self).to receive(:two_decimal_places).and_return('900.00')
      expect(display_service_total(li)).to eq '$900.00'
    end

    it 'should return a string of html with the correct amount given a one time fee' do
      expect(self).to receive(:determine_package_cost).and_return(1000)
      expect(self).to receive(:two_decimal_places).and_return('9000.00')
      expect(display_service_total(li2)).to eq '$9000.00'
    end
  end

  # TODO: Core (Organization) no longer has attributes like this
  # context :services_are_available do
  #   let (:core) { Core.new('attributes' => {'is_available' => true}) }
  #   let (:service) { Service.new(is_available: true) }
  #   let (:hash) { {name: 'dude'} }
  #   let (:li) { LineItem.new(service: Service.new(name: 'dude') ) }

  #   it "the services should be available" do
  #     services_are_available(service, hash, li, core).should eq true
  #   end

  #   it "the services should not be available if the core has the false flag set" do
  #     core.attributes['is_available'] = false
  #     services_are_available(service, hash, li, core).should eq false
  #   end

  #   it "the services should not be available if the service has the false flag" do
  #     service.is_available = false
  #     services_are_available(service, hash, li, core).should eq false
  #   end
  # end
end
