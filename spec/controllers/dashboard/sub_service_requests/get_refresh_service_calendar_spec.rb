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
  describe 'GET #refresh_service_calendar' do
    before :each do
      @logged_in_user = create(:identity)
      log_in_dashboard_identity(obj: @logged_in_user)

      @protocol             = create(:protocol_without_validations, primary_pi: @logged_in_user)
      @service_request      = create(:service_request_without_validations, protocol: @protocol)
      @organization         = create(:organization)
      @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, organization: @organization)
      @arm                  = create(:arm, protocol: @protocol)
      @arm2                 = create(:arm, protocol: @protocol)
    end

    #####AUTHORIZATION#####
    context 'authorize admin' do
      context 'user is authorized admin' do
        before :each do
          create(:super_user, identity: @logged_in_user, organization: @organization)

          xhr :get, :refresh_service_calendar, id: @sub_service_request.id, format: :js
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/refresh_service_calendar" }
        it { is_expected.to respond_with :ok }
      end

      context 'user is not authorized admin on SSR' do
        before :each do
          xhr :get, :refresh_service_calendar, id: @sub_service_request.id, format: :js
        end

        it { is_expected.to render_template "service_requests/_authorization_error" }
        it { is_expected.to respond_with :ok }
      end
    end

    #####INSTANCE VARIABLES#####
    context 'instance variables' do
      before :each do
        create(:super_user, identity: @logged_in_user, organization: @organization)

        xhr :get, :refresh_service_calendar, id: @sub_service_request.id, format: :js
      end

      it 'should assign instance variables' do
        expect(assigns(:sub_service_request)).to eq(@sub_service_request)
        expect(assigns(:admin_orgs)).to eq([@organization])
        expect(assigns(:service_request)).to eq(@service_request)
      end
      
      it { is_expected.to render_template "dashboard/sub_service_requests/refresh_service_calendar" }
      it { is_expected.to respond_with :ok }
    end

    context '@arm' do
      before :each do
        create(:super_user, identity: @logged_in_user, organization: @organization)
      end

      context 'params[:arm_id] assigned' do
        before :each do
          xhr :get, :refresh_service_calendar, id: @sub_service_request.id, arm_id: @arm.id, format: :js
        end

        it 'should be assigned' do
          expect(assigns(:arm)).to eq(@arm)
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/refresh_service_calendar" }
        it { is_expected.to respond_with :ok }
      end

      context 'params[:arm_id] not assigned' do
        before :each do
          xhr :get, :refresh_service_calendar, id: @sub_service_request.id, format: :js
        end

        it 'should not be assigned' do
          expect(assigns(:arm)).to eq(nil)
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/refresh_service_calendar" }
        it { is_expected.to respond_with :ok }
      end
    end

    context '@portal' do
      before :each do
        create(:super_user, identity: @logged_in_user, organization: @organization)
      end

      context 'params[:portal] assigned' do
        before :each do
          xhr :get, :refresh_service_calendar, id: @sub_service_request.id, portal: 'true', format: :js
        end

        it 'should be assigned' do
          expect(assigns(:portal)).to eq('true')
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/refresh_service_calendar" }
        it { is_expected.to respond_with :ok }
      end

      context 'params[:portal] not assigned' do
        before :each do
          xhr :get, :refresh_service_calendar, id: @sub_service_request.id, format: :js
        end

        it 'should not be assigned' do
          expect(assigns(:portal)).to be_nil
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/refresh_service_calendar" }
        it { is_expected.to respond_with :ok }
      end
    end

    context '@thead_class' do
      before :each do
        create(:super_user, identity: @logged_in_user, organization: @organization)
      end

      context '@portal == \'true\'' do
        before :each do
          xhr :get, :refresh_service_calendar, id: @sub_service_request.id, portal: 'true', format: :js
        end

        it 'should be \'default_calendar\'' do
          expect(assigns(:thead_class)).to eq('default_calendar')
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/refresh_service_calendar" }
        it { is_expected.to respond_with :ok }
      end

      context '@portal != \'true\'' do
        before :each do
          xhr :get, :refresh_service_calendar, id: @sub_service_request.id, format: :js
        end

        it 'should be \'red-provider\'' do
          expect(assigns(:thead_class)).to eq('red-provider')
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/refresh_service_calendar" }
        it { is_expected.to respond_with :ok }
      end
    end

    context '@pages' do
      before :each do
        create(:super_user, identity: @logged_in_user, organization: @organization)
      end

      context 'session[:service_calendar_pages] not assigned' do
        before :each do
          xhr :get, :refresh_service_calendar, id: @sub_service_request.id, format: :js
        end

        it 'should set the page to 1 for all arms' do
          expect(assigns(:pages)).to eq({@arm.id => 1, @arm2.id => 1})
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/refresh_service_calendar" }
        it { is_expected.to respond_with :ok }
      end

      context 'session[:service_calendar_pages] is assigned' do
        before :each do
          xhr :get, :refresh_service_calendar, id: @sub_service_request.id, arm_id: @arm.id, page: 1, pages: {}, format: :js
        end

        it 'should set corresponding page for all arms' do
          expect(assigns(:pages)).to eq({@arm.id => 1, @arm2.id => 1})
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/refresh_service_calendar" }
        it { is_expected.to respond_with :ok }
      end
    end

    #####SESSION VARIABLES#####
    context 'session[:service_calendar_pages]' do
      before :each do
        create(:super_user, identity: @logged_in_user, organization: @organization)
      end

      context 'params[:pages] assigned' do
        before :each do
          xhr :get, :refresh_service_calendar, id: @sub_service_request.id, pages: 'pages', format: :js
        end

        it 'should be assigned' do
          expect(session[:service_calendar_pages]).to eq('pages')
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/refresh_service_calendar" }
        it { is_expected.to respond_with :ok }
      end

      context 'params[:pages] not assigned' do
        before :each do
          xhr :get, :refresh_service_calendar, id: @sub_service_request.id, format: :js
        end

        it 'should not be assigned' do
          expect(session[:service_calendar_pages]).to eq(nil)
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/refresh_service_calendar" }
        it { is_expected.to respond_with :ok }
      end

      context 'params[:arm_id] and params[:page] assigned' do
        before :each do
          xhr :get, :refresh_service_calendar, id: @sub_service_request.id, arm_id: @arm.id, page: 1, pages: {}, format: :js
        end
        
        it 'should be assigned' do
          expect(session[:service_calendar_pages]).to eq({@arm.id.to_s => 1})
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/refresh_service_calendar" }
        it { is_expected.to respond_with :ok }
      end
    end
  end
end
