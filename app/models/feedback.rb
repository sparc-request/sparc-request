class Feedback < ActiveRecord::Base
  audited

  attr_accessible :email, :message

  validates :message, :presence => true
end
