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

describe Portal::NotificationsHelper do
  include Portal::NotificationsHelper

  context :read_unread do
    before { allow_message_expectations_on_nil }

    it 'should return read if the notification has no unread messages' do
      message = mock('Message', :read => nil, :from => 123)
      notification = mock('Notification', :messages => [message, message])
      user = mock('User', :id => 1234)
      message.read.stub!(:blank?).and_return(false)
      read_unread(notification, user).should eq 'read'
    end

    it 'should return unread if the notification has unread messages' do
      message = mock('Message', :read => nil, :from => 123)
      message2 = mock('Message', :read => true)
      notification = mock('Notification', :messages => [message, message])
      user = mock('User', :id => 1234)
      message.read.stub!(:blank?).and_return(true)
      read_unread(notification, user).should eq 'unread'
    end
  end

  # TODO: need to use FactoryGirl instead of a mock to get this test to pass
  # context :received_at do
  #   it 'should return a date when passed a datetime' do
  #     notification = mock('Notification', :messages => [mock('Message', :created_at => '2011-12-01 00:00:00')])
  #     received_at(notification).should eq '12/01/2011'
  #   end
  # end

  context :link_to_notification do
    it 'should return a path to a specific notification' do
      notification = mock('Notification', :id => 1)
      link_to_notification(notification).should eq "window.location = 'portal/notifications/1'"
    end
  end

  context :unread_notifications do
    it "should return a count of unread notifications" do
      note_1 = mock('Notification', :messages => [mock('Message', :read => true), mock('Message', :read => false)])
      note_2 = mock('Notification', :messages => [mock('Message', :read => true)])
      note_3 = mock('Notification', :messages => [mock('Message', :read => false)])
      Notification.stub!(:find_by_user_id).with(1).and_return([note_1, note_2, note_3])
      unread_notifications(1).should eq(2)
    end
  end

  context :message_hide_or_show do
    it "should hide or show a message depending on how many there are" do
      notification = mock('Notification', :messages => [1,2])
      message_hide_or_show(notification, 10).should eq("hidden")
    end

    it "should hide or show a message depending on how many there are" do
      notification = mock('Notification', :messages => [1,2])
      message_hide_or_show(notification, 1).should eq("shown")
    end
  end
end
