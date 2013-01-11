require 'mysql2'
require 'import'

db = Mysql2::Client.new(
    :host => 'localhost',
    :database => 'notifications',
    :username => 'notify',
    :password => 'notify')

ActiveRecord::Base.establish_connection(
    :adapter => 'mysql2',
    :host => 'localhost',   
    :database => 'sparc_development',  
    :username => 'sparc',
    :password => 'sparc',
) 

Notification.all.each     { |m| m.destroy }
Message.all.each          { |m| m.destroy }
UserNotification.all.each { |m| m.destroy }
Question.all.each         { |m| m.destroy }

Message.import = true

def update_timestamps(record, row)
  record.record_timestamps = false
  record.update_attributes(
      created_at: row['created_at'],
      updated_at: row['updated_at'])
  record.save!
end

# {"id"=>1, "originator"=>"87d1220c5abf9f9608121672be7956b1",
# "created_at"=>2012-03-14 21:06:01 -0400, "updated_at"=>2012-03-14
# 21:07:05 -0400, "sr_id"=>1863, "ssr_id"=>1}
puts "Importing notifications"
notifications = { }
db.query('select * from notifications').each do |row|
  identity = Identity.find_by_obisid(row['originator'])
  if not identity then
    puts "WARNING: importing notification for unknown originator #{row['originator']}"
  end

  sr = ServiceRequest.find_by_id(row['sr_id'])
  if sr then
    ssr = SubServiceRequest.find_by_service_request_id_and_ssr_id(sr.id, row['ssr_id'])
    if not ssr then
      puts "WARNING: importing notification for unknown sub service request #{row['ssr_id']} (on service request #{row['sr_id']}"
    end
  else
    puts "WARNING: importing notification for unknown service request #{row['sr_id']}"
  end

  record = notifications[row['id']] = Notification.create(
      originator_id: identity.try(:id),
      sub_service_request_id: ssr.try(:id),
      service_request_id: sr.try(:id))
  update_timestamps(record, row)
end

# {"id"=>22, "to"=>"87d1220c5abf9f9608121672be84bfa6",
# "email"=>"scoma@musc.edu", "from"=>"ca1a5b6a66a7eb7fd608d2f671c817fe",
# "subject"=>"hey", "body"=>"howdy", "read"=>nil,
# "created_at"=>2012-11-06 14:47:22 -0500, "updated_at"=>2012-11-06
# 15:59:25 -0500, "notification_id"=>13}
puts "Importing messages"
db.query('select * from messages').each do |row|
  notification = notifications.fetch(row['notification_id'])

  from = Identity.find_by_obisid(row['from'])
  if not from then
    puts "WARNING: importing message with unknown 'from' #{row['from']}"
  end

  to = Identity.find_by_obisid(row['to'])
  if not to then
    puts "WARNING: importing message with unknown 'to' #{row['to']}"
  end

  record = Message.create(
      notification_id: notification.id,
      to: to.try(:id),
      from: from.try(:id),
      email: row['email'],
      subject: row['subject'],
      body: row['body'])
  update_timestamps(record, row)
end

# {"id"=>26, "uid"=>"ca1a5b6a66a7eb7fd608d2f671c817fe",
# "created_at"=>2012-11-06 14:47:22 -0500, "updated_at"=>2012-11-06
# 14:47:22 -0500, "notification_id"=>13}
puts "Importing user notifications"
db.query('select * from user_notifications').each do |row|
  notification = notifications.fetch(row['notification_id'])

  identity = Identity.find_by_obisid(row['uid'])
  if not identity then
    puts "WARNING: importing message with unknown 'identity' #{row['identity']}"
  end

  record = UserNotification.create(
      identity_id: identity.try(:id),
      notification_id: notification.id,
      read: true)
  update_timestamps(record, row)
end

# {"id"=>6, "to"=>"glennj@musc.edu", "from"=>"catesa@musc.edu",
# "question"=>"test", "created_at"=>2012-10-25 16:03:28 -0400,
# "updated_at"=>2012-10-25 16:03:28 -0400}
puts "Importing questions"
db.query('select * from questions').each do |row|
  record = Question.create(
      from: row['from'],
      to: row['to'],
      body: row['question'])
  update_timestamps(record, row)
end

