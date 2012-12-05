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
end

