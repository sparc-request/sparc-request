# Copyright © 2011-2020 MUSC Foundation for Research Development
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

require 'directory'

class Identity < ApplicationRecord

  include RemotelyNotifiable

  audited

  before_save :update_institution
  after_create :send_admin_mail

  #Version.primary_key = 'id'
  #has_paper_trail

  #### DEVISE SETUP ####
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :validatable,
         :recoverable, :rememberable, :trackable, :omniauthable,
         omniauth_providers: Devise.omniauth_providers

  password_length = 6..128

  #### END DEVISE SETUP ####

  belongs_to :professional_organization, optional: true

  has_many :access_grants, class_name: 'Doorkeeper::AccessGrant', foreign_key: :resource_owner_id, dependent: :delete_all
  has_many :access_tokens, class_name: 'Doorkeeper::AccessToken', foreign_key: :resource_owner_id, dependent: :delete_all

  has_many :approvals, dependent: :destroy
  has_many :admin_rates
  has_many :approved_subsidies, class_name: 'ApprovedSubsidy', foreign_key: 'approved_by'
  has_many :catalog_manager_rights, class_name: 'CatalogManager'
  has_many :catalog_managers, dependent: :destroy
  has_many :clinical_providers, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :project_roles, dependent: :destroy
  has_many :protocol_filters, dependent: :destroy
  has_many :received_messages, class_name: 'Message', foreign_key: 'to'
  has_many :received_notifications, class_name: "Notification", foreign_key: 'other_user_id'
  has_many :responses, dependent: :destroy
  has_many :response_filters, dependent: :destroy
  has_many :sent_messages, class_name: 'Message', foreign_key: 'from'
  has_many :sent_notifications, class_name: "Notification", foreign_key: 'originator_id'
  has_many :service_providers, dependent: :destroy
  has_many :super_users, dependent: :destroy
  has_many :short_interactions, :dependent => :destroy

  has_many :protocols, through: :project_roles
  has_many :projects, -> { where("protocols.type = 'Project'")}, through: :project_roles, source: :protocol
  has_many :protocol_service_requests, through: :protocols, source: :service_requests
  has_many :studies, -> { where("protocols.type = 'Study'")}, through: :project_roles, source: :protocol

  has_many :races
  accepts_nested_attributes_for :races, :allow_destroy => true

  attr_accessor :updater_id

  validates_presence_of :first_name, :last_name, :email

  validates_presence_of :credentials_other, if: Proc.new{ |i| i.credentials == 'other' }

  validates_format_of :email, with: DataTypeValidator::EMAIL_REGEXP, allow_blank: true, if: :email_changed?
  validates_format_of :phone, with: DataTypeValidator::PHONE_REGEXP, allow_blank: true, if: :phone_changed?

  validates :ldap_uid, uniqueness: {case_sensitive: false}, presence: true
  validates :orcid, format: { with: /\A([0-9]{4}-){3}[0-9]{3}[0-9X]\z/ }, allow_blank: true
  # personal demographics are only required on Edit Profile page
  validate :validate_demographics, if: Proc.new { |i| i.id == i.updater_id && i.sign_in_count > 0 }


  scope :overlords, -> { where(catalog_overlord: true) }

  scope :sparc_users, ->{
    uids =  (ProjectRole.pluck(:identity_id) +
            ServiceProvider.pluck(:identity_id) +
            SuperUser.pluck(:identity_id) +
            CatalogManager.pluck(:identity_id) +
            ClinicalProvider.pluck(:identity_id)).uniq
    where(id: uids)
  }

  scope :sorted, -> (sort, order) {
    case sort
    when 'name'
      order(Arel.sql("identities.last_name #{order}, identities.first_name #{order}"))
    when 'created_at'
      order(Arel.sql("identities.created_at #{order}"))
    when 'last_sign_in_at'
      order(Arel.sql("identities.current_sign_in_at #{order}"))
    when 'sign_in_count'
      order(Arel.sql("identities.sign_in_count #{order}"))
    when 'institution'
      order(Arel.sql("identities.institution #{order}"))
    end
  }

  scope :search_query, -> (term) {
    return if term.blank?

    identity_arel = Identity.arel_table
    attrs = [:last_name, :first_name, :email, :institution]

    where (attrs
      .map { |attr| identity_arel[attr].matches("%#{term}%")}
      .inject(:or)
     )
  }

  ###############################################################################
  ############################## DEVISE OVERRIDES ###############################
  ###############################################################################

  def suggestion_value
    Setting.get_value("use_ldap") && Setting.get_value("lazy_load_ldap") ? ldap_uid : id
  end

  def validate_demographics
    errors.add(:age_group, "must select one") if Setting.get_value("displayed_demographics_fields").include?("age_group") && !self.age_group.present?
    errors.add(:gender, "must select one") if Setting.get_value("displayed_demographics_fields").include?("gender") && !self.gender.present?
    errors.add(:ethnicity, "must select one") if Setting.get_value("displayed_demographics_fields").include?("ethnicity") && !self.ethnicity.present?
    errors.add(:races, "Must select one or more") if Setting.get_value("displayed_demographics_fields").include?("race") && self.races.reject(&:marked_for_destruction?).empty?
  end

  ###############################################################################
  ############################## HELPER METHODS #################################
  ###############################################################################

  # Returns this user's first and last name humanized.
  def full_name
    "#{first_name.try(:humanize)} #{last_name.try(:humanize)}".lstrip.rstrip
  end

  def last_name_first
    "#{last_name.try(:humanize)}, #{first_name.try(:humanize)}"
  end

  def display_credential_value
    output =  "#{PermissibleValue.get_value('user_credential', credentials)}"
    if credentials == "other" && credentials_other.present?
      output = "Other (#{credentials_other})"
    end
    return output
  end

 # Returns this user's first and last name humanized, with their email.
  def display_name
    "#{first_name.try(:humanize)} #{last_name.try(:humanize)} (#{email})".lstrip.rstrip
  end

  # Return the netid (ldap_uid without the @musc.edu)
  def netid
    if Setting.get_value("use_ldap") then
      return ldap_uid.sub(/@#{Directory.domain}/, '')
    else
      return ldap_uid
    end
  end

  #replace old organization methods with new professional organization lookups
  def professional_org_lookup(org_type)
    professional_organization ? professional_organization.parents_and_self.select{|org| org.org_type == org_type}.first.try(:name) : ""
  end

  def display_races
    races = ""
    self.races.each do |race|
      races += races.blank? ? race.display_name : "; #{race.display_name}"
    end
    return races
  end

  def display_gender
    gender.present? ?  PermissibleValue.get_value('gender', gender) : ""
  end

  def display_age_group
    age_group.present? ?  PermissibleValue.get_value('age_group', age_group) : ""
  end

  def display_ethnicity
    ethnicity.present? ?  PermissibleValue.get_value('ethnicity', ethnicity) : ""
  end
  ###############################################################################
  ############################ ATTRIBUTE METHODS ################################
  ###############################################################################

  def is_site_admin?
    Setting.get_value("site_admins").include?(self.ldap_uid)
  end

  def is_super_user?
    @is_super_user ||= self.super_users.count > 0
  end

  def is_service_provider?(ssr=nil)
    ####TODO pretty sure this is totally unnecessary, and can be done in like, 2 lines.
    if ssr
      is_provider = false
      orgs =[]
      orgs << ssr.organization << ssr.organization.parents
      orgs.flatten!

      orgs.each do |org|
        provider_ids = org.service_providers_lookup.map{|x| x.identity_id}
        if provider_ids.include?(self.id)
          is_provider = true
        end
      end

      is_provider
    else
      @is_service_provider ||= self.service_providers.count > 0
    end
  end

  def is_catalog_manager?
    @is_catalog_manager ||= self.catalog_managers.count > 0
  end

  def is_funding_admin?
    Setting.get_value("funding_admins").include?(ldap_uid)
  end

  ###############################################################################
  ############################# SEARCH METHODS ##################################
  ###############################################################################

  def self.search(term)
    return Directory.search(term)
  end

  def self.find_or_create(id)
    if Setting.get_value("use_ldap") && Setting.get_value("lazy_load_ldap")
      return Directory.find_or_create(id)
    else
      return self.find(id)
    end
  end

  ###############################################################################
  ########################### PERMISSION METHODS ################################
  ###############################################################################

  # DEVISE specific methods
  def self.find_for_shibboleth_oauth(auth, signed_in_resource=nil)
    identity = Identity.where(ldap_uid: auth.uid).first

    unless identity
      email = auth.info.email.blank? ? auth.uid : auth.info.email # in case shibboleth doesn't return the required parameters
      identity = Identity.create ldap_uid: auth.uid, first_name: auth.info.first_name, last_name: auth.info.last_name, email: email, password: Devise.friendly_token[0,20], approved: true
    end
    identity
  end

  # search the database for the identity with the given ldap_uid, if not found, create a new one
  def self.find_for_cas_oauth(auth, _signed_in_resource = nil)
    Directory.find_for_cas_oauth(auth.uid)
  end

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    if !approved?
      :not_approved
    else
      super # Use whatever other message
    end
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(ldap_uid) = :value", { value: login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def self.send_reset_password_instructions(attributes={})
    recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    if !recoverable.approved?
      recoverable.errors[:base] << I18n.t("devise.failure.not_approved")
    elsif recoverable.persisted?
      recoverable.send_reset_password_instructions
    end
    recoverable
  end

  def send_admin_mail
    unless self.approved
      Notifier.new_identity_waiting_for_approval(self).deliver_now
    end
  end

  # Only users with request or approve rights can edit.
  def can_edit_service_request?(sr)
    self.catalog_overlord? || sr.sub_service_requests.where(service_requester: self).any? || (sr.protocol && can_edit_protocol?(sr.protocol))
  end

  def can_view_protocol?(protocol)
    self.catalog_overlord? || protocol.project_roles.where(identity_id: self.id, project_rights: ['view', 'approve', 'request']).any?
  end

  def can_edit_protocol?(protocol)
    self.catalog_overlord? || protocol.project_roles.where(identity_id: self.id, project_rights: ['approve', 'request']).any?
  end

  # Determines whether this identity can edit a given organization's information in CatalogManager.
  # Returns true if this identity's catalog_manager_organizations includes the given organization.
  def can_edit_organization?(organization)
    catalog_manager_organizations.include?(organization)
  end

  def can_edit_service?(service)
    can_edit_organization?(service.organization)
  end

  # Determines whether the user has permission to edit historical data for a given organization.
  # Returns true if the edit_historic_data flag is set to true on the relevant catalog_manager relationship.
  def can_edit_historical_data_for?(organization)
    if catalog_manager_organizations.include?(organization)
      if self.catalog_managers.find_by_organization_id(organization.id)
        if self.catalog_managers.find_by_organization_id(organization.id).edit_historic_data
          return true
        else
          return self.can_edit_historical_data_for? organization.parent
        end
      else
        return self.can_edit_historical_data_for? organization.parent
      end
    end

    false
  end

  ###############################################################################
  ########################### COLLECTION METHODS ################################
  ###############################################################################

  def authorized_admin_organizations
    # Returns an active record relation of organizations where the user has super user, or service provider rights.
    # Including all child organizations.
    Organization.authorized_for_identity(self.id)
  end

  # Returns an active record relation of organizations where the user has catalog manager rights.
  # Including all child organizations.
  def catalog_manager_organizations
    Organization.authorized_for_catalog_manager(self.id)
  end

  # Returns an active record relation of organizations where the user has service provider rights.
  # Including all child organizations.
  def service_provider_organizations
    Organization.authorized_for_service_provider(self.id)
  end

  # Returns an active record relation of organizations where the user has clinical provider rights.
  # Including all child organizations
  def clinical_provider_organizations
    Organization.authorized_for_clinical_provider(self.id)
  end

  # Returns an active record relation of organizations where the user has super user rights.
  # Including all child organizations
  def super_user_organizations
    Organization.authorized_for_super_user(self.id)
  end

  def go_to_cwf_rights?(organization)
    super_user_organizations.include?(organization) or clinical_provider_organizations.include?(organization)
  end

  def send_to_cwf_rights?(organization)
    authorized_admin_organizations.include?(organization)
  end

  def organizations_for_users(orgs, su_only)
    arr = []
    self.super_users.each do |user|
      orgs.each do |org|
        if user.organization_id == org.id
          arr << org
        end
      end
    end

    unless su_only[:su_only] == true
      self.service_providers.each do |user|
        orgs.each do |org|
          if user.organization_id == org.id
            arr << org
          end
        end
      end
    end
    arr = arr.flatten.compact.uniq

    arr
  end

  # short_interactions report
  # Display first available Provider/Program to which the SP user rights is assigned
  def display_available_provider_program_name
    name = "N/A"
    orgs = self.service_providers.map {|sp| sp.organization}.reject{|o| o.is_available == false}
    unless orgs.empty?
      providers = orgs.select {|o| o.type == "Provider"}

      #SP not assigned @Provider-level
      if providers.empty?
        programs = orgs.select {|o| o.type == "Program"}
        ## SP assigned @Program-level SP
        if !programs.empty?
          program = programs[0]
        ## SP assigned @Core-level
        else
          program = Organization.find(orgs[0].parent_id)
        end
        provider = Organization.find(program.parent_id)
        name = "#{provider.name}/#{program.name}"
      else
        name = providers[0].name
      end
    end
    name
  end

  def populate_for_edit
    self.setup_races
  end

  def setup_races
    position = 1
    obj_names = PermissibleValue.get_key_list('race')
    obj_names.each do |obj_name|
      race = races.detect{|obj| obj.name == obj_name}
      race = races.build(:name => obj_name, :new => true) unless race
      race.position = position
      position += 1
    end
    races.sort_by(&:position)
  end

  ###############################################################################
  ########################## NOTIFICATION METHODS ###############################
  ###############################################################################

  def all_notifications
    # Returns an array of Notifications.
    [sent_notifications, received_notifications].flatten
  end

  def unread_notification_count(sub_service_request_id=nil)
    Notification.of_ssr(sub_service_request_id).unread_by(self).count
  end

  private

  def update_institution
    self.institution = self.professional_org_lookup('institution') if professional_organization_id_changed?
  end
end
