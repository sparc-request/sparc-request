class VisitGroup < ActiveRecord::Base
  belongs_to :arm
  has_many :visits
  attr_accessible :name
  attr_accessible :position
  acts_as_list :scope => :arm


end
