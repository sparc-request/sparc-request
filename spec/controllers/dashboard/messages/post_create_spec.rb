# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

RSpec.describe Dashboard::MessagesController do
  describe "POST #create" do
    context "params[:message][:body] not empty" do
      before(:each) do
        ssr = build_stubbed(
          :sub_service_request,
          protocol: build_stubbed(:protocol),
          organization: build_stubbed(:organization)
        )
        @notification = findable_stub(Notification) do
          build_stubbed(:notification, sub_service_request: ssr)
        end
        allow(@notification).to receive(:messages).and_return("MyMessages")
        allow(@notification).to receive(:set_read_by)

        @to_identity = create(:identity)
        @from_identity = create(:identity)
        @new_message_attr = {
          notification_id: @notification.id.to_s,
          to: @to_identity.id.to_s,
          from: @from_identity.id.to_s,
          email: "jay@email.com",
          body: "hey"
        }.stringify_keys

        @new_message = Message.new(@new_message_attr)
        allow(Message).to receive(:create).and_return(@new_message)

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        post :create, params: { message: @new_message_attr }, xhr: true
      end

      it "should create a Message" do
        expect(Message).to have_received(:create).with controller_params(@new_message_attr)
      end

      it "should mark new Message as read by recipient" do
        expect(@notification).to have_received(:set_read_by).
          with(@to_identity, false)
      end

      it "should set @notification from params[:notification_id]" do
        expect(assigns(:notification)).to eq(@notification)
      end

      it "should set @messages to the Messages of Notification from params[:notification_id]" do
        expect(assigns(:messages)).to eq("MyMessages")
      end
    end

    context "params[:message][:body] empty" do
      before(:each) do
        ssr = build_stubbed(
          :sub_service_request,
          protocol: build_stubbed(:protocol),
          organization: build_stubbed(:organization)
        )
        @notification = findable_stub(Notification) do
          build_stubbed(:notification, sub_service_request: ssr)
        end
        allow(@notification).to receive(:messages).and_return("MyMessages")

        @to_identity = build_stubbed(:identity)
        @from_identity = build_stubbed(:identity)

        allow(Message).to receive(:create)

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        post :create, params: { message: { notification_id: @notification.id,
          to: @to_identity.id.to_s, from: @from_identity.id.to_s, email: "jay@email.com",
          body: "" } }, xhr: true
      end

      it "should not create a Message" do
        expect(Message).not_to have_received(:create)
      end

      it "should set @notification from params[:notification_id]" do
        expect(assigns(:notification)).to eq(@notification)
      end

      it "should set @messages to the Messages of Notification from params[:notification_id]" do
        expect(assigns(:messages)).to eq("MyMessages")
      end
    end
  end
end
