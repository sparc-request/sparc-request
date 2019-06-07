# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

RSpec.describe Dashboard::VisitGroupsController do
  describe '#navigate' do
    let!(:logged_in_user) { create(:identity) }

    context 'users with authorization' do
      before :each do
        log_in_dashboard_identity(obj: logged_in_user)

        org       = create(:organization)
                    create(:super_user, organization: org, identity: logged_in_user)
        @protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
        @sr       = create(:service_request_without_validations, protocol: @protocol)
        @ssr      = create(:sub_service_request, service_request: @sr, organization: org)
        @arm1     = create(:arm, protocol: @protocol)
        @arm2     = create(:arm, protocol: @protocol)
        @vg1      = @arm1.visit_groups.first
        @vg2      = @arm2.visit_groups.first
      end

      it 'should assign @service_request' do
        get :navigate, params: {
          service_request_id: @sr.id,
          sub_service_request_id: @ssr.id,
          protocol_id: @protocol.id,
          intended_action: 'new'
        }, xhr: true

        expect(assigns(:service_request)).to eq(@sr)
      end

      it 'should assign @sub_service_request' do
        get :navigate, params: {
          service_request_id: @sr.id,
          sub_service_request_id: @ssr.id,
          protocol_id: @protocol.id,
          intended_action: 'new'
        }, xhr: true

        expect(assigns(:sub_service_request)).to eq(@ssr)
      end

      it 'should assign @protocol' do
        get :navigate, params: {
          service_request_id: @sr.id,
          sub_service_request_id: @ssr.id,
          protocol_id: @protocol.id,
          intended_action: 'new'
        }, xhr: true

        expect(assigns(:protocol)).to eq(@protocol)
      end

      it 'should assign @intended_action' do
        get :navigate, params: {
          service_request_id: @sr.id,
          sub_service_request_id: @ssr.id,
          protocol_id: @protocol.id,
          intended_action: 'new'
        }, xhr: true

        expect(assigns(:intended_action)).to eq('new')
      end

      context 'params[:visit_group_id] is present' do
        before :each do
          get :navigate, params: {
            service_request_id: @sr.id,
            sub_service_request_id: @ssr.id,
            protocol_id: @protocol.id,
            intended_action: 'new',
            visit_group_id: @vg1.id
          }, xhr: true
        end

        it 'should assign @visit_group' do
          expect(assigns(:visit_group)).to eq(@vg1)
        end

        it 'should assign @arm' do
          expect(assigns(:arm)).to eq(@arm1)
        end
      end

      context 'params[:visit_group_id] is nil' do
        context 'params[:arm_id] is present' do
          before :each do
            get :navigate, params: {
              service_request_id: @sr.id,
              sub_service_request_id: @ssr.id,
              protocol_id: @protocol.id,
              intended_action: 'new',
              arm_id: @arm2.id
            }, xhr: true
          end

          it 'should assign @arm' do
            expect(assigns(:arm)).to eq(@arm2)
          end

          it 'should assign @visit_group' do
            expect(assigns(:visit_group)).to eq(@vg2)
          end
        end

        context 'params[:arm_id] is nil' do
          before :each do
            get :navigate, params: {
              service_request_id: @sr.id,
              sub_service_request_id: @ssr.id,
              protocol_id: @protocol.id,
              intended_action: 'new'
            }, xhr: true
          end

          it 'should assign @arm' do
            expect(assigns(:arm)).to eq(@arm1)
          end

          it 'should assign @visit_group' do
            expect(assigns(:visit_group)).to eq(@vg1)
          end
        end
      end

      it 'should render template' do
        get :navigate, params: {
          service_request_id: @sr.id,
          sub_service_request_id: @ssr.id,
          protocol_id: @protocol.id,
          intended_action: 'new'
        }, xhr: true

        expect(controller).to render_template(:navigate)
      end

      it 'should respond ok' do
        get :navigate, params: {
          service_request_id: @sr.id,
          sub_service_request_id: @ssr.id,
          protocol_id: @protocol.id,
          intended_action: 'new'
        }, xhr: true

        expect(controller).to respond_with(:ok)          
      end
    end

    context 'users without authorization' do
      before :each do
        log_in_dashboard_identity(obj: logged_in_user)

        org       = create(:organization)
        @protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
        @sr       = create(:service_request_without_validations, protocol: @protocol)
        @ssr      = create(:sub_service_request, service_request: @sr, organization: org)
        @arm      = create(:arm, protocol: @protocol)
        
        get :navigate, params: {
          service_request_id: @sr.id,
          sub_service_request_id: @ssr.id,
          protocol_id: @protocol.id,
          intended_action: 'new'
        }, xhr: true
      end

      it 'should not assign variables' do
        expect(assigns(:protocol)).to eq(nil)
        expect(assigns(:service_request)).to eq(nil)
        expect(assigns(:sub_service_request)).to eq(nil)
        expect(assigns(:visit_group)).to eq(nil)
      end

      it { is_expected.to redirect_to(dashboard_root_path) }

      it { is_expected.to respond_with(302) }
    end
  end
end
