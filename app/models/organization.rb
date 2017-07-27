# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class Organization < ApplicationRecord

  include RemotelyNotifiable

  audited
  acts_as_taggable

  belongs_to :parent, :class_name => 'Organization'
  has_many :submission_emails, :dependent => :destroy
  has_many :associated_surveys, as: :surveyable, dependent: :destroy
  has_many :pricing_setups, :dependent => :destroy
  has_one :subsidy_map, :dependent => :destroy

  has_many :super_users, :dependent => :destroy
  has_many :identities, :through => :super_users

  has_many :service_providers, :dependent => :destroy
  has_many :identities, :through => :service_providers

  has_many :catalog_managers, :dependent => :destroy
  has_many :clinical_providers, :dependent => :destroy
  has_many :identities, :through => :catalog_managers
  has_many :services, :dependent => :destroy
  has_many :sub_service_requests, :dependent => :destroy
  has_many :protocols, through: :sub_service_requests
  has_many :available_statuses, :dependent => :destroy
  has_many :editable_statuses, :dependent => :destroy
  has_many :org_children, class_name: "Organization", foreign_key: :parent_id
  
  accepts_nested_attributes_for :subsidy_map
  accepts_nested_attributes_for :pricing_setups
  accepts_nested_attributes_for :submission_emails
  accepts_nested_attributes_for :available_statuses, :allow_destroy => true
  accepts_nested_attributes_for :editable_statuses, :allow_destroy => true

  after_create :create_past_statuses
  # TODO: In rails 5, the .or operator will be added for ActiveRecord queries. We should try to
  #       condense this to a single query at that point
  scope :authorized_for_identity, -> (identity_id) {
    orgs = includes(:super_users, :service_providers).where("super_users.identity_id = ? or service_providers.identity_id = ?", identity_id, identity_id).references(:super_users, :service_providers).distinct(:organizations)
    where(id: orgs + Organization.authorized_child_organizations(orgs.map(&:id))).distinct
  }

  scope :in_cwf, -> { joins(:tags).where(tags: { name: 'clinical work fulfillment' }) }

  def label
    abbreviation || name
  end

  ###############################################################################
  ############################# HIERARCHY METHODS ###############################
  ###############################################################################

  # Returns an array of organizations, the current organization's parents, in order of climbing
  # the tree backwards (thus if called on a core it will return => [program, provider, institution]).
  def parents id_only=false
    my_parents = []
    if parent
      my_parents << (id_only ? parent.id : parent)
      my_parents.concat(parent.parents id_only)
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
      return self.parents.detect {|x| x.process_ssrs} || self
    end
  end

  #TODO SubServiceRequest.where(organization: self.all_child_organizations).each(:&update_org_tree)
  def update_ssr_org_name
    SubServiceRequest.where( organization: self.all_child_organizations<<self ).each(&:update_org_tree)
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

  def has_editable_status?(status)
    self.editable_statuses.where(status: status).any?
  end

  # Returns the immediate children of this organization (shallow search)
  def children orgs
    children = []

    orgs.each do |org|
      if org.parent_id == self.id
        children << org
      end
    end

    children
  end

  def all_child_organizations
    [
      org_children,
      org_children.map(&:all_child_organizations)
    ].flatten
  end

  def child_orgs_with_protocols
    organizations = all_child_organizations
    organizations_with_protocols = []
    organizations.flatten.uniq.each do |organization|
      if organization.protocols.any?
        organizations_with_protocols << organization
      end
    end
    organizations_with_protocols.flatten.uniq
  end

  # Returns an array of all children (and children of children) of this organization (deep search).
  # Optionally includes self
  def all_children (all_children=[], include_self=true, orgs)
    self.children(orgs).each do |child|
      all_children << child
      child.all_children(all_children, orgs)
    end

    all_children << self if include_self

    all_children.uniq
  end

  def update_descendants_availability(is_available)
    if is_available == "0"
      children = Organization.where(id: all_child_organizations << self)
      children.update_all(is_available: false)
      Service.where(organization_id: children).update_all(is_available: false)
    end
  end

  # Returns an array of all services that are offered by this organization as well of all of its
  # deep children.
  def all_child_services include_self=true
    orgs = Organization.all
    all_services = []
    children = self.all_children [], include_self, orgs
    children.each do |child|
      if child.services
        services = Service.where(:organization_id => child.id).includes(:pricing_maps)
        all_services = all_services | services.sort_by{|x| x.name}
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

  # Returns this organization's pricing setup that is effective on a given date.
  def effective_pricing_setup_for_date(date=Date.today)
    if self.pricing_setups.blank?
      raise ArgumentError, "Organization has no pricing setups" if self.parent.nil?
      return self.parent.effective_pricing_setup_for_date(date)
    end

    current_setups = self.pricing_setups.select { |x| x.effective_date.to_date <= date.to_date }

    raise ArgumentError, "Organization has no current effective pricing setups" if current_setups.empty?
    sorted_setups = current_setups.sort { |lhs, rhs| lhs.effective_date <=> rhs.effective_date }
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
      return self.service_providers
    elsif !self.parents.empty?
      parent = self.parents.select {|x| !x.service_providers.empty?}.first
      return parent.nil? ? [] : parent.service_providers
    else
      return []
    end
  end

  # Looks down through all child services. It looks back up through each service's parent organizations
  # and returns false if any of them do not have a service provider. Self is excluded.
  def service_providers_for_child_services?
    has_provider = true
    if !self.all_child_services.empty?
      self.all_child_services(false).each do |service|
        service_providers = service.organization.service_providers_lookup.reject{|x| x.organization_id == self.id}
        if service_providers == []
          has_provider = false
        end
      end
    end

    has_provider
  end

  # Returns all *relevant* service providers for an organization.  Returns this organization's
  # service providers, as well as the service providers on all parents.  If the process_ssrs flag
  # is true at this organization, also returns the service providers of all children.
  def all_service_providers(include_children=true)
    orgs = Organization.all
    all_service_providers = []

    # If process_ssrs is true, we need to also get our children's service providers
    if self.process_ssrs and include_children
      self.all_children(orgs).each do |child|
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
    orgs = Organization.all
    all_super_users = []

    # If process_ssrs is true, we need to also get our children's super users
    if self.process_ssrs
      self.all_children(orgs).each do |child|
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

  def setup_available_statuses
    position = 1
    obj_names = AvailableStatus::TYPES.map{ |k,v| k }
    obj_names.each do |obj_name|
      available_status = available_statuses.detect { |obj| obj.status == obj_name }
      available_status ||= available_statuses.build(status: obj_name, new: true)
      available_status.position = position
      position += 1
    end

    setup_editable_statuses
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

  def self.find_all_by_available_status status
    Organization.all.select{|x| x.get_available_statuses.keys.include? status}
  end

  def setup_editable_statuses
    EditableStatus::TYPES.each do |status|
      self.editable_statuses.build(status: status, new: true) unless self.editable_statuses.detect{ |es| es.status == status }
    end
  end

  def has_tag? tag
    if self.tag_list.include? tag
      return true
    elsif parent
      self.parent.has_tag? tag
    else
      return false
    end
  end

  private

  def create_past_statuses
    EditableStatus::TYPES.each do |status|
      self.editable_statuses.create(status: status)
    end
  end

  def self.authorized_child_organizations(org_ids)
    org_ids = org_ids.flatten.compact
    if org_ids.empty?
      []
    else
      orgs = Organization.where(parent_id: org_ids)
      orgs | authorized_child_organizations(orgs.pluck(:id))
    end
  end
end
