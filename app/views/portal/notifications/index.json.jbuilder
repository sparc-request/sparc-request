json.(@notifications) do |notification|
  json.id notification.id
  json.read notification.read_by_user_id @user.id
  json.from notification.messages.last.sender.full_name
  json.subject notification.messages.last.subject
  json.preview notification.messages.last.body
  json.time format_datetime(notification.messages.last.created_at)
end