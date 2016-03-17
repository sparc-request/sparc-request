# coding: utf-8
# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rails_helper'

RSpec.describe Portal::NotificationsController do
  stub_portal_controller

  let!(:institution)           { create(:institution) }
  let!(:provider)              { create(:provider, parent_id: institution.id) }
  let!(:program)               { create(:program, parent_id: provider.id) }
  let!(:core)                  { create(:core, parent_id: program.id) }

  let!(:service_request)       { create(:service_request_without_validations) }
  let!(:ssr)                   { create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id) }

  let!(:identity1)             { create(:identity) }
  let!(:identity2)             { create(:identity) }

  let!(:notification1)         { Notification.create() }
  let!(:notification2)         { Notification.create() }
  let!(:notification3)         { Notification.create() }
  let!(:notification4)         { Notification.create(sub_service_request_id: ssr.id) }

  let!(:user_notification1)    { UserNotification.create(identity_id: identity1.id, notification_id: notification1.id) }
  let!(:user_notification2)    { UserNotification.create(identity_id: identity1.id, notification_id: notification2.id) }

  let!(:user_notification3)    { UserNotification.create(identity_id: identity2.id, notification_id: notification3.id) }

  let!(:notification_with_ssr) { Notification.create(sub_service_request_id: ssr.id) }

  let!(:deliverer)             { double() }

  before(:each) do
    session[:identity_id] = identity1.id
    allow(UserMailer).to receive(:notification_received) do
      expect(deliverer).to receive(:deliver)
      deliverer
    end
  end

  describe 'GET index' do
    it 'should set notifications to all notifications for the user' do
      get(:index, format: :json)
      expect(assigns(:notifications)).to eq [notification1.reload, notification2.reload]
    end

    it 'should return the user and all notifications' do
      get(:index, format: :json)
      # TODO: can't just use as_json, because it formats time
      # differently
      expect(JSON.parse(response.body)).to eq(
        JSON.parse(
          ActiveSupport::JSON.encode(
            [notification1.reload, notification2.reload])))
    end
  end

  describe 'GET show' do
    it 'should set sub_service_request if sub_service_request_id was sent' do
      post :show, {
        format: :js,
        id: notification1.id,
        sub_service_request_id: ssr.id,
      }.with_indifferent_access
      expect(assigns(:sub_service_request)).to eq ssr
    end

    it 'should not set sub_service_request if sub_service_request_id was not sent' do
      post :show, {
        format: :js,
        id: notification1.id,
      }.with_indifferent_access
      expect(assigns(:sub_service_request)).to eq nil
    end

    it 'should send back the notification' do
      post :show, {
        format: :js,
        id: notification1.id,
      }.with_indifferent_access
      expect(response.body).to eq '' # TODO: looks like nothing is getting sent back just yet
    end
  end

  describe 'POST new' do
    it 'should set recipient' do
      post :new, {
        format: :js,
        identity_id: identity1.id,
        sub_service_request_id: ssr.id,
      }.with_indifferent_access
      expect(assigns(:recipient)).to eq identity1
    end

    it 'should set sub service request' do
      post :new, {
        format: :js,
        identity_id: identity1.id,
        sub_service_request_id: ssr.id,
      }.with_indifferent_access
      expect(assigns(:sub_service_request)).to eq ssr
    end

    # TODO: should #new create a new notification?  it doesn't.
  end

  describe 'POST create' do
    it 'should create a new notification' do
      post :create, {
        format: :js,
        notification: {
          sub_service_request_id: ssr.id,
          originator_id: identity2.id,
        },
      }.with_indifferent_access

      notification = assigns(:notification)
      expect(notification.id).not_to eq nil
      expect(notification.sub_service_request).to eq ssr
      expect(notification.originator).to eq identity2
    end

    it 'should create a new message' do
      xhr :get, :create, {
        format: :js,
        notification: {
          sub_service_request_id: ssr.id,
          originator_id: identity2.id,
        },
        message: {
          from: identity1.id,
          to:   identity2.id,
          email:   'abe.lincoln@whitehouse.gov',
          subject: 'Emancipation',
          body:    'Four score and seven years ago...',
        },
      }.with_indifferent_access

      notification = assigns(:notification)
      message = assigns(:message)
      expect(message.id).not_to eq nil
      expect(message.notification).to eq notification
      expect(message.sender).to eq identity1
      expect(message.recipient).to eq identity2
      expect(message.email).to eq 'abe.lincoln@whitehouse.gov'
      expect(message.subject).to eq 'Emancipation'
      expect(message.body).to eq 'Four score and seven years ago...'
    end

    it 'should set sub_service_request' do
      post :create, {
        format: :js,
        notification: {
          sub_service_request_id: ssr.id,
          originator_id: identity2.id,
        },
        message: {
          from: identity1.id,
          to:   identity2.id,
          email:   'abe.lincoln@whitehouse.gov',
          subject: 'Emancipation',
          body:    'Four score and seven years ago...',
        },
      }.with_indifferent_access

      expect(assigns(:sub_service_request)).to eq ssr
    end

    it 'should set notifications' do
      xhr :get, :create, {
        format: :js,
        notification: {
          sub_service_request_id: ssr.id,
          originator_id: identity1.id,
        },
        message: {
          from: identity1.id,
          to:   identity2.id,
          email:   'abe.lincoln@whitehouse.gov',
          subject: 'Emancipation',
          body:    'Four score and seven years ago...',
        },
      }.with_indifferent_access

      new_notification = assigns(:notification)
      expect(assigns(:notifications)).to eq [new_notification] # TODO: should new_notification be in the list?
    end

    it 'should deliver the notification via email' do
      expect(UserMailer).to receive(:notification_received)

      post :create, {
        format: :js,
        notification: {
          sub_service_request_id: ssr.id,
          originator_id: identity1.id,
        },
        message: {
          from: identity1.id,
          to:   identity2.id,
          email:   'abe.lincoln@whitehouse.gov',
          subject: 'Emancipation',
          body:    'Four score and seven years ago...',
        },
      }.with_indifferent_access
    end
  end

  describe 'POST user_portal_update' do
    it 'should set notification' do
      post :user_portal_update, {
        format: :js,
        id: notification1.id,
      }.with_indifferent_access
      expect(assigns(:notification)).to eq notification1
    end

    it 'should create a new message' do
      post :user_portal_update, {
        format: :js,
        id: notification4.id,
        message: {
          from: identity1.id,
          to:   identity2.id,
          email:   'abe.lincoln@whitehouse.gov',
          subject: 'Emancipation',
          body:    'Four score and seven years ago...',
        },
      }.with_indifferent_access

      notification4.reload
      expect(notification4.messages.count).to eq 1
      message = notification4.messages[0]
      expect(message.id).not_to eq nil
      expect(message.notification).to eq notification4
      expect(message.sender).to eq identity1
      expect(message.recipient).to eq identity2
      expect(message.email).to eq 'abe.lincoln@whitehouse.gov'
      expect(message.subject).to eq 'Emancipation'
      expect(message.body).to eq 'Four score and seven years ago...'
    end

    it 'should set notifications' do
      post :user_portal_update, {
        format: :js,
        id: notification4.id,
        message: {
          from: identity1.id,
          to:   identity2.id,
          email:   'abe.lincoln@whitehouse.gov',
          subject: 'Emancipation',
          body:    'Four score and seven years ago...',
        },
      }.with_indifferent_access
      expect(assigns(:notifications)).to eq [ notification1, notification2, notification4 ]
    end

    it 'should deliver the notification via email' do
      expect(UserMailer).to receive(:notification_received)

      post :user_portal_update, {
        format: :js,
        id: notification4.id,
        message: {
          from: identity1.id,
          to:   identity2.id,
          email:   'abe.lincoln@whitehouse.gov',
          subject: 'Emancipation',
          body:    'Four score and seven years ago...',
        },
      }.with_indifferent_access
    end
  end

  describe 'POST admin_update' do
    it 'should set notification' do
      post :admin_update, {
        format: :js,
        id: notification_with_ssr.id,
      }.with_indifferent_access
      expect(assigns(:notification)).to eq notification_with_ssr
    end

    it 'should create a new message' do
      post :admin_update, {
        format: :js,
        id: notification_with_ssr.id,
        message: {
          from: identity1.id,
          to:   identity2.id,
          email:   'abe.lincoln@whitehouse.gov',
          subject: 'Emancipation',
          body:    'Four score and seven years ago...',
        },
      }.with_indifferent_access

      notification_with_ssr.reload
      expect(notification_with_ssr.messages.count).to eq 1
      message = notification_with_ssr.messages[0]
      expect(message.id).not_to eq nil
      expect(message.notification).to eq notification_with_ssr
      expect(message.sender).to eq identity1
      expect(message.recipient).to eq identity2
      expect(message.email).to eq 'abe.lincoln@whitehouse.gov'
      expect(message.subject).to eq 'Emancipation'
      expect(message.body).to eq 'Four score and seven years ago...'
    end

    it 'should set sub_service_request' do
      post :admin_update, {
        format: :js,
        id: notification_with_ssr.id,
        message: {
          from: identity1.id,
          to:   identity2.id,
          email:   'abe.lincoln@whitehouse.gov',
          subject: 'Emancipation',
          body:    'Four score and seven years ago...',
        },
      }.with_indifferent_access
      expect(assigns(:sub_service_request)).to eq ssr
    end

    it 'should set notifications' do
      post :admin_update, {
        format: :js,
        id: notification_with_ssr.id,
        message: {
          from: identity1.id,
          to:   identity2.id,
          email:   'abe.lincoln@whitehouse.gov',
          subject: 'Emancipation',
          body:    'Four score and seven years ago...',
        },
      }.with_indifferent_access
      expect(assigns(:notifications)).to eq [ notification_with_ssr ]
    end

    it 'should deliver the notification via email' do
      expect(UserMailer).to receive(:notification_received)

      post :admin_update, {
        format: :js,
        id: notification_with_ssr.id,
        message: {
          from: identity1.id,
          to:   identity2.id,
          email:   'abe.lincoln@whitehouse.gov',
          subject: 'Emancipation',
          body:    'Four score and seven years ago...',
        },
      }.with_indifferent_access
    end
  end

  describe 'POST mark_as_read' do
    it 'should set sub_service_request if sub_service_request_id is sent' do
      post :mark_as_read, {
        format: :js,
        id: notification_with_ssr.id,
        sub_service_request_id: ssr.id,
        notifications: { },
      }
      expect(assigns(:sub_service_request)).to eq ssr
    end

    it 'should set notifications if sub_service_request_id is sent' do
      post :mark_as_read, {
        format: :js,
        id: notification_with_ssr.id,
        sub_service_request_id: ssr.id,
        notifications: { },
      }
      expect(assigns(:notifications)).to eq [ ]
    end

    it 'should not set sub_service_request if sub_service_request_id is not sent' do
      post :mark_as_read, {
        format: :js,
        id: notification_with_ssr.id,
        notifications: { },
      }
      expect(assigns(:sub_service_request)).to eq nil
    end

    it 'should set notifications if sub_service_request_id is not sent' do
      post :mark_as_read, {
        format: :js,
        id: notification_with_ssr.id,
        notifications: { },
      }
      expect(assigns(:notifications)).to eq [ notification1, notification2 ]
    end

    it 'should set the read attribute on all notifications that are passed in' do
      post :mark_as_read, {
        format: :js,
        id: notification_with_ssr.id,
        notifications: { notification1 => true, notification2  => false },
      }

      user_notification1.reload
      user_notification2.reload
      user_notification3.reload

      expect(user_notification1.read).to eq true
      expect(user_notification2.read).to eq false
      expect(user_notification3.read).to eq nil
    end
  end
end
