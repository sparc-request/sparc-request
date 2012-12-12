class Study < Protocol

  validates :funding_status, :presence => true
  
  def classes
    return [ 'project' ] # for backward-compatibility
  end

  def populate_for_edit
    self.build_research_types_info           unless self.research_types_info
    self.build_human_subjects_info           unless self.human_subjects_info
    self.build_vertebrate_animals_info       unless self.vertebrate_animals_info
    self.build_investigational_products_info unless self.investigational_products_info
    self.build_ip_patents_info               unless self.ip_patents_info
    self.setup_study_types
    self.setup_impact_areas
    self.setup_affiliations
  end
  
  def setup_study_types
    position = 1
    obj_names = StudyType::TYPES.map{|k,v| k}
    obj_names.each do |obj_name|
      study_type = study_types.detect{|obj| obj.name == obj_name}
      study_type = study_types.build(:name => obj_name, :new => true) unless study_type
      study_type.position = position
      position += 1
    end

    study_types.sort!{|a, b| a.position <=> b.position}
  end

  def setup_impact_areas
    position = 1
    obj_names = ImpactArea::TYPES.map{|k,v| k}
    obj_names.each do |obj_name|
      impact_area = impact_areas.detect{|obj| obj.name == obj_name}
      impact_area = impact_areas.build(:name => obj_name, :new => true) unless impact_area
      impact_area.position = position
      position += 1
    end

    impact_areas.sort!{|a, b| a.position <=> b.position}
  end
  
  def setup_affiliations
    position = 1
    obj_names = Affiliation::TYPES.map{|k,v| k}
    obj_names.each do |obj_name|
      affiliation = affiliations.detect{|obj| obj.name == obj_name}
      affiliation = affiliations.build(:name => obj_name, :new => true) unless affiliation
      affiliation.position = position
      position += 1
    end

    affiliations.sort!{|a, b| a.position <=> b.position}
  end


end

class Study
  include JsonSerializable
  json_serializer :obisentity, Protocol::ObisEntitySerializer
  json_serializer :relationships, Protocol::RelationshipsSerializer
  json_serializer :obissimple, ObisSimpleSerializer
  json_serializer :simplerelationships, ObisSimpleRelationshipsSerializer
end

