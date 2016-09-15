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

require "rails_helper"

RSpec.describe Dashboard::LineItemsController do
  describe "GET #new" do
    context "params[:one_time_fee] present" do
      before(:each) do
        @service_request = build_stubbed(:service_request)

        @sub_service_request = findable_stub(SubServiceRequest) do
          build_stubbed(:sub_service_request, service_request: @service_request)
        end
        allow(@sub_service_request).to receive(:candidate_pppv_services).
          and_return("candidate pppv services")

        allow(LineItem).to receive(:new).and_return("my new LineItem")

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        xhr :get, :new, sub_service_request_id: @sub_service_request.id,
          schedule_tab: "my schedule tab", one_time_fee: "yep"
      end

      it "should set @sub_service_request from params[:sub_service_request_id]" do
        expect(assigns(:sub_service_request)).to eq(@sub_service_request)
      end

      it "should set @service_request from params[:sub_service_request_id]" do
        expect(assigns(:service_request)).to eq(@service_request)
      end

      it "should set @schedule_tab from params[:schedule_tab]" do
        expect(assigns(:schedule_tab)).to eq("my schedule tab")
      end

      it "should assign @line_item to a new line_item" do
        expect(assigns(:line_item)).to eq("my new LineItem")
      end

      it "should assign @header_text" do
        expect(assigns(:header_text)).not_to be_nil
      end

      it { is_expected.to render_template "dashboard/line_items/new" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:one_time_fee] absent" do
      before(:each) do
        @service_request = build_stubbed(:service_request)
        @sub_service_request = findable_stub(SubServiceRequest) do
          build_stubbed(:sub_service_request, service_request: @service_request)
        end
        allow(@sub_service_request).to receive(:candidate_pppv_services).
          and_return("candidate pppv services")

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        xhr :get, :new, sub_service_request_id: @sub_service_request.id,
          schedule_tab: "my schedule tab", page_hash: "my page hash"
      end

      it "should set @sub_service_request from params[:sub_service_request_id]" do
        expect(assigns(:sub_service_request)).to eq(@sub_service_request)
      end

      it "should set @service_request from params[:sub_service_request_id]" do
        expect(assigns(:service_request)).to eq(@service_request)
      end

      it "should set @schedule_tab from params[:schedule_tab]" do
        expect(assigns(:schedule_tab)).to eq("my schedule tab")
      end

      it "should set @services to PPPV candidate Services of SubServiceRequest" do
        expect(assigns(:services)).to eq("candidate pppv services")
      end

      it "should set @page_hash from params[:page_hash]" do
        expect(assigns(:page_hash)).to eq("my page hash")
      end

      it { is_expected.to render_template "dashboard/line_items/new" }
      it { is_expected.to respond_with :ok }
    end
  end
end
