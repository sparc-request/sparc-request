class Protocol < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  has_many :study_types, :dependent => :destroy
  has_one :research_types_info, :dependent => :destroy
  has_one :human_subjects_info, :dependent => :destroy
  has_one :vertebrate_animals_info, :dependent => :destroy
  has_one :investigational_products_info, :dependent => :destroy
  has_one :ip_patents_info, :dependent => :destroy
  has_many :project_roles, :dependent => :destroy
  has_many :identities, :through => :project_roles
  has_many :service_requests
  has_many :affiliations, :dependent => :destroy
  has_many :impact_areas, :dependent => :destroy

  attr_accessible :obisid
  attr_accessible :identity_id
  attr_accessible :next_ssr_id
  attr_accessible :short_title
  attr_accessible :title
  attr_accessible :sponsor_name
  attr_accessible :brief_description
  attr_accessible :indirect_cost_rate
  attr_accessible :study_phase
  attr_accessible :udak_project_number
  attr_accessible :funding_rfa
  attr_accessible :funding_status
  attr_accessible :potential_funding_source
  attr_accessible :potential_funding_start_date
  attr_accessible :funding_source
  attr_accessible :funding_start_date
  attr_accessible :federal_grant_serial_number
  attr_accessible :federal_grant_title
  attr_accessible :federal_grant_code_id
  attr_accessible :federal_non_phs_sponsor
  attr_accessible :federal_phs_sponsor
  attr_accessible :potential_funding_source_other
  attr_accessible :funding_source_other
  attr_accessible :research_types_info_attributes
  attr_accessible :human_subjects_info_attributes
  attr_accessible :vertebrate_animals_info_attributes
  attr_accessible :investigational_products_info_attributes
  attr_accessible :ip_patents_info_attributes
  attr_accessible :study_types_attributes
  attr_accessible :impact_areas_attributes
  attr_accessible :affiliations_attributes
  attr_accessible :project_roles_attributes
  attr_accessible :requester_id

  attr_accessor :requester_id
  
  accepts_nested_attributes_for :research_types_info
  accepts_nested_attributes_for :human_subjects_info
  accepts_nested_attributes_for :vertebrate_animals_info
  accepts_nested_attributes_for :investigational_products_info
  accepts_nested_attributes_for :ip_patents_info
  accepts_nested_attributes_for :study_types, :allow_destroy => true
  accepts_nested_attributes_for :impact_areas, :allow_destroy => true
  accepts_nested_attributes_for :affiliations, :allow_destroy => true
  accepts_nested_attributes_for :project_roles, :allow_destroy => true

  before_validation :assign_obisid, :on => :create

  validates :short_title, :presence => true
  validates :title, :presence => true
  validate  :requester_included, :on => :create
  validate  :pi_exists
  validate  :validate_funding_source
  validate  :validate_proxy_rights

  def validate_funding_source
    if self.funding_status == "funded" && self.funding_source.blank?
      errors.add(:funding_source, "You must select a funding source")
    elsif self.funding_status == "pending_funding" && self.potential_funding_source.blank?
      errors.add(:potential_funding_source, "You must select a potential funding source")
    end
  end

  def validate_proxy_rights
    errors.add(:base, "All users must be assigned a proxy right") unless self.project_roles.map(&:project_rights).find_all(&:nil?).empty?
  end

  def principal_investigators
    project_roles.reject{|pr| pr.role != 'pi'}.map(&:identity)
  end

  def emailed_associated_users
    project_roles.reject {|pr| pr.project_rights == 'none'}
  end

  def requester_included
    errors.add(:base, "You must add yourself as an authorized user") unless project_roles.map(&:identity_id).include?(requester_id.to_i)
  end

  def pi_exists
    errors.add(:base, "You must add a PI to the study/project") unless project_roles.map(&:role).include? 'pi'
  end

  def role_for identity
    project_roles.detect{|pr| pr.identity_id == identity.id}.try(:role)
  end
  
  def role_other_for identity
    project_roles.detect{|pr| pr.identity_id == identity.id}.try(:role)
  end

  def subspecialty_for identity
    project_roles.detect{|pr| pr.identity_id == identity.id}.try(:subspecialty)
  end

  def all_child_sub_service_requests
    arr = []
    self.service_requests.each do |sr|
      sr.sub_service_requests.each do |ssr|
        arr << ssr
      end
    end
    
    arr
  end


  def display_funding_source_value
    if funding_status == "funded"
      if funding_source == "internal"
        "#{FUNDING_SOURCES.key funding_source}: #{funding_source_other}"
      else
        "#{FUNDING_SOURCES.key funding_source}"
      end
    elsif funding_status == "pending_funding"
      if potential_funding_source == "internal"
        "#{POTENTIAL_FUNDING_SOURCES.key potential_funding_source}: #{potential_funding_source_other}"
      else
        "#{POTENTIAL_FUNDING_SOURCES.key potential_funding_source}"
      end
    end
  end
  
  def funding_source_based_on_status
    funding_source = case self.funding_status
      when 'pending_funding' then self.potential_funding_source
      when 'funded' then self.funding_source
      else raise ArgumentError, "Invalid funding status: #{self.funding_status.inspect}"
      end

    return funding_source
  end

  include Entity
end

class Protocol::ObisEntitySerializer < Entity::ObisEntitySerializer
  def affiliations(protocol)
    h = { }
    protocol.affiliations.each do |affiliation|
      h[affiliation.name] = true
    end
    return h
  end

  def impact_areas(protocol)
    h = { }
    protocol.impact_areas.each do |impact_area|
      h[impact_area.name] = true
    end
    return h
  end

  def study_types(protocol)
    h = { }
    protocol.study_types.each do |study_type|
      h[study_type.name] = true
    end
    return h
  end

  def as_json(protocol, options = nil)
    h = super(protocol, options)

    h['identifiers'].update(
      'project_id'                    => protocol.id.to_s,
    )

    h['attributes'].update(
      'type'                           => protocol.type().downcase,
      'friendly_id'                    => protocol.id.to_s,
      'indirect_cost_rate'             => protocol.indirect_cost_rate.to_f,
      'affiliations'                   => affiliations(protocol),
      'impact_areas'                   => impact_areas(protocol),
      'research_types'                 => protocol.research_types_info.as_json(options),
      'study_types'                    => study_types(protocol),
    )

    optional_attributes = {
      'brief_description'              => protocol.brief_description,
      'federal_grant_code_id'          => protocol.federal_grant_code_id,
      'federal_grant_serial_number'    => protocol.federal_grant_serial_number,
      'federal_grant_title'            => protocol.federal_grant_title,
      'federal_non_phs_sponsor'        => protocol.federal_non_phs_sponsor,
      'federal_phs_sponsor'            => protocol.federal_phs_sponsor,
      'funding_rfa'                    => protocol.funding_rfa,
      'funding_status'                 => protocol.funding_status,
      'next_ssr_id'                    => protocol.next_ssr_id,
      'potential_funding_source'       => protocol.potential_funding_source,
      'potential_funding_source_other' => protocol.potential_funding_source_other,
      'potential_funding_start_date'   => protocol.potential_funding_start_date.try(:strftime, '%Y-%m-%d'),
      'funding_source'                 => protocol.funding_source,
      'funding_source_other'           => protocol.funding_source_other,
      'funding_start_date'             => protocol.funding_start_date.try(:strftime, '%Y-%m-%d'),
      'short_title'                    => protocol.short_title,
      'sponsor_name'                   => protocol.sponsor_name,
      'study_phase'                    => protocol.study_phase,
      'title'                          => protocol.title,
      'udak_project_number'            => protocol.udak_project_number,
 
      'hr_number'                      => protocol.human_subjects_info.try(:hr_number),
      'irb_approval_date'              => protocol.human_subjects_info.try(:irb_approval_date).try(:strftime, '%Y-%m-%d'),
      'irb_expiration_date'            => protocol.human_subjects_info.try(:irb_expiration_date).try(:strftime, '%Y-%m-%d'),
      'irb_of_record'                  => protocol.human_subjects_info.try(:irb_of_record),
      'pro_number'                     => protocol.human_subjects_info.try(:pro_number),
      'submission_type'                => protocol.human_subjects_info.try(:submission_type),
 
      'ide_number'                     => protocol.investigational_products_info.try(:ide_number),
      'ind_number'                     => protocol.investigational_products_info.try(:ind_number),
      'ind_on_hold'                    => protocol.investigational_products_info.try(:ind_on_hold),
 
      'inventors'                      => protocol.ip_patents_info.try(:inventors),
      'patent_number'                  => protocol.ip_patents_info.try(:patent_number),
 
      'iacuc_approval_date'            => protocol.vertebrate_animals_info.try(:iacuc_approval_date).try(:strftime, '%Y-%m-%d'),
      'iacuc_expiration_date'          => protocol.vertebrate_animals_info.try(:iacuc_expiration_date).try(:strftime, '%Y-%m-%d'),
      'iacuc_number'                   => protocol.vertebrate_animals_info.try(:iacuc_number),
      'name_of_iacuc'                  => protocol.vertebrate_animals_info.try(:name_of_iacuc),
    }

    optional_attributes.delete_if { |k, v| v.blank? }

    h['attributes'].update(optional_attributes)

    return h
  end

  def set_date_if_not_blank(model, field, attribute)
    if not attribute.blank? then
      model.update_attribute(field, Time.parse(attribute))
    end
  end

  def update_affiliations_from_json(entity, attributes, options)
    entity.affiliations.each do |affiliation|
      affiliation.destroy()
    end

    (attributes['affiliations'] || [ ]).each do |name, present|
      if present then
        affiliation = entity.affiliations.create(name: name)
      end
    end
  end

  def update_impact_areas_from_json(entity, attributes, options)
    entity.impact_areas.each do |impact_area|
      impact_area.destroy()
    end

    (attributes['impact_areas'] || [ ]).each do |name, present|
      if present then
        impact_area = entity.impact_areas.create(name: name)
      end
    end
  end

  def update_study_types_from_json(entity, attributes, options)
    entity.study_types.each do |study_type|
      study_type.destroy()
    end

    (attributes['study_types'] || [ ]).each do |name, present|
      if present then
        study_type = entity.study_types.create(name: name)
      end
    end
  end

  def update_research_types_from_json(entity, attributes, options)
    entity.build_research_types_info() if not entity.research_types_info
    entity.research_types_info.update_from_json(
        attributes['research_types'] || { },
        options)
  end

  def update_human_subjects_from_json(entity, attributes, research_types, options)
    if research_types and research_types['human_subjects'] then
      entity.build_human_subjects_info() if not entity.human_subjects_info
      entity.human_subjects_info.update_attributes!(
          hr_number:              attributes['hr_number'],
          irb_of_record:          attributes['irb_of_record'],
          pro_number:             attributes['pro_number'],
          submission_type:        attributes['submission_type'])
      set_date_if_not_blank(
          entity.human_subjects_info,
          :irb_approval_date,
          attributes['irb_approval_date'])
      set_date_if_not_blank(
          entity.human_subjects_info,
          :irb_expiration_date,
          attributes['irb_expiration_date'])
    end
  end

  def update_investigational_products_from_json(entity, attributes, research_types, options)
    if research_types and research_types['investigational_products'] then
      entity.build_investigational_products_info() if not entity.investigational_products_info
      entity.investigational_products_info.update_attributes!(
          ide_number:             attributes['ide_number'],
          ind_number:             attributes['ind_number'],
          ind_on_hold:            attributes['ind_on_hold'])
    end
  end

  def update_ip_patents_from_json(entity, attributes, research_types, options)
    if research_types and research_types['ip_patents'] then
      entity.build_ip_patents_info() if not entity.ip_patents_info
      entity.ip_patents_info.update_attributes!(
          inventors:              attributes['inventors'],
          ip_patents:             attributes['ip_patents'],
          patent_number:          attributes['patent_number'])
    end
  end

  def update_vertebrate_animals_from_json(entity, attributes, research_types, options)
    if research_types and research_types['vertebrate_animals'] then
      entity.build_vertebrate_animals_info() if not entity.vertebrate_animals_info
      entity.vertebrate_animals_info.update_attributes!(
          iacuc_number:           attributes['iacuc_number'],
          name_of_iacuc:          attributes['name_of_iacuc'])
      set_date_if_not_blank(
          entity.vertebrate_animals_info,
          :iacuc_approval_date,
          attributes['iacuc_approval_date'])
      set_date_if_not_blank(
          entity.vertebrate_animals_info,
          :iacuc_expiration_date,
          attributes['iacuc_expiration_date'])
    end
  end

  def update_attributes_from_json(entity, h, options = nil)
    super(entity, h, options)

    identifiers = h['identifiers']
    attributes = h['attributes']
    research_types = attributes['research_types']

    if identifiers['project_id'] and entity.id != Integer(identifiers['project_id']) then
      raise ArgumentError, "Cannot change project id from #{entity.id.inspect} to #{identifiers['project_id'].inspect}"
    end

    entity.attributes = {
        :indirect_cost_rate             => attributes['indirect_cost_rate'],
        :brief_description              => attributes['brief_description'],
        :federal_grant_code_id          => attributes['federal_grant_code_id'],
        :federal_grant_serial_number    => attributes['federal_grant_serial_number'],
        :federal_grant_title            => attributes['federal_grant_title'],
        :federal_non_phs_sponsor        => attributes['federal_non_phs_sponsor'],
        :federal_phs_sponsor            => attributes['federal_phs_sponsor'],
        :funding_rfa                    => attributes['funding_rfa'],
        :funding_status                 => attributes['funding_status'],
        :next_ssr_id                    => attributes['next_ssr_id'],
        :potential_funding_source       => attributes['potential_funding_source'],
        :potential_funding_source_other => attributes['potential_funding_source_other'],
        :potential_funding_start_date   => attributes['potential_funding_start_date'],
        :funding_source                 => attributes['funding_source'],
        :funding_source_other           => attributes['funding_source_other'],
        :funding_start_date             => attributes['funding_start_date'],
        :short_title                    => attributes['short_title'],
        :sponsor_name                   => attributes['sponsor_name'],
        :study_phase                    => attributes['study_phase'],
        :title                          => attributes['title'],
        :udak_project_number            => attributes['udak_project_number'],
    }
    entity.save!(:validate => false)

    update_affiliations_from_json(entity, attributes, options)
    update_impact_areas_from_json(entity, attributes, options)
    update_research_types_from_json(entity, attributes, options)
    update_study_types_from_json(entity, attributes, options)

    update_human_subjects_from_json(entity, attributes, research_types, options)
    update_investigational_products_from_json(entity, attributes, research_types, options)
    update_ip_patents_from_json(entity, attributes, research_types, options)
    update_vertebrate_animals_from_json(entity, attributes, research_types, options)
  end

  def self.create_from_json(entity_class, h, options = nil)
    obj = entity_class.new

    if h['identifiers'] and h['identifiers']['project_id'] then
      obj.id = h['identifiers']['project_id']
    end

    obj.update_from_json(h, options)

    return obj
  end

 
end

class Protocol
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
  json_serializer :relationships, RelationshipsSerializer
  json_serializer :obissimple, ObisSimpleSerializer
  json_serializer :simplerelationships, ObisSimpleRelationshipsSerializer
end

