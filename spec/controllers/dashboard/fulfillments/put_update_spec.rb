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
  describe "PUT #update" do
    context "params[:fulfillment] describes a valid update" do
      before(:each) do
        @fulfillment = findable_stub(Fulfillment) do
          instance_double(Fulfillment, id: 1)
        end
        allow(@fulfillment).to receive(:update_attributes).and_return(true)
        allow(@fulfillment).to receive(:line_item)

        log_in_dashboard_identity(obj: build_stubbed(:identity))

        xhr :put, :update, id: @fulfillment.id, fulfillment: "fulfillment attributes"
      end

      it "should update Fulfillment" do
        expect(@fulfillment).to have_received(:update_attributes).
          with("fulfillment attributes")
      end

      it "should not set @errors" do
        expect(assigns(:errors)).to be_nil
      end

      it { is_expected.to render_template "dashboard/fulfillments/update" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:fulfillment] describes an invalid update" do
      before(:each) do
        @fulfillment = findable_stub(Fulfillment) do
          instance_double(Fulfillment, id: 1)
        end
        allow(@fulfillment).to receive(:update_attributes).and_return(false)
        allow(@fulfillment).to receive(:line_item)
        allow(@fulfillment).to receive(:errors).and_return("my errors")

        logged_in_user = build_stubbed(:identity)
        log_in_dashboard_identity(obj: logged_in_user)

        xhr :put, :update, id: @fulfillment.id, fulfillment: "fulfillment attributes"
      end

      it "should attempt to update Fulfillment" do
        expect(@fulfillment).to have_received(:update_attributes).
          with("fulfillment attributes")
      end

      it "should set @errors" do
        expect(assigns(:errors)).to eq("my errors")
      end

      it { is_expected.to render_template "dashboard/fulfillments/update" }
      it { is_expected.to respond_with :ok }
    end
  end
end
