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
  describe "GET #index" do
    context "Notification from params[:notification_id] is unread" do
      before(:each) do
        @logged_in_user = build_stubbed(:identity)

        @notification = findable_stub(Notification) { build_stubbed(:notification) }
        allow(@notification).to receive(:read_by?).
          with(@logged_in_user).
          and_return(false)
        allow(@notification).to receive(:set_read_by)
        allow(@notification).to receive(:messages).
          and_return("MyMessages")

        log_in_dashboard_identity(obj: @logged_in_user)
        xhr :get, :index, notification_id: @notification.id
      end

      it "should mark Notification as read" do
        expect(@notification).to have_received(:set_read_by).
          with(@logged_in_user)
      end

      it "should set @read_by_user to false" do
        expect(assigns(:read_by_user)).to eq(false)
      end

      it "should set @notification from params[:notification_id]" do
        expect(assigns(:notification)).to eq(@notification)
      end

      it "should set @messages to Messages of Notification" do
        expect(assigns(:messages)).to eq("MyMessages")
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "dashboard/messages/index" }
    end

    context "Notification from params[:notification_id] is read" do
      before(:each) do
        @logged_in_user = build_stubbed(:identity)

        @notification = findable_stub(Notification) { build_stubbed(:notification) }

        allow(@notification).to receive(:read_by?).
          with(@logged_in_user).
          and_return(true)
        allow(@notification).to receive(:set_read_by)
        allow(@notification).to receive(:messages).
          and_return("MyMessages")

        log_in_dashboard_identity(obj: @logged_in_user)
        xhr :get, :index, notification_id: @notification.id
      end

      it "should not re-mark Notification as read" do
        expect(@notification).not_to have_received(:set_read_by).
          with(@logged_in_user)
      end

      it "should set @read_by_user to true" do
        expect(assigns(:read_by_user)).to eq(true)
      end

      it "should set @notification from params[:notification_id]" do
        expect(assigns(:notification)).to eq(@notification)
      end

      it "should set @messages to Messages of Notification" do
        expect(assigns(:messages)).to eq("MyMessages")
      end

      it { is_expected.to render_template "dashboard/messages/index" }
      it { is_expected.to respond_with :ok }
    end
  end
end
