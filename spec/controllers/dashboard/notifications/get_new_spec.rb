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
