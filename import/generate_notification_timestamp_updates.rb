require 'pp'

def update_timestamps(klass, table)
  klass.all.each do |notification|
    puts "UPDATE #{table} SET created_at='#{notification.created_at.to_s}' WHERE id='#{notification.id}';"
    puts "UPDATE #{table} SET updated_at='#{notification.updated_at.to_s}' WHERE id='#{notification.id}';"
  end
end

update_timestamps(Notification, 'notifications')
update_timestamps(Message, 'messages')
update_timestamps(UserNotification, 'user_notifications')
update_timestamps(Question, 'questions')
