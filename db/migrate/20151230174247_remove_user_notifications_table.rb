# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class RemoveUserNotificationsTable < ActiveRecord::Migration

  class UserNotification < ActiveRecord::Base
  end

  def self.up

    add_column :notifications, :subject, :string
    add_column :notifications, :other_user_id, :integer
    add_column :notifications, :read_by_originator, :boolean
    add_column :notifications, :read_by_other_user, :boolean

    Notification.all.each do |notification|
      messages = notification.messages
      unless messages.empty?
        last_message = messages.last
        notification.update_column(:subject, last_message.subject)

        other_user_id = ([last_message.to, last_message.from] - [notification.originator_id]).first
        notification.update_column(:other_user_id, other_user_id)
      end

      orig_user_notifications = UserNotification.where(identity_id: notification.originator_id, notification_id: notification.id)
      unless orig_user_notifications.empty?
        orig_user_notification = orig_user_notifications.first
        notification.update_column(:read_by_originator, orig_user_notification.read)
      end

      other_user_notifications = UserNotification.where(identity_id: notification.other_user_id, notification_id: notification.id)
      unless other_user_notifications.empty?
        other_user_notification = other_user_notifications.first
        notification.update_column(:read_by_other_user, other_user_notification.read)
      end
    end

    remove_column :messages, :subject, :string
    drop_table :user_notifications
  end

  def self.down

    create_table :user_notifications do |t|
      t.integer :identity_id
      t.integer :notification_id
      t.boolean :read
      t.timestamps
    end

    add_column :messages, :subject, :string

    Notification.all.each do |notification|
      UserNotification.create(identity_id: notification.originator_id, notification_id: notification.id, read: notification.read_by_originator)
      UserNotification.create(identity_id: notification.other_user_id, notification_id: notification.id, read: notification.read_by_other_user)

      unless notification.messages.empty?
        notification.messages.update_all(subject: notification.subject)
      end
    end

    remove_column :notifications, :read_by_originator, :boolean
    remove_column :notifications, :read_by_other_user, :boolean
    remove_column :notifications, :other_user_id, :integer
    remove_column :notifications, :subject, :string
  end

end
