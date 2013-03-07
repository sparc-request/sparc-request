class VisitGrouping < ActiveRecord::Base
  belongs_to :arm
  belongs_to :line_item

  has_many :visits, :dependent => :destroy, :order => 'position'

  attr_accessible :arm_id
  attr_accessible :line_item_id
  attr_accessible :subject_count
end

