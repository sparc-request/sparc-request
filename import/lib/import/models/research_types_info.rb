class ResearchTypesInfo::ObisEntitySerializer
  def as_json(research_types, options = nil)
    h = { }

    h = {
      'human_subjects'            => research_types.human_subjects,
      'vertebrate_animals'        => research_types.vertebrate_animals,
      'investigational_products'  => research_types.investigational_products,
      'ip_patents'                => research_types.ip_patents,
    }

    h.delete_if { |k, v| v.blank? }

    return h
  end

  def update_from_json(research_types, h, options = nil)
    research_types.update_attributes!(
        human_subjects:              h['human_subjects'],
        vertebrate_animals:          h['vertebrate_animals'],
        investigational_products:    h['investigational_products'],
        ip_patents:                  h['ip_patents']
    )
  end
end

class ResearchTypesInfo
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
end

