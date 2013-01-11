class SubsidyMap < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :organization
  has_many :excluded_funding_sources

  attr_accessible :organization_id
  attr_accessible :max_dollar_cap
  attr_accessible :max_percentage
end
