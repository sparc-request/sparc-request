require 'spec_helper'
require 'timecop'

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
        @user_portal_link = '/user_portal'
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
      time = Time.parse('2012-06-01 12:34:56')
      Timecop.freeze(time) do
        service_request_with_project.update_attribute(:submitted_at, nil)
        session[:service_request_id] = service_request_with_project.id
        get :confirmation, :id => service_request_with_project.id
        service_request_with_project.reload
        service_request_with_project.submitted_at.should eq Time.now
      end
    end

    it 'should increment next_ssr_id' do
      service_request_with_project.protocol.update_attribute(:next_ssr_id, 42)
      ssr = FactoryGirl.create(
          :sub_service_request,
          service_request_id: service_request_with_project.id)
      session[:service_request_id] = service_request_with_project.id
      get :confirmation, :id => service_request_with_project.id
      service_request_with_project.protocol.reload
      service_request_with_project.protocol.next_ssr_id.should eq 43
    end

    it 'should should set status and ssr_id on all the sub service request' do
      service_request_with_project.protocol.update_attribute(:next_ssr_id, 42)

      ssr1 = FactoryGirl.create(
          :sub_service_request,
          service_request_id: service_request_with_project.id,
          ssr_id: nil)
      ssr2 = FactoryGirl.create(
          :sub_service_request,
          service_request_id: service_request_with_project.id,
          ssr_id: nil)

      session[:service_request_id] = service_request_with_project.id
      get :confirmation, :id => service_request_with_project.id

      ssr1.reload
      ssr2.reload

      ssr1.status.should eq 'submitted'
      ssr2.status.should eq 'submitted'

      ssr1.ssr_id.should eq '0042'
      ssr2.ssr_id.should eq '0043'
    end

    it 'should set ssr_id correctly when next_ssr_id > 9999' do
      service_request_with_project.protocol.update_attribute(:next_ssr_id, 10042)

      ssr1 = FactoryGirl.create(
          :sub_service_request,
          service_request_id: service_request_with_project.id,
          ssr_id: nil)

      session[:service_request_id] = service_request_with_project.id
      get :confirmation, :id => service_request_with_project.id

      ssr1.reload
      ssr1.ssr_id.should eq '10042'
    end
  end

  describe 'GET save_and_exit' do
    it "should set the service request's status to submitted" do
      session[:service_request_id] = service_request_with_project.id
      get :save_and_exit, :id => service_request_with_project.id
      assigns(:service_request).status.should eq 'draft'
    end

    it "should NOT set the service request's submitted_at to Time.now" do
      time = Time.parse('2012-06-01 12:34:56')
      Timecop.freeze(time) do
        service_request_with_project.update_attribute(:submitted_at, nil)
        session[:service_request_id] = service_request_with_project.id
        get :save_and_exit, :id => service_request_with_project.id
        service_request_with_project.reload
        service_request_with_project.submitted_at.should eq nil
      end
    end

    it 'should increment next_ssr_id' do
      service_request_with_project.protocol.update_attribute(:next_ssr_id, 42)
      ssr = FactoryGirl.create(
          :sub_service_request,
          service_request_id: service_request_with_project.id)
      session[:service_request_id] = service_request_with_project.id
      get :save_and_exit, :id => service_request_with_project.id
      service_request_with_project.protocol.reload
      service_request_with_project.protocol.next_ssr_id.should eq 43
    end

    it 'should should set status and ssr_id on all the sub service request' do
      service_request_with_project.protocol.update_attribute(:next_ssr_id, 42)

      ssr1 = FactoryGirl.create(
          :sub_service_request,
          service_request_id: service_request_with_project.id,
          ssr_id: nil)
      ssr2 = FactoryGirl.create(
          :sub_service_request,
          service_request_id: service_request_with_project.id,
          ssr_id: nil)

      session[:service_request_id] = service_request_with_project.id
      get :save_and_exit, :id => service_request_with_project.id

      ssr1.reload
      ssr2.reload

      ssr1.status.should eq 'draft'
      ssr2.status.should eq 'draft'

      ssr1.ssr_id.should eq '0042'
      ssr2.ssr_id.should eq '0043'
    end

    it 'should set ssr_id correctly when next_ssr_id > 9999' do
      service_request_with_project.protocol.update_attribute(:next_ssr_id, 10042)

      ssr1 = FactoryGirl.create(
          :sub_service_request,
          service_request_id: service_request_with_project.id,
          ssr_id: nil)

      session[:service_request_id] = service_request_with_project.id
      get :save_and_exit, :id => service_request_with_project.id

      ssr1.reload
      ssr1.ssr_id.should eq '10042'
    end

    it 'should redirect the user to the user portal link' do
      session[:service_request_id] = service_request_with_project.id
      get :save_and_exit, :id => service_request_with_project.id
      response.should redirect_to('/user_portal')
    end
  end

  describe 'GET service_details' do
    it 'should do nothing?' do
      session[:service_request_id] = service_request.id
      get :service_details, :id => service_request.id
    end
  end

  describe 'GET service_calendar' do
    let!(:service) {
      service = FactoryGirl.create(:service, pricing_map_count: 1)
      service.pricing_maps[0].display_date = Date.today
      service
    }

    let!(:pricing_map) { service.pricing_maps[0] }
    let!(:line_item) { FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id) }

    it "should set the page if page is passed in" do
      session[:service_request_id] = service_request.id
      get :service_calendar, { :id => service_request.id, :page => 42 }.with_indifferent_access
      session[:service_calendar_page].should eq '42'
    end

    it 'should set subject count on the per patient per visit line items if it is not set' do
      pricing_map.update_attribute(:is_one_time_fee, false)
      service_request.update_attribute(:subject_count, 42)
      line_item.update_attribute(:subject_count, nil)

      session[:service_request_id] = service_request.id
      get :service_calendar, { :id => service_request.id, :page => 42 }.with_indifferent_access

      line_item.reload
      line_item.subject_count.should eq 42
    end

    it 'should NOT set subject count on the per patient per visit line items if it is set' do
      pricing_map.update_attribute(:is_one_time_fee, false)
      service_request.update_attribute(:subject_count, 42)
      line_item.update_attribute(:subject_count, 500)

      session[:service_request_id] = service_request.id
      get :service_calendar, { :id => service_request.id, :page => 42 }.with_indifferent_access

      line_item.reload
      line_item.subject_count.should eq 500
    end

    it 'should NOT set subject count on the one time fee line items' do
      pricing_map.update_attribute(:is_one_time_fee, true)
      service_request.update_attribute(:subject_count, 42)
      line_item.update_attribute(:subject_count, nil)

      session[:service_request_id] = service_request.id
      get :service_calendar, { :id => service_request.id, :page => 42 }.with_indifferent_access

      line_item.reload
      line_item.subject_count.should eq nil
    end

    it 'should delete extra visits on per patient per visit line items' do
      pricing_map.update_attribute(:is_one_time_fee, false)
      service_request.update_attribute(:visit_count, 10)
      Visit.bulk_create(20, line_item_id: line_item.id)

      session[:service_request_id] = service_request.id
      get :service_calendar, { :id => service_request.id, :page => 42 }.with_indifferent_access

      line_item.reload
      line_item.visits.count.should eq 10
    end

    it 'should create visits if too few on per patient per visit line items' do
      pricing_map.update_attribute(:is_one_time_fee, false)
      service_request.update_attribute(:visit_count, 10)
      Visit.bulk_create(0, line_item_id: line_item.id)

      session[:service_request_id] = service_request.id
      get :service_calendar, { :id => service_request.id, :page => 42 }.with_indifferent_access

      line_item.reload
      line_item.visits.count.should eq 10
    end

    it 'should NOT delete extra visits on one time fee line items' do
      pricing_map.update_attribute(:is_one_time_fee, true)
      service_request.update_attribute(:visit_count, 10)
      Visit.bulk_create(20, line_item_id: line_item.id)

      session[:service_request_id] = service_request.id
      get :service_calendar, { :id => service_request.id, :page => 42 }.with_indifferent_access

      line_item.reload
      line_item.visits.count.should eq 20
    end

    it 'should NOT create visits if too few on one time fee line items' do
      pricing_map.update_attribute(:is_one_time_fee, true)
      service_request.update_attribute(:visit_count, 10)
      Visit.bulk_create(5, line_item_id: line_item.id)

      session[:service_request_id] = service_request.id
      get :service_calendar, { :id => service_request.id, :page => 42 }.with_indifferent_access

      line_item.reload
      line_item.visits.count.should eq 5
    end
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
end

