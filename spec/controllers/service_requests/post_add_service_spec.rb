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

  describe '#add_service' do
    it 'should call before_filter #initialize_service_request' do
      expect(before_filters.include?(:initialize_service_request)).to eq(true)
    end

    it 'should call before_filter #authorize_identity' do
      expect(before_filters.include?(:authorize_identity)).to eq(true)
    end

    context 'service already in cart' do
      it 'should assign @duplicate_service' do
        org      = create(:organization, process_ssrs: true)
        service  = create(:service, organization: org)
        protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr)
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

        xhr :post, :add_service, {
          id: sr.id,
          service_id: service.id
        }

        expect(assigns(:duplicate_service)).to eq(true)
      end

      it 'should not create line item' do
        org      = create(:organization, process_ssrs: true)
        service  = create(:service, organization: org)
        protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr)
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

        xhr :post, :add_service, {
          id: sr.id,
          service_id: service.id
        }

        expect(sr.line_items.count).to eq(1)
      end

      it 'should render template' do
        org      = create(:organization, process_ssrs: true)
        service  = create(:service, organization: org)
        protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr)
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

        xhr :post, :add_service, {
          id: sr.id,
          service_id: service.id
        }

        expect(controller).to render_template(:add_service)
      end

      it 'should respond ok' do
        org      = create(:organization, process_ssrs: true)
        service  = create(:service, organization: org)
        protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr)
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

        xhr :post, :add_service, {
          id: sr.id,
          service_id: service.id
        }

        expect(controller).to respond_with(:ok)
      end
    end

    context 'service not in cart' do
      context 'ssr not present for organization' do
        it 'should create ssr' do
          org      = create(:organization, process_ssrs: true)
          service  = create(:service, organization: org)
          protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
          sr       = create(:service_request_without_validations, protocol: protocol)

          xhr :post, :add_service, {
            id: sr.id,
            service_id: service.id
          }

          expect(sr.sub_service_requests.count).to eq(1)
        end
      end

      context 'ssr already present for organization' do
        it 'should not create ssr' do
          org      = create(:organization, process_ssrs: true)
          service  = create(:service, organization: org)
          service2 = create(:service, organization: org)
          protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
          sr       = create(:service_request_without_validations, protocol: protocol)
          ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr)
          li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

          xhr :post, :add_service, {
            id: sr.id,
            service_id: service2.id
          }

          expect(sr.sub_service_requests.count).to eq(1)
        end
      end

      it 'should create line item' do
        org      = create(:organization, process_ssrs: true)
        service  = create(:service, organization: org)
        protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)

        xhr :post, :add_service, {
          id: sr.id,
          service_id: service.id
        }

        expect(sr.line_items.count).to eq(1)
        expect(sr.line_items.first.service).to eq(service)
      end

      it 'should create any required services' do
        org      = create(:organization, process_ssrs: true)
        service  = create(:service, organization: org)
        service2 = create(:service, organization: org)
        protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)
        ServiceRelation.create(service_id: service.id, related_service_id: service2.id, optional: false)

        session[:identity_id] = logged_in_user.id

        xhr :post, :add_service, {
          id: sr.id,
          service_id: service.id
        }

        expect(sr.line_items.count).to eq(2)
        expect(sr.line_items.first.service).to eq(service)
        expect(sr.line_items.second.service).to eq(service2)
        expect(sr.line_items.second.optional).to eq(false)
      end

      context 'service request is first_draft' do
        it 'should set ssr status to first_draft' do
          org      = create(:organization, process_ssrs: true)
          service  = create(:service, organization: org)
          protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
          sr       = create(:service_request_without_validations, protocol: protocol, status: 'first_draft')

          xhr :post, :add_service, {
            id: sr.id,
            service_id: service.id
          }

          expect(sr.sub_service_requests.first.status).to eq('first_draft')
        end
      end

      context 'service request not first_draft' do
        it 'should set ssr status to draft' do
          org      = create(:organization, process_ssrs: true)
          service  = create(:service, organization: org)
          protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
          sr       = create(:service_request_without_validations, protocol: protocol)
          ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr)

          session[:identity_id] = logged_in_user.id

          xhr :post, :add_service, {
            id: sr.id,
            service_id: service.id
          }
          expect(sr.sub_service_requests.first.status).to eq('draft')
        end
      end

      it 'should assign @line_items_count' do
        org      = create(:organization, process_ssrs: true)
        service  = create(:service, organization: org)
        protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)

        xhr :post, :add_service, {
          id: sr.id,
          service_id: service.id
        }

        expect(assigns(:line_items_count)).to eq(1)
      end

      it 'should assign @sub_service_requests' do
        org      = create(:organization, process_ssrs: true)
        service  = create(:service, organization: org)
        protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)

        xhr :post, :add_service, {
          id: sr.id,
          service_id: service.id
        }

        expect(assigns(:sub_service_requests)[:active].count + assigns(:sub_service_requests)[:complete].count).to eq(1)
      end

      it 'should render template' do
        org      = create(:organization, process_ssrs: true)
        service  = create(:service, organization: org)
        protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)

        xhr :post, :add_service, {
          id: sr.id,
          service_id: service.id
        }

        expect(controller).to render_template(:add_service)
      end

      it 'should respond ok' do
        org      = create(:organization, process_ssrs: true)
        service  = create(:service, organization: org)
        protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)

        xhr :post, :add_service, {
          id: sr.id,
          service_id: service.id
        }

        expect(controller).to respond_with(:ok)
      end
    end
  end
end
