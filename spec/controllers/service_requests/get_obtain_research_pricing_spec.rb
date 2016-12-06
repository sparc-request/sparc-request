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
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      session[:identity_id]        = logged_in_user.id

      xhr :get, :obtain_research_pricing, {
        id: sr.id
      }

      expect(assigns(:service_request).previous_submitted_at).to eq(sr.submitted_at)
    end

    context 'editing sub service request' do
      context 'status not get_a_cost_estimate' do
        it 'should notify' do
          org      = create(:organization)
          service  = create(:service, organization: org, one_time_fee: true)
          protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
          sr       = create(:service_request_without_validations, protocol: protocol)
          ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft')
          li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                     create(:service_provider, identity: logged_in_user, organization: org)

          session[:identity_id]            = logged_in_user.id


          # previously_submitted_at is null so we get 2 emails
          expect {
            xhr :get, :obtain_research_pricing, {
              id: sr.id
            }
          }.to change(ActionMailer::Base.deliveries, :count).by(2)
        end
      end

      it 'should update status to get_a_cost_estimate' do
        org      = create(:organization)
        service  = create(:service, organization: org, one_time_fee: true)
        protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft')
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

        session[:identity_id]            = logged_in_user.id


        xhr :get, :obtain_research_pricing, {
          id: sr.id
        }

        expect(ssr.reload.status).to eq('get_a_cost_estimate')
      end

      it 'should create past status' do
        org      = create(:organization)
        service  = create(:service, organization: org, one_time_fee: true)
        protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft')
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

        session[:identity_id]            = logged_in_user.id


        xhr :get, :obtain_research_pricing, {
          id: sr.id
        }

        expect(PastStatus.count).to eq(1)
        expect(PastStatus.first.sub_service_request).to eq(ssr)
      end
    end

    context 'editing a service request' do
      it 'should update status to get_a_cost_estimate' do
        org      = create(:organization)
        service  = create(:service, organization: org, one_time_fee: true)
        protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft')
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                   create(:service_provider, identity: logged_in_user, organization: org)

        session[:identity_id]            = logged_in_user.id

        xhr :get, :obtain_research_pricing, {
          id: sr.id
        }

        expect(sr.reload.status).to eq('get_a_cost_estimate')
      end

      it 'should notify' do
        org      = create(:organization)
        service  = create(:service, organization: org, one_time_fee: true)
        protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft')
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                   create(:service_provider, identity: logged_in_user, organization: org)

        session[:identity_id]            = logged_in_user.id

        # previously_submitted_at is null so we get 2 emails
        expect {
          xhr :get, :obtain_research_pricing, {
            id: sr.id
          }
        }.to change(ActionMailer::Base.deliveries, :count).by(2)
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

      xhr :get, :obtain_research_pricing, {
        id: sr.id
      }

      expect(controller).to render_template(:obtain_research_pricing)
    end

    it 'should respond ok' do
      org      = create(:organization)
      service  = create(:service, organization: org, one_time_fee: true)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      session[:identity_id]        = logged_in_user.id

      xhr :get, :obtain_research_pricing, {
        id: sr.id
      }

      expect(controller).to respond_with(:ok)
    end
  end
end
