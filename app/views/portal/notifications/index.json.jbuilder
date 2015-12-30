json.(@notifications) do |notification|
  json.id notification.id
  json.open read_unread_display(notification, @user.id)
  json.from notification.messages.last.sender.full_name
  json.subject notification.messages.last.subject
  json.preview notification.messages.last.body
  json.time format_datetime(notification.messages.last.created_at)
end