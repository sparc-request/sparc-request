require 'spec_helper'

describe Portal::NotificationsController do
  stub_portal_controller

  let!(:identity1) { FactoryGirl.create(:identity) }
  let!(:identity2) { FactoryGirl.create(:identity) }

  let!(:notification1) { Notification.create() }
  let!(:notification2) { Notification.create() }
  let!(:notification3) { Notification.create() }

  let!(:user_notification1) { UserNotification.create(identity_id: identity1.id, notification_id: notification1.id) }
  let!(:user_notification2) { UserNotification.create(identity_id: identity1.id, notification_id: notification2.id) }

  let!(:user_notification3) { UserNotification.create(identity_id: identity2.id, notification_id: notification3.id) }

  let!(:institution) { FactoryGirl.create(:institution) }
  let!(:provider) { FactoryGirl.create(:provider, parent_id: institution.id) }
  let!(:program) { FactoryGirl.create(:program, parent_id: provider.id) }
  let!(:core) { FactoryGirl.create(:core, parent_id: program.id) }

  let!(:service_request) { FactoryGirl.create(:service_request, visit_count: 0) }
  let!(:ssr) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id) }

  describe 'GET index' do
    it 'should set notifications to all notifications for the user' do
      session[:identity_id] = identity1.id
      get(:index, format: :json)
      assigns(:notifications).should eq [ notification1, notification2 ]
    end

    it 'should return the user and all notifications' do
      session[:identity_id] = identity1.id
      get(:index, format: :json)
      # TODO: can't just use as_json, because it formats time
      # differently
      JSON.parse(response.body).should eq(JSON.parse(ActiveSupport::JSON.encode([ notification1, notification2 ])))
    end
  end

  describe 'GET show' do
    it 'should set sub_service_request if sub_service_request_id was sent' do
      session[:identity_id] = identity1.id
      get :show, {
        format: :json,
        id: notification1.id,
        sub_service_request_id: ssr.id,
      }.with_indifferent_access
      assigns(:sub_service_request).should eq ssr
    end

    it 'should not set sub_service_request if sub_service_request_id was not sent' do
      session[:identity_id] = identity1.id
      get :show, {
        format: :json,
        id: notification1.id,
      }.with_indifferent_access
      assigns(:sub_service_request).should eq nil
    end

    it 'should send back the notification' do
      session[:identity_id] = identity1.id
      get :show, {
        format: :js,
        id: notification1.id,
      }.with_indifferent_access
      response.body.should eq '' # TODO: looks like nothing is getting sent back just yet
    end
  end

  describe 'POST new' do
    it 'should set recipient' do
      get :new, {
        format: :js,
        identity_id: identity1.id,
        sub_service_request_id: ssr.id,
      }.with_indifferent_access
      assigns(:recipient).should eq identity1
    end

    it 'should set sub service request' do
      get :new, {
        format: :js,
        identity_id: identity1.id,
        sub_service_request_id: ssr.id,
      }.with_indifferent_access
      assigns(:sub_service_request).should eq ssr
    end

    # TODO: should #new create a new notification?  it doesn't.
  end

  describe 'POST create' do
    it 'should create a new notification' do
      session[:identity_id] = identity1.id
      get :create, {
        format: :js,
        notification: {
          sub_service_request_id: ssr.id,
          originator_id: identity2.id,
        },
      }.with_indifferent_access

      notification = assigns(:notification)
      notification.sub_service_request.should eq ssr
      notification.originator.should eq identity2
    end
  end

  describe 'POST user_portal_update' do
  end

  describe 'POST admin_update' do
  end

  describe 'POST mark_as_read' do
  end
end
