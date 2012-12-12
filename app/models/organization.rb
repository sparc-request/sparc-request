class Organization < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  include Entity

  belongs_to :parent, :class_name => 'Organization'
  has_many :submission_emails, :dependent => :destroy
  has_many :pricing_setups, :dependent => :destroy
  has_one :subsidy_map, :dependent => :destroy

  has_many :super_users, :dependent => :destroy
  has_many :identities, :through => :super_users

  has_many :service_providers, :dependent => :destroy
  has_many :identities, :through => :service_providers

  has_many :catalog_managers, :dependent => :destroy
  has_many :identities, :through => :catalog_managers
  has_many :services, :dependent => :destroy
  has_many :subsidies, :dependent => :destroy
  has_many :sub_service_requests, :dependent => :destroy

  attr_accessible :name
  attr_accessible :order
  attr_accessible :css_class
  attr_accessible :description
  attr_accessible :obisid
  attr_accessible :parent_id
  attr_accessible :abbreviation
  attr_accessible :ack_language
  attr_accessible :process_ssrs
  attr_accessible :is_available
  attr_accessible :subsidy_map_attributes
  attr_accessible :pricing_setups_attributes
 
  accepts_nested_attributes_for :subsidy_map
  accepts_nested_attributes_for :pricing_setups

  before_validation :assign_obisid, :on => :create

  ###############################################################################
  ############################# HIERARCHY METHODS ###############################
  ###############################################################################

  # Returns an array of organizations, the current organization's parents, in order of climbing
  # the tree backwards (thus if called on a core it will return => [program, provider, institution]).
  def parents
    my_parents = []
    if parent
      my_parents << parent
      my_parents.concat(parent.parents)
    end

    my_parents
  end

  # Returns the first organization amongst the current organization's parents where the process_ssrs
  # flag is set to true.  Will return self if self has the flag set true.  Will return nil if no
  # organization in the hierarchy is found that has the flag set to true.
  def process_ssrs_parent
    if self.process_ssrs
      return self
    else
      return self.parents.select {|x| x.process_ssrs}.first
    end
  end
  
  def service_providers_lookup
    if !service_providers.empty?
      return service_providers
    else 
      return self.parents.select {|x| !x.service_providers.empty?}.first.service_providers
    end
  end

  # Returns the immediate children of this organization (shallow search)
  def children
    return Organization.find_all_by_parent_id(self.id)
  end

  # Returns an array of all children (and children of children) of this organization (deep search).
  # !!!INCLUDES SELF!!!
  def all_children all_children=[]
    self.children.each do |child|
      all_children << child
      child.all_children(all_children)
    end
    all_children << self

    all_children.uniq
  end


  # Returns an array of all services that are offered by this organization as well of all of its
  # deep children.
  def all_child_services
    all_services = []
    self.all_children.each do |child|
      if child.services
        all_services = all_services | child.services
      end
    end

    all_services    
  end
  
  ###############################################################################
  ############################## PRICING METHODS ################################
  ###############################################################################
  
  # Returns this organization's pricing setup that is displayed on todays date.
  def current_pricing_setup
    return pricing_setup_for_date(Date.today)
  end

  # Returns this organization's pricing setup that is displayed on a given date.
  def pricing_setup_for_date(date)
    if self.pricing_setups.blank?
      raise ArgumentError, "Organization has no pricing setups" if self.parent.nil?
      return self.parent.pricing_setup_for_date(date)
    end

    current_setups = self.pricing_setups.select { |x| x.display_date <= date }
    raise ArgumentError, "Organization has no current pricing setups" if current_setups.empty?

    sorted_setups = current_setups.sort { |lhs, rhs| lhs.display_date <=> rhs.display_date }
    pricing_setup = sorted_setups.last

    return pricing_setup
  end

  ###############################################################################
  ############################## SUBSIDY METHODS ################################
  ###############################################################################

  # Returns true if the funding source specified is an excluded funding source of this organization.
  # Otherwise, returns false.
  def funding_source_excluded_from_subsidy?(funding_source)
    excluded = false
    excluded_funding_sources = self.try(:subsidy_map).try(:excluded_funding_sources)
    if excluded_funding_sources 
      funding_source_names = excluded_funding_sources.map {|x| x.funding_source}
      excluded = true if funding_source_names.include?(funding_source)
    end

    excluded
  end

  # Returns true if this organization has any information (greater than 0) in its subsidy map.
  # It is assumed that if any information has been entered that the organization offers subsidies.
  def eligible_for_subsidy?
    eligible = false

    if subsidy_map then
      eligible = true if subsidy_map.max_dollar_cap and subsidy_map.max_dollar_cap > 0
      eligible = true if subsidy_map.max_percentage and subsidy_map.max_percentage > 0
    end

    return eligible
  end

  ###############################################################################
  ############################ RELATIONSHIP METHODS #############################
  ###############################################################################

  # Returns this organization's service providers if they exist.  If they do not, finds the first
  # parent organization which has service providers and returns the service providers of that parent.
  def service_providers_lookup
    if !service_providers.empty?
      return service_providers
    else 
      return self.parents.select {|x| !x.service_providers.empty?}.first.service_providers
    end
  end

  # Returns all *relevant* service providers for an organization.  Returns this organization's
  # service providers, as well as the service providers on all parents.  If the process_ssrs flag
  # is true at this organization, also returns the service providers of all children.
  def all_service_providers
    all_service_providers = []
    
    # If process_ssrs is true, we need to also get our children's service providers
    if self.process_ssrs
      self.all_children.each do |child|
        all_service_providers << child.service_providers
      end
    end

    # Get the service providers on self
    all_service_providers << self.service_providers

    # Get the service providers on all parents
    self.parents.each do |parent|
      all_service_providers << parent.service_providers
    end
    
    return all_service_providers.flatten.uniq {|x| x.identity_id}
  end

  # Returns all *relevant* super users for an organization.  Returns this organization's
  # super users, as well as the super users on all parents.  If the process_ssrs flag
  # is true at this organization, also returns the super users of all children.
  def all_super_users
    all_super_users = []
    
    # If process_ssrs is true, we need to also get our children's super users
    if self.process_ssrs
      self.all_children.each do |child|
        all_super_users << child.super_users
      end
    end

    # Get the super users on self
    all_super_users << self.super_users

    # Get the super users on all parents
    self.parents.each do |parent|
      all_super_users << parent.super_users
    end

    return all_super_users.flatten.uniq {|x| x.identity_id}
  end

end

class Organization::ObisEntitySerializer < Entity::ObisEntitySerializer
  def as_json(entity, options = nil)
    h = super(entity, options)

    optional_attributes = {
      'name'               => entity.name,
      'order'              => entity.order,
      'css_class'          => entity.css_class,
      'description'        => entity.description,
      'abbreviation'       => entity.abbreviation,
      'ack_language'       => entity.ack_language,
      'process_ssrs'       => entity.process_ssrs,
      'is_available'       => entity.is_available,
      'subsidy_map'        => entity.subsidy_map.as_json(options),
      'submission_emails'  => entity.submission_emails.as_json(options)
    }

    optional_attributes.delete_if { |k, v| v.nil? }

    h['attributes'].update(optional_attributes)

    return h
  end

  def update_attributes_from_json(entity, h, options = nil)
    super(entity, h, options)

    identifiers = h['identifiers']
    attributes = h['attributes']

    entity.update_attributes!(
        :name          => attributes['name'],
        :order         => attributes['order'],
        :css_class     => attributes['css_class'],
        :description   => attributes['description'],
        :abbreviation  => attributes['abbreviation'],
        :ack_language  => attributes['ack_language'],
        :process_ssrs  => attributes['process_ssrs'],
        :is_available  => attributes['is_available']
    )

    entity.build_subsidy_map() if not entity.subsidy_map
    if attributes['subsidy_map'] then
      entity.subsidy_map.update_from_json(
          attributes['subsidy_map'],
          options)
    else
      entity.subsidy_map.destroy() if entity.subsidy_map
    end

    # Delete all submission emails for the organization; they will be
    # re-created in the next step.
    entity.submission_emails.each do |submission_email|
      submission_email.destroy()
    end

    # Create a new SubmissionEmail for each one that is passed in.
    (attributes['submission_emails'] || [ ]).each do |h_submission_email|
      submission_email = entity.submission_emails.create()
      submission_email.update_from_json(h_submission_email, options)
    end
  end

  # The user might try to POST to an obisentity/organizational_units
  # url, so we need to instantiate the right Organization subclass in
  # order for the 'type' field to be set.
  def self.create_from_json(entity_class, h, options = nil)
    type = h['classes'][0]
    klass = type.classify.constantize
    obj = klass.new
    obj.update_from_json(h, options)
    return obj
  end
end

class Organization::ObisSimpleSerializer < Entity::ObisSimpleSerializer
  # The user might try to POST to an obisentity/organizational_units
  # url, so we need to instantiate the right Organization subclass in
  # order for the 'type' field to be set.
  def self.create_from_json(entity_class, h, options = nil)
    obj = options[:model].new
    obj.update_from_json(h, options)
    return obj
  end
end

class Organization
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
  json_serializer :relationships, RelationshipsSerializer
  json_serializer :obissimple, ObisSimpleSerializer
  json_serializer :simplerelationships, ObisSimpleRelationshipsSerializer
end

