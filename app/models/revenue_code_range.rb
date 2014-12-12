class RevenueCodeRange < ActiveRecord::Base
  has_many :services
  belongs_to :organization, :foreign_key => :applied_org_id
  attr_accessible :applied_org_id, :from, :percentage, :to, :vendor, :version
end
