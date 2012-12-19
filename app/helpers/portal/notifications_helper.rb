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
    notification.user_notifications_for_current_user(@user).order('created_at DESC').first.created_at.strftime('%D')
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
