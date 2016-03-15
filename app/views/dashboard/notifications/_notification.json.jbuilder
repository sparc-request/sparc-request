json.(notification)

json.id notification.id
json.table @table
json.read notification.read_by? @user
json.user notification.get_user_other_than(@user).full_name
json.subject notification_subject_line(notification)
json.time notification_time_display(notification)