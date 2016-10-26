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
  describe "GET #new" do
    before(:each) do
      @logged_in_user = build_stubbed(:identity)

      @notification = findable_stub(Notification) do
        build_stubbed(:notification)
      end

      @recipient = build_stubbed(:identity)
      allow(@notification).to receive(:get_user_other_than).
        with(@logged_in_user).
        and_return(@recipient)

      # expected
      @new_message_attrs = {
        notification_id: @notification.id,
        to: @recipient.id,
        from: @logged_in_user.id,
        email: @recipient.email
      }

      allow(Message).to receive(:new).
        and_return("new message")

      log_in_dashboard_identity(obj: @logged_in_user)
      xhr :get, :new, @new_message_attrs
    end

    it "should create a new Message from current user to user other than current user of Notification" do
      expect(Message).to have_received(:new).
        with(@new_message_attrs)
    end

    it "should assign @message to new Message built" do
      expect(assigns(:message)).to eq("new message")
    end

    it "should assign @notification from params[:notification_id]" do
      expect(assigns(:notification)).to eq(@notification)
    end

    it { is_expected.to render_template "dashboard/messages/new" }
    it { is_expected.to respond_with :ok }
  end
end
