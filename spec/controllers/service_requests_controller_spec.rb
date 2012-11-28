require 'spec_helper'

describe ServiceRequestsController do
  let!(:identity) { FactoryGirl.create(:identity) }
  let!(:institution) { FactoryGirl.create(:institution) }
  let!(:provider) { FactoryGirl.create(:provider, parent_id: institution.id) }
  let!(:program) { FactoryGirl.create(:program, parent_id: provider.id) }
  let!(:core) { FactoryGirl.create(:core, parent_id: program.id) }

  # TODO: shouldn't be bypassing validations...
  let!(:study) { study = Study.create(FactoryGirl.attributes_for(:protocol)); study.save!(:validate => false); study }
  let!(:project) { project = Project.create(FactoryGirl.attributes_for(:protocol)); project.save!(:validate => false); project }

  # TODO: assign service_list
  let!(:service_request) { FactoryGirl.create(:service_request) }
  let!(:service_request_with_study) { FactoryGirl.create(:service_request, :protocol_id => study.id) }
  let!(:service_request_with_project) { FactoryGirl.create(:service_request, :protocol_id => project.id) }

  let!(:sub_service_request) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id ) }


  # Stub out all the methods in ApplicationController so we're not
  # testing them
  # TODO: refactor this into stub_helper.rb
  before(:each) do
    controller.stub!(:authenticate)
    controller.stub!(:load_defaults)

    controller.stub!(:setup_session) do
      controller.instance_eval do
        @current_user = Identity.find_by_id(session[:identity_id])
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
      get :catalog, :id => service_request.id
      assigns(:institutions).should eq Institution.all.sort_by { |i| i.order.to_i }
    end

    it "should set instutitions to the sub service request's institution if there is a sub service request id" do
      session[:service_request_id] = service_request.id
      session[:sub_service_request_id] = sub_service_request.id
      get :catalog, :id => service_request.id
      assigns(:institutions).should eq [ institution ]
    end
  end

  describe 'GET protocol' do
    it "should set protocol to the service request's study" do
      session[:identity_id] = identity.id
      session[:service_request_id] = service_request_with_study.id
      session[:sub_service_request_id] = sub_service_request.id
      session[:saved_study_id] = study.id
      get :protocol, :id => service_request_with_study.id
      assigns(:service_request).protocol.should eq study
      session[:saved_study_id].should eq nil
    end

    it "should set protocol to the service request's project" do
      session[:identity_id] = identity.id
      session[:service_request_id] = service_request_with_project.id
      session[:sub_service_request_id] = sub_service_request.id
      session[:saved_project_id] = project.id
      get :protocol, :id => service_request_with_project.id
      assigns(:service_request).protocol.should eq project
      session[:saved_project_id].should eq nil
    end

    it "should set studies to the service request's studies if there is a sub service request" do
      # TODO
    end

    it "should set projects to the service request's projects if there is a sub service request" do
      # TODO
    end

    it "should set studies to the current user's studies if there is not a sub service request" do
      # TODO
    end

    it "should set projects to the current user's projects if there is not a sub service request" do
      # TODO
    end
  end

  describe 'GET review' do
    it "should set the page if page is passed in" do
      session[:service_request_id] = service_request.id
      get :review, { :id => service_request.id, :page => 42 }.with_indifferent_access
      session[:service_calendar_page].should eq '42'

      # TODO: sometimes this is 1 and sometimes it is 42.  I don't know
      # why.
      assigns(:page).should eq 42

      # TODO: check that set_visit_page is called?
    end

    it "should set service_list to the service request's service list" do
      session[:service_request_id] = service_request.id
      get :review, :id => service_request.id
      assigns(:service_request).service_list.should eq service_request.service_list
    end

    it "should set protocol to the service request's protocol" do
      session[:service_request_id] = service_request.id
      get :review, :id => service_request.id
      assigns(:service_request).protocol.should eq service_request.protocol
    end

    it "should set tab to pricing" do
      session[:service_request_id] = service_request.id
      get :review, :id => service_request.id
      assigns(:tab).should eq 'pricing'
    end
  end

  describe 'GET confirmation' do
    it "should set the service request's status to submitted" do
      session[:service_request_id] = service_request_with_project.id
      get :confirmation, :id => service_request_with_project.id
      assigns(:service_request).status.should eq 'submitted'
    end

    it "should set the service request's submitted_at to Time.now" do
    end
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

