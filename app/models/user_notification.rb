class UserNotification < ActiveRecord::Base
  audited

  belongs_to :notification
  belongs_to :user

  attr_accessible :identity_id
  attr_accessible :notification_id
  attr_accessible :read
end
