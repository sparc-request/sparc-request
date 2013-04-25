require 'spec_helper'

describe ServiceCalendarsController do
  stub_controller

  let!(:service_request) { FactoryGirl.create(:service_request) }
  let!(:arm) { FactoryGirl.create(:arm, service_request_id: service_request.id, visit_count: 1) }

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
        with(42, arm).
        and_return(12)

      session[:service_request_id] = service_request.id
      session[:service_calendar_pages] = { arm.id.to_s => 42 }
        
      get :table, {
        :format => :js,
        :tab => 'foo',
        :service_request_id => service_request.id,
      }.with_indifferent_access

      assigns(:pages).should eq({ arm.id => 12 })
    end
  end

  describe 'POST update' do
    let!(:service) {
      service = FactoryGirl.create(:service, pricing_map_count: 1)
      service.pricing_maps[0].display_date = Date.today
      service
    }

    let!(:line_item) { FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id) }
    let!(:line_items_visit) { FactoryGirl.create(:line_items_visit, arm_id: arm.id, line_item_id: line_item.id) }


    it 'should set visit to the given visit' do
      Visit.bulk_create(20, line_items_visit_id: line_items_visit.id)
      visit = line_items_visit.visits[0]

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
      Visit.bulk_create(20, line_items_visit_id: line_items_visit.id)

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :tab                 => 'foo',
        :service_request_id  => service_request.id,
        :line_item           => line_item.id,
        :visit               => line_items_visit.visits[0].id,
      }.with_indifferent_access

      assigns(:line_item).should eq line_item
    end

    it "should set line_item to the visit's line item if there is no line item given" do
      Visit.bulk_create(20, line_items_visit_id: line_items_visit.id)
      visit = line_items_visit.visits[0]

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :tab                 => 'foo',
        :service_request_id  => service_request.id,
        :line_item           => nil,
        :visit               => visit.id,
      }.with_indifferent_access

      assigns(:line_item).should eq line_item
    end

    it 'should set subject count on the visit grouping if on the template tab' do
      Visit.bulk_create(20, line_items_visit_id: line_items_visit.id)
      visit = line_items_visit.visits[0]

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :service_request_id  => service_request.id,
        :line_items_visit      => line_items_visit.id,
        :line_item           => line_item.id,
        :visit               => visit.id,
        :qty                 => 240,
        :tab                 => 'template',
      }.with_indifferent_access

      line_items_visit.reload
      line_items_visit.subject_count.should eq 240
    end

    it 'should set quantity and research billing quantity on the visit if on the template tab and there is no line item, research billing quantity is 0, and checked is true' do
      LineItem.any_instance.stub_chain(:service, :displayed_pricing_map, :unit_minimum) { 120 }

      Visit.bulk_create(20, line_items_visit_id: line_items_visit.id)
      visit = line_items_visit.visits[0]
      visit.update_attributes(:research_billing_qty => 0)

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :service_request_id  => service_request.id,
        :line_item           => nil,
        :visit               => visit.id,
        :tab                 => 'template',
        :checked             => 'true',
      }.with_indifferent_access

      visit.reload

      visit.quantity.should eq 120
      visit.research_billing_qty.should eq 120
    end

    it 'should set all the quantities to 0 if on the template tab and there is no line item and checked is false' do
      Visit.bulk_create(20, line_items_visit_id: line_items_visit.id)
      visit = line_items_visit.visits[0]
      visit.update_attributes(:research_billing_qty => 0)

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :service_request_id  => service_request.id,
        :line_item           => nil,
        :visit               => line_items_visit.visits[0].id,
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
      Visit.bulk_create(20, line_items_visit_id: line_items_visit.id)
      visit = line_items_visit.visits[0]
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
      Visit.bulk_create(20, line_items_visit_id: line_items_visit.id)
      visit = line_items_visit.visits[0]
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

      Visit.bulk_create(20, line_items_visit_id: line_items_visit.id)
      visit = line_items_visit.visits[0]
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
      Visit.bulk_create(20, line_items_visit_id: line_items_visit.id)
      visit = line_items_visit.visits[0]
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
      Visit.bulk_create(20, line_items_visit_id: line_items_visit.id)
      visit = line_items_visit.visits[0]
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
      Visit.bulk_create(20, line_items_visit_id: line_items_visit.id)
      visit = line_items_visit.visits[0]
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
      Visit.bulk_create(20, line_items_visit_id: line_items_visit.id)
      visit = line_items_visit.visits[0]
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

      visit.quantity.should eq(8 + 17 + 100)
    end
  end
end

