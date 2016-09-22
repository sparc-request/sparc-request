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
  describe 'PUT #update' do
    before :each do
      @logged_in_user = create(:identity)
      @other_user     = create(:identity)

      log_in_dashboard_identity(obj: @logged_in_user)
      service_requester = create(:identity)
      @protocol             = create(:protocol_without_validations, primary_pi: @other_user)
      @service_request      = create(:service_request_without_validations, protocol: @protocol)
      @organization         = create(:organization)
      @survey = create(:survey, access_code: 'sctr-customer-satisfaction-survey')
      @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, organization: @organization, service_requester_id:  service_requester.id)
    end

    #####AUTHORIZATION#####
    context 'authorize admin' do
      context 'user is authorized admin' do
        before :each do
          create(:super_user, identity: @logged_in_user, organization: @organization)

          put :update, id: @sub_service_request.id, format: :js
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/update" }
        it { is_expected.to respond_with :ok }
      end

      context 'user is not authorized admin on SSR' do
        before :each do
          get :show, id: @sub_service_request.id
        end

        it { is_expected.to render_template "service_requests/_authorization_error" }
        it { is_expected.to respond_with :ok }
      end
    end

    #####INSTANCE VARIABLES#####
    context 'instance variables' do
      before :each do
        create(:super_user, identity: @logged_in_user, organization: @organization)
        put :update, id: @sub_service_request.id, format: :js
      end

      it 'should assign instance variables' do
        expect(assigns(:sub_service_request)).to eq(@sub_service_request)
        expect(assigns(:admin_orgs)).to eq([@organization])
        expect(assigns(:errors)).to be_nil
      end

      it { is_expected.to render_template "dashboard/sub_service_requests/update" }
      it { is_expected.to respond_with :ok }
    end

    #####SURVEYS#####
    context 'ssr status is complete' do
      context 'org has associated surveys' do
        before :each do
          create(:super_user, identity: @logged_in_user, organization: @organization)
          @service         = create(:service_without_validations, organization_id:  @organization.id)
          @line_item      = create(:line_item_without_validations, service_request_id: @service_request.id,                          service_id:  @service.id,
                                      sub_service_request_id: @sub_service_request.id)
          @organization.associated_surveys.create survey_id: @survey.id
        end

        it 'should distribute surveys' do 
          expect_any_instance_of(SubServiceRequest).to receive(:distribute_surveys)
          put :update, sub_service_request: {status: 'complete'}, id: @sub_service_request.id, format: :js
        end
      end

      context 'org does not have associated surveys' do
        before :each do
          create(:super_user, identity: @logged_in_user, organization: @organization)
        end
        it 'should not distribute surveys' do
          expect_any_instance_of(SubServiceRequest).to_not receive(:distribute_surveys)
          put :update, sub_service_request: {status: 'complete'}, id: @sub_service_request.id, format: :js
        end
      end
    end

    context 'org has associated surveys' do
      context 'ssr status is not complete' do
        before :each do
          create(:super_user, identity: @logged_in_user, organization: @organization)
          @service         = create(:service_without_validations, organization_id:  @organization.id)
          @line_item      = create(:line_item_without_validations, service_request_id: @service_request.id,                          service_id:  @service.id,
                                      sub_service_request_id: @sub_service_request.id)
          @organization.associated_surveys.create survey_id: @survey.id
        end
        it 'should not distribute surveys' do
          expect_any_instance_of(SubServiceRequest).to_not receive(:distribute_surveys)
          put :update, sub_service_request: {status: 'not_complete'}, id: @sub_service_request.id, format: :js
        end
      end
    end

    context 'org does not have associated surveys' do
      context 'ssr status is not complete' do
        before :each do
          create(:super_user, identity: @logged_in_user, organization: @organization)
        end
        it 'should not distribute surveys' do
          expect_any_instance_of(SubServiceRequest).to_not receive(:distribute_surveys)
          put :update, sub_service_request: {status: 'not_complete'}, id: @sub_service_request.id, format: :js
        end
      end
    end
  end
end
