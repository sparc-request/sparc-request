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

def add_visits_to_arm_line_item(arm, line_item, n=arm.visit_count)
  line_items_visit = LineItemsVisit.for(arm, line_item)

  n.times do |index|
    FactoryGirl.create(:visit_group, arm_id: arm.id, day: index )
  end

  n.times do |index|
     FactoryGirl.create(:visit, quantity: 0, line_items_visit_id: line_items_visit.id, visit_group_id: arm.visit_groups[index].id)
  end
end

describe ServiceCalendarsController do
  
  let_there_be_lane
  fake_login_for_each_test
  let_there_be_j
  build_service_request_with_project
  stub_controller
  stub_portal_controller
  
  before(:each) do
    session[:identity_id] = jug2
    add_visits
  end

  describe 'GET table' do
    it 'should set tab to whatever was passed in' do
      session[:service_request_id] = service_request.id

      get :table, {
        :format => :js,
        :tab => 'foo',
        :service_request_id => service_request.id,
      }.with_indifferent_access

      assigns(:tab).should eq 'foo'
    end

    it 'should set the visit page for the service request' do
      ServiceRequest.any_instance.
        should_receive(:set_visit_page).
        with(42, arm1).
        and_return(12)

      ServiceRequest.any_instance.
        should_receive(:set_visit_page).
        with(0, arm2).
        and_return(13)

      session[:service_request_id] = service_request.id
      session[:service_calendar_pages] = { arm1.id.to_s => 42 }
        
      get :table, {
        :format => :js,
        :tab => 'foo',
        :service_request_id => service_request.id,
      }.with_indifferent_access

      assigns(:pages).should eq({ arm1.id => 12, arm2.id => 13 })
    end
  end

  describe 'POST update' do
    it 'should set visit to the given visit' do
      visit = arm1.visits[0]

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :tab                 => 'foo',
        :service_request_id  => service_request.id,
        :line_item           => line_item.id,
        :visit               => visit.id,
      }.with_indifferent_access

      assigns(:visit).should eq visit
    end

    it 'should set line_item to the given line item if it exists' do
      visit = arm1.visits[0]

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :tab                 => 'foo',
        :service_request_id  => service_request.id,
        :line_item           => line_item.id,
        :visit               => visit.id,
      }.with_indifferent_access

      assigns(:line_item).should eq line_item
    end

    it "should set line_item to the visit's line item if there is no line item given" do
      visit = arm1.visits[0]

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :tab                 => 'foo',
        :service_request_id  => service_request.id,
        :line_item           => nil,
        :visit               => visit.id,
      }.with_indifferent_access

      assigns(:line_item).should eq visit.line_items_visit.line_item
    end

    it 'should set subject count on the visit grouping if on the template tab' do
      visit = arm1.visits[0]
      line_items_visit = visit.line_items_visit

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :service_request_id  => service_request.id,
        :line_items_visit    => line_items_visit.id,
        :line_item           => line_item.id,
        :visit               => visit.id,
        :qty                 => 240,
        :tab                 => 'template',
      }.with_indifferent_access

      line_items_visit.reload
      line_items_visit.subject_count.should eq 240
    end

    it 'should set all the quantities to 0 if on the template tab and there is no line item and checked is false' do
      visit = arm1.visits[0]
      visit.update_attributes(:research_billing_qty => 0)

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :service_request_id  => service_request.id,
        :line_item           => nil,
        :visit               => visit.id,
        :tab                 => 'template',
        :checked             => 'false',
      }.with_indifferent_access

      visit.reload

      visit.quantity.should eq 0
      visit.research_billing_qty.should eq 0
      visit.insurance_billing_qty.should eq 0
      visit.effort_billing_qty.should eq 0
    end

    it 'should give an error if on the quantity tab and quantity is less than 0' do
      visit = arm1.visits[0]
      visit.update_attributes(:research_billing_qty => 0)

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :service_request_id  => service_request.id,
        :line_item           => nil,
        :visit               => visit.id,
        :tab                 => 'quantity',
        :qty                 => -1,
      }.with_indifferent_access

      assigns(:errors).should eq "Quantity must be greater than zero"
    end

    it 'should update quantity on the visit if on the quantity tab and quantity is 0' do
      visit = arm1.visits[0]
      visit.update_attributes(:research_billing_qty => 0)

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :service_request_id  => service_request.id,
        :line_item           => nil,
        :visit               => visit.id,
        :tab                 => 'quantity',
        :qty                 => 0
      }.with_indifferent_access

      visit.reload

      visit.quantity.should eq 0
    end

    it 'should update quantity on the visit if on the quantity tab and quantity is greater than 0' do
      LineItem.any_instance.stub_chain(:service, :displayed_pricing_map, :unit_minimum) { 120 }

      visit = arm1.visits[0]
      visit.update_attributes(:research_billing_qty => 0)

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :service_request_id  => service_request.id,
        :line_item           => nil,
        :visit               => visit.id,
        :tab                 => 'quantity',
        :qty                 => 18
      }.with_indifferent_access

      visit.reload

      visit.quantity.should eq 18
    end

    it 'should give an error if on the billing strategy tab and quantity is less than 0' do
      visit = arm1.visits[0]
      visit.update_attributes(:research_billing_qty => 0)

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :service_request_id  => service_request.id,
        :line_item           => nil,
        :visit               => visit.id,
        :tab                 => 'billing_strategy',
        :qty                 => -1,
      }.with_indifferent_access

      assigns(:errors).should eq "Quantity must be greater than zero"
    end

    it 'should update the given column on the visit if on the billing strategy tab and quantity is 0' do
      visit = arm1.visits[0]
      visit.update_attributes(:research_billing_qty => 0)
      visit.update_attributes(:effort_billing_qty => 42)

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :service_request_id  => service_request.id,
        :line_item           => nil,
        :visit               => visit.id,
        :tab                 => 'billing_strategy',
        :qty                 => 0,
        :column              => 'effort_billing_qty',
      }.with_indifferent_access

      visit.reload

      visit.effort_billing_qty.should eq 0
    end

    it 'should update the given column on the visit if on the billing strategy tab and quantity is greater than 0' do
      visit = arm1.visits[0]
      visit.update_attributes(:research_billing_qty => 0)
      visit.update_attributes(:effort_billing_qty => 42)

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :service_request_id  => service_request.id,
        :line_item           => nil,
        :visit               => visit.id,
        :tab                 => 'billing_strategy',
        :qty                 => 100,
        :column              => 'effort_billing_qty',
      }.with_indifferent_access

      visit.reload

      visit.effort_billing_qty.should eq 100
    end

    it 'should update quantity on the visit to the total if on the billing strategy tab' do
      visit = arm1.visits[0]
      visit.update_attributes(:research_billing_qty => 8)
      visit.update_attributes(:insurance_billing_qty => 17)
      visit.update_attributes(:effort_billing_qty => 42)

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :service_request_id  => service_request.id,
        :line_item           => nil,
        :visit               => visit.id,
        :tab                 => 'billing_strategy',
        :qty                 => 100,
        :column              => 'effort_billing_qty',
      }.with_indifferent_access

      visit.reload

      visit.quantity.should eq(8 + 17 + 42)
    end
  end

  context('calendar methods') do
    let!(:service1) {
      service = FactoryGirl.create(:service, pricing_map_count: 1, organization_id: program.id)
      service.pricing_maps[0].update_attributes(display_date: Date.today, is_one_time_fee: false)
      service
    }

    let!(:service2) {
      service = FactoryGirl.create(:service, pricing_map_count: 1, organization_id: program.id)
      service.pricing_maps[0].update_attributes(display_date: Date.today, is_one_time_fee: false)
      service
    }

    let!(:service3) {
      service = FactoryGirl.create(:service, pricing_map_count: 1, organization_id: program.id)
      service.pricing_maps[0].update_attributes(display_date: Date.today, is_one_time_fee: false)
      service
    }

    let!(:pricing_map1) { service1.pricing_maps[0] }
    let!(:pricing_map2) { service2.pricing_maps[0] }
    let!(:pricing_map3) { service3.pricing_maps[0] }

    let!(:line_item1) { FactoryGirl.create(:line_item, service_id: service1.id, service_request_id: service_request.id, sub_service_request_id: sub_service_request.id) }
    let!(:line_item2) { FactoryGirl.create(:line_item, service_id: service2.id, service_request_id: service_request.id, sub_service_request_id: sub_service_request.id) }
    let!(:line_item3) { FactoryGirl.create(:line_item, service_id: service3.id, service_request_id: service_request.id, sub_service_request_id: sub_service_request.id) }

    build_project
    build_arms

    describe 'POST select_calendar_row' do

      it 'should set line item' do
        liv = LineItemsVisit.for(arm1, line_item1)

        pricing_map1.update_attribute(:unit_minimum, 100)
        add_visits_to_arm_line_item(arm1, line_item1, 3)

        session[:service_request_id] = service_request.id
        post :select_calendar_row, {
          :id                   => service_request.id,
          :line_items_visit_id  => liv.id,
          :format               => :js
        }.with_indifferent_access

        assigns(:line_items_visit).should eq liv
      end

      it "should update each of the line item's visits" do
        liv = LineItemsVisit.for(arm1, line_item1)

        pricing_map1.update_attribute(:unit_minimum, 100)
        add_visits_to_arm_line_item(arm1, line_item1, 3)

        session[:service_request_id] = service_request.id
        post :select_calendar_row, {
          :id                   => service_request.id,
          :line_items_visit_id  => liv.id,
          :format               => :js
        }.with_indifferent_access

        liv.visits.count.should eq 3
        liv.visits[0].quantity.should               eq 100
        liv.visits[0].research_billing_qty.should   eq 100
        liv.visits[0].insurance_billing_qty.should  eq 0
        liv.visits[0].effort_billing_qty.should     eq 0
        liv.visits[1].quantity.should               eq 100
        liv.visits[1].research_billing_qty.should   eq 100
        liv.visits[1].insurance_billing_qty.should  eq 0
        liv.visits[1].effort_billing_qty.should     eq 0
        liv.visits[2].quantity.should               eq 100
        liv.visits[2].research_billing_qty.should   eq 100
        liv.visits[2].insurance_billing_qty.should  eq 0
        liv.visits[2].effort_billing_qty.should     eq 0
      end
    end

    describe 'GET unselect_calendar_row' do
      it 'should set line item' do
        liv = LineItemsVisit.for(arm1, line_item1)

        pricing_map1.update_attribute(:unit_minimum, 100)
        add_visits_to_arm_line_item(arm1, line_item1, 3)

        session[:service_request_id] = service_request.id
        post :unselect_calendar_row, {
          :id                   => service_request.id,
          :line_items_visit_id  => liv.id,
          :format               => :js
        }.with_indifferent_access

        assigns(:line_items_visit).should eq liv
      end

      it "should update each of the line item's visits" do
        liv = LineItemsVisit.for(arm1, line_item1)

        pricing_map1.update_attribute(:unit_minimum, 100)
        add_visits_to_arm_line_item(arm1, line_item1, 3)

        session[:service_request_id] = service_request.id
        post :unselect_calendar_row, {
          :id                   => service_request.id,
          :line_items_visit_id  => liv.id,
          :format               => :js
        }.with_indifferent_access

        liv.visits.count.should eq 3
        liv.visits[0].quantity.should               eq 0
        liv.visits[0].research_billing_qty.should   eq 0
        liv.visits[0].insurance_billing_qty.should  eq 0
        liv.visits[0].effort_billing_qty.should     eq 0
        liv.visits[1].quantity.should               eq 0
        liv.visits[1].research_billing_qty.should   eq 0
        liv.visits[1].insurance_billing_qty.should  eq 0
        liv.visits[1].effort_billing_qty.should     eq 0
        liv.visits[2].quantity.should               eq 0
        liv.visits[2].research_billing_qty.should   eq 0
        liv.visits[2].insurance_billing_qty.should  eq 0
        liv.visits[2].effort_billing_qty.should     eq 0
      end
    end

    describe 'GET select_calendar_column' do
      it 'should update each of the visits' do
        pricing_map1.update_attribute(:unit_minimum, 100)
        pricing_map2.update_attribute(:unit_minimum, 100)
        pricing_map3.update_attribute(:unit_minimum, 100)

        add_visits_to_arm_line_item(arm1, line_item1, 3)
        add_visits_to_arm_line_item(arm1, line_item2, 3)
        add_visits_to_arm_line_item(arm1, line_item3, 3)

        session[:service_request_id] = service_request.id
        post :select_calendar_column, {
          :id            => service_request.id,
          :column_id     => 2, # 1-based
          :arm_id        => arm1.id,
          :format        => :js,
        }.with_indifferent_access

        liv = LineItemsVisit.for(arm1, line_item1)
        liv.visits[1].quantity.should               eq 100
        liv.visits[1].research_billing_qty.should   eq 100
        liv.visits[1].insurance_billing_qty.should  eq 0
        liv.visits[1].effort_billing_qty.should     eq 0
        liv.visits[1].quantity.should               eq 100
        liv.visits[1].research_billing_qty.should   eq 100
        liv.visits[1].insurance_billing_qty.should  eq 0
        liv.visits[1].effort_billing_qty.should     eq 0
        liv.visits[1].quantity.should               eq 100
        liv.visits[1].research_billing_qty.should   eq 100
        liv.visits[1].insurance_billing_qty.should  eq 0
        liv.visits[1].effort_billing_qty.should     eq 0
      end
    end

    describe 'GET unselect_calendar_column' do
      it 'should update each of the visits' do
        pricing_map1.update_attribute(:unit_minimum, 100)
        pricing_map2.update_attribute(:unit_minimum, 100)
        pricing_map3.update_attribute(:unit_minimum, 100)

        add_visits_to_arm_line_item(arm1, line_item1, 3)
        add_visits_to_arm_line_item(arm1, line_item2, 3)
        add_visits_to_arm_line_item(arm1, line_item3, 3)

        session[:service_request_id] = service_request.id
        post :unselect_calendar_column, {
          :id            => service_request.id,
          :column_id     => 2, # 1-based
          :arm_id        => arm1.id,
          :format        => :js,
        }.with_indifferent_access

        liv = LineItemsVisit.for(arm1, line_item1)
        liv.visits[1].quantity.should               eq 0
        liv.visits[1].research_billing_qty.should   eq 0
        liv.visits[1].insurance_billing_qty.should  eq 0
        liv.visits[1].effort_billing_qty.should     eq 0
        liv.visits[1].quantity.should               eq 0
        liv.visits[1].research_billing_qty.should   eq 0
        liv.visits[1].insurance_billing_qty.should  eq 0
        liv.visits[1].effort_billing_qty.should     eq 0
        liv.visits[1].quantity.should               eq 0
        liv.visits[1].research_billing_qty.should   eq 0
        liv.visits[1].insurance_billing_qty.should  eq 0
        liv.visits[1].effort_billing_qty.should     eq 0
      end
    end
  end
end

