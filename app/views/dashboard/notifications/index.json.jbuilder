json.(@notifications) do |notification|
  json.id       notification.id
  json.table    @table
  json.read     notification.read_by? current_user
  json.user     (@table == 'shared' ? notification.originator : notification.get_user_other_than(current_user)).full_name
  json.subject  notification_subject_line(notification, @table)
  json.time     notification_time_display(notification)
end
