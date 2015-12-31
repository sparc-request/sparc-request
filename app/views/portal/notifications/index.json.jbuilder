json.(@notifications) do |notification|
  json.id notification.id
  json.read notification.read_by_user_id? @user.id
  json.from notification.get_other_user(@user.id).full_name
  json.subject subject_line(notification.messages.last)
  json.time format_datetime(notification.messages.last.created_at)
end