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

module Portal::NotificationsHelper
  def read_unread notification, user
    begin
      unless notification.messages.last.from == user.id
        notification.messages.select{ |message| message.read.blank? }.empty? ? 'read' : 'unread'
      else
        'read'
      end
    rescue
      'read'
    end
  end

  def received_at notification
    timestamp = notification.user_notifications_for_current_user(@user).order('created_at DESC').first.created_at
    if timestamp.strftime('%D') == Date.today.strftime('%D')
      timestamp.strftime('%l:%M%p')
    else
      timestamp.strftime('%D')
    end
  end

  def link_to_notification notification
    "window.location = 'portal/notifications/#{notification.id}'"
  end

  def link_to_new_notification user_id
    new_notification_path(:user_id => user_id)
  end

  def unread_notifications user_id
    Notification.find_by_user_id(user_id).map do |note|
      note.messages.reject {|m| m.read }.length
    end.inject(0){|a,b|a+b}
  end

  def message_hide_or_show(notification, index)
    notification.messages.length - 1 == index ? 'shown' : 'hidden'
  end

end
