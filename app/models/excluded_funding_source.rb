class ExcludedFundingSource < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :subsidy_map

  attr_accessible :subsidy_map_id, :funding_source
end
