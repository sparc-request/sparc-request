require 'spec_helper'
require 'timecop'

describe ServiceRequestsController do
  let!(:identity) { FactoryGirl.create(:identity) }
  let!(:institution) { FactoryGirl.create(:institution) }
  let!(:provider) { FactoryGirl.create(:provider, parent_id: institution.id) }
  let!(:program) { FactoryGirl.create(:program, parent_id: provider.id) }
  let!(:core) { FactoryGirl.create(:core, parent_id: program.id) }
  let!(:core2) { FactoryGirl.create(:core, parent_id: program.id) }
  let!(:service_provider)  {FactoryGirl.create(:service_provider, identity_id: identity.id, organization_id: core.id, hold_emails: false)}

  let!(:institution_subsidy_map) { FactoryGirl.create(:subsidy_map, organization_id: institution.id) }
  let!(:provider_subsidy_map)    { FactoryGirl.create(:subsidy_map, organization_id: provider.id) }
  let!(:program_subsidy_map)     { FactoryGirl.create(:subsidy_map, organization_id: program.id) }
  let!(:core_subsidy_map)        { FactoryGirl.create(:subsidy_map, organization_id: core.id) }
  let!(:core2_subsidy_map)       { FactoryGirl.create(:subsidy_map, organization_id: core2.id) }

  # TODO: shouldn't be bypassing validations...
  let!(:study) { study = Study.create(FactoryGirl.attributes_for(:protocol)); study.save!(:validate => false); study }
  let!(:project) { 
    project = Project.create(FactoryGirl.attributes_for(:protocol))
    project.save!(:validate => false)
    project_role = FactoryGirl.create(
        :project_role,
        protocol_id: project.id,
        identity_id: identity.id,
        project_rights: "approve",
        role: "pi")
    project.reload
    project
  }

  # TODO: assign service_list
  let!(:service_request) { FactoryGirl.create(:service_request, visit_count: 0) }
  let!(:service_request_with_study) { FactoryGirl.create(:service_request, :protocol_id => study.id, visit_count: 0) }
  let!(:service_request_with_project) { FactoryGirl.create(:service_request, :protocol_id => project.id, visit_count: 0) }

  let!(:sub_service_request) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id ) }

  stub_controller

  describe 'GET show' do
    it 'should set protocol and service_list' do
      session[:service_request_id] = service_request.id
      get :show, :id => service_request.id
      assigns(:protocol).should eq service_request.protocol
      assigns(:service_list).should eq service_request.service_list
    end
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
      service_request.update_attribute(:visit_count, 500)

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
      session[:identity_id] = identity.id
      session[:service_request_id] = service_request_with_project.id
      get :confirmation, :id => service_request_with_project.id
      assigns(:service_request).status.should eq 'submitted'
    end

    it "should set the service request's submitted_at to Time.now" do
      session[:identity_id] = identity.id
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
      session[:identity_id] = identity.id
      service_request_with_project.protocol.update_attribute(:next_ssr_id, 42)
      ssr = FactoryGirl.create(
          :sub_service_request,
          service_request_id: service_request_with_project.id,
          organization_id: core.id)
      session[:service_request_id] = service_request_with_project.id
      get :confirmation, :id => service_request_with_project.id
      service_request_with_project.protocol.reload
      service_request_with_project.protocol.next_ssr_id.should eq 43
    end

    it 'should should set status and ssr_id on all the sub service request' do
      session[:identity_id] = identity.id
      service_request_with_project.protocol.update_attribute(:next_ssr_id, 42)

      ssr1 = FactoryGirl.create(
          :sub_service_request,
          service_request_id: service_request_with_project.id,
          ssr_id: nil,
          organization_id: provider.id)
      ssr2 = FactoryGirl.create(
          :sub_service_request,
          service_request_id: service_request_with_project.id,
          ssr_id: nil,
          organization_id: core.id)

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
      session[:identity_id] = identity.id
      service_request_with_project.protocol.update_attribute(:next_ssr_id, 10042)

      ssr1 = FactoryGirl.create(
          :sub_service_request,
          service_request_id: service_request_with_project.id,
          ssr_id: nil,
          organization_id: core.id)

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
      response.should redirect_to(USER_PORTAL_LINK)
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
      service.pricing_maps[0].update_attributes(display_date: Date.today)
      service
    }

    let!(:pricing_map) { service.pricing_maps[0] }

    let!(:line_item) { FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id) }

    it "should set the page if page is passed in" do
      service_request.update_attribute(:visit_count, 500)

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

    it 'should NOT create visits if there are too few of them, on one time fee line items' do
      pricing_map.update_attribute(:is_one_time_fee, true)
      service_request.update_attribute(:visit_count, 10)
      Visit.bulk_create(5, line_item_id: line_item.id)

      session[:service_request_id] = service_request.id
      get :service_calendar, { :id => service_request.id, :page => 42 }.with_indifferent_access

      line_item.reload
      line_item.visits.count.should eq 5
    end
  end

  describe 'GET document_management' do
    let!(:service1) { service = FactoryGirl.create(:service) }
    let!(:service2) { service = FactoryGirl.create(:service) }

    before(:each) do
      service_list = [ service1, service2 ]

      controller.stub!(:initialize_service_request) do
        controller.instance_eval do
          @service_request = ServiceRequest.find_by_id(session[:service_request_id])
          @sub_service_request = SubServiceRequest.find_by_id(session[:sub_service_request_id])

          @service_request.stub!(:service_list) { service_list }
        end
      end
    end

    it "should set the service list to the service request's service list" do
      session[:service_request_id] = service_request.id
      get :document_management, :id => service_request.id

      assigns(:service_list).should eq [ service1, service2 ]
    end
  end

  describe 'POST ask_a_question' do
    it 'should call ask_a_question and then deliver' do
      deliverer = double()
      deliverer.should_receive(:deliver)
      Notifier.stub!(:ask_a_question) { |question|
        question.to.should eq DEFAULT_MAIL_TO
        question.from.should eq 'no-reply@musc.edu'
        question.body.should eq 'No question asked'
        deliverer
      }
      get :ask_a_question, {
        :id => service_request.id,
        :format => :js
      }
    end

    it 'should use question_email if passed in' do
      deliverer = double()
      deliverer.should_receive(:deliver)
      Notifier.stub!(:ask_a_question) { |question|
        question.from.should eq 'billg@microsoft.com'
        deliverer
      }
      get :ask_a_question, {
        :id => service_request.id,
        :question_email => 'billg@microsoft.com',
        :format => :js
      }
    end

    it 'should use question_body if passed in' do
      deliverer = double()
      deliverer.should_receive(:deliver)
      Notifier.stub!(:ask_a_question) { |question|
        question.body.should eq 'is this thing on?'
        deliverer
      }
      get :ask_a_question, {
        :id => service_request.id,
        :question_body => 'is this thing on?',
        :format => :js
      }
    end
  end

  describe 'GET refresh_service_calendar' do
    it "should set the page if page is passed in" do
      service_request.update_attribute(:visit_count, 500)

      session[:service_request_id] = service_request.id
      get :refresh_service_calendar, { :id => service_request.id, :page => 42, :format => :js }.with_indifferent_access
      session[:service_calendar_page].should eq 42
    
      # TODO: sometimes this is 1 and sometimes it is 42.  I don't know
      # why.
      assigns(:page).should eq 42
    
      # TODO: check that set_visit_page is called?
    end
    
    it 'should set tab to pricing' do
      session[:service_request_id] = service_request.id
      get :refresh_service_calendar, :id => service_request.id, :format => :js
      assigns(:tab).should eq 'pricing'
    end
  end

  describe 'POST add_service' do
    let!(:service) {
      service = FactoryGirl.create(
          :service,
          pricing_map_count: 1,
          organization_id: core.id)
      service.pricing_maps[0].update_attributes(display_date: Date.today)
      service
    }

    let!(:service2) {
      service = FactoryGirl.create(
          :service,
          pricing_map_count: 1,
          organization_id: core.id)
      service.pricing_maps[0].update_attributes(display_date: Date.today)
      service
    }

    let!(:service3) {
      service = FactoryGirl.create(
          :service,
          pricing_map_count: 1,
          organization_id: core2.id)
      service.pricing_maps[0].update_attributes(display_date: Date.today)
      service
    }

    it 'should give an error if the service request already has a line item for the service' do
      line_item = FactoryGirl.create(
          :line_item,
          service_id: service.id,
          service_request_id: service_request.id)
      session[:service_request_id] = service_request.id
      post :add_service, { :id => service_request.id, :service_id => service.id, :format => :js }.with_indifferent_access
      response.body.should eq 'Service exists in line items'
    end

    it 'should create a line item for the service' do
      session[:service_request_id] = service_request.id
      post :add_service, { :id => service_request.id, :service_id => service.id, :format => :js }.with_indifferent_access

      service_request.reload
      service_request.line_items.count.should eq 1
      service_request.line_items[0].service.should eq service
      service_request.line_items[0].optional.should eq true
      service_request.line_items[0].quantity.should eq 1
    end

    it 'should create a line item for a required service' do
      FactoryGirl.create(
          :service_relation,
          service_id: service.id,
          related_service_id: service2.id,
          optional: false)

      session[:service_request_id] = service_request.id
      post :add_service, { :id => service_request.id, :service_id => service.id, :format => :js }.with_indifferent_access

      service_request.reload
      service_request.line_items.count.should eq 2
      service_request.line_items[0].service.should eq service
      service_request.line_items[0].optional.should eq true
      service_request.line_items[0].quantity.should eq 1
      service_request.line_items[1].service.should eq service2
      service_request.line_items[1].optional.should eq false
      service_request.line_items[1].quantity.should eq 1
    end

    it 'should create a line item for an optional service' do
      FactoryGirl.create(
          :service_relation,
          service_id: service.id,
          related_service_id: service2.id,
          optional: true)

      session[:service_request_id] = service_request.id
      post :add_service, { :id => service_request.id, :service_id => service.id, :format => :js }.with_indifferent_access

      service_request.reload
      service_request.line_items.count.should eq 2
      service_request.line_items[0].service.should eq service
      service_request.line_items[0].optional.should eq true
      service_request.line_items[0].quantity.should eq 1
      service_request.line_items[1].service.should eq service2
      service_request.line_items[1].optional.should eq true
      service_request.line_items[1].quantity.should eq 1
    end

    it 'should create a sub service request for each organization in the service list' do
      session[:service_request_id] = service_request.id

      [ service, service2, service3 ].each do |service_to_add|
        post :add_service, { :id => service_request.id, :service_id => service_to_add.id, :format => :js }.with_indifferent_access
      end

      service_request.reload
      service_request.sub_service_requests.count.should eq 2
      service_request.sub_service_requests[0].organization.should eq core
      service_request.sub_service_requests[1].organization.should eq core2
    end

    it 'should update each of the line items with the appropriate ssr id' do
      session[:service_request_id] = service_request.id

      [ service, service2, service3 ].each do |service_to_add|
        post :add_service, { :id => service_request.id, :service_id => service_to_add.id, :format => :js }.with_indifferent_access
      end

      core_ssr = service_request.sub_service_requests.find_by_organization_id(core.id)
      core2_ssr = service_request.sub_service_requests.find_by_organization_id(core2.id)

      service_request.reload
      service_request.line_items.count.should eq 3
      service_request.line_items[0].sub_service_request.should eq core_ssr
      service_request.line_items[1].sub_service_request.should eq core_ssr
      service_request.line_items[2].sub_service_request.should eq core2_ssr
    end

    # TODO: test for adding an already added service
  end

  describe 'POST remove_service' do
    let!(:service1) { service = FactoryGirl.create( :service, organization_id: core.id) }
    let!(:service2) { service = FactoryGirl.create( :service, organization_id: core.id) }
    let!(:service3) { service = FactoryGirl.create( :service, organization_id: core2.id) }

    let!(:line_item1) { FactoryGirl.create(:line_item, service_id: service1.id, service_request_id: service_request.id) }
    let!(:line_item2) { FactoryGirl.create(:line_item, service_id: service2.id, service_request_id: service_request.id) }
    let!(:line_item3) { FactoryGirl.create(:line_item, service_id: service3.id, service_request_id: service_request.id) }

    let!(:ssr1) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id) }
    let!(:ssr2) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core2.id) }

    it 'should delete any line items for the removed service' do
      controller.request.stub referrer: 'http://example.com'

      line_item1 # create line item (service1, core)
      line_item2 # create line item (service2, core)
      line_item3 # create line item (service3, core2)

      session[:service_request_id] = service_request.id
      post :remove_service, {
        :id            => service_request.id,
        :service_id    => service1.id,
        :line_item_id  => line_item1.id,
        :format        => :js,
      }.with_indifferent_access

      service_request.reload
      service_request.line_items.should_not include(line_item1)
      service_request.line_items.should include(line_item2)
      service_request.line_items.should include(line_item3)
    end

    it 'should delete sub service requests for organizations that no longer have a service in the service request' do
      controller.request.stub referrer: 'http://example.com'

      line_item1 # create line item (service1, core)
      line_item2 # create line item (service2, core)
      line_item3 # create line item (service3, core2)

      ssr1 # create ssr (core)
      ssr2 # create ssr (core2)

      session[:service_request_id] = service_request.id

      post :remove_service, {
        :id            => service_request.id,
        :service_id    => service1.id,
        :line_item_id  => line_item1.id,
        :format        => :js,
      }.with_indifferent_access

      service_request.reload
      service_request.sub_service_requests.should include(ssr1)
      service_request.sub_service_requests.should include(ssr2)

      post :remove_service, {
        :id            => service_request.id,
        :service_id    => service2.id,
        :line_item_id  => line_item2.id,
        :format        => :js,
      }.with_indifferent_access

      service_request.reload
      service_request.sub_service_requests.should_not include(ssr1)
      service_request.sub_service_requests.should include(ssr2)

      post :remove_service, {
        :id            => service_request.id,
        :service_id    => service3.id,
        :line_item_id  => line_item3.id,
        :format        => :js,
      }.with_indifferent_access

      service_request.reload
      service_request.sub_service_requests.should_not include(ssr1)
      service_request.sub_service_requests.should_not include(ssr2)
    end

    it 'should set the page' do
      controller.request.stub referrer: 'http://example.com/foo/bar'

      line_item1 # create line item (service1, core)
      line_item2 # create line item (service2, core)
      line_item3 # create line item (service3, core2)

      session[:service_request_id] = service_request.id
      post :remove_service, {
        :id            => service_request.id,
        :service_id    => service1.id,
        :line_item_id  => line_item1.id,
        :format        => :js,
      }.with_indifferent_access

      # TODO: why is @page set to a string in this method but set to an
      # integer elsewhere?
      assigns(:page).should eq 'bar'
    end

    it 'should raise an exception if a service is removed twice' do
      controller.request.stub referrer: 'http://example.com'

      line_item1 # create line item (service1, core)
      line_item2 # create line item (service2, core)
      line_item3 # create line item (service3, core2)

      session[:service_request_id] = service_request.id

      post :remove_service, {
        :id            => service_request.id,
        :service_id    => service1.id,
        :line_item_id  => line_item1.id,
        :format        => :js,
      }.with_indifferent_access

      proc {
        post :remove_service, {
          :id            => service_request.id,
          :service_id    => service1.id,
          :line_item_id  => line_item1.id,
          :format        => :js,
        }.with_indifferent_access
      }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context('calendar methods') do
    let!(:service1) {
      service = FactoryGirl.create(:service, pricing_map_count: 1)
      service.pricing_maps[0].update_attributes(
          display_date: Date.today,
          is_one_time_fee: false)
      service
    }

    let!(:service2) {
      service = FactoryGirl.create(:service, pricing_map_count: 1)
      service.pricing_maps[0].update_attributes(
          display_date: Date.today,
          is_one_time_fee: false)
      service
    }

    let!(:service3) {
      service = FactoryGirl.create(:service, pricing_map_count: 1)
      service.pricing_maps[0].update_attributes(
          display_date: Date.today,
          is_one_time_fee: false)
      service
    }

    let!(:pricing_map1) { service1.pricing_maps[0] }
    let!(:pricing_map2) { service2.pricing_maps[0] }
    let!(:pricing_map3) { service3.pricing_maps[0] }

    let!(:line_item1) { FactoryGirl.create(:line_item, service_id: service1.id, service_request_id: service_request.id) }
    let!(:line_item2) { FactoryGirl.create(:line_item, service_id: service2.id, service_request_id: service_request.id) }
    let!(:line_item3) { FactoryGirl.create(:line_item, service_id: service3.id, service_request_id: service_request.id) }

    describe 'POST select_calendar_row' do
      it 'should set line item' do
        pricing_map1.update_attribute(:unit_minimum, 100)
        Visit.bulk_create(3, line_item_id: line_item1.id)

        session[:service_request_id] = service_request.id
        post :select_calendar_row, {
          :id            => service_request.id,
          :line_item_id  => line_item1.id,
          :format        => :js
        }.with_indifferent_access

        assigns(:line_item).should eq line_item1
      end

      it "should update each of the line item's visits" do
        pricing_map1.update_attribute(:unit_minimum, 100)
        Visit.bulk_create(3, line_item_id: line_item1.id)

        session[:service_request_id] = service_request.id
        post :select_calendar_row, {
          :id            => service_request.id,
          :line_item_id  => line_item1.id,
          :format        => :js
        }.with_indifferent_access

        line_item1.visits.count.should eq 3
        line_item1.visits[0].quantity.should               eq 100
        line_item1.visits[0].research_billing_qty.should   eq 100
        line_item1.visits[0].insurance_billing_qty.should  eq 0
        line_item1.visits[0].effort_billing_qty.should     eq 0
        line_item1.visits[1].quantity.should               eq 100
        line_item1.visits[1].research_billing_qty.should   eq 100
        line_item1.visits[1].insurance_billing_qty.should  eq 0
        line_item1.visits[1].effort_billing_qty.should     eq 0
        line_item1.visits[2].quantity.should               eq 100
        line_item1.visits[2].research_billing_qty.should   eq 100
        line_item1.visits[2].insurance_billing_qty.should  eq 0
        line_item1.visits[2].effort_billing_qty.should     eq 0
      end
    end

    describe 'GET unselect_calendar_row' do
      it 'should set line item' do
        pricing_map1.update_attribute(:unit_minimum, 100)
        Visit.bulk_create(3, line_item_id: line_item1.id)

        session[:service_request_id] = service_request.id
        post :unselect_calendar_row, {
          :id            => service_request.id,
          :line_item_id  => line_item1.id,
          :format        => :js
        }.with_indifferent_access

        assigns(:line_item).should eq line_item1
      end

      it "should update each of the line item's visits" do
        pricing_map1.update_attribute(:unit_minimum, 100)
        Visit.bulk_create(3, line_item_id: line_item1.id)

        session[:service_request_id] = service_request.id
        post :unselect_calendar_row, {
          :id            => service_request.id,
          :line_item_id  => line_item1.id,
          :format        => :js
        }.with_indifferent_access

        line_item1.visits.count.should eq 3
        line_item1.visits[0].quantity.should               eq 0
        line_item1.visits[0].research_billing_qty.should   eq 0
        line_item1.visits[0].insurance_billing_qty.should  eq 0
        line_item1.visits[0].effort_billing_qty.should     eq 0
        line_item1.visits[1].quantity.should               eq 0
        line_item1.visits[1].research_billing_qty.should   eq 0
        line_item1.visits[1].insurance_billing_qty.should  eq 0
        line_item1.visits[1].effort_billing_qty.should     eq 0
        line_item1.visits[2].quantity.should               eq 0
        line_item1.visits[2].research_billing_qty.should   eq 0
        line_item1.visits[2].insurance_billing_qty.should  eq 0
        line_item1.visits[2].effort_billing_qty.should     eq 0
      end
    end

    describe 'GET select_calendar_column' do
      it 'should update each of the visits' do
        pricing_map1.update_attribute(:unit_minimum, 100)
        pricing_map2.update_attribute(:unit_minimum, 100)
        pricing_map3.update_attribute(:unit_minimum, 100)

        Visit.bulk_create(3, line_item_id: line_item1.id)
        Visit.bulk_create(3, line_item_id: line_item2.id)
        Visit.bulk_create(3, line_item_id: line_item3.id)

        session[:service_request_id] = service_request.id
        post :select_calendar_column, {
          :id            => service_request.id,
          :column_id     => 2, # 1-based
          :format        => :js,
        }.with_indifferent_access

        line_item1.visits[1].quantity.should               eq 100
        line_item1.visits[1].research_billing_qty.should   eq 100
        line_item1.visits[1].insurance_billing_qty.should  eq 0
        line_item1.visits[1].effort_billing_qty.should     eq 0
        line_item2.visits[1].quantity.should               eq 100
        line_item2.visits[1].research_billing_qty.should   eq 100
        line_item2.visits[1].insurance_billing_qty.should  eq 0
        line_item2.visits[1].effort_billing_qty.should     eq 0
        line_item3.visits[1].quantity.should               eq 100
        line_item3.visits[1].research_billing_qty.should   eq 100
        line_item3.visits[1].insurance_billing_qty.should  eq 0
        line_item3.visits[1].effort_billing_qty.should     eq 0
      end
    end

    describe 'GET unselect_calendar_column' do
      it 'should update each of the visits' do
        pricing_map1.update_attribute(:unit_minimum, 100)
        pricing_map2.update_attribute(:unit_minimum, 100)
        pricing_map3.update_attribute(:unit_minimum, 100)

        Visit.bulk_create(3, line_item_id: line_item1.id)
        Visit.bulk_create(3, line_item_id: line_item2.id)
        Visit.bulk_create(3, line_item_id: line_item3.id)

        session[:service_request_id] = service_request.id
        post :unselect_calendar_column, {
          :id            => service_request.id,
          :column_id     => 2, # 1-based
          :format        => :js,
        }.with_indifferent_access

        line_item1.visits[1].quantity.should               eq 0
        line_item1.visits[1].research_billing_qty.should   eq 0
        line_item1.visits[1].insurance_billing_qty.should  eq 0
        line_item1.visits[1].effort_billing_qty.should     eq 0
        line_item2.visits[1].quantity.should               eq 0
        line_item2.visits[1].research_billing_qty.should   eq 0
        line_item2.visits[1].insurance_billing_qty.should  eq 0
        line_item2.visits[1].effort_billing_qty.should     eq 0
        line_item3.visits[1].quantity.should               eq 0
        line_item3.visits[1].research_billing_qty.should   eq 0
        line_item3.visits[1].insurance_billing_qty.should  eq 0
        line_item3.visits[1].effort_billing_qty.should     eq 0
      end
    end
  end

  describe 'POST delete_document_group' do
    let!(:docgroup) { DocumentGrouping.create(:service_request_id => service_request.id) }

    let!(:ssr1) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id) }
    let!(:ssr2) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core2.id) }

    let!(:doc1) { Document.create(:document_grouping_id => docgroup.id, :sub_service_request_id => ssr1.id) }
    let!(:doc2) { Document.create(:document_grouping_id => docgroup.id, :sub_service_request_id => ssr2.id) }

    context('document group methods') do
      it 'should set tr_id' do
        session[:service_request_id] = service_request.id
        post :delete_documents, {
          :id                => service_request.id,
          :document_group_id => docgroup.id,
          :format            => :js,
        }.with_indifferent_access
        assigns(:tr_id).should eq "#document_grouping_#{docgroup.id}"
      end

      it 'should destroy the grouping if there is no sub service request' do
        session[:service_request_id] = service_request.id
        post :delete_documents, {
          :id                => service_request.id,
          :document_group_id => docgroup.id,
          :format            => :js,
        }.with_indifferent_access

        expect {
          docgroup.reload
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'should destroy only the document for that sub service request if there is a sub service request' do
        session[:service_request_id] = service_request.id
        session[:sub_service_request_id] = ssr1.id
        post :delete_documents, {
          :id                      => service_request.id,
          :document_group_id       => docgroup.id,
          :format                  => :js,
        }.with_indifferent_access

        docgroup.reload
        docgroup.destroyed?.should eq false

        expect {
          doc1.reload
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'should destroy the document grouping if all documents are destroyed' do
        doc1.destroy

        session[:service_request_id] = service_request.id
        session[:sub_service_request_id] = ssr2.id
        post :delete_documents, {
          :id                      => service_request.id,
          :document_group_id       => docgroup.id,
          :format                  => :js,
        }.with_indifferent_access

        expect {
          docgroup.reload
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe 'POST edit_document_group' do
      it 'should set grouping' do
        session[:service_request_id] = service_request.id
        post :edit_documents, {
          :id                      => service_request.id,
          :document_group_id       => docgroup.id,
          :format                  => :js,
        }.with_indifferent_access
        assigns(:grouping).should eq docgroup
      end

      it 'should set service_list' do
        session[:service_request_id] = service_request.id
        post :edit_documents, {
          :id                      => service_request.id,
          :document_group_id       => docgroup.id,
          :format                  => :js,
        }.with_indifferent_access
        assigns(:service_list).should eq service_request.service_list
      end
    end
  end

  describe 'GET service_subsidy' do
    it 'should set subsidies to an empty array if there are no sub service requests' do
      service_request.sub_service_requests.each { |ssr| ssr.destroy }
      service_request.reload
      session[:service_request_id] = service_request.id
      get :service_subsidy, :id => service_request.id
      assigns(:subsidies).should eq [ ]
    end

    it 'should put the subsidy into subsidies if the ssr has a subsidy' do
      subsidy = FactoryGirl.create(
          :subsidy,
          sub_service_request_id: sub_service_request.id)

      session[:service_request_id] = service_request.id
      get :service_subsidy, :id => service_request.id
      assigns(:subsidies).should eq [ subsidy ]
    end

    it 'should create a new subsidy and put it into subsidies if the ssr does not have a subsidy and it is eligible for subsidy' do
      sub_service_request.subsidy_organization.subsidy_map.update_attributes(
          max_dollar_cap: 100,
          max_percentage: 100)

      session[:service_request_id] = service_request.id
      get :service_subsidy, :id => service_request.id

      assigns(:subsidies).map { |s| s.class}.should eq [ Subsidy ]
    end

    it 'should not create a new subsidy if the ssr does not have a subsidy and it not is eligible for subsidy' do
      core.subsidy_map.update_attributes!(
          max_dollar_cap: 0,
          max_percentage: 0)
      provider.subsidy_map.update_attributes!(
          max_dollar_cap: 0,
          max_percentage: 0)
      program.subsidy_map.update_attributes!(
          max_dollar_cap: 0,
          max_percentage: 0)

      sub_service_request.eligible_for_subsidy?.should_not eq nil

      session[:service_request_id] = service_request.id
      get :service_subsidy, :id => service_request.id

      subsidy = sub_service_request.subsidy
      subsidy.should eq nil

      assigns(:subsidies).should eq [ ]
    end
  end

  describe 'GET navigate' do
    # TODO: wow, this method is complicated.  I'm not sure what to test
    # for.
  end

  describe 'POST navigate' do
    # TODO: wow, this method is complicated.  I'm not sure what to test
    # for.
  end
end

