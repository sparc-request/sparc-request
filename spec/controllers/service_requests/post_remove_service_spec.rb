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

  before(:each) do
    allow(controller.request).to receive(:referrer).and_return('http://example.com')
  end

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
      ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
      li2      = create(:line_item, service_request: sr, sub_service_request: ssr, service: service2)
      ServiceRelation.create(service_id: service.id, related_service_id: service2.id, optional: false)


      xhr :post, :remove_service, {
        id: sr.id,
        line_item_id: li.id
      }

      expect(li2.reload.optional).to eq(true)
    end

    it 'should delete line item' do
      org      = create(:organization, process_ssrs: true)
      service  = create(:service, organization: org)
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)


      xhr :post, :remove_service, {
        id: sr.id,
        line_item_id: li.id
      }

      expect(sr.line_items.count).to eq(0)
    end

    it 'should not delete complete line item' do
      org      = create(:organization, process_ssrs: true)
      service  = create(:service, organization: org)
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'complete')
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)


      xhr :post, :remove_service, {
        id: sr.id,
        line_item_id: li.id
      }

      expect(sr.line_items.count).to eq(1)
    end

    context 'ssr is locked' do
      it 'should not update status' do
        org      = create(:organization, process_ssrs: true)
        service  = create(:service, organization: org)
        protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'on_hold')
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                   create(:line_item, service_request: sr, sub_service_request: ssr, service: create(:service, organization: org))

        stub_const("EDITABLE_STATUSES", { org.id => ['first_draft'] })

        xhr :post, :remove_service, {
          id: sr.id,
          line_item_id: li.id
        }

        expect(ssr.reload.status).to eq('on_hold')
      end
    end

    context 'ssr is not locked' do
      it 'should update status' do
        org      = create(:organization, process_ssrs: true)
        service  = create(:service, organization: org)
        protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'on_hold')
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                   create(:line_item, service_request: sr, sub_service_request: ssr, service: create(:service, organization: org))

        session[:identity_id]        = logged_in_user.id

        xhr :post, :remove_service, {
          id: sr.id,
          line_item_id: li.id
        }

        expect(ssr.reload.status).to eq('draft')
      end

      it 'should create past status' do
        org      = create(:organization, process_ssrs: true)
        service  = create(:service, organization: org)
        protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'on_hold')
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                   create(:line_item, service_request: sr, sub_service_request: ssr, service: create(:service, organization: org))

        session[:identity_id]        = logged_in_user.id

        xhr :post, :remove_service, {
          id: sr.id,
          line_item_id: li.id
        }

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
        ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'first_draft')
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                   create(:line_item, service_request: sr, sub_service_request: ssr, service: create(:service, organization: org))


        xhr :post, :remove_service, {
          id: sr.id,
          line_item_id: li.id
        }

        expect(ssr.reload.status).to eq('first_draft')
      end
    end

    context 'last line item in ssr' do
      it 'should delete ssr' do
        org      = create(:organization, process_ssrs: true)
        service  = create(:service, organization: org)
        protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'first_draft')
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

        session[:identity_id]        = logged_in_user.id

        xhr :post, :remove_service, {
          id: sr.id,
          line_item_id: li.id
        }

        expect(sr.sub_service_requests.count).to eq(0)
      end
    end

    it 'should assign @line_items_count' do
      org      = create(:organization, process_ssrs: true)
      service  = create(:service, organization: org)
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'first_draft')
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                 create(:line_item, service_request: sr, sub_service_request: ssr, service: create(:service, organization: org))


      xhr :post, :remove_service, {
        id: sr.id,
        line_item_id: li.id
      }

      expect(assigns(:line_items_count)).to eq(1)
    end

    it 'should assign @sub_service_requests' do
      org      = create(:organization, process_ssrs: true)
      service  = create(:service, organization: org)
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'first_draft')
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                 create(:line_item, service_request: sr, sub_service_request: ssr, service: create(:service, organization: org))


      xhr :post, :remove_service, {
        id: sr.id,
        line_item_id: li.id
      }

      expect(assigns(:sub_service_requests)[:active].count + assigns(:sub_service_requests)[:complete].count).to eq(1)
    end

    it 'should render template' do
      org      = create(:organization, process_ssrs: true)
      service  = create(:service, organization: org)
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)


      xhr :post, :remove_service, {
        id: sr.id,
        line_item_id: li.id
      }

      expect(controller).to render_template(:remove_service)
    end

    it 'should respond ok' do
      org      = create(:organization, process_ssrs: true)
      service  = create(:service, organization: org)
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, organization: org, service_request: sr)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)


      xhr :post, :remove_service, {
        id: sr.id,
        line_item_id: li.id
      }

      expect(controller).to respond_with(:ok)
    end
    context 'SSR has been previously submitted' do

      before :each do
        @org      = create(:organization, process_ssrs: true)
        @org1     = create(:organization, process_ssrs: true)
        @service  = create(:service, organization: @org)
        @service1 = create(:service, organization: @org1)
        protocol = create(:study_without_validations, primary_pi: logged_in_user)
        @sr       = create(:service_request_without_validations, protocol: protocol)
        @ssr      = create(:sub_service_request_without_validations, organization: @org, service_request_id: @sr.id, submitted_at: Time.now.yesterday)
        @ssr1     = create(:sub_service_request_without_validations, organization: @org, service_request_id: @sr.id, submitted_at: Time.now.yesterday)
        @li       = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: @service1)
        @li_1     = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: @service)
                    create(:line_item, service_request: @sr, sub_service_request: @ssr1, service: @service1)
                    create(:line_item, service_request: @sr, sub_service_request: @ssr1, service: @service)
                   create(:service_provider, identity: logged_in_user, organization: @org)
        @li_id = @li.id
      end

      context 'removed all services (line_item1 & line_item2) for SSR' do

        it 'should send notifications to the service provider' do
          @li_1.destroy
          session[:identity_id]        = logged_in_user.id

          allow(Notifier).to receive(:notify_service_provider) do
            mailer = double('mail')
            expect(mailer).to receive(:deliver_now)
            mailer
          end

          post :remove_service, {
                 :id            => @sr.id,
                 :service_id    => @service.id,
                 :line_item_id  => @li_id,
                 :format        => :js,
               }.with_indifferent_access

          expect(Notifier).to have_received(:notify_service_provider)
        end
      end

      context 'removed one of two services for SSR' do

        it 'should not send notifications to the service provider' do
          # expect(controller).not_to receive(:send_ssr_service_provider_notifications)
          session[:identity_id]        = logged_in_user.id

          allow(Notifier).to receive(:notify_service_provider) do
            mailer = double('mail')
            expect(mailer).to receive(:deliver_now)
            mailer
          end

          post :remove_service, {
                 :id            => @sr.id,
                 :service_id    => @service.id,
                 :line_item_id  => @li_id,
                 :format        => :js,
               }.with_indifferent_access
          expect(Notifier).not_to have_received(:notify_service_provider)
        end

        it 'should not delete SSR (ssr1)' do
          session[:identity_id]        = logged_in_user.id

          post :remove_service, {
                 :id            => @sr.id,
                 :service_id    => @service.id,
                 :line_item_id  => @li_id,
                 :format        => :js,
               }.with_indifferent_access
          ssrs = [@ssr, @ssr1]
          expect(@sr.sub_service_requests).to eq(ssrs)
        end
      end
    end

    context 'SSR has one service and it is removed' do
      before :each do
        @org      = create(:organization, process_ssrs: true)
        @service  = create(:service, organization: @org)
        @service1 = create(:service, organization: @org1)
        protocol = create(:study_without_validations, primary_pi: logged_in_user)
        @sr       = create(:service_request_without_validations, protocol: protocol)
        @ssr      = create(:sub_service_request_without_validations, organization: @org, service_request_id: @sr.id, submitted_at: Time.now.yesterday)
        @li       = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: @service)
                   create(:service_provider, identity: logged_in_user, organization: @org)
        @li_id = @li.id
      end

      it 'should send notifications to the service_provider' do

        session[:identity_id]        = logged_in_user.id

        allow(Notifier).to receive(:notify_service_provider) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver_now)
          mailer
        end

        post :remove_service, {
               :id            => @sr.id,
               :service_id    => @service.id,
               :line_item_id  => @li_id,
               :format        => :js,
             }.with_indifferent_access

        expect(Notifier).to have_received(:notify_service_provider)
      end

      it 'should delete SSR' do
        session[:identity_id]        = logged_in_user.id

        post :remove_service, {
               :id            => @sr.id,
               :service_id    => @service.id,
               :line_item_id  => @li_id,
               :format        => :js,
             }.with_indifferent_access
        expect(@sr.sub_service_requests).to eq([])
      end
    end
  end
end
