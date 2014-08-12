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
require 'timecop'

def add_visits_to_arm_line_item(arm, line_item, n=arm.visit_count)
  line_items_visit = LineItemsVisit.for(arm, line_item)

  n.times do |index|
    FactoryGirl.create(:visit_group, arm_id: arm.id, day: index )
  end

  n.times do |index|
     FactoryGirl.create(:visit, quantity: 0, line_items_visit_id: line_items_visit.id, visit_group_id: arm.visit_groups[index].id)
  end
end

describe ServiceRequestsController do
  stub_controller

  let_there_be_lane
  let_there_be_j
  build_service_request_with_study
  build_one_time_fee_services
  build_per_patient_per_visit_services

  before(:each) do
    add_visits
  end

  let!(:core2) { FactoryGirl.create(:core, parent_id: program.id) }

  describe 'GET show' do
    it 'should set protocol and service_list' do
      session[:service_request_id] = service_request.id
      get :show, :id => service_request.id
      assigns(:protocol).should eq service_request.protocol
      assigns(:service_list).should eq service_request.service_list.with_indifferent_access
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
    context 'with study' do
      build_study

      it "should set protocol to the service request's study" do
        session[:identity_id] = jug2.id
        session[:service_request_id] = service_request.id
        session[:sub_service_request_id] = sub_service_request.id
        session[:saved_protocol_id] = study.id
        get :protocol, :id => service_request.id
        assigns(:service_request).protocol.should eq study
        session[:saved_protocol_id].should eq nil
      end

      it "should set studies to the service request's studies if there is a sub service request" do
        # TODO
      end

      it "should set studies to the current user's studies if there is not a sub service request" do
        # TODO
      end

    end

    context 'with project' do
      build_project

      it "should set protocol to the service request's project" do
        session[:identity_id] = jug2.id
        session[:service_request_id] = service_request.id
        session[:sub_service_request_id] = sub_service_request.id
        session[:saved_protocol_id] = project.id
        get :protocol, :id => service_request.id
        assigns(:service_request).protocol.should eq project
        session[:saved_protocol_id].should eq nil
      end

      it "should set projects to the service request's projects if there is a sub service request" do
        # TODO
      end

      it "should set projects to the current user's projects if there is not a sub service request" do
        # TODO
      end
    end
  end

  describe 'GET review' do
    build_project
    build_arms

    it "should set the page if page is passed in" do
      arm1.update_attribute(:visit_count, 500)

      session[:service_request_id] = service_request.id
      get :review, { :id => service_request.id, :pages => { arm1.id.to_s => 42 } }.with_indifferent_access
      session[:service_calendar_pages].should eq({arm1.id.to_s => '42'})

      assigns(:pages).should eq({arm1.id => 1, arm2.id => 1})

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

    it "should set tab to full calendar" do
      session[:service_request_id] = service_request.id
      get :review, :id => service_request.id
      assigns(:tab).should eq 'calendar'
    end
  end

  describe 'GET confirmation' do
    context 'with project' do
      build_project
      build_arms

      it "should set the service request's status to submitted" do
        session[:identity_id] = jug2.id
        session[:service_request_id] = service_request.id
        get :confirmation, :id => service_request.id
        assigns(:service_request).status.should eq 'submitted'
      end

      it "should set the service request's submitted_at to Time.now" do
        session[:identity_id] = jug2.id
        time = Time.parse('2012-06-01 12:34:56')
        Timecop.freeze(time) do
          service_request.update_attribute(:submitted_at, nil)
          session[:service_request_id] = service_request.id
          get :confirmation, :id => service_request.id
          service_request.reload
          service_request.submitted_at.should eq Time.now
        end
      end

      it 'should increment next_ssr_id' do
        session[:identity_id] = jug2.id
        service_request.protocol.update_attribute(:next_ssr_id, 42)
        service_request.sub_service_requests.each { |ssr| ssr.destroy }
        ssr = FactoryGirl.create(
            :sub_service_request,
            service_request_id: service_request.id,
            organization_id: core.id)
        session[:service_request_id] = service_request.id
        get :confirmation, :id => service_request.id
        service_request.protocol.reload
        service_request.protocol.next_ssr_id.should eq 43
      end

      it 'should should set status and ssr_id on all the sub service request' do
        session[:identity_id] = jug2.id
        service_request.protocol.update_attribute(:next_ssr_id, 42)
        service_request.sub_service_requests.each { |ssr| ssr.destroy }

        ssr1 = FactoryGirl.create(
            :sub_service_request,
            service_request_id: service_request.id,
            ssr_id: nil,
            organization_id: provider.id)
        ssr2 = FactoryGirl.create(
            :sub_service_request,
            service_request_id: service_request.id,
            ssr_id: nil,
            organization_id: core.id)

        session[:service_request_id] = service_request.id
        get :confirmation, :id => service_request.id

        ssr1.reload
        ssr2.reload

        ssr1.status.should eq 'submitted'
        ssr2.status.should eq 'submitted'

        ssr1.ssr_id.should eq '0042'
        ssr2.ssr_id.should eq '0043'
      end

      it 'should set ssr_id correctly when next_ssr_id > 9999' do
        session[:identity_id] = jug2.id
        service_request.protocol.update_attribute(:next_ssr_id, 10042)
        service_request.sub_service_requests.each { |ssr| ssr.destroy }

        ssr1 = FactoryGirl.create(
            :sub_service_request,
            service_request_id: service_request.id,
            ssr_id: nil,
            organization_id: core.id)

        session[:service_request_id] = service_request.id
        get :confirmation, :id => service_request.id

        ssr1.reload
        ssr1.ssr_id.should eq '10042'
      end

      it 'should send an email if services are set to send to epic' do
        stub_const("QUEUE_EPIC", false)
        stub_const("USE_EPIC", true)

        session[:identity_id] = jug2.id
        session[:service_request_id] = service_request.id

        service.update_attributes(send_to_epic: false)
        service2.update_attributes(send_to_epic: true)
        protocol = service_request.protocol
        protocol.project_roles.first.update_attributes(epic_access: true)

        deliverer = double()
        deliverer.should_receive(:deliver)
        Notifier.stub!(:notify_for_epic_user_approval) { |sr|
          sr.should eq(protocol)
          deliverer
        }

        get :confirmation, {
          :id => service_request.id,
          :format => :js
        }
      end

      it 'should not send an email if no services are set to send to epic' do
        session[:identity_id] = jug2.id
        session[:service_request_id] = service_request.id

        service.update_attributes(send_to_epic: false)
        service2.update_attributes(send_to_epic: false)

        deliverer = double()
        deliverer.should_not_receive(:deliver)
        Notifier.stub!(:notify_for_epic_user_approval) { |sr|
          sr.should eq(service_request)
          deliverer
        }

        get :confirmation, {
          :id => service_request.id,
          :format => :js
        }
      end
    end
  end

  describe 'GET save_and_exit' do
    context 'with project' do
      build_project
      build_arms

      it "should set the service request's status to submitted" do
        session[:service_request_id] = service_request.id
        get :save_and_exit, :id => service_request.id
        assigns(:service_request).status.should eq 'draft'
      end

      it "should NOT set the service request's submitted_at to Time.now" do
        time = Time.parse('2012-06-01 12:34:56')
        Timecop.freeze(time) do
          service_request.update_attribute(:submitted_at, nil)
          session[:service_request_id] = service_request.id
          get :save_and_exit, :id => service_request.id
          service_request.reload
          service_request.submitted_at.should eq nil
        end
      end

      it 'should increment next_ssr_id' do
        service_request.protocol.update_attribute(:next_ssr_id, 42)
        service_request.sub_service_requests.each { |ssr| ssr.destroy }
        ssr = FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id)
        session[:service_request_id] = service_request.id
        get :save_and_exit, :id => service_request.id
        service_request.protocol.reload
        service_request.protocol.next_ssr_id.should eq 43
      end

      it 'should should set status and ssr_id on all the sub service request' do
        service_request.protocol.update_attribute(:next_ssr_id, 42)

        service_request.sub_service_requests.each { |ssr| ssr.destroy }
        ssr1 = FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, ssr_id: nil, organization_id: core.id)
        ssr2 = FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, ssr_id: nil, organization_id: core.id)

        session[:service_request_id] = service_request.id
        get :save_and_exit, :id => service_request.id

        ssr1.reload
        ssr2.reload

        ssr1.status.should eq 'draft'
        ssr2.status.should eq 'draft'

        ssr1.ssr_id.should eq '0042'
        ssr2.ssr_id.should eq '0043'
      end

      it 'should set ssr_id correctly when next_ssr_id > 9999' do
        service_request.protocol.update_attribute(:next_ssr_id, 10042)

        service_request.sub_service_requests.each { |ssr| ssr.destroy }
        ssr1 = FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, ssr_id: nil, organization_id: core.id)

        session[:service_request_id] = service_request.id
        get :save_and_exit, :id => service_request.id

        ssr1.reload
        ssr1.ssr_id.should eq '10042'
      end

      it 'should redirect the user to the user portal link' do
        session[:service_request_id] = service_request.id
        get :save_and_exit, :id => service_request.id
        response.should redirect_to(USER_PORTAL_LINK)
      end
    end
  end

  describe 'GET service_calendar' do
    build_project
    build_arms

    describe 'GET service_details' do
      it 'should do nothing?' do
        session[:service_request_id] = service_request.id
        get :service_details, :id => service_request.id
      end
    end

    let!(:service) {
      service = FactoryGirl.create(:service, pricing_map_count: 1)
      service.pricing_maps[0].update_attributes(display_date: Date.today)
      service.pricing_maps[0].update_attributes(is_one_time_fee: false)
      service
    }

    let!(:one_time_fee_service) {
      service = FactoryGirl.create(:service, pricing_map_count: 1)
      service.pricing_maps[0].update_attributes(display_date: Date.today)
      service.pricing_maps[0].update_attributes(is_one_time_fee: true)
      service
    }

    let!(:pricing_map) { service.pricing_maps[0] }
    let!(:one_time_fee_pricing_map) { one_time_fee_service.pricing_maps[0] }

    let!(:line_item) { FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id) }
    let!(:one_time_fee_line_item) { FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id) }

    it "should set the page if page is passed in" do
      arm1.update_attribute(:visit_count, 500)

      session[:service_request_id] = service_request.id
      get :service_calendar, { :id => service_request.id, :pages => { arm1.id.to_s => 42 } }.with_indifferent_access
      session[:service_calendar_pages].should eq({arm1.id.to_s => '42'})
    end

    it 'should set subject count on the per patient per visit line items if it is not set' do
      arm1.update_attribute(:subject_count, 42)

      liv = LineItemsVisit.for(arm1, line_item)
      liv.update_attribute(:subject_count, nil)

      session[:service_request_id] = service_request.id
      get :service_calendar, { :id => service_request.id, :pages => { arm1.id => 42 } }.with_indifferent_access

      liv.reload
      liv.subject_count.should eq 42
    end

    it 'should set subject count on the per patient per visit line items if it is set and is higher than the visit grouping subject count' do
      arm1.update_attribute(:subject_count, 42)

      liv = LineItemsVisit.for(arm1, line_item)
      liv.update_attribute(:subject_count, 500)

      session[:service_request_id] = service_request.id
      get :service_calendar, { :id => service_request.id, :pages => { arm1.id => 42 } }.with_indifferent_access

      liv.reload
      liv.subject_count.should eq 42
    end

    it 'should NOT set subject count on the per patient per visit line items if it is set and is lower than the visit grouping subject count' do
      arm1.update_attribute(:subject_count, 42)

      liv = LineItemsVisit.for(arm1, line_item)
      liv.update_attribute(:subject_count, 10)

      session[:service_request_id] = service_request.id
      get :service_calendar, { :id => service_request.id, :pages => { arm1.id => 42 } }.with_indifferent_access

      liv.reload
      liv.subject_count.should eq 10
    end

    it 'should delete extra visits on per patient per visit line items' do
      arm1.update_attribute(:visit_count, 10)

      liv = LineItemsVisit.for(arm1, line_item)
      liv.visits.each { |visit| visit.destroy }
      add_visits_to_arm_line_item(arm1, line_item, 20)

      session[:service_request_id] = service_request.id
      get :service_calendar, { :id => service_request.id, :pages => { arm1.id => 42 } }.with_indifferent_access

      liv.reload
      liv.visits.count.should eq 10
    end

    it 'should create visits if too few on per patient per visit line items' do
      arm1.update_attribute(:visit_count, 10)

      liv = LineItemsVisit.for(arm1, line_item)
      add_visits_to_arm_line_item(arm1, line_item, 0)

      session[:service_request_id] = service_request.id
      get :service_calendar, { :id => service_request.id, :pages => { arm1.id => 42 } }.with_indifferent_access

      liv.reload
      liv.visits.count.should eq 10
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
      Notifier.stub!(:ask_a_question) { |quick_question|
        quick_question.to.should eq DEFAULT_MAIL_TO
        quick_question.from.should eq 'no-reply@musc.edu'
        quick_question.body.should eq 'No question asked'
        deliverer
      }
      get :ask_a_question, { :quick_question => { :email => ''}, :quick_question => { :body => ''}, :id => service_request.id, :format => :js }
    end

    it 'should use question_email if passed in' do
      deliverer = double()
      deliverer.should_receive(:deliver)
      Notifier.stub!(:ask_a_question) { |quick_question|
        quick_question.from.should eq 'no-reply@musc.edu'
        deliverer
      }
      get :ask_a_question, { :id => service_request.id, :quick_question => { :email => 'no-reply@musc.edu' }, :quick_question => { :body => '' }, :format => :js }
    end

    it 'should use question_body if passed in' do
      deliverer = double()
      deliverer.should_receive(:deliver)
      Notifier.stub!(:ask_a_question) { |quick_question|
        quick_question.body.should eq 'is this thing on?'
        deliverer
      }
      get :ask_a_question, { :id => service_request.id, :quick_question => { :email => '' }, :quick_question => { :body => 'is this thing on?' }, :format => :js }
    end
  end

  describe 'GET refresh_service_calendar' do
    build_project
    build_arms

    it "should set the page if page is passed in" do
      arm1.update_attribute(:visit_count, 500)

      session[:service_request_id] = service_request.id
      get :refresh_service_calendar, { :id => service_request.id, :arm_id => arm1.id, :pages => { arm1.id.to_s => 42 }, :format => :js }.with_indifferent_access
      session[:service_calendar_pages].should eq({arm1.id.to_s => 42})
    
      # TODO: sometimes this is 1 and sometimes it is 42.  I don't know
      # why.
      assigns(:pages).should eq({arm1.id => 42, arm2.id => 1})
    
      # TODO: check that set_visit_page is called?
    end
    
    it 'should set tab to full calendar' do
      session[:service_request_id] = service_request.id
      get :refresh_service_calendar, :id => service_request.id, :arm_id => arm1.id, :format => :js
      assigns(:tab).should eq 'calendar'
    end
  end

  describe 'POST add_service' do
    let!(:new_service) {
      service = FactoryGirl.create(
          :service,
          pricing_map_count: 1,
          organization_id: core.id)
      service.pricing_maps[0].update_attributes(
          display_date: Date.today,
          is_one_time_fee: true,
          quantity_minimum: 42)
      service
    }

    let!(:new_service2) {
      service = FactoryGirl.create(
          :service,
          pricing_map_count: 1,
          organization_id: core.id)
      service.pricing_maps[0].update_attributes(
          display_date: Date.today,
          is_one_time_fee: true,
          quantity_minimum: 54)
      service
    }

    let!(:new_service3) {
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
          service_id: new_service.id,
          service_request_id: service_request.id)
      session[:service_request_id] = service_request.id
      post :add_service, {
        :id          => service_request.id,
        :service_id  => new_service.id,
        :format      => :js
      }.with_indifferent_access
      response.body.should eq 'Service exists in line items'
    end

    it 'should create a line item for the service' do
      orig_count = service_request.line_items.count

      session[:service_request_id] = service_request.id
      post :add_service, {
        :id          => service_request.id,
        :service_id  => new_service.id,
        :format      => :js
      }.with_indifferent_access

      service_request.reload
      service_request.line_items.count.should eq orig_count + 1
      line_item = service_request.line_items.find_by_service_id(new_service.id)
      line_item.service.should eq new_service
      line_item.optional.should eq true
      line_item.quantity.should eq 42
    end

    it 'should create a line item for a required service' do
      orig_count = service_request.line_items.count

      FactoryGirl.create(
          :service_relation,
          service_id: new_service.id,
          related_service_id: new_service2.id,
          optional: false)

      session[:service_request_id] = service_request.id
      post :add_service, { :id => service_request.id, :service_id => new_service.id, :format => :js }.with_indifferent_access

      # there was one service and one line item already, then we added
      # one

      service_request.reload
      service_request.line_items.count.should eq orig_count + 2
      line_item = service_request.line_items.find_by_service_id(new_service2.id)
      line_item.service.should eq new_service2
      line_item.optional.should eq false
      line_item.quantity.should eq 54
    end

    it 'should create a line item for an optional service' do
      orig_count = service_request.line_items.count

      FactoryGirl.create(
          :service_relation,
          service_id: new_service.id,
          related_service_id: new_service2.id,
          optional: true)

      session[:service_request_id] = service_request.id
      post :add_service, {
        :id          => service_request.id,
        :service_id  => new_service.id,
        :format      => :js
      }.with_indifferent_access

      service_request.reload
      service_request.line_items.count.should eq orig_count + 2

      line_item = service_request.line_items.find_by_service_id(new_service.id)
      line_item.service.should eq new_service
      line_item.optional.should eq true
      line_item.quantity.should eq 42

      line_item = service_request.line_items.find_by_service_id(new_service2.id)
      line_item.service.should eq new_service2
      line_item.optional.should eq true
      line_item.quantity.should eq 54
    end

    it 'should create a sub service request for each organization in the service list' do
      orig_count = service_request.sub_service_requests.count

      session[:service_request_id] = service_request.id

      [ new_service, new_service2, new_service3 ].each do |service_to_add|
        post :add_service, {
          :id          => service_request.id,
          :service_id  => service_to_add.id,
          :format      => :js
        }.with_indifferent_access
      end

      service_request.reload
      service_request.sub_service_requests.count.should eq orig_count + 2
      service_request.sub_service_requests[-2].organization.should eq core
      service_request.sub_service_requests[-1].organization.should eq core2
    end

    it 'should update each of the line items with the appropriate ssr id' do
      orig_count = service_request.line_items.count

      session[:service_request_id] = service_request.id

      [ new_service, new_service2, new_service3 ].each do |service_to_add|
        post :add_service, {
          :id          => service_request.id,
          :service_id  => service_to_add.id,
          :format      => :js
        }.with_indifferent_access
      end

      core_ssr = service_request.sub_service_requests.find_by_organization_id(core.id)
      core2_ssr = service_request.sub_service_requests.find_by_organization_id(core2.id)

      service_request.reload
      service_request.line_items.count.should eq(orig_count + 3)
      service_request.line_items[-3].sub_service_request.should eq core_ssr
      service_request.line_items[-2].sub_service_request.should eq core_ssr
      service_request.line_items[-1].sub_service_request.should eq core2_ssr
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
        assigns(:service_list).should eq service_request.service_list.with_indifferent_access
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
      session[:service_request_id] = service_request.id
      get :service_subsidy, :id => service_request.id
      assigns(:subsidies).should eq [ subsidy ]
    end

    it 'should create a new subsidy and put it into subsidies if the ssr does not have a subsidy and it is eligible for subsidy' do
      sub_service_request.organization.subsidy_map.update_attributes(
          max_dollar_cap: 100,
          max_percentage: 100)

      session[:service_request_id] = service_request.id
      get :service_subsidy, :id => service_request.id

      assigns(:subsidies).map { |s| s.class}.should eq [ Subsidy ]
    end

    context 'with subsidy maps' do
      let!(:core_subsidy_map)     { FactoryGirl.create(:subsidy_map, organization_id: core.id) }
      let!(:provider_subsidy_map) { FactoryGirl.create(:subsidy_map, organization_id: provider.id) }
      let!(:program_subsidy_map)  { subsidy_map }

      it 'should not create a new subsidy if the ssr does not have a subsidy and it not is eligible for subsidy' do
        # destroy the subsidy; we want to ensure that #service_subsidy
        # doesn't create a subsidy
        sub_service_request.subsidy.destroy

        core.build_subsidy_map
        provider.build_subsidy_map
        program.build_subsidy_map

        core.subsidy_map.update_attributes!(
            max_dollar_cap: 0,
            max_percentage: 0)
        provider.subsidy_map.update_attributes!(
            max_dollar_cap: 0,
            max_percentage: 0)
        program.subsidy_map.update_attributes!(
            max_dollar_cap: 0,
            max_percentage: 0)

        # make sure before we start the test that the ssr is not
        # eligible for subsidy
        sub_service_request.eligible_for_subsidy?.should_not eq nil

        # call service_subsidy
        session[:service_request_id] = service_request.id
        get :service_subsidy, :id => service_request.id

        # Now the ssr should not have a subsidy
        sub_service_request.reload
        subsidy = sub_service_request.subsidy
        subsidy.should eq nil

        assigns(:subsidies).should eq [ ]
      end
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

