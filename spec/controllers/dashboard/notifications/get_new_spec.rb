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
  describe "GET #new" do
    context "params[:identity_id] present and params[:sub_service_request_id] present" do
      before(:each) do
        @sub_service_request = findable_stub(SubServiceRequest) do
          build_stubbed(:sub_service_request)
        end

        @new_notification = build_stubbed(:notification)
        allow(@sub_service_request.notifications).to receive(:new).
          and_return(@new_notification)

        @recipient = build_stubbed(:identity)
        @new_message = build_stubbed(:message)
        allow(@new_notification.messages).to receive(:new).
          and_return(@new_message)

        @logged_in_user = build_stubbed(:identity)
        log_in_dashboard_identity(obj: @logged_in_user)
        xhr :get, :new, sub_service_request_id: @sub_service_request.id, identity_id: @recipient.id
      end

      it "should set @sub_service_request_id to params[:sub_service_request_id]" do
        expect(assigns(:sub_service_request_id)).to eq(@sub_service_request.id.to_s)
      end

      it "should set @sub_service_request from params[:sub_service_request_id]" do
        expect(assigns(:sub_service_request)).to eq(@sub_service_request)
      end

      it "should build a new Notification associated with SubServiceRequest" do
        expect(assigns(:notification)).to eq(@new_notification)
      end

      it "should build a new Message to Identity from params[:identity_id]" do
        expect(@new_notification.messages).to have_received(:new).
          with(to: @recipient.id.to_s)
      end

      it "should assign new Message to @message" do
        expect(assigns(:message)).to eq(@new_message)
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "dashboard/notifications/new" }
    end

    context "params[:identity_id] present and params[:sub_service_request_id] absent" do
      before(:each) do
        @new_notification = build_stubbed(:notification)
        allow(Notification).to receive(:new).
          and_return(@new_notification)

        @recipient = build_stubbed(:identity)
        @new_message = build_stubbed(:message)
        allow(@new_notification.messages).to receive(:new).
          and_return(@new_message)

        @logged_in_user = build_stubbed(:identity)
        log_in_dashboard_identity(obj: @logged_in_user)
        xhr :get, :new, identity_id: @recipient.id
      end

      it "should build a new Notification" do
        expect(assigns(:notification)).to eq(@new_notification)
      end

      it "should build a new Message to Identity from params[:identity_id]" do
        expect(@new_notification.messages).to have_received(:new).
          with(to: @recipient.id.to_s)
      end

      it "should assign new Message to @message" do
        expect(assigns(:message)).to eq(@new_message)
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "dashboard/notifications/new" }
    end

    context "params[:identity_id] == current_user.id" do
      before(:each) do
        @logged_in_user = build_stubbed(:identity)

        @new_notification = build_stubbed(:notification)
        allow(Notification).to receive(:new).
          and_return(@new_notification)
        allow(@new_notification.errors).to receive(:add)

        @recipient = build_stubbed(:identity)
        @new_message = build_stubbed(:message)
        allow(@new_notification.messages).to receive(:new).
          and_return(@new_message)

        log_in_dashboard_identity(obj: @logged_in_user)
        xhr :get, :new, identity_id: @logged_in_user.id
      end

      it "should add an error to new Notification" do
        expect(@new_notification.errors).to have_received(:add)
      end

      it "should set @errors to new Notification's errors" do
        expect(assigns(:errors)).to eq(@new_notification.errors)
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "dashboard/notifications/new" }
    end
  end
end
