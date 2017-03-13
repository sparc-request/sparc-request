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

require 'rails_helper'
require 'timecop'

RSpec.describe ServiceRequestsController, type: :controller do
  stub_controller
  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity) }

  describe '#confirmation' do
    it 'should call before_filter #initialize_service_request' do
      expect(before_filters.include?(:initialize_service_request)).to eq(true)
    end

    it 'should call before_filter #validate_step' do
      expect(before_filters.include?(:validate_step)).to eq(true)
    end

    it 'should call before_filter #authorize_identity' do
      expect(before_filters.include?(:authorize_identity)).to eq(true)
    end

    it 'should call before_filter #authenticate_identity!' do
      expect(before_filters.include?(:authenticate_identity!)).to eq(true)
    end

    it 'should update previous_submitted_at' do
      org      = create(:organization)
      service  = create(:service, organization: org, one_time_fee: true)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
      sr       = create(:service_request_without_validations, protocol: protocol, submitted_at: '2015-06-01')
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, protocol_id: protocol.id)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      session[:identity_id]        = logged_in_user.id

      xhr :get, :confirmation, {
        id: sr.id
      }

      expect(assigns(:service_request).previous_submitted_at).to eq(sr.submitted_at)
    end

    #  Scenario: You have an existing SR, you add a new service that creates a new SSR (0004), you then delete this same service (therefore deleting the SSR), you then (because you are in indecisive user) decide to add said service back AGAIN (0005).  You then go through the app to resubmit
    # Result: authorized users should receive a request amendment email with the service being added(and it should have the number of the last added service- 0005). SP and Admin should receive an initial submit
    context 'previously submitted SR and SSR' do
      context 'add line item to new SSR, then immediately delete before resubmitting' do
        before :each do

          # SR
          protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
          @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: '2015-06-01')

          # ORIGINAL SSR
          @org         = create(:organization)
          service     = create(:service, organization: @org, one_time_fee: true)
          @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday.utc, protocol_id: protocol.id)
          li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)

          # NEW LI ADDED TO NEW SSR
          @initial_submit_org         = create(:organization)
          initial_submit_service    = create(:service, organization: @initial_submit_org, one_time_fee: true)
          # Add LI
          @ssr2        = create(:sub_service_request_without_validations, service_request: @sr, organization: @initial_submit_org, status: 'draft', submitted_at: nil, protocol_id: protocol.id)
          initial_submit_li        = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: initial_submit_service)
          @audit_add = AuditRecovery.where("auditable_id = '#{initial_submit_li.id}' AND auditable_type = 'LineItem' AND action = 'create'")
          @audit_add.first.update_attribute(:created_at, Time.now.utc)
          @audit_add.first.update_attribute(:user_id, logged_in_user.id)
          initial_submit_li_id = initial_submit_li.id

          @sr.reload
          # Delete LI
          @ssr2.line_items.first.destroy!
          @sr.sub_service_requests.last.destroy!

          @sr.reload
          @audit_delete = AuditRecovery.where("auditable_id = '#{initial_submit_li_id}' AND auditable_type = 'LineItem' AND action = 'destroy'")
          @audit_delete.first.update_attribute(:created_at, Time.now.utc)
          @audit_delete.first.update_attribute(:user_id, logged_in_user.id)

          # Readd LI
          @readded_ssr        = create(:sub_service_request_without_validations, service_request: @sr, organization: @initial_submit_org, status: 'draft', submitted_at: nil, protocol_id: protocol.id)
          readded_li        = create(:line_item, service_request: @sr, sub_service_request: @readded_ssr, service: initial_submit_service)
          @audit_readded = AuditRecovery.where("auditable_id = '#{readded_li.id}' AND auditable_type = 'LineItem' AND action = 'create'")
          @audit_readded.first.update_attribute(:created_at, Time.now.utc)
          @audit_readded.first.update_attribute(:user_id, logged_in_user.id)

          session[:identity_id]        = logged_in_user.id
        end

        context 'with an authorized_user, service provider, admin' do
          before :each do
            @service_provider = create(:service_provider, identity: logged_in_user, organization: @initial_submit_org)
            @admin = @initial_submit_org.submission_emails.create(email: 'hedwig@owlpost.com')
          end

          it "should increase deliveries by 1 (authorized_user), should not send to service_provider and admin" do
            expect {
              xhr :get, :confirmation, {
                id: @sr.id
              }
            }.to change(ActionMailer::Base.deliveries, :count).by(3)
          end

          it 'should send request amendment email to authorized_user' do
            allow(Notifier).to receive(:notify_user) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver_now)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }
            @sr.update_attribute(:status, 'submitted')
            @sr.reload
            @audit = { :line_items => @audit_readded }
            expect(Notifier).to have_received(:notify_user).with(@sr.protocol.project_roles.first, @sr, nil, "", false, logged_in_user, @audit, false)
          end

          it 'should send initial submit email to service provider' do
            request_amendment = false
            @audit = nil
            allow(Notifier).to receive(:notify_service_provider) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver_now)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }

            expect(Notifier).to have_received(:notify_service_provider).with(@service_provider, @sr, {"service_request_#{@sr.id}.xlsx"=>""}, logged_in_user, @readded_ssr, @audit, false, request_amendment, false)
          end


          it 'should send initial submit email to admin' do
            @audit = nil
            allow(Notifier).to receive(:notify_admin) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }

            expect(Notifier).to have_received(:notify_admin).with(@admin.email, "", logged_in_user, @readded_ssr, @audit, false, false)
          end
        end
      end
    end


    #Scenario: You already have an existing SSR with one service and you delete that one service- deleting that SSR.  Service Providers and Admin get their emails with the deleted SSR.  Then you add that same service back, creating a new SSR, go through the app and resubmit.  The authorized users should receive a request amendment email that should display the deleted SSR service and the added SSR service. SP and Admin should get an initial submit email with the added SSR
    context 'previously submitted ssr with two SSRs' do
      context 'delete the only service on the SSR (deleting SSR) and then add back that service' do
        before :each do
          #  Service Request
          protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
          @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: '2015-06-01')

          # original SSR
          @org_associated_with_deleted         = create(:organization)
          service_associated_with_deleted     = create(:service, organization: @org_associated_with_deleted, one_time_fee: true)
          @ssr_associated_with_deleted         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org_associated_with_deleted, status: 'submitted', submitted_at: Time.now.yesterday, protocol_id: protocol.id)
          create(:line_item, service_request: @sr, sub_service_request: @ssr_associated_with_deleted, service: service_associated_with_deleted)

          # SSR that is left alone
          @unaffected_org        = create(:organization)
          unaffected_service     = create(:service, organization: @unaffected_org, one_time_fee: true)
          @unaffected_ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @unaffected_org, status: 'submitted', submitted_at: Time.now.yesterday, protocol_id: protocol.id)
          create(:line_item, service_request: @sr, sub_service_request: @unaffected_ssr, service: unaffected_service)

          # Destroy SSR
          destroyed_ssr_id = @ssr_associated_with_deleted.id
          destroyed_line_item_id = @ssr_associated_with_deleted.line_items.first.id
          @ssr_associated_with_deleted.line_items.first.destroy!
          @ssr_associated_with_deleted.destroy!
          @sr.reload

          @audit = AuditRecovery.where("auditable_id = '#{destroyed_line_item_id}' AND auditable_type = 'LineItem' AND action = 'destroy'")
          @audit2 = AuditRecovery.where("auditable_id = '#{destroyed_ssr_id}' AND auditable_type = 'SubServiceRequest' AND action = 'destroy'")
          @audit.first.update_attribute(:created_at, Time.now)
          @audit.first.update_attribute(:user_id, logged_in_user.id)
          @audit2.first.update_attribute(:created_at, Time.now - 4.hours)
          @audit2.first.update_attribute(:user_id, logged_in_user.id)

          # Add service back
          service_associated_with_added     = create(:service, organization: @org_associated_with_deleted, one_time_fee: true)
          @ssr_associated_with_added         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org_associated_with_deleted, status: 'draft', submitted_at: nil, protocol_id: protocol.id)
          line_item_added = create(:line_item, service_request: @sr, sub_service_request: @ssr_associated_with_added, service: service_associated_with_added)
          @audit_for_added_li = AuditRecovery.where("auditable_id = '#{line_item_added.id}' AND auditable_type = 'LineItem' AND action = 'create'")
          @audit_for_added_ssr = AuditRecovery.where("auditable_id = '#{@ssr_associated_with_added.id}' AND auditable_type = 'SubServiceRequest' AND action = 'create'")
          @audit_for_added_ssr.first.update_attribute(:created_at, Time.now - 4.hours)
          @audit_for_added_ssr.first.update_attribute(:user_id, logged_in_user.id)
          @audit_for_added_li.first.update_attribute(:created_at, Time.now - 4.hours)
          @audit_for_added_li.first.update_attribute(:user_id, logged_in_user.id)

          @audit_for_user = []
          @audit_for_user << @audit
          @audit_for_user << @audit_for_added_li
          @audit_for_user = @audit_for_user.flatten
          session[:identity_id]        = logged_in_user.id
        end

        context 'with an authorized_user, service provider, admin' do
          before :each do
            @service_provider = create(:service_provider, identity: logged_in_user, organization: @org_associated_with_deleted)
            @admin = @org_associated_with_deleted.submission_emails.create(email: 'hedwig@owlpost.com')
          end

          it "should increase deliveries by 1 (authorized_user), should not send to service_provider and admin" do
            expect {
              xhr :get, :confirmation, {
                id: @sr.id
              }
            }.to change(ActionMailer::Base.deliveries, :count).by(3)
          end

          it 'should send request amendment email to authorized_user' do
            allow(Notifier).to receive(:notify_user) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver_now)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }
            @sr.update_attribute(:status, 'submitted')
            @sr.reload
            @audit = { :line_items => @audit_for_user }
            expect(Notifier).to have_received(:notify_user).with(@sr.protocol.project_roles.first, @sr, nil, "", false, logged_in_user, @audit, false)
          end

          it 'should send initial submit email to service provider' do
            request_amendment = false
            @audit = nil
            allow(Notifier).to receive(:notify_service_provider) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver_now)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }

            expect(Notifier).to have_received(:notify_service_provider).with(@service_provider, @sr, {"service_request_#{@sr.id}.xlsx"=>""}, logged_in_user, @ssr_associated_with_added, @audit, false, request_amendment, false)
          end


          it 'should send initial submit email to admin' do
            @audit = nil
            allow(Notifier).to receive(:notify_admin) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }

            expect(Notifier).to have_received(:notify_admin).with(@admin.email, "", logged_in_user, @ssr_associated_with_added, @audit, false, false)
          end
        end
      end
    end

    # Scenario:  Delete all services for an existing SSR and resubmit.
    # Result:  Authorized users get a request amendment with the deleted services
    # (The service providers get their notification upon deletion of last service in SSR and not on resubmit so they should not get emails)
    context 'previously submitted ssr with two SSRs' do
      context 'delete one of the SSRs' do
        before :each do
          #  Service Request
          protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
          @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: '2015-06-01')

          # original SSR
          @org_associated_with_deleted         = create(:organization)
          service_associated_with_deleted     = create(:service, organization: @org_associated_with_deleted, one_time_fee: true)
          @ssr_associated_with_deleted         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org_associated_with_deleted, status: 'submitted', submitted_at: Time.now.yesterday, protocol_id: protocol.id)
          create(:line_item, service_request: @sr, sub_service_request: @ssr_associated_with_deleted, service: service_associated_with_deleted)

          # SSR that is left alone
          @unaffected_org        = create(:organization)
          unaffected_service     = create(:service, organization: @unaffected_org, one_time_fee: true)
          @unaffected_ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @unaffected_org, status: 'submitted', submitted_at: Time.now.yesterday, protocol_id: protocol.id)
          create(:line_item, service_request: @sr, sub_service_request: @unaffected_ssr, service: unaffected_service)


          session[:identity_id]        = logged_in_user.id

          # Destroy SSR
          destroyed_ssr_id = @ssr_associated_with_deleted.id
          destroyed_line_item_id = @ssr_associated_with_deleted.line_items.first.id
          @ssr_associated_with_deleted.line_items.first.destroy!
          @ssr_associated_with_deleted.destroy!
          @sr.reload

          @audit = AuditRecovery.where("auditable_id = '#{destroyed_line_item_id}' AND auditable_type = 'LineItem' AND action = 'destroy'")
          @audit2 = AuditRecovery.where("auditable_id = '#{destroyed_ssr_id}' AND auditable_type = 'SubServiceRequest' AND action = 'destroy'")
          @audit.first.update_attribute(:created_at, Time.now)
          @audit.first.update_attribute(:user_id, logged_in_user.id)
          @audit2.first.update_attribute(:created_at, Time.now - 4.hours)
          @audit2.first.update_attribute(:user_id, logged_in_user.id)
        end

        context 'with an authorized_user, service provider, admin' do
          before :each do
            @service_provider = create(:service_provider, identity: logged_in_user, organization: @org_associated_with_deleted)
            @admin = @org_associated_with_deleted.submission_emails.create(email: 'hedwig@owlpost.com')
          end

          it "should increase deliveries by 1 (authorized_user), should not send to service_provider and admin" do
            expect {
              xhr :get, :confirmation, {
                id: @sr.id
              }
            }.to change(ActionMailer::Base.deliveries, :count).by(1)
          end

          it 'should send request amendment email to authorized_user' do
            allow(Notifier).to receive(:notify_user) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver_now)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }
            @sr.update_attribute(:status, 'submitted')
            @sr.reload
            @audit = { :line_items => @audit }
            expect(Notifier).to have_received(:notify_user).with(@sr.protocol.project_roles.first, @sr, nil, "", false, logged_in_user, @audit, false)
          end
        end
      end
    end

    # Scenario: You have an existing SR that has been previously submitted , you do not add/remove/or change services in any way, you go through and resubmit
    # Result:  no emails should be sent out.
    context 'previously submitted ssr with two SSRs' do
      context 'change nothing and resubmit' do
        before :each do
          #  Service Request
          protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
          @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: '2015-06-01')

          # original SSR
          @org         = create(:organization)
          service     = create(:service, organization: @org, one_time_fee: true)
          @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday, protocol_id: protocol.id)
          create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
          session[:identity_id]        = logged_in_user.id
        end

        context 'with an authorized_user, service provider, admin' do
          before :each do
            create(:service_provider, identity: logged_in_user, organization: @org)
            @org.submission_emails.create(email: 'hedwig@owlpost.com')
          end

          it "should not send any emails" do
            expect {
              xhr :get, :confirmation, {
                id: @sr.id
              }
            }.to change(ActionMailer::Base.deliveries, :count).by(0)
          end
        end
      end
    end

    # Scenario: You have an existing SR, you add a new service that creates a new SSR, you then delete this same service (therefore deleting the SSR).
    # Result: No emails should be sent out to Service Providers or Admin.  Then when you go through the app and resubmit, no emails should be sent out to authorized users either.

    context 'previously submitted SR and SSR' do
      context 'add line item to new SSR, then immediately delete before resubmitting' do
        before :each do

          # SR
          protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
          @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: '2015-06-01')

          # ORIGINAL SSR
          @org         = create(:organization)
          service     = create(:service, organization: @org, one_time_fee: true)
          @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday.utc, protocol_id: protocol.id)
          li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)

          # NEW LI ADDED TO NEW SSR
          @initial_submit_org         = create(:organization)
          initial_submit_service    = create(:service, organization: @initial_submit_org, one_time_fee: true)
          @ssr2        = create(:sub_service_request_without_validations, service_request: @sr, organization: @initial_submit_org, status: 'draft', submitted_at: nil, protocol_id: protocol.id)
          initial_submit_li        = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: initial_submit_service)
          @audit_add = AuditRecovery.where("auditable_id = '#{initial_submit_li.id}' AND auditable_type = 'LineItem' AND action = 'create'")
          initial_submit_li_id = initial_submit_li.id

          @sr.reload
          @ssr2.line_items.first.destroy!
          @sr.sub_service_requests.last.destroy!

          @sr.reload
          @audit_delete = AuditRecovery.where("auditable_id = '#{initial_submit_li_id}' AND auditable_type = 'LineItem' AND action = 'destroy'")

          @audit_delete.first.update_attribute(:created_at, Time.now.utc)
          @audit_delete.first.update_attribute(:user_id, logged_in_user.id)

          @audit_add.first.update_attribute(:created_at, Time.now.utc)
          @audit_add.first.update_attribute(:user_id, logged_in_user.id)
          session[:identity_id]        = logged_in_user.id
        end

        it "should not send any emails" do
          expect {
            xhr :get, :confirmation, {
              id: @sr.id
            }
          }.to change(ActionMailer::Base.deliveries, :count).by(0)
        end
      end
    end

    # Scenario:  You have an existing SR, you decide to delete a service (line_item) on an existing SSR
    # (but there is still another service under this SSR so it does not get deleted therefore Service Providers
    # and Admin do not receive emails at this point), then you re-add this service, go through the app and resubmit
    # Result: Request amendment emails are sent to Service Providers, Admin, and authorized users and the email displays both the deleted and added services.
    context 'previously submitted SR with previously submitted SSR' do
      context 'delete a service(line item) out of cart' do
        before :each do
          # SR
          protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
          @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: '2015-06-01')

          #SSR with two line items (services)
          @org         = create(:organization)
          service     = create(:service, organization: @org, one_time_fee: true)
          service1     = create(:service, organization: @org, one_time_fee: true)
          @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday, protocol_id: protocol.id)
          li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
          li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service1)
          session[:identity_id]        = logged_in_user.id

          ssr_li_id   = @ssr.line_items.first.id
          # destroyed line item
          @ssr.line_items.first.destroy!
          @audit = AuditRecovery.where("auditable_id = '#{ssr_li_id}' AND auditable_type = 'LineItem' AND action = 'destroy'")
          # Re-add previously deleted service
          re_added_service = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service1)
          @audit_readded = AuditRecovery.where("auditable_id = '#{re_added_service.id}' AND auditable_type = 'LineItem' AND action = 'create'")

          @audit.first.update_attribute(:created_at, Time.now - 5.hours)
          @audit.first.update_attribute(:user_id, logged_in_user.id)
          @audit_readded.first.update_attribute(:created_at, Time.now - 5.hours)
          @audit_readded.first.update_attribute(:user_id, logged_in_user.id)

          @audit_with_deleted_and_added_services = []
          @audit_with_deleted_and_added_services << @audit
          @audit_with_deleted_and_added_services << @audit_readded
          @audit_with_deleted_and_added_services = @audit_with_deleted_and_added_services.flatten
        end

        context 'with an authorized_user, and service provider, and admin' do
          before :each do
            @service_provider = create(:service_provider, identity: logged_in_user, organization: @org)
            @admin = @org.submission_emails.create(email: 'hedwig@owlpost.com')
          end

          it "should increase deliveries by 3 (authorized_user, service provider, admin)" do
            expect {
              xhr :get, :confirmation, {
                id: @sr.id
              }
            }.to change(ActionMailer::Base.deliveries, :count).by(3)
          end

          it 'should send request amendment email to authorized_user' do
            allow(Notifier).to receive(:notify_user) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver_now)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }
            @sr.update_attribute(:status, 'submitted')
            @sr.reload
            @audit = { :line_items => @audit_with_deleted_and_added_services }
            expect(Notifier).to have_received(:notify_user).with(@sr.protocol.project_roles.first, @sr, nil, "", false, logged_in_user, @audit, false)
          end

          it 'should send request amendment email to service provider' do
            allow(Notifier).to receive(:notify_service_provider) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver_now)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }

            @sr.update_attribute(:status, 'submitted')
            @sr.reload
            @audit = { :line_items => @audit_with_deleted_and_added_services, :sub_service_request_id => @ssr.id }

            expect(Notifier).to have_received(:notify_service_provider).with(@service_provider, @sr, {"service_request_#{@sr.id}.xlsx"=>""}, logged_in_user, @ssr, @audit, false, true, false)
          end

          it 'should send request amendment email to admin' do

            allow(Notifier).to receive(:notify_admin) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }
            @sr.update_attribute(:status, 'submitted')
            @sr.reload
            @audit = { :line_items => @audit_with_deleted_and_added_services, :sub_service_request_id => @ssr.id }
            expect(Notifier).to have_received(:notify_admin).with(@admin.email, "", logged_in_user, @ssr, @audit, false, false)
          end
        end
      end
    end

    # Scenario:  Delete all services for an existing SSR and add service to an existing SSR and resubmit.
    # Result:  Authorized users get a request amendment with the deleted services
    # (The service providers get their notification upon deletion of last service in SSR and not on resubmit so they should not get emails)
    # Service providers and admin get a request amendment for added service
    context 'previously submitted ssr with two SSRs' do
      context 'delete one of the SSRs and add service to an existing SSR' do
        before :each do
          #  Service Request
          protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
          @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: '2015-06-01')

          # SSR that is deleted
          @org_associated_with_deleted         = create(:organization)
          service_associated_with_deleted     = create(:service, organization: @org_associated_with_deleted, one_time_fee: true)
          @ssr_associated_with_deleted         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org_associated_with_deleted, status: 'submitted', submitted_at: Time.now.yesterday, protocol_id: protocol.id)
          create(:line_item, service_request: @sr, sub_service_request: @ssr_associated_with_deleted, service: service_associated_with_deleted)

          # SSR with added line item
          @request_amendment_org        = create(:organization)
          request_amendment_service     = create(:service, organization: @request_amendment_org, one_time_fee: true)
          @request_amendment_ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @request_amendment_org, status: 'submitted', submitted_at: Time.now.yesterday, protocol_id: protocol.id)
          create(:line_item, service_request: @sr, sub_service_request: @request_amendment_ssr, service: request_amendment_service)
          # Add line item
          added_li        = create(:line_item, service_request: @sr, sub_service_request: @request_amendment_ssr, service: request_amendment_service)

          @request_amendment_audit = AuditRecovery.where("auditable_id = '#{added_li.id}' AND auditable_type = 'LineItem' AND action = 'create'")
          @request_amendment_audit.first.update_attribute(:created_at, Time.now.utc)
          @request_amendment_audit.first.update_attribute(:user_id, logged_in_user.id)

          # Destroy SSR
          destroyed_ssr_id = @ssr_associated_with_deleted.id
          destroyed_line_item_id = @ssr_associated_with_deleted.line_items.first.id
          @ssr_associated_with_deleted.line_items.first.destroy!
          @ssr_associated_with_deleted.destroy!
          @sr.reload

          @audit = AuditRecovery.where("auditable_id = '#{destroyed_line_item_id}' AND auditable_type = 'LineItem' AND action = 'destroy'")
          @audit2 = AuditRecovery.where("auditable_id = '#{destroyed_ssr_id}' AND auditable_type = 'SubServiceRequest' AND action = 'destroy'")
          @audit.first.update_attribute(:created_at, Time.now)
          @audit.first.update_attribute(:user_id, logged_in_user.id)
          @audit2.first.update_attribute(:created_at, Time.now - 4.hours)
          @audit2.first.update_attribute(:user_id, logged_in_user.id)

          @audit_for_user = []
          @audit_for_user << @request_amendment_audit
          @audit_for_user << @audit
          @audit_for_user = @audit_for_user.flatten

          session[:identity_id]        = logged_in_user.id

        end

        context 'with an authorized_user, and service provider, and admin' do
          before :each do
            @service_provider = create(:service_provider, identity: logged_in_user, organization: @request_amendment_org)
            @admin = @request_amendment_org.submission_emails.create(email: 'hedwig@owlpost.com')
          end

          it "should increase deliveries by 3 (authorized_user, service provider, admin)" do
            expect {
              xhr :get, :confirmation, {
                id: @sr.id
              }
            }.to change(ActionMailer::Base.deliveries, :count).by(3)
          end

          it 'should send request amendment email to authorized_user' do
            allow(Notifier).to receive(:notify_user) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver_now)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }
            @sr.update_attribute(:status, 'submitted')
            @sr.reload
            @audit = { :line_items => @audit_for_user }
            expect(Notifier).to have_received(:notify_user).with(@sr.protocol.project_roles.first, @sr, nil, "", false, logged_in_user, @audit, false)
          end

          it 'should send request amendment email to service provider' do
            allow(Notifier).to receive(:notify_service_provider) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver_now)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }

            @sr.update_attribute(:status, 'submitted')
            @sr.reload
            @audit = { :line_items => @request_amendment_audit, :sub_service_request_id => @request_amendment_ssr.id }

            expect(Notifier).to have_received(:notify_service_provider).with(@service_provider, @sr, {"service_request_#{@sr.id}.xlsx"=>""}, logged_in_user, @request_amendment_ssr, @audit, false, true, false)
          end

          it 'should send request amendment email to admin' do

            allow(Notifier).to receive(:notify_admin) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }
            @sr.update_attribute(:status, 'submitted')
            @sr.reload
            @audit = { :line_items => @request_amendment_audit, :sub_service_request_id => @request_amendment_ssr.id }
            expect(Notifier).to have_received(:notify_admin).with(@admin.email, "", logged_in_user, @request_amendment_ssr, @audit, false, false)
          end
        end
      end
    end


    # Scenario:  Delete a service from an existing SSR and resubmit.
    # Result:
    # The Authorized Users, Service Providers, and Admin should receive a request amendment that shows the deleted service for the existing SSR.
    context 'previously submitted SR with previously submitted SSR' do
      context 'delete a service(line item) out of cart' do
        before :each do
          # SR
          protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
          @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: '2015-06-01')

          #SSR with two line items (services)
          @org         = create(:organization)
          service     = create(:service, organization: @org, one_time_fee: true)
          service1     = create(:service, organization: @org, one_time_fee: true)
          @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday, protocol_id: protocol.id)
          li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
          li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service1)
          session[:identity_id]        = logged_in_user.id

          ssr_li_id   = @ssr.line_items.first.id
          @ssr.line_items.first.destroy!
          @audit = AuditRecovery.where("auditable_id = '#{ssr_li_id}' AND auditable_type = 'LineItem' AND action = 'destroy'")
          @audit.first.update_attribute(:created_at, Time.now - 5.hours)
          @audit.first.update_attribute(:user_id, logged_in_user.id)
        end

        it 'should update previous_submitted_at' do
          xhr :get, :confirmation, {
            id: @sr.id
          }

          expect(assigns(:service_request).previous_submitted_at).to eq(@sr.submitted_at)
        end

        context 'with an authorized_user, service provider, admin' do
          before :each do
            @service_provider = create(:service_provider, identity: logged_in_user, organization: @org)
            @admin = @org.submission_emails.create(email: 'hedwig@owlpost.com')
          end

          it 'should send request amendment email to authorized_user' do
            allow(Notifier).to receive(:notify_user) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver_now)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }
            @sr.update_attribute(:status, 'submitted')
            @sr.reload
            @audit = { :line_items => @audit }
            expect(Notifier).to have_received(:notify_user).with(@sr.protocol.project_roles.first, @sr, nil, "", false, logged_in_user, @audit, false)
          end

          it 'should send request amendment email to service provider' do
            allow(Notifier).to receive(:notify_service_provider) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver_now)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }

            @sr.update_attribute(:status, 'submitted')
            @sr.reload
            @audit = { :line_items => @audit, :sub_service_request_id => @ssr.id }

            expect(Notifier).to have_received(:notify_service_provider).with(@service_provider, @sr, {"service_request_#{@sr.id}.xlsx"=>""}, logged_in_user, @ssr, @audit, false, true, false)
          end

          it 'should send request amendment email to admin' do

            allow(Notifier).to receive(:notify_admin) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }
            @ssr.update_attribute(:status, 'submitted')
            @ssr.reload
            @audit = { :line_items => @audit, :sub_service_request_id => @ssr.id }
            expect(Notifier).to have_received(:notify_admin).with(@admin.email, "", logged_in_user, @ssr, @audit, false, false)
          end


          it "should increase deliveries by 3 (authorized_user, service provider, admin)" do
            expect {
              xhr :get, :confirmation, {
                id: @sr.id
              }
            }.to change(ActionMailer::Base.deliveries, :count).by(3)
          end
        end
      end
    end

    # Scenario:  Add a service to an existing SSR and resubmit.
    # Result: The Authorized Users, Service Providers, and Admin should receive a request amendment that shows the added service for the existing SSR.
    context 'previously submitted SR and SSR' do
      context 'add line item to existing SSR' do
        before :each do
          # SR
          protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
          @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: '2015-06-01')

          # SSR
          @org         = create(:organization)
          service     = create(:service, organization: @org, one_time_fee: true)
          service1     = create(:service, organization: @org, one_time_fee: true)
          @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: '2015-06-01', protocol_id: protocol.id)
          li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
          li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service1)

          @audit = AuditRecovery.where("auditable_id = '#{li_1.id}' AND auditable_type = 'LineItem' AND action = 'create'")
          @audit.first.update_attribute(:created_at, Time.now.utc)
          @audit.first.update_attribute(:user_id, logged_in_user.id)
          session[:identity_id]        = logged_in_user.id
        end

        it 'should update previous_submitted_at' do
          xhr :get, :confirmation, {
            id: @sr.id
          }

          expect(assigns(:service_request).previous_submitted_at).to eq(@sr.submitted_at)
        end

        context 'with an authorized_user, service provider, admin' do
          before :each do
            @service_provider = create(:service_provider, identity: logged_in_user, organization: @org)
            @admin = @org.submission_emails.create(email: 'hedwig@owlpost.com')
          end

          it 'should send request amendment email to authorized_user' do
            allow(Notifier).to receive(:notify_user) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver_now)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }
            @sr.update_attribute(:status, 'submitted')
            @sr.reload
            @audit = { :line_items => @audit }
            expect(Notifier).to have_received(:notify_user).with(@sr.protocol.project_roles.first, @sr, nil, "", false, logged_in_user, @audit, false)
          end

          it 'should send request amendment email to service provider' do
            allow(Notifier).to receive(:notify_service_provider) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver_now)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }

            @sr.update_attribute(:status, 'submitted')
            @sr.reload
            @audit = { :line_items => @audit, :sub_service_request_id => @ssr.id }

            expect(Notifier).to have_received(:notify_service_provider).with(@service_provider, @sr, {"service_request_#{@sr.id}.xlsx"=>""}, logged_in_user, @ssr, @audit, false, true, false)
          end

          it 'should send request amendment email to admin' do

            allow(Notifier).to receive(:notify_admin) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }
            @ssr.update_attribute(:status, 'submitted')
            @ssr.reload
            @audit = { :line_items => @audit, :sub_service_request_id => @ssr.id }
            expect(Notifier).to have_received(:notify_admin).with(@admin.email, "", logged_in_user, @ssr, @audit, false, false)
          end


          it "should increase deliveries by 3 (authorized_user, service provider, admin)" do
            expect {
              xhr :get, :confirmation, {
                id: @sr.id
              }
            }.to change(ActionMailer::Base.deliveries, :count).by(3)
          end
        end
      end
    end

    # Scenario: A new service is added that belongs to a new SSR and resubmit.
    # Result:  The Service Providers and Admin for this SSR receive an initial submission email.
    # The authorized users should receive a request amendment with the new service.

    context 'previously submitted SR and SSR' do
      context 'add line item to new SSR' do
        before :each do

          # SR
          protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
          @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: '2015-06-01')

          # ORIGINAL SSR
          @org         = create(:organization)
          service     = create(:service, organization: @org, one_time_fee: true)
          @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday.utc, protocol_id: protocol.id)
          li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)

          # NEW LI ADDED TO NEW SSR
          @initial_submit_org         = create(:organization)
          initial_submit_service    = create(:service, organization: @initial_submit_org, one_time_fee: true)
          @ssr2        = create(:sub_service_request_without_validations, service_request: @sr, organization: @initial_submit_org, status: 'draft', submitted_at: nil, protocol_id: protocol.id)
          initial_submit_li        = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: initial_submit_service)
          session[:identity_id]        = logged_in_user.id

          @audit = AuditRecovery.where("auditable_id = '#{initial_submit_li.id}' AND auditable_type = 'LineItem' AND action = 'create'")
          @audit.first.update_attribute(:created_at, Time.now.utc)
          @audit.first.update_attribute(:user_id, logged_in_user.id)
        end

        it 'should update previous_submitted_at' do
          xhr :get, :confirmation, {
            id: @sr.id
          }

          expect(assigns(:service_request).previous_submitted_at).to eq(@sr.submitted_at)
        end

        context 'with an authorized_user, service provider, admin' do
          before :each do
            @service_provider = create(:service_provider, identity: logged_in_user, organization: @initial_submit_org)
            @admin = @initial_submit_org.submission_emails.create(email: 'hedwig@owlpost.com')
          end

          it 'should send request amendment email to authorized_user' do
            allow(Notifier).to receive(:notify_user) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver_now)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }
            @sr.update_attribute(:status, 'submitted')
            @sr.reload
            @audit = { :line_items => @audit }
            expect(Notifier).to have_received(:notify_user).with(@sr.protocol.project_roles.first, @sr, nil, "", false, logged_in_user, @audit, false)
          end

          it 'should send initial submit email to service provider' do
            request_amendment = false
            @audit = nil
            allow(Notifier).to receive(:notify_service_provider) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver_now)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }

            expect(Notifier).to have_received(:notify_service_provider).with(@service_provider, @sr, {"service_request_#{@sr.id}.xlsx"=>""}, logged_in_user, @ssr2, @audit, false, request_amendment, false)
          end

          it 'should send initial submit email to admin' do
            @audit = nil
            allow(Notifier).to receive(:notify_admin) do
              mailer = double('mail')
              expect(mailer).to receive(:deliver)
              mailer
            end

            xhr :get, :confirmation, {
              id: @sr.id
            }

            expect(Notifier).to have_received(:notify_admin).with(@admin.email, "", logged_in_user, @ssr2, @audit, false, false)
          end


          it "should increase deliveries by 3 (authorized_user, service provider, admin)" do
            expect {
              xhr :get, :confirmation, {
                id: @sr.id
              }
            }.to change(ActionMailer::Base.deliveries, :count).by(3)
          end
        end
      end
    end

      # Scenario:  A new service is added that belongs to a new SSR AND a new service is added to an existing SSR and resubmit.
      # Result:
      # The Service Providers and Admin for the new SSR receive an initial submission email.
      # The Service Providers and Admin for the existing SSR receive a request amendment with the added/deleted service.
      # The Authorized Users receive a request amendment that shows the added service for the new SSR and the added/deleted service for the existing SSR.

    context 'previously submitted SR and SSR' do
      context 'add a new service to a new SSR' do
        context 'AND add a new service to an existing SSR' do
          before :each do
            # SR
            protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
            @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: '2015-06-01')

            # Add a new service to a new SSR
            # Original SSR
            @org         = create(:organization)
            service     = create(:service, organization: @org, one_time_fee: true)
            @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday.utc, protocol_id: protocol.id)
            li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)

            # NEW SSR
            @initial_submit_org         = create(:organization)
            initial_submit_service    = create(:service, organization: @initial_submit_org, one_time_fee: true)
            @initial_submit_ssr        = create(:sub_service_request_without_validations, service_request: @sr, organization: @initial_submit_org, status: 'draft', submitted_at: nil, protocol_id: protocol.id)
            initial_submit_li        = create(:line_item, service_request: @sr, sub_service_request: @initial_submit_ssr, service: initial_submit_service)

            @audit = AuditRecovery.where("auditable_id = '#{initial_submit_li.id}' AND auditable_type = 'LineItem' AND action = 'create'")
            @audit.first.update_attribute(:created_at, Time.now.utc)
            @audit.first.update_attribute(:user_id, logged_in_user.id)

            # request amendment SSR
            # Add a new service to an existing SSR
            # EXISTING SSR
            @request_amendment_org         = create(:organization)
            request_amendment_service     = create(:service, organization: @request_amendment_org, one_time_fee: true)
            other_request_amendment_service     = create(:service, organization: @request_amendment_org, one_time_fee: true)
            @request_amendment_ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @request_amendment_org, status: 'submitted', submitted_at: '2015-06-01', protocol_id: protocol.id)
            request_amendment_li        = create(:line_item, service_request: @sr, sub_service_request: @request_amendment_ssr, service: other_request_amendment_service)
                                          create(:line_item, service_request: @sr, sub_service_request: @request_amendment_ssr, service: request_amendment_service)

            @sr.reload
            @request_amendment_audit = AuditRecovery.where("auditable_id = '#{request_amendment_li.id}' AND auditable_type = 'LineItem' AND action = 'create'")
            @request_amendment_audit.first.update_attribute(:created_at, Time.now.utc)
            @request_amendment_audit.first.update_attribute(:user_id, logged_in_user.id)

            @audit_for_user = []
            @audit_for_user << @audit
            @audit_for_user << @request_amendment_audit
            @audit_for_user = @audit_for_user.flatten
            session[:identity_id]        = logged_in_user.id
          end

          it 'should update previous_submitted_at' do
            xhr :get, :confirmation, {
              id: @sr.id
            }

            expect(assigns(:service_request).previous_submitted_at).to eq(@sr.submitted_at)
          end

          context 'with an authorized_user, service provider, admin' do
            before :each do
              @service_provider = create(:service_provider, identity: logged_in_user, organization: @initial_submit_org)
              @request_amendment_service_provider = create(:service_provider, identity: logged_in_user, organization: @request_amendment_org)
              @admin2 = @initial_submit_org.submission_emails.create(email: 'hedwig@owlpost.com')
              @admin = @request_amendment_org.submission_emails.create(email: 'hedwig@owlpost.com')
            end

            it 'should send request amendment email to authorized_user' do
              allow(Notifier).to receive(:notify_user) do
                mailer = double('mail')
                expect(mailer).to receive(:deliver_now)
                mailer
              end

              xhr :get, :confirmation, {
                id: @sr.id
              }
              @sr.update_attribute(:status, 'submitted')
              @sr.reload
              @audit = { :line_items => @audit_for_user }
              expect(Notifier).to have_received(:notify_user).with(@sr.protocol.project_roles.first, @sr, nil, "", false, logged_in_user, @audit, false)
            end

            it 'should send initial submit email and resubmit email to service provider' do
              allow(Notifier).to receive(:notify_service_provider) do
                mailer = double('mail')
                expect(mailer).to receive(:deliver_now)
                mailer
              end

              xhr :get, :confirmation, {
                id: @sr.id
              }

              # Request Amendment Email
              @sr.update_attribute(:status, 'submitted')
              @sr.reload
              @audit = { :line_items => @request_amendment_audit, :sub_service_request_id => @request_amendment_ssr.id }

              expect(Notifier).to have_received(:notify_service_provider).with(@request_amendment_service_provider, @sr, {"service_request_#{@sr.id}.xlsx"=>""}, logged_in_user, @request_amendment_ssr, @audit, false, true, false)

              # Initial submit email
              @sr.update_attribute(:status, 'submitted')
              @sr.reload
              @audit = nil

              expect(Notifier).to have_received(:notify_service_provider).with(@service_provider, @sr, {"service_request_#{@sr.id}.xlsx"=>""}, logged_in_user, @initial_submit_ssr, @audit, false, false, false)
            end

            it 'should send initial submit and request amendment email to admin' do

              allow(Notifier).to receive(:notify_admin) do
                mailer = double('mail')
                expect(mailer).to receive(:deliver)
                mailer
              end

              xhr :get, :confirmation, {
                id: @sr.id
              }

              # Request amendment email
              @ssr.update_attribute(:status, 'submitted')
              @ssr.reload
              @audit = { :line_items => @request_amendment_audit, :sub_service_request_id => @request_amendment_ssr.id }
              expect(Notifier).to have_received(:notify_admin).with(@admin.email, "", logged_in_user, @request_amendment_ssr, @audit, false, false)

              # Initial submit email
              expect(Notifier).to have_received(:notify_admin).with(@admin2.email, "", logged_in_user, @initial_submit_ssr, nil, false, false)
            end


            it "should increase deliveries by 5 (authorized_user(1), service provider(2), admin(2))" do
              expect {
                xhr :get, :confirmation, {
                  id: @sr.id
                }
              }.to change(ActionMailer::Base.deliveries, :count).by(5)
            end
          end
        end
      end
    end

    context 'editing sub service request' do
      context 'no session[:sub_service_request_id] = ssr.id' do
        context 'status not submitted' do
          context 'ssr submitted_at: nil' do
            it 'should notify' do
              org      = create(:organization)
              service  = create(:service, organization: org, one_time_fee: true)
              protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
              sr       = create(:service_request_without_validations, protocol: protocol)
              ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', submitted_at: nil, protocol_id: protocol.id)
              li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                         create(:service_provider, identity: logged_in_user, organization: org)

              session[:identity_id]            = logged_in_user.id
              session[:service_request_id]     = sr.id

              # previously_submitted_at is null so we get 2 emails
              expect {
                xhr :get, :confirmation, {
                  id: sr.id
                }
              }.to change(ActionMailer::Base.deliveries, :count).by(2)
            end
          end
        end

        context 'status not submitted' do
          context 'ssr submitted_at: Time.now' do
            it 'should NOT notify' do
              org      = create(:organization)
              service  = create(:service, organization: org, one_time_fee: true)
              protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
              sr       = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now)
              ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', submitted_at: Time.now, protocol_id: protocol.id)
              li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                         create(:service_provider, identity: logged_in_user, organization: org)

              session[:identity_id]            = logged_in_user.id
              session[:service_request_id]     = sr.id

              expect {
                xhr :get, :confirmation, {
                  id: sr.id
                }
              }.to change(ActionMailer::Base.deliveries, :count).by(0)
            end
          end
        end
      end

      context 'session[:sub_service_request_id] = ssr.id' do
        context 'ssr submitted_at: nil' do
          it 'should notify' do
            org      = create(:organization)
            service  = create(:service, organization: org, one_time_fee: true)
            protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
            sr       = create(:service_request_without_validations, protocol: protocol)
            ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', submitted_at: nil, protocol_id: protocol.id)
            li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                       create(:service_provider, identity: logged_in_user, organization: org)

            session[:identity_id]            = logged_in_user.id
            session[:service_request_id]     = sr.id
            session[:sub_service_request_id] = ssr.id

            # previously_submitted_at is null so we get 2 emails
            expect {
              xhr :get, :confirmation, {
                id: sr.id
              }
            }.to change(ActionMailer::Base.deliveries, :count).by(2)
          end
        end

        context 'ssr submitted_at: Time.now' do
          it 'should NOT notify' do
            org      = create(:organization)
            service  = create(:service, organization: org, one_time_fee: true)
            protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
            sr       = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now)
            ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', submitted_at: Time.now, protocol_id: protocol.id)
            li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                       create(:service_provider, identity: logged_in_user, organization: org)

            session[:identity_id]            = logged_in_user.id
            session[:service_request_id]     = sr.id
            session[:sub_service_request_id] = ssr.id

            expect {
              xhr :get, :confirmation, {
                id: sr.id
              }
            }.to change(ActionMailer::Base.deliveries, :count).by(0)
          end
        end
      end

      it 'should update status to submitted and approvals to false' do
        org      = create(:organization)
        service  = create(:service, organization: org, one_time_fee: true)
        protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', protocol_id: protocol.id)
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

        session[:identity_id]            = logged_in_user.id

        xhr :get, :confirmation, {
          sub_service_request_id: ssr.id,
          id: sr.id
        }

        expect(ssr.reload.status).to eq('submitted')
        expect(ssr.reload.nursing_nutrition_approved).to eq(false)
        expect(ssr.reload.lab_approved).to eq(false)
        expect(ssr.reload.imaging_approved).to eq(false)
        expect(ssr.reload.committee_approved).to eq(false)
      end

      it 'should create past status' do
        org      = create(:organization)
        service  = create(:service, organization: org, one_time_fee: true)
        protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', protocol_id: protocol.id)
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

        session[:identity_id]            = logged_in_user.id

        xhr :get, :confirmation, {
          sub_service_request_id: ssr.id,
          id: sr.id
        }

        expect(PastStatus.count).to eq(1)
        expect(PastStatus.first.sub_service_request).to eq(ssr)
      end

      context 'using EPIC and QUEUE_EPIC' do
        it 'should create an item in the queue' do
          org      = create(:organization)
          service  = create(:service, organization: org, one_time_fee: true, send_to_epic: true)
          protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study', selected_for_epic: true)
          sr       = create(:service_request_without_validations, protocol: protocol)
          ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', protocol_id: protocol.id)
          li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

          session[:identity_id]            = logged_in_user.id
          stub_const("USE_EPIC", true)
          stub_const("QUEUE_EPIC", true)
          setup_valid_study_answers(protocol)

          xhr :get, :confirmation, {
          sub_service_request_id: ssr.id,
            id: sr.id
          }

          expect(EpicQueue.count).to eq(1)
          expect(EpicQueue.first.protocol_id).to eq(protocol.id)
        end
      end

      context 'using EPIC but not QUEUE_EPIC' do
        it 'should notify' do
          org      = create(:organization)
          service  = create(:service, organization: org, one_time_fee: true, send_to_epic: true)
          protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study', selected_for_epic: true)
          sr       = create(:service_request_without_validations, protocol: protocol)
          ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', protocol_id: protocol.id)
          li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                     create(:service_provider, identity: logged_in_user, organization: org)

          session[:identity_id]            = logged_in_user.id
          stub_const("USE_EPIC", true)
          setup_valid_study_answers(protocol)

          # previously_submitted_at is null so we get 2 emails
          expect {
            xhr :get, :confirmation, {
              sub_service_request_id: ssr.id,
              id: sr.id
            }
          }.to change(ActionMailer::Base.deliveries, :count).by(3)
        end
      end
    end

    context 'editing a service request' do
      it 'should set submitted at to now' do
        org      = create(:organization)
        service  = create(:service, organization: org, one_time_fee: true)
        protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        sr       = create(:service_request_without_validations, protocol: protocol, submitted_at: nil)
        ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', protocol_id: protocol.id)
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                   create(:service_provider, identity: logged_in_user, organization: org)

        session[:identity_id]        = logged_in_user.id
        time                         = Time.parse('2016-06-01 12:34:56')

        Timecop.freeze(time) do
          xhr :get, :confirmation, {
            id: sr.id
          }
          expect(sr.reload.submitted_at).to eq(time)
        end
      end

      it 'should update status to submitted and approvals to false' do
        org      = create(:organization)
        service  = create(:service, organization: org, one_time_fee: true)
        protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', protocol_id: protocol.id)
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                   create(:service_provider, identity: logged_in_user, organization: org)

        session[:identity_id]        = logged_in_user.id

        xhr :get, :confirmation, {
          id: sr.id
        }

        expect(sr.reload.status).to eq('submitted')
        expect(ssr.reload.nursing_nutrition_approved).to eq(false)
        expect(ssr.reload.lab_approved).to eq(false)
        expect(ssr.reload.imaging_approved).to eq(false)
        expect(ssr.reload.committee_approved).to eq(false)
      end

      it 'should notify' do
        org      = create(:organization)
        service  = create(:service, organization: org, one_time_fee: true)
        protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', protocol_id: protocol.id)
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                   create(:service_provider, identity: logged_in_user, organization: org)

        session[:identity_id]        = logged_in_user.id

        # previously_submitted_at is null so we get 2 emails
        expect {
          xhr :get, :confirmation, {
            id: sr.id
          }
        }.to change(ActionMailer::Base.deliveries, :count).by(2)
      end

      context 'using EPIC and QUEUE_EPIC' do
        it 'should create an item in the queue' do
          org      = create(:organization)
          service  = create(:service, organization: org, one_time_fee: true, send_to_epic: true)
          protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study', selected_for_epic: true)
          sr       = create(:service_request_without_validations, protocol: protocol)
          ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', protocol_id: protocol.id)
          li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

          session[:identity_id]            = logged_in_user.id
          stub_const("USE_EPIC", true)
          stub_const("QUEUE_EPIC", true)
          setup_valid_study_answers(protocol)

          xhr :get, :confirmation, {
            id: sr.id
          }

          expect(EpicQueue.count).to eq(1)
          expect(EpicQueue.first.protocol_id).to eq(protocol.id)
        end
      end

      context 'using EPIC but not QUEUE_EPIC' do
        it 'should notify' do
          org      = create(:organization)
          service  = create(:service, organization: org, one_time_fee: true, send_to_epic: true)
          protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study', selected_for_epic: true)
          sr       = create(:service_request_without_validations, protocol: protocol)
          ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', protocol_id: protocol.id)
          li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                     create(:service_provider, identity: logged_in_user, organization: org)

          session[:identity_id]            = logged_in_user.id
          stub_const("USE_EPIC", true)
          setup_valid_study_answers(protocol)

          # previously_submitted_at is null so we get 2 emails
          expect {
            xhr :get, :confirmation, {
              sub_service_request_id: ssr.id,
              id: sr.id
            }
          }.to change(ActionMailer::Base.deliveries, :count).by(3)
        end
      end
    end

    it 'should render template' do
      org      = create(:organization)
      service  = create(:service, organization: org, one_time_fee: true)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, protocol_id: protocol.id)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      session[:identity_id]        = logged_in_user.id

      xhr :get, :confirmation, {
        id: sr.id
      }

      expect(controller).to render_template(:confirmation)
    end

    it 'should respond ok' do
      org      = create(:organization)
      service  = create(:service, organization: org, one_time_fee: true)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, protocol_id: protocol.id)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      session[:identity_id]        = logged_in_user.id

      xhr :get, :confirmation, {
        id: sr.id
      }

      expect(controller).to respond_with(:ok)
    end
  end
end

def setup_valid_study_answers(protocol)
  question_group = StudyTypeQuestionGroup.create(active: true)
  question_1     = StudyTypeQuestion.create(friendly_id: 'certificate_of_conf', study_type_question_group_id: question_group.id)
  question_2     = StudyTypeQuestion.create(friendly_id: 'higher_level_of_privacy', study_type_question_group_id: question_group.id)
  question_3     = StudyTypeQuestion.create(friendly_id: 'access_study_info', study_type_question_group_id: question_group.id)
  question_4     = StudyTypeQuestion.create(friendly_id: 'epic_inbasket', study_type_question_group_id: question_group.id)
  question_5     = StudyTypeQuestion.create(friendly_id: 'research_active', study_type_question_group_id: question_group.id)
  question_6     = StudyTypeQuestion.create(friendly_id: 'restrict_sending', study_type_question_group_id: question_group.id)

  answer         = StudyTypeAnswer.create(protocol_id: protocol.id, study_type_question_id: question_1.id, answer: true)
end
