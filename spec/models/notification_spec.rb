require "rails_helper"

RSpec.describe Notification do
  describe ".belonging_to" do
    context "with :sub_service_request_id" do
      it "should return only Notifications to or from :user, belonging to specified SubServiceRequest" do
        user1 = create(:identity)
        user2 = create(:identity)
        user3 = create(:identity)

        sub_service_request1 = create(:sub_service_request_with_organization)
        sub_service_request2 = create(:sub_service_request_with_organization)

        # expect:
        notification1 = create(:notification,
          sub_service_request_id: sub_service_request1.id,
          originator_id: user1.id,
          other_user_id: user2.id,
          body: "message1")
        notification2 = create(:notification,
          originator_id: user2.id,
          other_user_id: user1.id,
          sub_service_request_id: sub_service_request1.id,
          body: "message2")
        expected = [notification1, notification2]

        # don't expect:
        create(:notification,
          originator_id: user1.id,
          other_user_id: user2.id,
          sub_service_request_id: sub_service_request2.id,
          body: "message3") # different SSR
        create(:notification,
          originator_id: user2.id,
          other_user_id: user3.id,
          sub_service_request_id: sub_service_request1.id,
          body: "message4") # doesn't involve user1

        expect(Notification.belonging_to(user1.id, sub_service_request1.id).to_a).to eq(expected)
      end
    end

    context "without :sub_service_request_id" do
      it "should return only Notifications to or from :user, belonging to any SubServiceRequest" do
        user1 = create(:identity)
        user2 = create(:identity)
        user3 = create(:identity)

        sub_service_request1 = create(:sub_service_request_with_organization)
        sub_service_request2 = create(:sub_service_request_with_organization)

        # expect:
        notification1 = create(:notification,
          sub_service_request_id: sub_service_request1.id,
          originator_id: user2.id,
          other_user_id: user1.id,
          body: "message1")
        notification2 = create(:notification,
          sub_service_request_id: sub_service_request1.id,
          originator_id: user1.id,
          other_user_id: user2.id,
          body: "message2")
        notification3 = create(:notification,
          sub_service_request_id: sub_service_request2.id,
          originator_id: user2.id,
          other_user_id: user1.id,
          body: "message3")
        expected = [notification1, notification2, notification3]

        # don't expect:
        create(:notification,
          originator_id: user2.id,
          other_user_id: user3.id,
          sub_service_request_id: sub_service_request1.id,
          body: "message4") # doesn't involve user1

        expect(Notification.belonging_to(user1.id).to_a).to eq(expected)
      end
    end
  end

  describe ".in_inbox_of" do
    context "with :sub_service_request_id" do
      it "should return only Notifications with Messages to :user, belonging to SubServiceRequest" do
        user1 = create(:identity)
        user2 = create(:identity)

        sub_service_request1 = create(:sub_service_request_with_organization)
        sub_service_request2 = create(:sub_service_request_with_organization)

        notification1 = create(:notification,
          sub_service_request_id: sub_service_request1.id,
          originator_id: user2.id,
          other_user_id: user1.id,
          body: "message1")

        notification2 = create(:notification,
          sub_service_request_id: sub_service_request1.id,
          originator_id: user1.id,
          other_user_id: user2.id,
          body: "message2")

        notification3 = create(:notification,
          sub_service_request_id: sub_service_request2.id,
          originator_id: user2.id,
          other_user_id: user1.id,
          body: "message3")

        expect(Notification.in_inbox_of(user1.id, sub_service_request1.id).to_a).to eq([notification1])
      end
    end

    context "without :sub_service_request_id" do
      it "should return only Notifications with Messages to :user, belonging to any SubServiceRequest" do
        user1 = create(:identity)
        user2 = create(:identity)

        sub_service_request1 = create(:sub_service_request_with_organization)
        sub_service_request2 = create(:sub_service_request_with_organization)

        notification1 = create(:notification,
          sub_service_request_id: sub_service_request1.id,
          originator_id: user2.id,
          other_user_id: user1.id,
          body: "message1")

        create(:notification,
          sub_service_request_id: sub_service_request1.id,
          originator_id: user1.id,
          other_user_id: user2.id,
          body: "message2")

        notification2 = create(:notification,
          sub_service_request_id: sub_service_request2.id,
          originator_id: user2.id,
          other_user_id: user1.id,
          body: "message3")

        expect(Notification.in_inbox_of(user1.id).to_a).to eq([notification1, notification2])
      end
    end
  end

  describe ".in_sent_of" do
    context "with :sub_service_request_id" do
      it "should return only Notifications with Messages from :user, belonging to SubServiceRequest" do
        user1 = create(:identity)
        user2 = create(:identity)

        sub_service_request1 = create(:sub_service_request_with_organization)
        sub_service_request2 = create(:sub_service_request_with_organization)

        expected_notification = create(:notification,
          sub_service_request_id: sub_service_request1.id,
          originator_id: user1.id,
          other_user_id: user2.id,
          body: "message1")

        create(:notification,
          sub_service_request_id: sub_service_request1.id,
          originator_id: user2.id,
          other_user_id: user1.id,
          body: "message2")

        create(:notification,
          sub_service_request_id: sub_service_request2.id,
          originator_id: user1.id,
          other_user_id: user2.id,
          body: "message3")

        expect(Notification.in_sent_of(user1.id, sub_service_request1.id).to_a).to eq([expected_notification])
      end
    end

    context "without :sub_service_request_id" do
      it "should return only Notifications with Messages from :user, belonging to any SubServiceRequest" do
        user1 = create(:identity)
        user2 = create(:identity)

        sub_service_request1 = create(:sub_service_request_with_organization)
        sub_service_request2 = create(:sub_service_request_with_organization)

        notification1 = create(:notification,
          sub_service_request_id: sub_service_request1.id,
          originator_id: user1.id,
          other_user_id: user2.id,
          body: "message1")

        create(:notification,
          sub_service_request_id: sub_service_request1.id,
          originator_id: user2.id,
          other_user_id: user1.id,
          body: "message2")

        notification2 = create(:notification,
          sub_service_request_id: sub_service_request2.id,
          originator_id: user1.id,
          other_user_id: user2.id,
          body: "message3")

        expect(Notification.in_sent_of(user1.id).to_a).to eq([notification1, notification2])
      end
    end
  end
end
