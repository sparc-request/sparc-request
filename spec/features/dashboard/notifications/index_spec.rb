require 'rails_helper'

RSpec.describe 'Notifications index', js: true do
  let_there_be_lane
  fake_login_for_each_test

  def visit_notifications_index_page
    page = Dashboard::Notifications::IndexPage.new
    page.load
    page
  end

  describe 'inbox' do
    it 'should show Notifications associated with Messages to user' do
      # does not have a message to user; should not be displayed
      other_user = create(:identity, first_name: 'Santa', last_name: 'Claws')
      create(:notification,
        originator_id: jug2.id,
        other_user_id: other_user.id,
        subject: 'notification 1',
        body: 'message 1')
      # note1 = create(:notification, originator_id: jug2.id, other_user_id: other_user.id, subject: 'notification 1')
      # create(:message, notification_id: note1.id, from: jug2.id, to: other_user.id, body: 'message 1')

      # has a message to user; should be displayed
      create(:notification,
        originator_id: other_user.id,
        other_user_id: jug2.id,
        subject: 'notification 2',
        body: 'message 2')
      # note2 = create(:notification, other_user_id: jug2.id, originator_id: other_user.id, subject: 'notification 2')
      # create(:message, notification_id: note2.id, from: other_user.id, to: jug2.id, body: 'message 2')

      page = visit_notifications_index_page
      expect(page).to have_content('message 2')
      expect(page).not_to have_content('message 1')
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

      index_page.notifications_table.select_all.click
      wait_for_javascript_to_finish

      # I think this should have worked??
      # expect(index_page.notifications_table.notifications.map(&:select_checkbox)).to all(be_checked)
      expect(index_page.notifications_table.notifications.
        map(&:select_checkbox).all?(&:checked?)).to be
    end
  end

  describe '"Mark as Unread" button' do
    it 'should mark selected Notifications as unread' do
      other_user = create(:identity, first_name: 'Santa', last_name: 'Claws')
      note = create(:notification, other_user_id: jug2.id,
        originator_id: other_user.id, subject: 'notification 1',
        body: 'message 1', read_by_originator: true, read_by_other_user: true)
      index_page = visit_notifications_index_page

      index_page.notifications_table.notifications.first.select_checkbox.click
      index_page.mark_as_unread_button.click
      wait_for_javascript_to_finish

      # should mark notification as unread
      expect(note.reload.read_by? jug2).not_to be
    end
  end

  describe '"Mark as Read" button' do
    it 'should mark selected Notifications as read' do
      other_user = create(:identity, first_name: 'Santa', last_name: 'Claws')
      note = create(:notification, other_user_id: jug2.id,
        originator_id: other_user.id, subject: 'notification 1',
        body: 'message 1', read_by_originator: false, read_by_other_user: false)
      index_page = visit_notifications_index_page

      index_page.notifications_table.notifications.first.select_checkbox.click
      index_page.mark_as_read_button.click
      wait_for_javascript_to_finish

      # should mark notification as read
      expect(note.reload.read_by? jug2).to be
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

        expect(index_page.notifications_table.notifications[0]).to have_content('Santa Claws')
        expect(index_page.notifications_table.notifications[1]).to have_content('Tooth Carie')
        index_page.notifications_table.user_header.click

        expect(index_page.notifications_table.notifications[0]).to have_content('Tooth Carie')
        expect(index_page.notifications_table.notifications[1]).to have_content('Santa Claws')
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
        # other_user3 = create(:identity, first_name: 'Feaster', last_name: 'Bunny')
        # create(:notification, other_user_id: jug2.id,
        #   originator_id: other_user3.id, subject: 'notification 3',
        #   body: 'message 3')

        notifications_table = visit_notifications_index_page.notifications_table
        notifications_table.user_header.click
        notifications_table.user_header.click

        # expect(notifications_table.notifications[0]).to have_content('Feaster Bunny')
        expect(notifications_table.notifications[0]).to have_content('Santa Claws')
        expect(notifications_table.notifications[1]).to have_content('Tooth Carie')
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

        expect(index_page.notifications_table.notifications[0]).to have_content('notification 1')
        expect(index_page.notifications_table.notifications[1]).to have_content('notification 2')
        index_page.notifications_table.user_header.click

        expect(index_page.notifications_table.notifications[0]).to have_content('notification 2')
        expect(index_page.notifications_table.notifications[1]).to have_content('notification 1')
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

        index_page.notifications_table.user_header.click
        index_page.notifications_table.user_header.click

        expect(index_page.notifications_table.notifications[0]).to have_content('notification 1')
        expect(index_page.notifications_table.notifications[1]).to have_content('notification 2')
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
      expect(index_page.notifications_table).not_to have_content('Tooth Carie')

      other_user2 = create(:identity, first_name: 'Tooth', last_name: 'Carie')
      create(:notification, other_user_id: jug2.id,
      originator_id: other_user2.id, subject: 'notification 2',
      body: 'message 2', message_created_at: 1.days.ago)
      index_page.view_inbox_button.click

      expect(index_page.notifications_table).to have_content('notification 2')
    end
  end

  context 'user clicks sent button' do
    let!(:page) { visit_notifications_index_page }
    before(:each) { page.view_sent_button.click }

    it 'should show sent messages' do
      other_user1 = create(:identity, first_name: 'Santa', last_name: 'Claws')
      create(:notification, other_user_id: other_user1.id,
        originator_id: jug2.id, subject: 'notification 1',
        body: 'message 1', message_created_at: 2.days.ago)

      index_page = visit_notifications_index_page
      index_page.view_sent_button.click
      wait_for_javascript_to_finish

      expect(index_page.notifications_table).to have_content('notification 1')
    end
  end

  describe 'search field' do
    it 'should search by user' do
      other_user1 = create(:identity, first_name: 'Santa', last_name: 'Claws')
      create(:notification, other_user_id: jug2.id,
        originator_id: other_user1.id, subject: 'notification 1',
        body: 'message 1', message_created_at: 2.days.ago)
      other_user2 = create(:identity, first_name: 'Tooth', last_name: 'Carie')
      create(:notification, other_user_id: jug2.id,
        originator_id: other_user2.id, subject: 'notification 2',
        body: 'message 2', message_created_at: 1.days.ago)
      index_page = visit_notifications_index_page

      index_page.search_field.set('Tooth')
      expect(index_page.notifications_table).to have_content('Tooth Carie')
      expect(index_page.notifications_table).not_to have_content('Santa Claws')
    end

    it 'should search by subject' do
      other_user1 = create(:identity, first_name: 'Santa', last_name: 'Claws')
      create(:notification, other_user_id: jug2.id,
        originator_id: other_user1.id, subject: 'MUSC Broadcast Messages for February 17th, 2016',
        body: 'message 1', message_created_at: 2.days.ago)
      other_user2 = create(:identity, first_name: 'Tooth', last_name: 'Carie')
      create(:notification, other_user_id: jug2.id,
        originator_id: other_user2.id, subject: 'notification 2',
        body: 'message 2', message_created_at: 1.days.ago)
      index_page = visit_notifications_index_page

      index_page.search_field.set('MUSC Broadcast Messages')
      expect(index_page.notifications_table).to have_content('message 1')
      expect(index_page.notifications_table).not_to have_content('message 2')
    end
  end
end
