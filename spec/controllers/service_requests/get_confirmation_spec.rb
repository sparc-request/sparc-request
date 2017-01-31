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
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      session[:identity_id]        = logged_in_user.id

      xhr :get, :confirmation, {
        id: sr.id
      }

      expect(assigns(:service_request).previous_submitted_at).to eq(sr.submitted_at)
    end

    context 'previously submitted ssr that has deleted services' do
      before :each do
        @org         = create(:organization)
        service     = create(:service, organization: @org, one_time_fee: true)
        protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday)
        @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday)
        li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
                      create(:service_provider, identity: logged_in_user, organization: @org)
        
        ssr_li_id   = @ssr.line_items.first.id
        @ssr.line_items.first.destroy!
        audit = AuditRecovery.where("auditable_id = '#{ssr_li_id}' AND auditable_type = 'LineItem' AND action = 'destroy'")
        audit.first.update_attribute(:created_at, Time.now - 5.hours)
        audit.first.update_attribute(:user_id, logged_in_user.id)
      end

      it 'should send request amendment email to service provider' do
        session[:identity_id]        = logged_in_user.id

        allow(Notifier).to receive(:notify_service_provider) do
          mailer = double('mail') 
          expect(mailer).to receive(:deliver_now)
          mailer
        end

        xhr :get, :confirmation, {
          sub_service_request_id: @ssr.id,
          id: @sr.id
        }

        expect(Notifier).to have_received(:notify_service_provider)
      end

      it 'should send request amendment email to admin' do
        @org.submission_emails.create(email: 'hedwig@owlpost.com')
        session[:identity_id]        = logged_in_user.id

        allow(Notifier).to receive(:notify_admin) do
          mailer = double('mail') 
          expect(mailer).to receive(:deliver)
          mailer
        end
        xhr :get, :confirmation, {
          sub_service_request_id: @ssr.id,
          id: @sr.id
        }
        expect(Notifier).to have_received(:notify_admin)
      end

      it 'should send request amendment email to authorized users' do
        @org.submission_emails.create(email: 'hedwig@owlpost.com')
        session[:identity_id]        = logged_in_user.id
        session[:service_request_id] = @sr.id
        session[:sub_service_request_id] = @ssr.id

        allow(Notifier).to receive(:notify_user) do
          mailer = double('mail') 
          expect(mailer).to receive(:deliver_now)
          mailer
        end
        xhr :get, :confirmation, {
          id: @sr.id
        }
        expect(Notifier).to have_received(:notify_user)
      end
    end

    context 'previously submitted SSR (existing SSR) that has added services' do
      before :each do
        @org         = create(:organization)
        service     = create(:service, organization: @org, one_time_fee: true)
        protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
        @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday.utc)
        li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
                      create(:service_provider, identity: logged_in_user, organization: @org)
        
        audit = AuditRecovery.where("auditable_id = '#{li_1.id}' AND auditable_type = 'LineItem' AND action = 'create'")
        audit.first.update_attribute(:created_at, Time.now.utc - 5.hours)
        audit.first.update_attribute(:user_id, logged_in_user.id)
      end

      it 'should send request amendment email to service provider' do
        session[:identity_id]        = logged_in_user.id

        allow(Notifier).to receive(:notify_service_provider) do
          mailer = double('mail') 
          expect(mailer).to receive(:deliver_now)
          mailer
        end
        xhr :get, :confirmation, {
          sub_service_request_id: @ssr.id,
          id: @sr.id
        }
        expect(Notifier).to have_received(:notify_service_provider)
      end

      it 'should send request amendment email to admin' do
        @org.submission_emails.create(email: 'hedwig@owlpost.com')

        session[:identity_id]        = logged_in_user.id

        allow(Notifier).to receive(:notify_admin) do
            mailer = double('mail') 
            expect(mailer).to receive(:deliver)
            mailer
          end
        xhr :get, :confirmation, {
          sub_service_request_id: @ssr.id,
          id: @sr.id
        }
        expect(Notifier).to have_received(:notify_admin)
      end

      it 'should send request amendment email to authorized users' do
        @org.submission_emails.create(email: 'hedwig@owlpost.com')

        session[:identity_id]        = logged_in_user.id
        session[:service_request_id] = @sr.id
        session[:sub_service_request_id] = @ssr.id

        allow(Notifier).to receive(:notify_user) do
            mailer = double('mail') 
            expect(mailer).to receive(:deliver_now)
            mailer
          end
        xhr :get, :confirmation, {
          id: @sr.id
        }
        expect(Notifier).to have_received(:notify_user)
      end
    end

    context 'added a service to a new SSR and resubmit SR' do
      before :each do
        @org         = create(:organization)
        service     = create(:service, organization: @org, one_time_fee: true)
        service2    = create(:service, organization: @org, one_time_fee: true)
        protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday)
        @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday)
        li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)

        @ssr2        = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'draft', submitted_at: nil)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: service2)
                      create(:service_provider, identity: logged_in_user, organization: @org)

        audit = AuditRecovery.where("auditable_id = '#{li_1.id}' AND auditable_type = 'LineItem' AND action = 'create'")
        audit.first.update_attribute(:created_at, Time.now)
        audit.first.update_attribute(:user_id, logged_in_user.id)

        audit_of_ssr = AuditRecovery.where("auditable_id = '#{@ssr2.id}' AND auditable_type = 'SubServiceRequest' AND action = 'create'")
        audit_of_ssr.first.update_attribute(:created_at, Time.now)
        audit_of_ssr.first.update_attribute(:user_id, logged_in_user.id)
      end

      it 'should send request amendment email to service provider' do
        session[:identity_id]        = logged_in_user.id
        session[:service_request_id] = @sr.id

        allow(Notifier).to receive(:notify_service_provider) do
          mailer = double('mail') 
          expect(mailer).to receive(:deliver_now)
          mailer
        end
        xhr :get, :confirmation, {
          id: @sr.id
        }
        expect(Notifier).to have_received(:notify_service_provider)
      end

      it 'should send request amendment email to admin' do
        @org.submission_emails.create(email: 'hedwig@owlpost.com')

        session[:identity_id]        = logged_in_user.id
        session[:service_request_id] = @sr.id

        allow(Notifier).to receive(:notify_admin) do
            mailer = double('mail') 
            expect(mailer).to receive(:deliver)
            mailer
          end
        xhr :get, :confirmation, {
          id: @sr.id
        }
        expect(Notifier).to have_received(:notify_admin)
      end

      it 'should send request amendment email to authorized users' do

        session[:identity_id]        = logged_in_user.id
        session[:service_request_id] = @sr.id

        allow(Notifier).to receive(:notify_user) do
            mailer = double('mail') 
            expect(mailer).to receive(:deliver_now)
            mailer
          end
        xhr :get, :confirmation, {
          id: @sr.id
        }
        expect(Notifier).to have_received(:notify_user)
      end
    end

    context 'deleted an entire SSR and resubmit SR' do
      before :each do
        @org         = create(:organization)
        service     = create(:service, organization: @org, one_time_fee: true)
        protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
        @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'draft', submitted_at: nil)
        @ssr2        = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday.utc)
        li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: service)
                      create(:service_provider, identity: logged_in_user, organization: @org)
                      
        @ssr.destroy
        @sr.reload
        audit = AuditRecovery.where("auditable_id = '#{li.id}' AND auditable_type = 'LineItem' AND action = 'destroy'")
        audit.first.update_attribute(:created_at, Time.now.utc - 5.hours)
        audit.first.update_attribute(:user_id, logged_in_user.id)

        audit_of_ssr = AuditRecovery.where("auditable_id = '#{@ssr.id}' AND auditable_type = 'SubServiceRequest' AND action = 'destroy'")
        audit_of_ssr.first.update_attribute(:created_at, Time.now.utc - 5.hours)
        audit_of_ssr.first.update_attribute(:user_id, logged_in_user.id)

      end

      it 'should NOT send request amendment email to service provider' do
        session[:identity_id]        = logged_in_user.id
        session[:service_request_id] = @sr.id

        allow(Notifier).to receive(:notify_service_provider) do
          mailer = double('mail') 
          expect(mailer).to receive(:deliver_now)
          mailer
        end
        xhr :get, :confirmation, {
          id: @sr.id
        }
        expect(Notifier).not_to have_received(:notify_service_provider)
      end

      it 'should NOT send request amendment email to admin' do
        @org.submission_emails.create(email: 'hedwig@owlpost.com')

        session[:identity_id]        = logged_in_user.id
        session[:service_request_id] = @sr.id

        allow(Notifier).to receive(:notify_admin) do
            mailer = double('mail') 
            expect(mailer).to receive(:deliver)
            mailer
        end
        xhr :get, :confirmation, {
          id: @sr.id
        }
        expect(Notifier).not_to have_received(:notify_admin)
      end

      it 'should send request amendment email to authorized users' do

        session[:identity_id]        = logged_in_user.id
        session[:service_request_id] = @sr.id

        allow(Notifier).to receive(:notify_user) do
            mailer = double('mail') 
            expect(mailer).to receive(:deliver_now)
            mailer
        end
        xhr :get, :confirmation, {
          id: @sr.id
        }
        expect(Notifier).to have_received(:notify_user)
      end
    end

    context 'previously submitted ssr that has both added and deleted services' do
      before :each do
        @org         = create(:organization)
        service     = create(:service, organization: @org, one_time_fee: true)
        service1    = create(:service, organization: @org, one_time_fee: true)
        protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday)
        @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday)
        li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service1)
                      create(:service_provider, identity: logged_in_user, organization: @org)
        
        audit = AuditRecovery.where("auditable_id = '#{li_1.id}' AND auditable_type = 'LineItem' AND action = 'create'")
        audit.first.update_attribute(:created_at, Time.now - 5.hours)
        audit.first.update_attribute(:user_id, logged_in_user.id)

        ssr_li_id   = @ssr.line_items.first.id
        @ssr.line_items.first.destroy!
        audit_1 = AuditRecovery.where("auditable_id = '#{ssr_li_id}' AND auditable_type = 'LineItem' AND action = 'destroy'")
        audit_1.first.update_attribute(:created_at, Time.now - 5.hours)
        audit_1.first.update_attribute(:user_id, logged_in_user.id)
      end

      it 'should send request amendment email to service provider' do
        session[:identity_id]        = logged_in_user.id

        allow(Notifier).to receive(:notify_service_provider) do
            mailer = double('mail') 
            expect(mailer).to receive(:deliver_now)
            mailer
          end
        xhr :get, :confirmation, {
          sub_service_request_id: @ssr.id,
          id: @sr.id
        }
        expect(Notifier).to have_received(:notify_service_provider)
      end

      it 'should send request amendment email to admin' do
        @org.submission_emails.create(email: 'hedwig@owlpost.com')

        session[:identity_id]        = logged_in_user.id

        allow(Notifier).to receive(:notify_admin) do
            mailer = double('mail') 
            expect(mailer).to receive(:deliver)
            mailer
          end
        xhr :get, :confirmation, {
          sub_service_request_id: @ssr.id,
          id: @sr.id
        }
        expect(Notifier).to have_received(:notify_admin)
      end

      it 'should send request amendment email to authorized users' do
        @org.submission_emails.create(email: 'hedwig@owlpost.com')

        session[:identity_id]        = logged_in_user.id
        session[:service_request_id] = @sr.id
        session[:sub_service_request_id] = @ssr.id

        allow(Notifier).to receive(:notify_user) do
            mailer = double('mail') 
            expect(mailer).to receive(:deliver_now)
            mailer
          end
        xhr :get, :confirmation, {
          id: @sr.id
        }
        expect(Notifier).to have_received(:notify_user)
      end
    end

    context 'previously submitted ssr that does NOT have added or deleted services' do
      before :each do
        @org         = create(:organization)
        service     = create(:service, organization: @org, one_time_fee: true)
        protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday)
        @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday)
      end

      it 'should NOT send request amendment email to service provider' do
        session[:identity_id]        = logged_in_user.id

        allow(Notifier).to receive(:notify_service_provider) do
          mailer = double('mail') 
          expect(mailer).not_to receive(:deliver_now)
          mailer
        end
        xhr :get, :confirmation, {
          sub_service_request_id: @ssr.id,
          id: @sr.id
        }
        expect(Notifier).not_to have_received(:notify_service_provider)
      end

      it 'should NOT send request amendment email to admin' do
        @org.submission_emails.create(email: 'hedwig@owlpost.com')

        session[:identity_id]        = logged_in_user.id

        allow(Notifier).to receive(:notify_admin) do
            mailer = double('mail') 
            expect(mailer).to receive(:deliver)
            mailer
          end
        xhr :get, :confirmation, {
          sub_service_request_id: @ssr.id,
          id: @sr.id
        }
        expect(Notifier).not_to have_received(:notify_admin)
      end

      it 'should NOT send request amendment email to authorized users' do
        @org.submission_emails.create(email: 'hedwig@owlpost.com')

        session[:identity_id]        = logged_in_user.id
        session[:service_request_id] = @sr.id
        session[:sub_service_request_id] = @ssr.id

        allow(Notifier).to receive(:notify_user) do
            mailer = double('mail') 
            expect(mailer).to receive(:deliver_now)
            mailer
          end
        xhr :get, :confirmation, {
          id: @sr.id
        }
        expect(Notifier).not_to have_received(:notify_user)
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
              ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', submitted_at: nil)
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
              ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', submitted_at: Time.now)
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
            ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', submitted_at: nil)
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
            ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', submitted_at: Time.now)
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
        ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft')
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
        ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft')
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
          ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft')
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
          ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft')
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
        ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft')
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
        ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft')
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
        ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft')
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
          ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft')
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
          ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft')
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
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
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
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
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
