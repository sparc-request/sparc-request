class Organization < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

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
  has_many :available_statuses, :dependent => :destroy

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
  attr_accessible :submission_emails_attributes
  attr_accessible :is_ctrc
  attr_accessible :available_statuses_attributes
 
  accepts_nested_attributes_for :subsidy_map
  accepts_nested_attributes_for :pricing_setups
  accepts_nested_attributes_for :submission_emails
  accepts_nested_attributes_for :available_statuses, :allow_destroy => true

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
      return self.parents.select {|x| !x.service_providers.empty?}.first.try(:service_providers) || []
    end
  end

  def submission_emails_lookup
    if !submission_emails.empty?
      return submission_emails
    else 
      return self.parents.select {|x| !x.submission_emails.empty?}.first.try(:submission_emails) || []
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

    current_setups = self.pricing_setups.select { |x| x.display_date.to_date <= date.to_date }
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

  def get_available_statuses
    tmp_available_statuses = self.available_statuses.reject{|status| status.new_record?} 
    statuses = []
    if tmp_available_statuses.empty?
      self.parents.each do |parent|
        if !parent.available_statuses.empty?
          statuses = AVAILABLE_STATUSES.select{|k,v| parent.available_statuses.map(&:status).include? k}
          return statuses
        end        
      end
    else
      statuses = AVAILABLE_STATUSES.select{|k,v| tmp_available_statuses.map(&:status).include? k}
    end
    if statuses.empty?
      statuses = AVAILABLE_STATUSES.select{|k,v| DEFAULT_STATUSES.include? k}
    end
    statuses
  end

end
