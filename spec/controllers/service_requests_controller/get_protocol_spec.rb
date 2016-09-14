# Copyright © 2011-2016 MUSC Foundation for Research Development~
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
require 'timecop'

RSpec.describe ServiceRequestsController do
  stub_controller
  let_there_be_lane
  let_there_be_j

  describe 'GET protocol' do

    before(:each) do
      session[:identity_id] = jug2.id
      session[:saved_protocol_id] = project.id
    end

    # these studies should not appear in @studies
    let!(:anothers_study) do
      create(:study, :without_validations,
             identity: jpl6,
             project_rights: "approve",
             role: "primary-pi",
             funding_status: "funded",
             funding_source: "federal",
             indirect_cost_rate: 50.0,
             start_date: Time.now,
             end_date: Time.now + 2.month)
    end

    let!(:none_rights) do
      create(:study, :without_validations,
             identity: jug2,
             project_rights: "none",
             role: "primary-pi",
             funding_status: "funded",
             funding_source: "federal",
             indirect_cost_rate: 50.0,
             start_date: Time.now,
             end_date: Time.now + 2.month)
    end

    let!(:view_rights) do
      create(:study, :without_validations,
             identity: jug2,
             project_rights: "view",
             role: "primary-pi",
             funding_status: "funded",
             funding_source: "federal",
             indirect_cost_rate: 50.0,
             start_date: Time.now,
             end_date: Time.now + 2.month)
    end

    # this study should appear in @studies
    let!(:study2) do
      create(:study, :without_validations,
             identity: jug2,
             project_rights: "approve",
             role: "primary-pi",
             funding_status: "funded",
             funding_source: "federal",
             indirect_cost_rate: 50.0,
             start_date: Time.now,
             end_date: Time.now + 2.month)
    end

    let!(:project) do
      create(:project, :without_validations,
             type: "Project",
             identity: jug2,
             project_rights: "approve",
             role: "primary-pi",
             funding_status: "funded",
             funding_source: "federal",
             indirect_cost_rate: 50.0,
             start_date: Time.now,
             end_date: Time.now + 2.month)
    end

    context 'with session[:saved_protocol_id]' do

      build_service_request_with_study

      before(:each) do
        session[:saved_protocol_id] = project.id
        get :protocol, id: service_request.id
      end

      it "should clear the saved protocol in session" do
        expect(session[:saved_protocol_id]).to_not be
      end

      it 'should assign @service_request\'s protocol_id to session[:saved_protocol_id]' do
        expect(assigns(:service_request).protocol_id).to eq project.id
      end
    end

    context "with ServiceRequest belonging to a Study" do

      build_service_request_with_study

      context "with params[:sub_service_request] present" do

        before do
          get :protocol, id: service_request.id, sub_service_request_id: sub_service_request.id
        end

        it "should clear the saved protocol in session" do
          expect(session[:saved_protocol_id]).to eq nil
        end

        it "should set service_request" do
          expect(assigns(:service_request)).to eq service_request
        end
      end

      context "without params[:sub_service_request]" do

        before do
          get :protocol, id: service_request.id
        end

        it "should set service_request" do
          expect(assigns(:service_request)).to eq service_request
        end
      end
    end

    context "with ServiceRequest belonging to a Project" do

      build_service_request_with_project

      context "with params[:sub_service_request] present" do

        before do
          get :protocol, id: service_request.id, sub_service_request_id: sub_service_request.id
        end

        it "should set service_request" do
          expect(assigns(:service_request)).to eq service_request
        end
      end

      context "without params[:sub_service_request]" do

        before do
          get :protocol, id: service_request.id
        end

        it "should set service_request" do
          expect(assigns(:service_request)).to eq service_request
        end
      end
    end
  end
end
