require 'rails_helper'

RSpec.describe 'Notifications index', js: true do
  let_there_be_lane
  fake_login_for_each_test

  def visit_notifications_index_page
    page = Dashboard::Notifications::IndexPage.new
    page.load
    page
  end

  context 'user clicked select all Notifications checkbox' do
    scenario 'user clicks "Mark as Unread" button' do
      page = visit_notifications_index_page
      page.mark_as_unread_button.click
    end

    scenario 'user clicks "Mark as Read" button' do
      page = visit_notifications_index_page
      page.mark_as_read_button.click
    end
  end

  context 'user selected some but not all Notifications' do
    scenario 'user clicks "Mark as Unread" button' do
      page = visit_notifications_index_page
      page.mark_as_unread_button.click
    end

    scenario 'user clicks "Mark as Read" button' do
      page = visit_notifications_index_page
      page.mark_as_read_button.click
    end
  end

  context 'user clicks user header' do
    it 'should sort Notifications by user name' do
      page = visit_notifications_index_page
      page.notifications_table.user_header.click
    end
  end

  context 'user clicks time header' do
    it 'should sort Notifications by time' do
      page = visit_notifications_index_page
      page.notifications_table.time_header.click
    end
  end

  context 'user clicks inbox button' do
    it 'should refresh inbox' do
      page = visit_notifications_index_page
      page.view_inbox_button.click
    end
  end

  context 'user clicks sent button' do
    let!(:page) { visit_notifications_index_page }
    before(:each) { page.view_sent_button.click }

    it 'should show sent messages' do
    end

    context 'user clicks inbox button' do
      it 'should take user back to inbox' do
        page.view_inbox_button.click
      end
    end
  end

  describe 'search field' do
    it 'should search by user' do
      page = visit_notifications_index_page
      page.search_field.set('Santa Claws')
    end

    it 'should search by subject' do
      page = visit_notifications_index_page
      page.search_field.set('MUSC Broadcast Messages for February 17th, 2016')
    end
  end

  describe 'message colors' do
    context 'unread message' do
      it 'should be green' do
        page = visit_notifications_index_page
      end
    end

    context 'read message' do
      it 'should be gray' do
        page = visit_notifications_index_page
      end
    end
  end
end
