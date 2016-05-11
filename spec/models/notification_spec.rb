require "rails_helper"

RSpec.describe Notification do
  describe ".of_ssr" do
    context "with :sub_service_request_id" do
      it "should return all Notifications belonging to SubServiceRequest" do
        notification1 = create(:notification_without_validations,
          sub_service_request_id: 1)
        create(:notification_without_validations,
          sub_service_request_id: 2)

        expect(Notification.of_ssr(1)).to eq([notification1])
      end
    end

    context "without :sub_service_request_id" do
      it "should return all Notifications" do
        notification1 = create(:notification_without_validations,
          sub_service_request_id: 1)
        notification2 = create(:notification_without_validations,
          sub_service_request_id: 2)

        expect(Notification.of_ssr).to eq([notification1, notification2])
      end
    end
  end

  describe ".unread_by" do
    it "should only return Notifications unread by user" do
      user1 = create(:identity)
      user2 = create(:identity)

      # expect:
      notification1 = create(:notification,
        originator_id: user1.id,
        read_by_originator: false,
        other_user_id: user2.id,
        read_by_other_user: true,
        body: "message1")
      notification2 = create(:notification,
        originator_id: user2.id,
        read_by_originator: true,
        other_user_id: user1.id,
        read_by_other_user: false,
        body: "message2")
      expected = [notification1, notification2]

      # don't expect:
      create(:notification,
        originator_id: user1.id,
        read_by_originator: true,
        other_user_id: user2.id,
        read_by_other_user: false,
        body: "message3")
      create(:notification,
        originator_id: user2.id,
        read_by_originator: false,
        other_user_id: user1.id,
        read_by_other_user: true,
        body: "message4")

      expect(Notification.unread_by(user1.id)).to eq(expected)
    end
  end

  describe ".belonging_to" do
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

        expect(Notification.belonging_to(user1.id)).to eq(expected)
      end
    end

    context "with :sub_service_request_id" do
      it "should return only Notifications to or from :user, belonging to SubServiceRequest" do
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
        expected = [notification1, notification2]

        # don't expect:
        create(:notification,
          sub_service_request_id: sub_service_request2.id,
          originator_id: user2.id,
          other_user_id: user1.id,
          body: "message3")
        create(:notification,
          originator_id: user2.id,
          other_user_id: user3.id,
          sub_service_request_id: sub_service_request1.id,
          body: "message4") # doesn't involve user1

        expect(Notification.belonging_to(user1.id, sub_service_request1.id)).to eq(expected)
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

        create(:notification,
          sub_service_request_id: sub_service_request1.id,
          originator_id: user1.id,
          other_user_id: user2.id,
          body: "message2")

        create(:notification,
          sub_service_request_id: sub_service_request2.id,
          originator_id: user2.id,
          other_user_id: user1.id,
          body: "message3")

        expect(Notification.in_inbox_of(user1.id, sub_service_request1.id)).to eq([notification1])
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

        expect(Notification.in_inbox_of(user1.id)).to eq([notification1, notification2])
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

        expect(Notification.in_sent_of(user1.id, sub_service_request1.id)).to eq([expected_notification])
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

        expect(Notification.in_sent_of(user1.id)).to eq([notification1, notification2])
      end
    end
  end
end
