class Arm < ActiveRecord::Base
  belongs_to :service_request

  has_many :visit_groupings, :dependent => :destroy
  has_many :line_items, :through => :visit_groupings

  attr_accessible :name
  attr_accessible :visit_count
  attr_accessible :subject_count
end
