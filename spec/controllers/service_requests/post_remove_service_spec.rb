# Copyright © 2011-2018 MUSC Foundation for Research Development
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

  describe '#remove_service' do
    it 'should call before_filter #initialize_service_request' do
      expect(before_filters.include?(:initialize_service_request)).to eq(true)
    end

    it 'should call before_filter #authorize_identity' do
      expect(before_filters.include?(:authorize_identity)).to eq(true)
    end

    it 'should set required related services to optional' do
      org      = create(:organization, process_ssrs: true)
      service  = create(:service, organization: org)
      service2 = create(:service, organization: org)
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, protocol_id: protocol.id)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
      li2      = create(:line_item, service_request: sr, sub_service_request: ssr, service: service2)
      ServiceRelation.create(service_id: service.id, related_service_id: service2.id, required: true)


      post :remove_service, params: {
        id: sr.id,
        line_item_id: li.id
      }, xhr: true

      expect(li2.reload.optional).to eq(true)
    end

    it 'should delete line item' do
      org      = create(:organization, process_ssrs: true)
      service  = create(:service, organization: org)
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, protocol_id: protocol.id)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)


      post :remove_service, params: {
        id: sr.id,
        line_item_id: li.id
      }, xhr: true

      expect(sr.line_items.count).to eq(0)
    end

    it 'should not delete complete line item' do
      stub_const('FINISHED_STATUSES', ['complete'])
      org      = create(:organization, process_ssrs: true)
      service  = create(:service, organization: org)
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'complete', protocol_id: protocol.id)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)


      post :remove_service, params: {
        id: sr.id,
        line_item_id: li.id
      }, xhr: true

      expect(sr.line_items.count).to eq(1)
    end

    context 'ssr is locked' do
      it 'should not update status' do
        org      = create(:organization, process_ssrs: true, use_default_statuses: false)
        service  = create(:service, organization: org)
        protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'on_hold', protocol_id: protocol.id)
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                   create(:line_item, service_request: sr, sub_service_request: ssr, service: create(:service, organization: org))

        org.editable_statuses.where(status: 'on_hold').destroy_all

        post :remove_service, params: {
          id: sr.id,
          line_item_id: li.id
        }, xhr: true

        expect(ssr.reload.status).to eq('on_hold')
      end
    end

    context 'ssr is not locked' do
      it 'should update status' do
        org      = create(:organization, process_ssrs: true)
        service  = create(:service, organization: org)
        protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'on_hold', protocol_id: protocol.id)
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                   create(:line_item, service_request: sr, sub_service_request: ssr, service: create(:service, organization: org))

        session[:identity_id]        = logged_in_user.id

        post :remove_service, params: {
          id: sr.id,
          line_item_id: li.id
        }, xhr: true

        expect(ssr.reload.status).to eq('draft')
      end

      it 'should create past status' do
        org      = create(:organization, process_ssrs: true)
        service  = create(:service, organization: org)
        protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'on_hold', protocol_id: protocol.id)
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                   create(:line_item, service_request: sr, sub_service_request: ssr, service: create(:service, organization: org))

        session[:identity_id]        = logged_in_user.id

        post :remove_service, params: {
          id: sr.id,
          line_item_id: li.id
        }, xhr: true

        expect(PastStatus.count).to eq(1)
        expect(PastStatus.first.sub_service_request_id).to eq(ssr.id)
      end
    end

    context 'ssr is first_draft' do
      it 'should not update status' do
        org      = create(:organization, process_ssrs: true)
        service  = create(:service, organization: org)
        protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'first_draft', protocol_id: protocol.id)
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                   create(:line_item, service_request: sr, sub_service_request: ssr, service: create(:service, organization: org))


        post :remove_service, params: {
          id: sr.id,
          line_item_id: li.id
        }, xhr: true

        expect(ssr.reload.status).to eq('first_draft')
      end
    end

    context 'last line item in ssr' do
      it 'should delete ssr' do
        org      = create(:organization, process_ssrs: true)
        service  = create(:service, organization: org)
        protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'first_draft', protocol_id: protocol.id)
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

        session[:identity_id]        = logged_in_user.id

        post :remove_service, params: {
          id: sr.id,
          line_item_id: li.id
        }, xhr: true

        expect(sr.sub_service_requests.count).to eq(0)
      end
    end

    it 'should assign @line_items_count' do
      org      = create(:organization, process_ssrs: true)
      service  = create(:service, organization: org)
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'first_draft', protocol_id: protocol.id)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                 create(:line_item, service_request: sr, sub_service_request: ssr, service: create(:service, organization: org))


      post :remove_service, params: {
        id: sr.id,
        line_item_id: li.id
      }, xhr: true

      expect(assigns(:line_items_count)).to eq(1)
    end

    it 'should assign @sub_service_requests' do
      org      = create(:organization, process_ssrs: true)
      service  = create(:service, organization: org)
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'first_draft', protocol_id: protocol.id)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                 create(:line_item, service_request: sr, sub_service_request: ssr, service: create(:service, organization: org))


      post :remove_service, params: {
        id: sr.id,
        line_item_id: li.id
      }, xhr: true

      expect(assigns(:sub_service_requests)[:active].count + assigns(:sub_service_requests)[:complete].count).to eq(1)
    end

    it 'should render template' do
      org      = create(:organization, process_ssrs: true)
      service  = create(:service, organization: org)
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, protocol_id: protocol.id)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)


      post :remove_service, params: {
        id: sr.id,
        line_item_id: li.id
      }, xhr: true

      expect(controller).to render_template(:remove_service)
    end

    it 'should respond ok' do
      org      = create(:organization, process_ssrs: true)
      service  = create(:service, organization: org)
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, protocol_id: protocol.id)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)


      post :remove_service, params: {
        id: sr.id,
        line_item_id: li.id
      }, xhr: true

      expect(controller).to respond_with(:ok)
    end
  end
end
