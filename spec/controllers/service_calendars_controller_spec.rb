require 'spec_helper'

describe ServiceCalendarsController do
  stub_controller

  let!(:service_request) { FactoryGirl.create(:service_request, visit_count: 0) }

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
        with(42).
        and_return(12)

      session[:service_request_id] = service_request.id
      session[:service_calendar_page] = 42
        
      get :table, {
        :format => :js,
        :tab => 'foo',
        :service_request_id => service_request.id,
      }.with_indifferent_access

      assigns(:page).should eq 12
    end
  end

  describe 'POST update' do
    let!(:service) {
      service = FactoryGirl.create(:service, pricing_map_count: 1)
      service.pricing_maps[0].display_date = Date.today
      service
    }

    let!(:line_item) { FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id) }


    it 'should set visit to the given visit' do
      Visit.bulk_create(20, line_item_id: line_item.id)

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :tab                 => 'foo',
        :service_request_id  => service_request.id,
        :line_item           => line_item.id,
        :visit               => line_item.visits[0].id,
      }.with_indifferent_access

      assigns(:visit).should eq line_item.visits[0]
    end

    it 'should set line_item to the given line item if it exists' do
      Visit.bulk_create(20, line_item_id: line_item.id)

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :tab                 => 'foo',
        :service_request_id  => service_request.id,
        :line_item           => line_item.id,
        :visit               => line_item.visits[0].id,
      }.with_indifferent_access

      assigns(:line_item).should eq line_item
    end

    it "should set line_item to the visit's line item if there is no line item given" do
      Visit.bulk_create(20, line_item_id: line_item.id)

      session[:service_request_id] = service_request.id

      get :update, {
        :format              => :js,
        :tab                 => 'foo',
        :service_request_id  => service_request.id,
        :line_item           => nil,
        :visit               => line_item.visits[0].id,
      }.with_indifferent_access

      assigns(:line_item).should eq line_item
    end

    it 'should set subject count on the line item if on the template tab' do
    end

    it 'should set quantity and research billing quantity on the visit if on the template tab and there is no line item, research billing quantity is 0, and checked is true' do
    end

    it 'should set all the quantities to 0 if on the template tab and there is no line item and checked is false' do
    end

    it 'should give an error if on the quantity tab and quantity is less than 0' do
    end

    it 'should update quantity on the visit if on the quantity tab and quantity is 0' do
    end

    it 'should update quantity on the visit if on the quantity tab and quantity is greater than 0' do
    end

    it 'should give an error if on the billing strategy tab and quantity is less than 0' do
    end

    it 'should update the given column on the visit if on the billing strategy tab and quantity is 0' do
    end

    it 'should update the given column on the visit if on the billing strategy tab and quantity is greater than 0' do
    end

    it 'should update quantity on the visit to the total if on the billing strategy tab' do
    end

    it 'should set displayed_visits' do
    end
  end
end

