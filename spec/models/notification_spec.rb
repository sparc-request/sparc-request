require "rails_helper"

RSpec.describe Notification do
  describe ".in_inbox_of" do
    context "with :sub_service_request_id" do
      it "should return only Notifications with Messages to :user, belonging to SubServiceRequest" do
        user1 = create(:identity)
        user2 = create(:identity)

        sub_service_request1 = create(:sub_service_request_with_organization)
        notification1 = Notification.create(sub_service_request_id: sub_service_request1.id)
        Message.create(notification_id: notification1.id, to: user1.id, from: user2.id, body: "message1")

        notification2 = Notification.create(sub_service_request_id: sub_service_request1.id)
        Message.create(notification_id: notification2.id, to: user2.id, from: user1.id, body: "message2")

        sub_service_request2 = create(:sub_service_request_with_organization)
        notification3 = Notification.create(sub_service_request_id: sub_service_request2.id)
        Message.create(notification_id: notification3.id, to: user1.id, from: user2.id, body: "message3")

        expect(Notification.in_inbox_of(user1.id, sub_service_request1.id).to_a).to eq([notification1])
      end
    end

    context "without :sub_service_request_id" do
      it "should return only Notifications with Messages to :user, belonging to any SubServiceRequest" do
        user1 = create(:identity)
        user2 = create(:identity)

        sub_service_request1 = create(:sub_service_request_with_organization)
        notification1 = Notification.create(sub_service_request_id: sub_service_request1.id)
        Message.create(notification_id: notification1.id, to: user1.id, from: user2.id, body: "message1")

        notification2 = Notification.create(sub_service_request_id: sub_service_request1.id)
        Message.create(notification_id: notification2.id, to: user2.id, from: user1.id, body: "message2")

        sub_service_request2 = create(:sub_service_request_with_organization)
        notification3 = Notification.create(sub_service_request_id: sub_service_request2.id)
        Message.create(notification_id: notification3.id, to: user1.id, from: user2.id, body: "message3")

        expect(Notification.in_inbox_of(user1.id).to_a).to eq([notification1, notification3])
      end
    end
  end

  describe ".in_sent_of" do
    context "with :sub_service_request_id" do
      it "should return only Notifications with Messages from :user, belonging to SubServiceRequest" do
        user1 = create(:identity)
        user2 = create(:identity)

        sub_service_request1 = create(:sub_service_request_with_organization)
        notification1 = Notification.create(sub_service_request_id: sub_service_request1.id)
        Message.create(notification_id: notification1.id, to: user2.id, from: user1.id, body: "message1")

        notification2 = Notification.create(sub_service_request_id: sub_service_request1.id)
        Message.create(notification_id: notification2.id, to: user1.id, from: user2.id, body: "message2")

        sub_service_request2 = create(:sub_service_request_with_organization)
        notification3 = Notification.create(sub_service_request_id: sub_service_request2.id)
        Message.create(notification_id: notification3.id, to: user2.id, from: user1.id, body: "message3")

        expect(Notification.in_sent_of(user1.id, sub_service_request1.id).to_a).to eq([notification1])
      end
    end

    context "without :sub_service_request_id" do
      it "should return only Notifications with Messages from :user, belonging to any SubServiceRequest" do
        user1 = create(:identity)
        user2 = create(:identity)

        sub_service_request1 = create(:sub_service_request_with_organization)
        notification1 = Notification.create(sub_service_request_id: sub_service_request1.id)
        Message.create(notification_id: notification1.id, to: user2.id, from: user1.id, body: "message1")

        notification2 = Notification.create(sub_service_request_id: sub_service_request1.id)
        Message.create(notification_id: notification2.id, to: user1.id, from: user2.id, body: "message2")

        sub_service_request2 = create(:sub_service_request_with_organization)
        notification3 = Notification.create(sub_service_request_id: sub_service_request2.id)
        Message.create(notification_id: notification3.id, to: user2.id, from: user1.id, body: "message3")

        expect(Notification.in_sent_of(user1.id).to_a).to eq([notification1, notification3])
      end
    end
  end
end
