class ExcludedFundingSource < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :subsidy_map

  attr_accessible :subsidy_map_id, :funding_source
end

class ExcludedFundingSource::ObisEntitySerializer
  def as_json(source, options = nil)
    return source.funding_source
  end

  def update_from_json(excluded_funding_source, funding_source, options = nil)
    excluded_funding_source.update_attributes!(
        funding_source: funding_source)
  end
end

class ExcludedFundingSource
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
end

