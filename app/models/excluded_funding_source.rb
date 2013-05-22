class ExcludedFundingSource < ActiveRecord::Base
  audited

  belongs_to :subsidy_map

  attr_accessible :subsidy_map_id, :funding_source
end
