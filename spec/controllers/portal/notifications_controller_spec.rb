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

require 'spec_helper'

describe Portal::NotificationsController do
  stub_portal_controller

  let!(:institution) { FactoryGirl.create(:institution) }
  let!(:provider) { FactoryGirl.create(:provider, parent_id: institution.id) }
  let!(:program) { FactoryGirl.create(:program, parent_id: provider.id) }
  let!(:core) { FactoryGirl.create(:core, parent_id: program.id) }

  let!(:service_request) { FactoryGirl.create_without_validation(:service_request) }
  let!(:ssr) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id) }

  let!(:identity1) { FactoryGirl.create(:identity) }
  let!(:identity2) { FactoryGirl.create(:identity) }

  let!(:notification1) { Notification.create() }
  let!(:notification2) { Notification.create() }
  let!(:notification3) { Notification.create() }
  let!(:notification4) { Notification.create(sub_service_request_id: ssr.id) }

  let!(:user_notification1) { UserNotification.create(identity_id: identity1.id, notification_id: notification1.id) }
  let!(:user_notification2) { UserNotification.create(identity_id: identity1.id, notification_id: notification2.id) }

  let!(:user_notification3) { UserNotification.create(identity_id: identity2.id, notification_id: notification3.id) }

  let!(:notification_with_ssr) { Notification.create(sub_service_request_id: ssr.id) }

  let!(:deliverer) { double() }

  before(:each) do
    UserMailer.stub!(:notification_received) {
      deliverer.should_receive(:deliver)
      deliverer
    }
  end

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
      post :show, {
        format: :json,
        id: notification1.id,
        sub_service_request_id: ssr.id,
      }.with_indifferent_access
      assigns(:sub_service_request).should eq ssr
    end

    it 'should not set sub_service_request if sub_service_request_id was not sent' do
      session[:identity_id] = identity1.id
      post :show, {
        format: :json,
        id: notification1.id,
      }.with_indifferent_access
      assigns(:sub_service_request).should eq nil
    end

    it 'should send back the notification' do
      session[:identity_id] = identity1.id
      post :show, {
        format: :js,
        id: notification1.id,
      }.with_indifferent_access
      response.body.should eq '' # TODO: looks like nothing is getting sent back just yet
    end
  end

  describe 'POST new' do
    it 'should set recipient' do
      post :new, {
        format: :js,
        identity_id: identity1.id,
        sub_service_request_id: ssr.id,
      }.with_indifferent_access
      assigns(:recipient).should eq identity1
    end

    it 'should set sub service request' do
      post :new, {
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
      post :create, {
        format: :js,
        notification: {
          sub_service_request_id: ssr.id,
          originator_id: identity2.id,
        },
      }.with_indifferent_access

      notification = assigns(:notification)
      notification.id.should_not eq nil
      notification.sub_service_request.should eq ssr
      notification.originator.should eq identity2
    end

    it 'should create a new message' do
      session[:identity_id] = identity1.id
      get :create, {
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
      message.id.should_not eq nil
      message.notification.should eq notification
      message.sender.should eq identity1
      message.recipient.should eq identity2
      message.email.should eq 'abe.lincoln@whitehouse.gov'
      message.subject.should eq 'Emancipation'
      message.body.should eq 'Four score and seven years ago...'
    end

    it 'should set sub_service_request' do
      session[:identity_id] = identity1.id
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

      assigns(:sub_service_request).should eq ssr
    end

    it 'should set notifications' do
      session[:identity_id] = identity1.id
      get :create, {
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
      assigns(:notifications).should eq [new_notification] # TODO: should new_notification be in the list?
    end

    it 'should deliver the notification via email' do
      UserMailer.should_receive(:notification_received)

      session[:identity_id] = identity1.id
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
      session[:identity_id] = identity1.id
      post :user_portal_update, {
        format: :json,
        id: notification1.id,
      }.with_indifferent_access
      assigns(:notification).should eq notification1
    end

    it 'should create a new message' do
      session[:identity_id] = identity1.id
      post :user_portal_update, {
        format: :json,
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
      notification4.messages.count.should eq 1
      message = notification4.messages[0]
      message.id.should_not eq nil
      message.notification.should eq notification4
      message.sender.should eq identity1
      message.recipient.should eq identity2
      message.email.should eq 'abe.lincoln@whitehouse.gov'
      message.subject.should eq 'Emancipation'
      message.body.should eq 'Four score and seven years ago...'
    end

    it 'should set notifications' do
      session[:identity_id] = identity1.id
      post :user_portal_update, {
        format: :json,
        id: notification4.id,
        message: {
          from: identity1.id,
          to:   identity2.id,
          email:   'abe.lincoln@whitehouse.gov',
          subject: 'Emancipation',
          body:    'Four score and seven years ago...',
        },
      }.with_indifferent_access
      assigns(:notifications).should eq [ notification1, notification2, notification4 ]
    end

    it 'should deliver the notification via email' do
      UserMailer.should_receive(:notification_received)

      session[:identity_id] = identity1.id
      post :user_portal_update, {
        format: :json,
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
      session[:identity_id] = identity1.id
      post :admin_update, {
        format: :json,
        id: notification_with_ssr.id,
      }.with_indifferent_access
      assigns(:notification).should eq notification_with_ssr
    end

    it 'should create a new message' do
      session[:identity_id] = identity1.id
      post :admin_update, {
        format: :json,
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
      notification_with_ssr.messages.count.should eq 1
      message = notification_with_ssr.messages[0]
      message.id.should_not eq nil
      message.notification.should eq notification_with_ssr
      message.sender.should eq identity1
      message.recipient.should eq identity2
      message.email.should eq 'abe.lincoln@whitehouse.gov'
      message.subject.should eq 'Emancipation'
      message.body.should eq 'Four score and seven years ago...'
    end

    it 'should set sub_service_request' do
      session[:identity_id] = identity1.id
      post :admin_update, {
        format: :json,
        id: notification_with_ssr.id,
        message: {
          from: identity1.id,
          to:   identity2.id,
          email:   'abe.lincoln@whitehouse.gov',
          subject: 'Emancipation',
          body:    'Four score and seven years ago...',
        },
      }.with_indifferent_access
      assigns(:sub_service_request).should eq ssr
    end

    it 'should set notifications' do
      session[:identity_id] = identity1.id
      post :admin_update, {
        format: :json,
        id: notification_with_ssr.id,
        message: {
          from: identity1.id,
          to:   identity2.id,
          email:   'abe.lincoln@whitehouse.gov',
          subject: 'Emancipation',
          body:    'Four score and seven years ago...',
        },
      }.with_indifferent_access
      assigns(:notifications).should eq [ notification_with_ssr ]
    end

    it 'should deliver the notification via email' do
      UserMailer.should_receive(:notification_received)

      session[:identity_id] = identity1.id
      post :admin_update, {
        format: :json,
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
      session[:identity_id] = identity1.id
      post :mark_as_read, {
        format: :json,
        id: notification_with_ssr.id,
        sub_service_request_id: ssr.id,
        notifications: { },
      }
      assigns(:sub_service_request).should eq ssr
    end

    it 'should set notifications if sub_service_request_id is sent' do
      session[:identity_id] = identity1.id
      post :mark_as_read, {
        format: :json,
        id: notification_with_ssr.id,
        sub_service_request_id: ssr.id,
        notifications: { },
      }
      assigns(:notifications).should eq [ ]
    end

    it 'should not set sub_service_request if sub_service_request_id is not sent' do
      session[:identity_id] = identity1.id
      post :mark_as_read, {
        format: :json,
        id: notification_with_ssr.id,
        notifications: { },
      }
      assigns(:sub_service_request).should eq nil
    end

    it 'should set notifications if sub_service_request_id is not sent' do
      session[:identity_id] = identity1.id
      post :mark_as_read, {
        format: :json,
        id: notification_with_ssr.id,
        notifications: { },
      }
      assigns(:notifications).should eq [ notification1, notification2 ]
    end

    it 'should set the read attribute on all notifications that are passed in' do
      session[:identity_id] = identity1.id
      post :mark_as_read, {
        format: :json,
        id: notification_with_ssr.id,
        notifications: { notification1 => true, notification2  => false },
      }

      user_notification1.reload
      user_notification2.reload
      user_notification3.reload

      user_notification1.read.should eq true
      user_notification2.read.should eq false
      user_notification3.read.should eq nil
    end
  end
end
