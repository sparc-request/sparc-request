require 'spec_helper'

describe ServiceRequestsController do
  let!(:institution) { FactoryGirl.create(:institution) }
  let!(:provider) { FactoryGirl.create(:provider, parent_id: institution.id) }
  let!(:program) { FactoryGirl.create(:program, parent_id: provider.id) }
  let!(:core) { FactoryGirl.create(:core, parent_id: program.id) }
  let!(:service_request) { FactoryGirl.create(:service_request) }
  let!(:sub_service_request) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id ) }

  before(:each) do
    controller.stub!(:authenticate)
    controller.stub!(:load_defaults)

    controller.stub!(:setup_session) do
      controller.instance_eval do
        @service_request = ServiceRequest.find_by_id(session[:service_request_id])
        @sub_service_request = SubServiceRequest.find_by_id(session[:sub_service_request_id])
      end
    end

    controller.stub!(:setup_navigation)
  end

  describe 'GET show' do
    it 'should set protocol and service_list' do
      session[:service_request_id] = service_request.id
      get :show, :id => service_request.id
      assigns(:protocol).should eq service_request.protocol
      assigns(:service_list).should eq service_request.service_list
    end
  end

  describe 'GET navigate' do
    # TODO: wow, this method is complicated.  I'm not sure what to test
    # for.
  end

  describe 'GET catalog' do
    it 'should set institutions to all institutions if there is no sub service request id' do
      session[:service_request_id] = service_request.id
      get :catalog
      assigns(:institutions).should eq Institution.all.sort_by { |i| i.order.to_i }
    end

    it "should set instutitions to the sub service request's institution if there is a sub service request id" do
      session[:service_request_id] = service_request.id
      session[:sub_service_request_id] = sub_service_request.id
      get :catalog
      assigns(:institutions).should eq [ institution ]
    end
  end

  describe 'GET protocol' do
  end

  describe 'GET review' do
  end

  describe 'GET confirmation' do
  end

  describe 'GET service_details' do
  end

  describe 'GET service_calendar' do
  end

  describe 'GET service_subsidy' do
  end

  describe 'GET document_management' do
  end

  describe 'POST navigate' do
  end

  describe 'POST ask_a_question' do
  end

  describe 'GET refresh_service_calendar' do
  end

  describe 'GET save_and_exit' do
  end
end

