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
