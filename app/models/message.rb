class Message < ActiveRecord::Base
  audited

  belongs_to :notification
  belongs_to :sender, :class_name => 'Identity', :foreign_key => 'from'
  belongs_to :recipient, :class_name => 'Identity', :foreign_key => 'to'

  after_save :create_user_notifications

  attr_accessible :notification_id
  attr_accessible :to
  attr_accessible :from
  attr_accessible :email
  attr_accessible :subject
  attr_accessible :body

  validates :to, :presence => true
  validates :from, :presence => true

  # Simple way to skip the after_save callback for the import process
  class << self
    @import = false
    attr_accessor :import
  end

  # TODO: do we really want to create user notifications every time we
  # modify a Message?
  def create_user_notifications
    return if self.class.import
    self.notification.user_notifications.create(:identity_id => self.to)
    self.notification.user_notifications.create(:identity_id => self.from, :read => true)
  end
end

