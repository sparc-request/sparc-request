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
  describe "GET #index" do
    context "format js" do
      before(:each) do
        @line_item = findable_stub(LineItem) { build_stubbed(:line_item) }

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        get :index, params: { line_item_id: @line_item.id }, xhr: true
      end

      it "should assign LineItem from params[:line_item_id] to @line_item" do
        expect(assigns(:line_item)).to eq(@line_item)
      end

      it { is_expected.to render_template "dashboard/fulfillments/index" }
      it { is_expected.to respond_with :ok }
    end

    context "format json" do
      before(:each) do
        @line_item = findable_stub(LineItem) { build_stubbed(:line_item) }
        @fulfillments = instance_double(ActiveRecord::Relation)
        allow(@line_item).to receive(:fulfillments).and_return(@fulfillments)

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        get :index, params: { line_item_id: @line_item.id, format: :json }, xhr: true
      end

      it "should assign LineItem from params[:line_item_id] to @line_item" do
        expect(assigns(:line_item)).to eq(@line_item)
      end

      it "should assign Fulfillments of LineItem to @fulfillments" do
        expect(assigns(:fulfillments)).to eq(@fulfillments)
      end

      it { is_expected.to render_template "dashboard/fulfillments/index" }
      it { is_expected.to respond_with :ok }
    end
  end
end
