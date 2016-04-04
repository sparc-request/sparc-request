require 'rails_helper'

RSpec.describe 'Notifications index', js: true do
  let_there_be_lane
  fake_login_for_each_test

  def visit_notifications_index_page
    page = Dashboard::Notifications::IndexPage.new
    page.load
    page
  end

  describe "Compose Message button" do
    context "user clicks button" do
      it "should allow user to search for a recipient and compose a new message to them" do
        other_user = create(:identity, first_name: 'Santa', last_name: 'Claws')

        page = visit_notifications_index_page
        page.compose_button.click

        page.wait_for_send_notification_modal
        page.notification_modal.instance_exec do
          select_user.set("Claws")
          wait_for_search_results
          search_results.select { |sr| sr.text =~ "Claws" }.first.click

        end
      end
    end
  end

  describe 'default' do
    it 'should show Notifications associated with Messages to user' do
      # does not have a message to user; should not be displayed
      other_user = create(:identity, first_name: 'Santa', last_name: 'Claws')
      create(:notification,
        originator_id: jug2.id,
        other_user_id: other_user.id,
        subject: 'notification 1',
        body: 'message 1')

      # has a message to user; should be displayed
      create(:notification,
        originator_id: other_user.id,
        other_user_id: jug2.id,
        subject: 'notification 2',
        body: 'message 2')

      page = visit_notifications_index_page

      expect(page).to have_no_notifications(text: 'notification 1')
      expect(page).to have_notifications(text: 'notification 2')
    end
  end

  describe 'select all checkbox' do
    it 'should select all Notifications' do
      other_user = create(:identity, first_name: 'Santa', last_name: 'Claws')
      create(:notification, other_user_id: jug2.id,
        originator_id: other_user.id, subject: 'notification 1',
        body: 'message 1')
      create(:notification, other_user_id: jug2.id,
        originator_id: other_user.id, subject: 'notification 2',
        body: 'message 2')

      index_page = visit_notifications_index_page
      expect(index_page).to have_notifications(count: 2)
      index_page.select_all.click

      expect(index_page.notifications.first).to have_checked_select_checkbox
      expect(index_page.notifications.second).to have_checked_select_checkbox
    end
  end

  describe '"Mark as Unread" button' do
    it 'should mark selected Notifications as unread' do
      other_user = create(:identity, first_name: 'Santa', last_name: 'Claws')
      note = create(:notification, other_user_id: jug2.id,
        originator_id: other_user.id, subject: 'notification 1',
        body: 'message 1', read_by_originator: true, read_by_other_user: true)

      index_page = visit_notifications_index_page
      wait_for_javascript_to_finish
      index_page.notifications.first.select_checkbox.click
      index_page.mark_as_unread_button.click
      wait_for_javascript_to_finish

      # should mark notification as unread
      expect(note.reload.read_by?(jug2)).not_to be(true)
    end
  end

  describe '"Mark as Read" button' do
    it 'should mark selected Notifications as read' do
      other_user = create(:identity, first_name: 'Santa', last_name: 'Claws')
      note = create(:notification, other_user_id: jug2.id,
        originator_id: other_user.id, subject: 'notification 1',
        body: 'message 1', read_by_originator: false, read_by_other_user: false)

      index_page = visit_notifications_index_page
      wait_for_javascript_to_finish
      index_page.notifications.first.select_checkbox.click
      index_page.mark_as_read_button.click
      wait_for_javascript_to_finish

      # should mark notification as read
      expect(note.reload.read_by?(jug2)).to be(true)
    end
  end

  describe 'order' do
    it 'should order Notifications by :id' do
      other_user = create(:identity, first_name: 'Santa', last_name: 'Claws')
      create(:notification, other_user_id: jug2.id,
             originator_id: other_user.id, subject: 'notification 1',
             body: 'message 1')
      create(:notification, other_user_id: jug2.id,
             originator_id: other_user.id, subject: 'notification 2',
             body: 'message 2')

      index_page = visit_notifications_index_page
      expect(index_page).to have_notifications(count: 2)
      index_page.select_all.click

      expect(index_page.notifications.first).to have_content('notification 1')
      expect(index_page.notifications.second).to have_content('notification 2')
    end
  end

  describe 'sort by user name' do
    context 'user name header clicked once' do
      it 'should sort Notifications by user first name, descending' do
        other_user1 = create(:identity, first_name: 'Santa', last_name: 'Claws')
        create(:notification, other_user_id: jug2.id,
          originator_id: other_user1.id, subject: 'notification 1',
          body: 'message 1')
        other_user2 = create(:identity, first_name: 'Tooth', last_name: 'Carie')
        create(:notification, other_user_id: jug2.id,
          originator_id: other_user2.id, subject: 'notification 2',
          body: 'message 2')

        index_page = visit_notifications_index_page
        index_page.user_header.click

        expect(index_page.notifications.first).to have_content('Tooth Carie')
        expect(index_page.notifications.second).to have_content('Santa Claws')
      end
    end

    context 'user name header clicked twice' do
      it 'should sort Notifications by user first name, ascending' do
        other_user1 = create(:identity, first_name: 'Santa', last_name: 'Claws')
        create(:notification, other_user_id: jug2.id,
          originator_id: other_user1.id, subject: 'notification 1',
          body: 'message 1')
        other_user2 = create(:identity, first_name: 'Tooth', last_name: 'Carie')
        create(:notification, other_user_id: jug2.id,
          originator_id: other_user2.id, subject: 'notification 2',
          body: 'message 2')

        notifications_table = visit_notifications_index_page
        notifications_table.user_header.click
        notifications_table.user_header.click

        expect(notifications_table.notifications.first).to have_content('Santa Claws')
        expect(notifications_table.notifications.second).to have_content('Tooth Carie')
      end
    end
  end

  describe 'sort by time' do
    context 'time header clicked once' do
      it 'should put most recent messages at the top' do
        other_user1 = create(:identity, first_name: 'Santa', last_name: 'Claws')
        create(:notification, other_user_id: jug2.id,
          originator_id: other_user1.id, subject: 'notification 1',
          body: 'message 1', message_created_at: 2.days.ago)
        other_user2 = create(:identity, first_name: 'Tooth', last_name: 'Carie')
        create(:notification, other_user_id: jug2.id,
          originator_id: other_user2.id, subject: 'notification 2',
          body: 'message 2', message_created_at: 1.days.ago)

        index_page = visit_notifications_index_page
        expect(index_page.notifications.first).to have_content('notification 1')
        expect(index_page.notifications.second).to have_content('notification 2')
        index_page.user_header.click

        expect(index_page.notifications.first).to have_content('notification 2')
        expect(index_page.notifications.second).to have_content('notification 1')
      end
    end

    context 'time header clicked twice' do
      it 'should put oldest messages at the top' do
        other_user1 = create(:identity, first_name: 'Santa', last_name: 'Claws')
        create(:notification, other_user_id: jug2.id,
          originator_id: other_user1.id, subject: 'notification 1',
          body: 'message 1', message_created_at: 2.days.ago)
        other_user2 = create(:identity, first_name: 'Tooth', last_name: 'Carie')
        create(:notification, other_user_id: jug2.id,
          originator_id: other_user2.id, subject: 'notification 2',
          body: 'message 2', message_created_at: 1.days.ago)

        index_page = visit_notifications_index_page
        index_page.user_header.click
        index_page.user_header.click

        expect(index_page.notifications.first).to have_content('notification 1')
        expect(index_page.notifications.second).to have_content('notification 2')
      end
    end
  end

  context 'user clicks inbox button' do
    it 'should refresh inbox' do
      other_user1 = create(:identity, first_name: 'Santa', last_name: 'Claws')
      create(:notification, other_user_id: jug2.id,
        originator_id: other_user1.id, subject: 'notification 1',
        body: 'message 1', message_created_at: 2.days.ago)

      index_page = visit_notifications_index_page
      other_user2 = create(:identity, first_name: 'Tooth', last_name: 'Carie')
      create(:notification, other_user_id: jug2.id,
             originator_id: other_user2.id,
             subject: 'notification 2',
             body: 'message 2',
             message_created_at: 1.days.ago)
      index_page.view_inbox_button.click

      expect(index_page).to have_notifications(text: 'notification 2')
    end
  end

  context 'user clicks sent button' do
    let!(:page) { visit_notifications_index_page }
    before(:each) { page.view_sent_button.click }

    it 'should show sent messages' do
      other_user1 = create(:identity, first_name: 'Santa', last_name: 'Claws')
      create(:notification,
             other_user_id: other_user1.id,
             originator_id: jug2.id,
             subject: 'notification 1',
             body: 'message 1',
             message_created_at: 2.days.ago)

      index_page = visit_notifications_index_page
      index_page.view_sent_button.click
      wait_for_javascript_to_finish

      expect(index_page).to have_notifications(text: 'notification 1')
    end
  end

  describe 'search field' do
    it 'should search by user' do
      other_user1 = create(:identity, first_name: 'Santa', last_name: 'Claws')
      create(:notification,
             other_user_id: jug2.id,
             originator_id: other_user1.id,
             subject: 'notification 1',
             body: 'message 1',
             message_created_at: 2.days.ago)
      other_user2 = create(:identity, first_name: 'Tooth', last_name: 'Carie')
      create(:notification,
             other_user_id: jug2.id,
             originator_id: other_user2.id,
             subject: 'notification 2',
             body: 'message 2',
             message_created_at: 1.days.ago)

      index_page = visit_notifications_index_page
      index_page.search_field.set('Tooth')

      expect(index_page).to have_notifications(text: 'Tooth Carie')
      expect(index_page).to have_no_notifications(text: 'Santa Claws')
    end

    it 'should search by subject' do
      other_user1 = create(:identity, first_name: 'Santa', last_name: 'Claws')
      create(:notification,
             other_user_id: jug2.id,
             originator_id: other_user1.id,
             subject: 'MUSC Broadcast Messages for February 17th, 2016',
             body: 'message 1',
             message_created_at: 2.days.ago)
      other_user2 = create(:identity, first_name: 'Tooth', last_name: 'Carie')
      create(:notification,
             other_user_id: jug2.id,
             originator_id: other_user2.id,
             subject: 'notification 2',
             body: 'message 2',
             message_created_at: 1.days.ago)

      index_page = visit_notifications_index_page
      index_page.search_field.set('MUSC Broadcast Messages')

      expect(index_page).to have_notifications(text: 'message 1')
      expect(index_page).to have_no_notifications(text: 'message 2')
    end
  end
end
