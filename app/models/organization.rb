# Copyright © 2011-2019 MUSC Foundation for Research Development
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
  has_one :subsidy_map, :dependent => :destroy
  has_many :submission_emails, :dependent => :destroy
  has_many :associated_surveys, as: :associable, dependent: :destroy
  has_many :pricing_setups, :dependent => :destroy
  has_many :forms, -> { active }, as: :surveyable, dependent: :destroy
  has_many :super_users, :dependent => :destroy
  has_many :service_providers, :dependent => :destroy
  has_many :catalog_managers, :dependent => :destroy
  has_many :clinical_providers, :dependent => :destroy
  has_many :patient_registrars, :dependent => :destroy
  has_many :services, :dependent => :destroy
  has_many :sub_service_requests, :dependent => :destroy
  has_many :available_statuses, :dependent => :destroy
  has_many :editable_statuses, :dependent => :destroy
  has_many :org_children, class_name: "Organization", foreign_key: :parent_id

  has_many :protocols, through: :sub_service_requests
  has_many :surveys, through: :associated_surveys

  validates :abbreviation,
            :order,
            presence: true, on: :update
  validates :name, presence: true
  validates :order, numericality: { only_integer: true }, on: :update

  accepts_nested_attributes_for :submission_emails

  after_create :create_statuses

  default_scope -> {
    order(:order, :name)
  }

  scope :authorized_for_identity, -> (identity_id) {
    where(
      id: Organization.authorized_child_organization_ids(
        includes(:super_users, :service_providers).
        where("super_users.identity_id = ? or service_providers.identity_id = ?", identity_id, identity_id).
        references(:super_users, :service_providers).
        distinct(:organizations).ids
      )
    ).distinct
  }

  scope :authorized_for_super_user, -> (identity_id) {
    where(
      id: Organization.authorized_child_organization_ids(
        joins(:super_users).
        where(super_users: { identity_id: identity_id } ).
        references(:super_users).
        distinct(:organizations).ids)
    ).distinct
  }

  scope :authorized_for_service_provider, -> (identity_id) {
    where(
      id: Organization.authorized_child_organization_ids(
        joins(:service_providers).
        where(service_providers: { identity_id: identity_id } ).
        references(:service_providers).
        distinct(:organizations).ids)
    ).distinct
  }

  scope :authorized_for_catalog_manager, -> (identity_id) {
    where(
      id: Organization.authorized_child_organization_ids(
        joins(:catalog_managers).
        where(catalog_managers: { identity_id: identity_id } ).
        references(:catalog_managers).
        distinct(:organizations).ids)
    ).distinct
  }

  scope :authorized_for_clinical_provider, -> (identity_id) {
    where(
      id: Organization.authorized_child_organization_ids(
        joins(:clinical_providers).
        where(clinical_providers: { identity_id: identity_id } ).
        references(:clinical_providers).
        distinct(:organizations).ids)
    ).distinct
  }

  scope :available, -> {
    where(is_available: true)
  }

  scope :not_available, -> {
    where(is_available: false)
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
      return self.parents.detect {|x| x.process_ssrs}
    end
  end

  # Organization A, which belongs to
  # Organization B, which belongs to Organization C, return "C > B > A".
  # This "hierarchy" stops at a process_ssrs Organization.
  def organization_hierarchy(include_self=false, process_ssrs=true, use_css=false, use_array=false)
    parent_orgs = self.parents.reverse

    if process_ssrs
      root = parent_orgs.find_index { |org| org.process_ssrs? } || (parent_orgs.length - 1)
    else
      root = parent_orgs.length - 1
    end

    if use_array
      parent_orgs[0..root]
    elsif use_css
      parent_orgs[0..root].map{ |o| "<span class='#{o.css_class}-text'>#{o.abbreviation}</span>"}.join('<span> / </span>') + (include_self ? '<span> / </span>' + "<span class='#{self.css_class}-text'>#{self.abbreviation}</span>" : '')
    else
      parent_orgs[0..root].map(&:abbreviation).join(' > ') + (include_self ? ' > ' + self.abbreviation : '')
    end
  end

  def update_ssr_org_name
    SubServiceRequest.where( organization: self.all_child_organizations_with_self ).each(&:update_org_tree)
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
    get_editable_statuses.include?(status)
  end

  #Returns all child organizations, all the way down the tree
  def all_child_organizations
    [org_children, org_children.map(&:all_child_organizations)].flatten
  end

  def all_child_organizations_with_self
    all_child_organizations << self
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

  def update_descendants_availability(is_available)
    child_orgs_with_self = Organization.where(id: all_child_organizations_with_self)
    child_orgs_with_self.each do |org|
      org.update_attributes(is_available: is_available)
    end
    Service.where(organization_id: child_orgs_with_self).each do |service|
      service.update_attributes(is_available: is_available)
    end
  end

  # Returns an array of all services that are offered by this organization as well of all of its
  # deep children.
  def all_child_services(include_self=true)
    org_ids = include_self ? all_child_organizations_with_self.map(&:id) : all_child_organizations.map(&:id)
    Service.where(organization_id: org_ids)
  end

  def has_one_time_fee_services?(opts={})
    Service.where(one_time_fee: true, is_available: (opts[:is_available] ? opts[:is_available] : [true, false]), organization_id: Organization.authorized_child_organization_ids([self.id])).any?
  end

  def has_per_patient_per_visit_services?(opts={})
    Service.where(one_time_fee: false, is_available: (opts[:is_available] ? opts[:is_available] : [true, false]), organization_id: Organization.authorized_child_organization_ids([self.id])).any?
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
    # If process_ssrs is true, we need to also get our children's service providers
    if self.process_ssrs and include_children
      org_ids = all_child_organizations_with_self.map(&:id)
    else
      org_ids = [self.id]
    end

    # Get the service providers on all parents
    org_ids << parents.map(&:id)

    ServiceProvider.where(organization_id: org_ids.flatten)
  end

  # Returns all *relevant* super users for an organization.  Returns this organization's
  # super users, as well as the super users on all parents.  If the process_ssrs flag
  # is true at this organization, also returns the super users of all children.
  def all_super_users
    # If process_ssrs is true, we need to also get our children's super users
    if self.process_ssrs
      org_ids = all_child_organizations_with_self.map(&:id)
    else
      org_ids = [self.id]
    end

    # Get the super users on all parents
    org_ids << parents.map(&:id)

    SuperUser.where(organization_id: org_ids.flatten)
  end

  # Returns all user rights on the organization, optionally including Service Providers
  def all_user_rights(include_service_providers=false)
    identity_ids = self.super_users.pluck(:identity_id) + self.catalog_managers.pluck(:identity_id)
    identity_ids += self.service_providers.pluck(:identity_id) if include_service_providers
    Identity.where(id: identity_ids)
  end

  # Returns all fulfillment user rights on the organization
  def all_fulfillment_rights
    identity_ids = self.clinical_providers.pluck(:identity_id)
    identity_ids += self.patient_registrars.pluck(:identity_id)
    # Placeholder for invoicers, which will be included later
    # identity_ids += self.invoicers.pluck(:identity_id)
    Identity.where(id: identity_ids)
  end

  def get_available_statuses
    if process_ssrs
      if use_default_statuses
        selected_statuses = AvailableStatus.defaults
      else
        selected_statuses = available_statuses.selected.pluck(:status)
      end
    elsif process_ssrs_parent
      if process_ssrs_parent.use_default_statuses
        selected_statuses = AvailableStatus.defaults
      else
        selected_statuses = process_ssrs_parent.available_statuses.selected.pluck(:status)
      end
    else
      selected_statuses = AvailableStatus.defaults
    end

    AvailableStatus.statuses.slice(*selected_statuses)
  end

  def get_editable_statuses
    if process_ssrs
      if self.use_default_statuses
        AvailableStatus.defaults
      else
        if self.editable_statuses.loaded?
          self.editable_statuses.select{ |es| es.selected? }.map(&:status)
        else
          self.editable_statuses.selected.pluck(:status)
        end
      end
    elsif process_ssrs_parent
      process_ssrs_parent.get_editable_statuses
    else
      AvailableStatus.defaults
    end
  end

  def self.find_all_by_available_status status
    Organization.all.select{|x| x.get_available_statuses.keys.include? status}
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

  def create_statuses
    EditableStatus.import PermissibleValue.available.where(category: 'status').map{|pv| EditableStatus.new(organization: self, status: pv.key, selected: pv.default)}
    AvailableStatus.import PermissibleValue.available.where(category: 'status').map{|pv| AvailableStatus.new(organization: self, status: pv.key, selected: pv.default)}
  end

  def self.authorized_child_organization_ids(org_ids)
    child_ids = Organization.where(parent_id: org_ids).ids
    if child_ids.empty?
      org_ids
    else
      org_ids + self.authorized_child_organization_ids(child_ids)
    end
  end
end
