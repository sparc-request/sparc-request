class UserNotification < ActiveRecord::Base
  belongs_to :notification
  belongs_to :user

  attr_accessible :identity_id
  attr_accessible :notification_id
  attr_accessible :read
end
