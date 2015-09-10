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

RSpec.describe Portal::NotificationsHelper do
  include Portal::NotificationsHelper

  context '#read_unread' do
    before { allow_message_expectations_on_nil }

    it 'should return read if the notification has no unread messages' do
      message      = double('Message', read: nil, from: 123)
      notification = double('Notification', messages: [message, message])
      user         = double('User', id: 1234)
      allow(message.read).to receive(:blank?).and_return(false)
      expect(read_unread(notification, user)).to eq 'read'
    end

    it 'should return unread if the notification has unread messages' do
      message      = double('Message', read: nil, from: 123)
      message2     = double('Message', read: true)
      notification = double('Notification', messages: [message, message])
      user         = double('User', id: 1234)
      allow(message.read).to receive(:blank?).and_return(true)
      expect(read_unread(notification, user)).to eq 'unread'
    end
  end

  # TODO: need to use FactoryGirl instead of a mock to get this test to pass
  # context :received_at do
  #   it 'should return a date when passed a datetime' do
  #     notification = mock('Notification', messages: [mock('Message', created_at: '2011-12-01 00:00:00')])
  #     received_at(notification).should eq '12/01/2011'
  #   end
  # end

  context '#link_to_notification' do
    it 'should return a path to a specific notification' do
      notification = double('Notification', id: 1)
      expect(link_to_notification(notification)).to eq "window.location = 'portal/notifications/1'"
    end
  end

  context '#message_hide_or_show' do
    it "should hide or show a message depending on how many there are" do
      notification = double('Notification', messages: [1,2])
      expect(message_hide_or_show(notification, 10)).to eq("hidden")
    end

    it "should hide or show a message depending on how many there are" do
      notification = double('Notification', messages: [1,2])
      expect(message_hide_or_show(notification, 1)).to eq("shown")
    end
  end
end
