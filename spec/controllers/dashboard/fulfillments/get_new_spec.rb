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
  describe "GET #new" do
    before(:each) do
      @fulfillment = instance_double(Fulfillment, id: 1)
      allow(Fulfillment).to receive(:new).
        and_return(@fulfillment)

      logged_in_user = build_stubbed(:identity)
      log_in_dashboard_identity(obj: logged_in_user)
      get :new, params: { line_item_id: "line item id" }, xhr: true
    end

    it "should assign to @fulfillment a new Fulfillment associated with LineItem from params[:line_item_id]" do
      expect(Fulfillment).to have_received(:new).with(line_item_id: "line item id")
      expect(assigns(:fulfillment)).to eq(@fulfillment)
    end

    it "should assign @header_text" do
      expect(assigns(:header_text)).not_to be_nil
    end

    it { is_expected.to render_template "dashboard/fulfillments/new" }
    it { is_expected.to respond_with :ok }
  end
end
