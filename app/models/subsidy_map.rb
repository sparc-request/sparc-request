class SubsidyMap < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :organization
  has_many :excluded_funding_sources

  attr_accessible :organization_id
  attr_accessible :max_dollar_cap
  attr_accessible :max_percentage
end

class SubsidyMap::ObisEntitySerializer
  def as_json(map, options = nil)
    h = {
      'max_percentage'            => map.max_percentage ? map.max_percentage.to_f : nil,
      'max_dollar_cap'            => map.max_dollar_cap ? map.max_dollar_cap.to_f : nil,
      'excluded_funding_sources'  => map.excluded_funding_sources.as_json(options),
    }
    return h
  end

  def update_from_json(map, h, options = nil)
    map.update_attributes!(
        max_percentage:            h['max_percentage'],
        max_dollar_cap:            h['max_dollar_cap'],
    )

    # Delete all excluded funding sources for the subsidy map; they will
    # be re-created in the next step.
    map.excluded_funding_sources.each do |excluded_funding_source|
      excluded_funding_source.destroy()
    end

    # Create a new excluded funding source for each one that is passed in.
    h['excluded_funding_sources'].each do |funding_source|
      excluded_funding_source = map.excluded_funding_sources.create()
      excluded_funding_source.update_from_json(funding_source, options)
    end
  end
end

class SubsidyMap
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
end

