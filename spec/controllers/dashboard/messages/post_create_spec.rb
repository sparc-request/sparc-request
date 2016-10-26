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

RSpec.describe Dashboard::MessagesController do
  describe "POST #create" do
    context "params[:message][:body] not empty" do
      before(:each) do
        @notification = findable_stub(Notification) do
          build_stubbed(:notification)
        end
        allow(@notification).to receive(:messages).and_return("MyMessages")
        allow(@notification).to receive(:set_read_by)

        @to_identity = findable_stub(Identity) { build_stubbed(:identity) }
        @from_identity = build_stubbed(:identity)
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
        xhr :post, :create, message: @new_message_attr
      end

      it "should create a Message" do
        expect(Message).to have_received(:create).with(@new_message_attr)
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
        @notification = findable_stub(Notification) do
          build_stubbed(:notification)
        end
        allow(@notification).to receive(:messages).and_return("MyMessages")

        @to_identity = build_stubbed(:identity)
        @from_identity = build_stubbed(:identity)

        allow(Message).to receive(:create)

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        xhr :post, :create, message: { notification_id: @notification.id,
          to: @to_identity.id.to_s, from: @from_identity.id.to_s, email: "jay@email.com",
          body: "" }
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
