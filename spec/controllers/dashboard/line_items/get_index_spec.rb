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
  describe "GET #index" do
    before(:each) do
      @sub_service_request = findable_stub(SubServiceRequest) do
        build_stubbed(:sub_service_request)
      end
      allow(@sub_service_request).to receive(:one_time_fee_line_items).
        and_return("my otf line items")

      log_in_dashboard_identity(obj: build_stubbed(:identity))
      get :index, sub_service_request_id: @sub_service_request.id, format: :json
    end

    it "should assign @sub_service_request from params[:sub_service_request_id]" do
      expect(assigns(:sub_service_request)).to eq(@sub_service_request)
    end

    it "should assign @line_items from one time fee LineItems of SubServiceRequest" do
      expect(assigns(:line_items)).to eq("my otf line items")
    end

    it { is_expected.to render_template "dashboard/line_items/index" }
    it { is_expected.to respond_with :ok }
  end
end
