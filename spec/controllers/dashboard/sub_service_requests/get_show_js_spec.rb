# Copyright © 2011-2016 MUSC Foundation for Research Development
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

RSpec.describe Dashboard::SubServiceRequestsController do
  describe 'GET #show.js' do
    before :each do
      @logged_in_user = create(:identity)
      log_in_dashboard_identity(obj: @logged_in_user)

      @protocol             = create(:protocol_without_validations, primary_pi: @logged_in_user)
      @service_request      = create(:service_request_without_validations, protocol: @protocol)
      service               = create(:service, organization: create(:organization))
      line_item             = create(:line_item_without_validations, service_request: @service_request, service: service)
      @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, organization: create(:organization))
      @arm                  = create(:arm, protocol: @protocol)
      @arm2                 = create(:arm, protocol: @protocol)
    end

    #####INSTANCE VARIABLES#####
    context 'instance variables' do
      before :each do
        xhr :get, :show, id: @sub_service_request.id, format: :js
      end

      it 'should assign instance variables' do
        expect(assigns(:sub_service_request)).to eq(@sub_service_request)
        expect(assigns(:service_request)).to eq(@service_request)
        expect(assigns(:service_list)).to eq(@service_request.service_list)
        expect(assigns(:protocol)).to eq(@protocol)
        expect(assigns(:tab)).to eq('calendar')
        expect(assigns(:portal)).to eq(true)
        expect(assigns(:thead_class)).to eq('default_calendar')
        expect(assigns(:review)).to eq(true)
      end
      
      it { is_expected.to render_template "dashboard/sub_service_requests/show" }
      it { is_expected.to respond_with :ok }
    end

    context '@selected_arm' do
      context 'params[:arm_id] assigned' do
        before :each do
          xhr :get, :show, id: @sub_service_request.id, arm_id: @arm.id, format: :js
        end

        it 'should be assigned' do
          expect(assigns(:selected_arm)).to eq(@arm)
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/show" }
        it { is_expected.to respond_with :ok }
      end

      context 'params[:arm_id] not assigned' do
        before :each do
          xhr :get, :show, id: @sub_service_request.id, format: :js
        end

        it 'should not be assigned' do
          expect(assigns(:selected_arm)).to eq(nil)
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/show" }
        it { is_expected.to respond_with :ok }
      end
    end

    context '@pages' do
      context 'session[:service_calendar_pages] not assigned' do
        before :each do
          xhr :get, :show, id: @sub_service_request.id, format: :js
        end

        it 'should set the page to 1 for all arms' do
          expect(assigns(:pages)).to eq({@arm.id => 1, @arm2.id => 1})
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/show" }
        it { is_expected.to respond_with :ok }
      end

      context 'session[:service_calendar_pages] is assigned' do
        before :each do
          xhr :get, :show, id: @sub_service_request.id, arm_id: @arm.id, page: 1, format: :js
        end

        it 'should set corresponding page for all arms' do
          expect(assigns(:pages)).to eq({@arm.id => 1, @arm2.id => 1})
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/show" }
        it { is_expected.to respond_with :ok }
      end
    end

    #####SESSION VARIABLES#####
    context 'session[:service_calendar_pages]' do
      context 'params[:pages] assigned' do
        before :each do
          xhr :get, :show, id: @sub_service_request.id, pages: 'pages', format: :js
        end

        it 'should be assigned' do
          expect(session[:service_calendar_pages]).to eq('pages')
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/show" }
        it { is_expected.to respond_with :ok }
      end

      context 'params[:pages] not assigned' do
        before :each do
          xhr :get, :show, id: @sub_service_request.id, format: :js
        end

        it 'should not be assigned' do
          expect(session[:service_calendar_pages]).to eq(nil)
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/show" }
        it { is_expected.to respond_with :ok }
      end

      context 'params[:arm_id] and params[:page] assigned' do
        before :each do
          xhr :get, :show, id: @sub_service_request.id, arm_id: @arm.id, page: 1, format: :js
        end
        
        it 'should be assigned' do
          expect(session[:service_calendar_pages]).to eq({@arm.id => 1})
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/show" }
        it { is_expected.to respond_with :ok }
      end
    end
  end
end
