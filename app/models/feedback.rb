class Feedback < ActiveRecord::Base
  attr_accessible :email, :message

  validates :message, :presence => true
end
