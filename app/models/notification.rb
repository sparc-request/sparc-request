class Notification < ActiveRecord::Base
  belongs_to :originator, :class_name => "Identity"
  belongs_to :sub_service_request

  has_many :messages
  has_many :user_notifications

  attr_accessible :sub_service_request_id
  attr_accessible :originator_id

  def user_notifications_for_current_user identity
    self.user_notifications.where(:identity_id => identity.id)
  end
end
