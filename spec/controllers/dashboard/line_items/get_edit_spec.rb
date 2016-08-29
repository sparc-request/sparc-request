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
  describe "GET #edit" do
    context "LineItem is a one time fee" do
      before(:each) do
        @line_item = findable_stub(LineItem) { build_stubbed(:line_item) }
        allow(@line_item).to receive_message_chain(:service, :one_time_fee).
          and_return(true)

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        xhr :get, :edit, id: @line_item.id, modal: "my modal"
      end

      it "should assign @otf to whether or not LineItem's Service is a one time fee" do
        expect(assigns(:otf)).to eq(true)
      end

      it "should assign @header_text" do
        expect(assigns(:header_text)).not_to be_nil
      end

      it "should assign @line_item from params[:id]" do
        expect(assigns(:line_item)).to eq(@line_item)
      end

      it "should assign @modal_to_render to params[:modal]" do
        expect(assigns(:modal_to_render)).to eq("my modal")
      end

      it { is_expected.to render_template "dashboard/line_items/edit" }
      it { is_expected.to respond_with :ok }
    end

    context "LineItem is a not one time fee" do
      before(:each) do
        @line_item = findable_stub(LineItem) { build_stubbed(:line_item) }
        allow(@line_item).to receive_message_chain(:service, :one_time_fee).
          and_return(false)

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        xhr :get, :edit, id: @line_item.id, modal: "my modal"
      end

      it "should assign @otf to whether or not LineItem's Service is a one time fee" do
        expect(assigns(:otf)).to eq(false)
      end

      it "should assign not @header_text" do
        expect(assigns(:header_text)).to be_nil
      end

      it "should assign @line_item from params[:id]" do
        expect(assigns(:line_item)).to eq(@line_item)
      end

      it "should assign @modal_to_render to params[:modal]" do
        expect(assigns(:modal_to_render)).to eq("my modal")
      end

      it { is_expected.to render_template "dashboard/line_items/edit" }
      it { is_expected.to respond_with :ok }
    end
  end
end
