# Copyright © 2011-2019 MUSC Foundation for Research Development
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

RSpec.describe ServiceRequestsController, type: :controller do
  stub_controller
  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity) }

  describe '#obtain_research_pricing' do
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
      sr       = create(:service_request_without_validations, protocol: protocol, submitted_at: '2015-02-10')
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, protocol_id: protocol.id)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      session[:identity_id] = logged_in_user.id

      get :obtain_research_pricing, params: { srid: sr.id }, xhr: true

      expect(assigns(:service_request).previous_submitted_at).to eq(sr.submitted_at)
    end

    context 'a new service request' do
      before :each do
        @org     = create(:organization)
        service  = create(:service, organization: @org, one_time_fee: true)
        protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr      = create(:service_request_without_validations, protocol: protocol, original_submitted_date: nil, status: 'draft')
        @ssr     = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'draft', submitted_at: nil, protocol_id: protocol.id)
        li       = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)

        session[:identity_id] = logged_in_user.id
      end

      it 'should update SR status to "get_a_cost_estimate"' do
        get :obtain_research_pricing, params: { srid: @sr.id }, xhr: true

        expect(@sr.reload.status).to eq('get_a_cost_estimate')
      end

      it 'should update SSR status to "get_a_cost_estimate"' do
        get :obtain_research_pricing, params: { srid: @sr.id }, xhr: true

        expect(@ssr.reload.status).to eq('get_a_cost_estimate')
      end

      it 'should create past status' do
        get :obtain_research_pricing, params: { srid: @sr.id }, xhr: true

        expect(PastStatus.count).to eq(1)
        expect(PastStatus.first.sub_service_request).to eq(@ssr)
      end

      context 'with an authorized_user' do
        it 'should notify everyone (authorized_user)' do
          get :obtain_research_pricing, params: { srid: @sr.id }, xhr: true

          expect(Delayed::Backend::ActiveRecord::Job.count).to eq(1)
        end
      end

      context 'with an authorized_user, a service_provider' do
        it 'should notify everyone (authorized_user, service_provider)' do
          create(:service_provider, identity: logged_in_user, organization: @org)
          get :obtain_research_pricing, params: { srid: @sr.id }, xhr: true

          expect(Delayed::Backend::ActiveRecord::Job.count).to eq(2)
        end
      end

      context 'with an authorized_user, a service_provider, and an admin' do
        it 'should notify everyone (authorized_user, service_provider, and admin)' do
          create(:service_provider, identity: logged_in_user, organization: @org)
          @org.submission_emails.create(email: 'hedwig@owlpost.com')
          get :obtain_research_pricing, params: { srid: @sr.id }, xhr: true

          expect(Delayed::Backend::ActiveRecord::Job.count).to eq(3)
        end
      end
    end

    context 'editing a service request that has been previously submitted' do
      context 'status is get_a_cost_estimate' do
        before :each do
          @org     = create(:organization)
          service  = create(:service, organization: @org, one_time_fee: true)
          protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
          @sr      = create(:service_request_without_validations, protocol: protocol, original_submitted_date: Time.now.yesterday)
          @ssr     = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'get_a_cost_estimate', submitted_at: Time.now.yesterday, protocol_id: protocol.id)
          li       = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)

          session[:identity_id] = logged_in_user.id
        end

        it 'status should remain get_a_cost_estimate' do
          get :obtain_research_pricing, params: { srid: @sr.id }, xhr: true

          expect(@ssr.reload.status).to eq('get_a_cost_estimate')
        end

        context 'with an authorized_user' do
          it 'should not notify anyone' do
            expect {
              get :obtain_research_pricing, params: { srid: @sr.id }, xhr: true
            }.to change(ActionMailer::Base.deliveries, :count).by(0)
          end
        end

        context 'with an authorized_user and a service_provider' do
          it 'should not notify anyone' do
            create(:service_provider, identity: logged_in_user, organization: @org)

            expect {
              get :obtain_research_pricing, params: { srid: @sr.id }, xhr: true
            }.to change(ActionMailer::Base.deliveries, :count).by(0)
          end
        end

        context 'with an authorized_user, a service_provider, and an admin' do
          it 'should not notify anyone' do
            create(:service_provider, identity: logged_in_user, organization: @org)
            @org.submission_emails.create(email: 'hedwig@owlpost.com')

            expect {
              get :obtain_research_pricing, params: { srid: @sr.id }, xhr: true
            }.to change(ActionMailer::Base.deliveries, :count).by(0)
          end
        end
      end
    end

    context 'editing a service request that has been previously submitted' do
      context 'ssr status is set to a locked status' do
        before :each do
          @org     = create(:organization, use_default_statuses: false, process_ssrs: true)
          service  = create(:service, organization: @org, one_time_fee: true)
          protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
          @sr      = create(:service_request_without_validations, protocol: protocol, original_submitted_date: Time.now.yesterday)
          @ssr     = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'on_hold', submitted_at: Time.now.yesterday, protocol_id: protocol.id)
          li       = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)

          session[:identity_id] = logged_in_user.id

          @org.editable_statuses.where(status: 'on_hold').destroy_all
        end

        it 'should not update status to "get_a_cost_estimate"' do
          get :obtain_research_pricing, params: { srid: @sr.id }, xhr: true

          expect(@ssr.reload.status).to eq('on_hold')
        end

        context 'with an authorized_user' do
          it 'should not notify anyone' do
            expect {
              get :obtain_research_pricing, params: { srid: @sr.id }, xhr: true
            }.to change(ActionMailer::Base.deliveries, :count).by(0)
          end
        end

        context 'with an authorized_user and a service_provider' do
          it 'should not notify anyone' do
            create(:service_provider, identity: logged_in_user, organization: @org)
            expect {
              get :obtain_research_pricing, params: { srid: @sr.id }, xhr: true
            }.to change(ActionMailer::Base.deliveries, :count).by(0)
          end
        end

        context 'with an authorized_user, a service_provider, and an admin' do
          it 'should not notify anyone' do
            create(:service_provider, identity: logged_in_user, organization: @org)
            @org.submission_emails.create(email: 'hedwig@owlpost.com')
            expect {
              get :obtain_research_pricing, params: { srid: @sr.id }, xhr: true
            }.to change(ActionMailer::Base.deliveries, :count).by(0)
          end
        end
      end

      context 'ssr status is set to "complete"' do
         before :each do
          @org      = create(:organization)
          service  = create(:service, organization: @org, one_time_fee: true)
          protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
          @sr      = create(:service_request_without_validations, protocol: protocol, original_submitted_date: Time.now.yesterday)
          @ssr     = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'complete', submitted_at: Time.now.yesterday, protocol_id: protocol.id)
          li       = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)

          session[:identity_id] = logged_in_user.id
        end

        it 'should not update status to "get_a_cost_estimate"' do
          get :obtain_research_pricing, params: { srid: @sr.id }, xhr: true

          expect(@ssr.reload.status).to eq('complete')
        end

        context 'with an authorized_user' do
          it 'should not notify anyone' do
            expect {
              get :obtain_research_pricing, params: { srid: @sr.id }, xhr: true
            }.to change(ActionMailer::Base.deliveries, :count).by(0)
          end
        end

        context 'with an authorized_user and a service_provider' do
          it 'should not notify anyone' do
            create(:service_provider, identity: logged_in_user, organization: @org)
            expect {
              get :obtain_research_pricing, params: { srid: @sr.id }, xhr: true
            }.to change(ActionMailer::Base.deliveries, :count).by(0)
          end
        end

        context 'with an authorized_user, a service_provider, and an admin' do
          it 'should not notify anyone' do
            create(:service_provider, identity: logged_in_user, organization: @org)
            @org.submission_emails.create(email: 'hedwig@owlpost.com')

            expect {
              get :obtain_research_pricing, params: { srid: @sr.id }, xhr: true
            }.to change(ActionMailer::Base.deliveries, :count).by(0)
          end
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

      session[:identity_id] = logged_in_user.id

      get :obtain_research_pricing, params: { srid: sr.id }, xhr: true

      expect(controller).to render_template(:obtain_research_pricing)
    end

    it 'should respond ok' do
      org      = create(:organization)
      service  = create(:service, organization: org, one_time_fee: true)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, protocol_id: protocol.id)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      session[:identity_id] = logged_in_user.id

      get :obtain_research_pricing, params: { srid: sr.id }, xhr: true

      expect(controller).to respond_with(:ok)
    end
  end
end
