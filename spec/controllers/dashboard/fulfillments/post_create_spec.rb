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

RSpec.describe Dashboard::FulfillmentsController do
  describe "POST #create" do
    context "params[:fulfillment] describes a valid Fulfillment" do
      before(:each) do
        # stub a Fulfillment#create to return a valid fulfillment
        @fulfillment = instance_double(Fulfillment, id: 1)
        allow(@fulfillment).to receive(:valid?).and_return(true)
        allow(Fulfillment).to receive(:new).and_return(@fulfillment)
        allow(@fulfillment).to receive(:save)
        allow(@fulfillment).to receive(:line_item)

        log_in_dashboard_identity(obj: build_stubbed(:identity))

        xhr :post, :create, fulfillment: "fulfillment attributes"
      end

      it "should create Fulfillment" do
        expect(Fulfillment).to have_received(:new).with("fulfillment attributes")
        expect(@fulfillment).to have_received(:save)
      end

      it "should not set @errors" do
        expect(assigns(:errors)).to be_nil
      end

      it { is_expected.to render_template "dashboard/fulfillments/create" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:fulfillment] describes an invalid Fulfillment" do
      before(:each) do
        # stub an invalid Fulfillment
        @fulfillment = instance_double(Fulfillment, id: 1)
        allow(@fulfillment).to receive(:valid?).and_return(false)
        allow(Fulfillment).to receive(:new).and_return(@fulfillment)
        allow(@fulfillment).to receive(:errors).and_return("my errors")
        allow(@fulfillment).to receive(:save)
        allow(@fulfillment).to receive(:line_item)

        log_in_dashboard_identity(obj: build_stubbed(:identity))

        xhr :post, :create, fulfillment: "fulfillment attributes"
      end

      it "should attempt to create Fulfillment" do
        expect(Fulfillment).to have_received(:new).with("fulfillment attributes")
      end

      it "should set @errors" do
        expect(assigns(:errors)).to eq("my errors")
      end

      it { is_expected.to render_template "dashboard/fulfillments/create" }
      it { is_expected.to respond_with :ok }
    end
  end
end
