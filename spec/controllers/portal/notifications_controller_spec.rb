require 'spec_helper'

describe Portal::NotificationsController do
  stub_portal_controller

  describe 'GET index' do
    let!(:identity1) { FactoryGirl.create(:identity) }
    let!(:identity2) { FactoryGirl.create(:identity) }

    let!(:notification1) { Notification.create() }
    let!(:notification2) { Notification.create() }
    let!(:notification3) { Notification.create() }

    let!(:user_notification1) { UserNotification.create(identity_id: identity1.id, notification_id: notification1.id) }
    let!(:user_notification2) { UserNotification.create(identity_id: identity1.id, notification_id: notification2.id) }

    let!(:user_notification3) { UserNotification.create(identity_id: identity2.id, notification_id: notification3.id) }

    it 'should set notifications to all notifications for the user' do
      session[:identity_id] = identity1.id
      get(:index, format: :js)
      assigns(:notifications).should eq [ notification1, notification2 ]
    end

    it 'should return the user and all notifications' do
    end
  end

  describe 'GET show' do
  end

  describe 'POST new' do
  end

  describe 'POST create' do
  end

  describe 'POST user_portal_update' do
  end

  describe 'POST admin_update' do
  end

  describe 'POST mark_as_read' do
  end
end
