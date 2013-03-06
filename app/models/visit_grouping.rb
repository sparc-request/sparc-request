class VisitGrouping < ActiveRecord::Base
  belongs_to :arm
  belongs_to :line_item

  has_many :visits

  attr_accessible :subject_count
end

