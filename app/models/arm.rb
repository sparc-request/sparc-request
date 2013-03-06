class Arm < ActiveRecord::Base
  has_many :visit_groupings
  has_many :line_items, :through => :visit_groupings
end
