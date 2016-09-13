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
  describe "POST #create" do
    context "params[:line_item][:service_id] blank" do
      before(:each) do
        @service_request = build_stubbed(:service_request)

        @sub_service_request = findable_stub(SubServiceRequest) do
          build_stubbed(:sub_service_request, service_request: @service_request)
        end
        allow(@sub_service_request).to receive(:candidate_pppv_services).
          and_return("candidate pppv services")

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        xhr :post, :create, line_item: { sub_service_request_id: @sub_service_request.id }
      end

      it "should set @sub_service_request from params[:line_item][:sub_service_request_id]" do
        expect(assigns(:sub_service_request)).to eq(@sub_service_request)
      end

      it "should set @service_request to ServiceRequest of @sub_service_request" do
        expect(assigns(:service_request)).to eq(@service_request)
      end

      it "should add an error message to SubServiceRequest for Service" do
        expect(assigns(:errors).full_messages).to eq(["Service must be selected"])
      end

      it { is_expected.to render_template "dashboard/line_items/create" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:line_item][:service_id] present but params[:line_item] still describes an invalid LineItem" do
      before(:each) do
        @service_request = build_stubbed(:service_request)

        @sub_service_request = findable_stub(SubServiceRequest) do
          build_stubbed(:sub_service_request, service_request: @service_request)
        end
        allow(@sub_service_request).to receive(:errors).and_return("my errors")

        # params[:line_item] does not describe valid LineItem
        allow(@sub_service_request).to receive(:create_line_item).and_return(false)

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        xhr :post, :create, line_item: { service_id: "not blank",
            sub_service_request_id: @sub_service_request.id }
      end

      it "should set @errors" do
        expect(assigns(:errors)).to eq("my errors")
      end

      it "should set @sub_service_request from params[:sub_service_request_id]" do
        expect(assigns(:sub_service_request)).to eq(@sub_service_request)
      end

      it "should set @service_request from params[:sub_service_request_id]" do
        expect(assigns(:service_request)).to eq(@service_request)
      end

      it { is_expected.to render_template "dashboard/line_items/create" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:line_item] describes a valid LineItem" do
      before(:each) do
        @service_request = build_stubbed(:service_request)

        @sub_service_request = findable_stub(SubServiceRequest) do
          build_stubbed(:sub_service_request, service_request: @service_request)
        end

        # params[:line_item] does not describe valid LineItem
        allow(@sub_service_request).to receive(:create_line_item).and_return(true)

        logged_in_user = build_stubbed(:identity)
        log_in_dashboard_identity(obj: logged_in_user)
        xhr :post, :create, line_item: { service_id: "not blank",
          sub_service_request_id: @sub_service_request.id }
      end

      it "should set @sub_service_request from params[:sub_service_request_id]" do
        expect(assigns(:sub_service_request)).to eq(@sub_service_request)
      end

      it "should set @service_request from params[:sub_service_request_id]" do
        expect(assigns(:service_request)).to eq(@service_request)
      end

      it "should not set @errors" do
        expect(assigns(:errors)).to be_nil
      end

      it { is_expected.to render_template "dashboard/line_items/create" }
      it { is_expected.to respond_with :ok }
    end
  end
end
