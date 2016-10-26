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

RSpec.describe Dashboard::NotificationsController do
  describe "GET #index" do
    context "params[:table] == 'inbox'" do
      before(:each) do
        @logged_in_user = build_stubbed(:identity)

        allow(Notification).to receive(:in_inbox_of).
          with(@logged_in_user.id, "SubServiceRequest id").
          and_return(["inbox notification1", "inbox notification1", "inbox notification2"])

        log_in_dashboard_identity(obj: @logged_in_user)
        get :index, table: "inbox", sub_service_request_id: "SubServiceRequest id"
      end

      it "should asssign @table to params[:table]" do
        expect(assigns(:table)).to eq("inbox")
      end

      it "should assign @notifications to current user's inbox (with no duplicates) restricted by SubServiceRequest" do
        expect(assigns(:notifications)).to eq(["inbox notification1", "inbox notification2"])
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "dashboard/notifications/index" }
    end

    context "params[:table] != 'inbox'" do
      before(:each) do
        @logged_in_user = build_stubbed(:identity)

        allow(Notification).to receive(:in_sent_of).
          with(@logged_in_user.id, "SubServiceRequest id").
          and_return(["sent notification1", "sent notification1", "sent notification2"])

        log_in_dashboard_identity(obj: @logged_in_user)
        get :index, table: "not-inbox", sub_service_request_id: "SubServiceRequest id"
      end

      it "should asssign @table to params[:table]" do
        expect(assigns(:table)).to eq("not-inbox")
      end

      it "should assign @notifications to current user's inbox (with no duplicates) restricted by SubServiceRequest" do
        expect(assigns(:notifications)).to eq(["sent notification1", "sent notification2"])
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "dashboard/notifications/index" }
    end
  end
end
