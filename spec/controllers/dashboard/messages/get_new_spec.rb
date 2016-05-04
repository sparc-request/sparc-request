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

      @new_message_attrs = {
        notification_id: @notification.id,
        to: @recipient.id,
        from: @logged_in_user.id,
        email: @recipient.email
      }

      allow(Message).to receive(:new).
        with(@new_message_attrs).
        and_return("new message")

      log_in_dashboard_identity(obj: @logged_in_user)
      xhr :get, :new, @new_message_attrs
    end

    it "should assign @notification from params[:notification_id]" do
      expect(assigns(:notification)).to eq(@notification)
    end

    it "should assign @message to new Message built from params to other user from Notification" do
      expect(assigns(:message)).to eq("new message")
    end

    it { is_expected.to render_template "dashboard/messages/new" }
    it { is_expected.to respond_with :ok }
  end
end
