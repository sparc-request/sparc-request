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
