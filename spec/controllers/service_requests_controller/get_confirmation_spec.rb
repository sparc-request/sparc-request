# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'
require 'timecop'

RSpec.describe ServiceRequestsController do
  stub_controller
  let_there_be_lane
  let_there_be_j
  build_service_request_with_project

  before do
    session[:identity_id] = jug2.id
  end

  describe 'GET confirmation' do

    context 'previously submitted ssr that has deleted services' do
      before :each do
        @identity = Identity.find(jug2.id)
        service = create(:service,
                      organization_id: provider.id,
                      name: 'ABCD',
                      one_time_fee: true)
        @submission_email = provider.submission_emails.create(email: 'hedwig@owlpost.com')
        service_request.update_attribute(:submitted_at, Time.now.yesterday)
        service_request.sub_service_requests.each do |ssr|
          ssr.update_attribute(:submitted_at, Time.now.yesterday)
          ssr.update_attribute(:status, 'submitted')
        end
        @attachments = {"service_request_1.xlsx"=>""}
        @xls = ""
      end
      
      it 'should send request amendment email to service provider' do
        service_request.sub_service_requests.each do |ssr|
          ssr.line_items.first.destroy
          ssr.reload
          @audit = AuditRecovery.where("auditable_id = '#{ssr.line_items.first.id}' AND auditable_type = 'LineItem'")
        end
        
        @audit.first.update_attribute(:created_at, Time.now - 5.hours)
        @audit.first.update_attribute(:user_id, @identity.id)

        allow(Notifier).to receive(:notify_service_provider) do
            mailer = double('mail') 
            expect(mailer).to receive(:deliver_now)
            mailer
          end
        xhr :get, :confirmation, id: service_request.id, format: :js
        expect(Notifier).to have_received(:notify_service_provider)
      end

      it 'should send request amendment email to admin' do
        
        allow(Notifier).to receive(:notify_admin).with(@submission_email.email, @xls, @identity, service_request.sub_service_requests.first, @audit) do
            mailer = double('mail') 
            expect(mailer).to receive(:deliver)
            mailer
          end
        xhr :get, :confirmation, id: service_request.id, format: :js
        expect(Notifier).to have_received(:notify_admin).with(@submission_email.email, @xls, @identity, service_request.sub_service_requests.first, @audit)
      end
    end

    context 'previously submitted ssr that has added services' do
      before :each do
        @identity = Identity.find(jug2.id)
        service = create(:service,
                      organization_id: provider.id,
                      name: 'ABCD',
                      one_time_fee: true)
        @submission_email = provider.submission_emails.create(email: 'hedwig@owlpost.com')
        service_request.update_attribute(:submitted_at, Time.now.yesterday)
        service_request.sub_service_requests.each do |ssr|
          ssr.update_attribute(:submitted_at, Time.now.yesterday)
          ssr.update_attribute(:status, 'submitted')
        end
        sr_id = service_request.id
        @attachments = {"service_request_#{sr_id}.xlsx"=>""}
        @xls = ""
        audit_with_added = create(:audit_without_validations,
                                   auditable_id: service_request.line_items.last.id, 
                                   action: "create", 
                                   auditable_type: 'LineItem',
                                   user_id: jug2.id,
                                   audited_changes: 
                                  { "sub_service_request_id"=>service_request.sub_service_requests.first.id, "service_id"=>service.id }, created_at: Time.now - 4.hours)
        @audit = { line_items: [audit_with_added],
               sub_service_request_id: service_request.sub_service_requests.first.id }
      end

      it 'should send request amendment email to service provider' do
        allow(Notifier).to receive(:notify_service_provider).with(service_provider, service_request, @attachments, @identity, @audit, false) do
            mailer = double('mail') 
            expect(mailer).to receive(:deliver_now)
            mailer
          end
        xhr :get, :confirmation, id: service_request.id, format: :js
        expect(Notifier).to have_received(:notify_service_provider).with(service_provider, service_request, @attachments, @identity, @audit, false)
      end

      it 'should send request amendment email to admin' do
        allow(Notifier).to receive(:notify_admin).with(@submission_email.email, @xls, @identity, service_request.sub_service_requests.first, @audit) do
            mailer = double('mail') 
            expect(mailer).to receive(:deliver)
            mailer
          end
        xhr :get, :confirmation, id: service_request.id, format: :js
        expect(Notifier).to have_received(:notify_admin).with(@submission_email.email, @xls, @identity, service_request.sub_service_requests.first, @audit)
      end
    end

    context 'previously submitted ssr that has both added and deleted services' do
      before :each do
        @identity = Identity.find(jug2.id)
        service = create(:service,
                      organization_id: provider.id,
                      name: 'ABCD',
                      one_time_fee: true)
        @submission_email = provider.submission_emails.create(email: 'hedwig@owlpost.com')
        service_request.update_attribute(:submitted_at, Time.now.yesterday)
        service_request.update_attribute(:status, 'submitted')
        service_request.sub_service_requests.each do |ssr|
          ssr.update_attribute(:submitted_at, Time.now.yesterday)
          ssr.update_attribute(:status, 'submitted')
        end
        sr_id = service_request.id
        @attachments = {"service_request_#{sr_id}.xlsx"=>""}
        @xls = ""
        audit_with_deleted = create(:audit_without_validations, 
                                     auditable_id: service_request.line_items.first.id, 
                                     action: "destroy", 
                                     auditable_type: 'LineItem',
                                     user_id: jug2.id,
                                     audited_changes: 
                                    { "sub_service_request_id"=>service_request.sub_service_requests.first.id, "service_id"=>service.id}, created_at: Time.now - 5.hours)

        audit_with_added = create(:audit_without_validations,
                                   auditable_id: service_request.line_items.last.id, 
                                   action: "create", 
                                   auditable_type: 'LineItem',
                                   user_id: jug2.id,
                                   audited_changes: 
                                  { "sub_service_request_id"=>service_request.sub_service_requests.first.id, "service_id"=>service.id }, created_at: Time.now - 4.hours)
        @audit = { line_items: [audit_with_deleted, audit_with_added],
               sub_service_request_id: service_request.sub_service_requests.first.id }
      end

      it 'should send request amendment email to service provider' do
        allow(Notifier).to receive(:notify_service_provider).with(service_provider, service_request, @attachments, @identity, @audit, false) do
            mailer = double('mail') 
            expect(mailer).to receive(:deliver_now)
            mailer
          end
        xhr :get, :confirmation, id: service_request.id, format: :js
        expect(Notifier).to have_received(:notify_service_provider).with(service_provider, service_request, @attachments, @identity, @audit, false)
      end

      it 'should send request amendment email to admin' do
        allow(Notifier).to receive(:notify_admin).with(@submission_email.email, @xls, @identity, service_request.sub_service_requests.first, @audit) do
            mailer = double('mail') 
            expect(mailer).to receive(:deliver)
            mailer
          end
        xhr :get, :confirmation, id: service_request.id, format: :js
        expect(Notifier).to have_received(:notify_admin).with(@submission_email.email, @xls, @identity, service_request.sub_service_requests.first, @audit)
      end
    end

    context 'previously submitted ssr that does NOT have added or deleted services' do
      before :each do
        @identity = Identity.find(jug2.id)
        @submission_email = provider.submission_emails.create(email: 'hedwig@owlpost.com')
        service_request.update_attribute(:submitted_at, Time.now.yesterday)
        service_request.sub_service_requests.each do |ssr|
          ssr.update_attribute(:submitted_at, Time.now.yesterday)
          ssr.update_attribute(:status, 'submitted')
        end
        @attachments = {"service_request_1.xlsx"=>""}
        @xls = ""
        @audit = nil
      end

      it 'should NOT send request amendment email to service provider' do
        allow(Notifier).to receive(:notify_service_provider) do
            mailer = double('mail') 
            expect(mailer).to receive(:deliver_now)
            mailer
          end
        xhr :get, :confirmation, id: service_request.id, format: :js
        expect(Notifier).not_to have_received(:notify_service_provider)
      end

      it 'should NOT send request amendment email to admin' do
        allow(Notifier).to receive(:notify_admin) do
            mailer = double('mail') 
            expect(mailer).to receive(:deliver)
            mailer
          end
        xhr :get, :confirmation, id: service_request.id, format: :js
        expect(Notifier).not_to have_received(:notify_admin)
      end
    end

    context 'with project' do

      it "should set the service request's status to submitted" do
        xhr :get, :confirmation, id: service_request.id
        expect(assigns(:service_request).status).to eq 'submitted'
      end

      it "should set overridden to true for all associated Subsidies" do
        service_request.subsidies.each do |s|
          s.update_attributes(overridden: true)
        end

        xhr :get, :confirmation, id: service_request.id
        expect(service_request.reload.subsidies).to all(satisfy { |s| s.overridden })
      end

      it "should set the approval attributes to false for all associated SubServiceRequests" do
        service_request.sub_service_requests.each do |ssr|
          ssr.update_attributes(:nursing_nutrition_approved => true, :lab_approved => true, :imaging_approved => true, :committee_approved => true)
        end

        xhr :get, :confirmation, id: service_request.id
        expect(service_request.reload.sub_service_requests).to all(satisfy do |ssr|
                                                                      !(ssr.nursing_nutrition_approved ||
                                                                        ssr.lab_approved ||
                                                                        ssr.imaging_approved ||
                                                                        ssr.committee_approved)
                                                                    end)
      end

      it "should set the service request's submitted_at to Time.now" do
        time = Time.parse('2012-06-01 12:34:56')
        Timecop.freeze(time) do
          service_request.update_attribute(:submitted_at, nil)
          xhr :get, :confirmation, id: service_request.id
          service_request.reload
          expect(service_request.submitted_at).to eq Time.now
        end
      end

      it "should set the service request's previous_submitted_at" do
        previous_submitted_at = service_request.submitted_at
        xhr :get, :confirmation, id: service_request.id
        expect(service_request.reload.previous_submitted_at).to eq previous_submitted_at
      end

      it 'should should set status on all the sub service request' do
        service_request.sub_service_requests.each { |ssr| ssr.destroy }

        ssr1 = create(:sub_service_request,
                      service_request_id: service_request.id,
                      ssr_id: nil,
                      organization_id: provider.id)
        ssr2 = create(:sub_service_request,
                      service_request_id: service_request.id,
                      ssr_id: nil,
                      organization_id: core.id)

        xhr :get, :confirmation, id: service_request.id

        ssr1.reload
        ssr2.reload

        expect(ssr1.status).to eq 'submitted'
        expect(ssr2.status).to eq 'submitted'
      end

      it "should set the service request's sub service requests' submitted_at to Time.now" do
        time = Time.parse('2012-06-01 12:34:56')
        Timecop.freeze(time) do
          service_request.update_attribute(:submitted_at, nil)
          xhr :get, :confirmation, id: service_request.id
          expect(service_request.sub_service_requests.first.submitted_at).to eq(Time.now)
        end
      end

      it 'should create a past status for each sub service request' do
        service_request.sub_service_requests.each { |ssr| ssr.destroy }

        ssr1 = create(:sub_service_request,
                      service_request_id: service_request.id,
                      status: 'draft',
                      organization_id: provider.id)
        ssr2 = create(:sub_service_request,
                      service_request_id: service_request.id,
                      status: 'draft',
                      organization_id: core.id)

        xhr :get, :confirmation, id: service_request.id

        ps1 = PastStatus.find_by(sub_service_request_id: ssr1.id)
        ps2 = PastStatus.find_by(sub_service_request_id: ssr2.id)

        expect(ps1.status).to eq('draft')
        expect(ps2.status).to eq('draft')
      end

      it 'should send an email if services are set to send to epic' do
        stub_const("QUEUE_EPIC", false)
        stub_const("USE_EPIC", true)

        session[:service_request_id] = service_request.id

        service.update_attributes(send_to_epic: false)
        service2.update_attributes(send_to_epic: true)
        protocol = service_request.protocol
        protocol.project_roles.first.update_attribute(:epic_access, true)
        protocol.update_attribute(:selected_for_epic, true)
        deliverer = double()
        expect(deliverer).to receive(:deliver)
        allow(Notifier).to receive(:notify_for_epic_user_approval) do |sr|
          expect(sr).to eq(protocol)
          deliverer
        end

        xhr :get, :confirmation, id: service_request.id, format: :js
      end

      it 'should not send an email if no services are set to send to epic' do
        service.update_attributes(send_to_epic: false)
        service2.update_attributes(send_to_epic: false)

        deliverer = double()
        expect(deliverer).not_to receive(:deliver)
        allow(Notifier).to receive(:notify_for_epic_user_approval) do |sr|
          expect(sr).to eq(service_request)
          deliverer
        end

        xhr :get, :confirmation, id: service_request.id, format: :js
      end
    end
  end
end
