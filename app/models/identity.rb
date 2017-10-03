# Copyright © 2011-2017 MUSC Foundation for Research Development
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

  after_create :send_admin_mail

  #Version.primary_key = 'id'
  #has_paper_trail

  #### DEVISE SETUP ####
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :omniauthable

  email_regexp = /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
  password_length = 6..128

  #### END DEVISE SETUP ####

  belongs_to :professional_organization
  has_many :approvals, dependent: :destroy
  has_many :approved_subsidies, class_name: 'ApprovedSubsidy', foreign_key: 'approved_by'
  has_many :catalog_manager_rights, class_name: 'CatalogManager'
  has_many :catalog_managers, dependent: :destroy
  has_many :clinical_providers, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :project_roles, dependent: :destroy
  has_many :projects, -> { where("protocols.type = 'Project'")}, through: :project_roles, source: :protocol
  has_many :protocol_filters, dependent: :destroy
  has_many :protocol_service_requests, through: :protocols, source: :service_requests
  has_many :protocols, through: :project_roles
  has_many :received_messages, class_name: 'Message', foreign_key: 'to'
  has_many :received_notifications, class_name: "Notification", foreign_key: 'other_user_id'
  has_many :received_toast_messages, class_name: 'ToastMessage', foreign_key: 'to', dependent: :destroy
  has_many :sent_messages, class_name: 'Message', foreign_key: 'from'
  has_many :sent_notifications, class_name: "Notification", foreign_key: 'originator_id'
  has_many :sent_toast_messages, class_name: 'ToastMessage', foreign_key: 'from', dependent: :destroy
  has_many :service_providers, dependent: :destroy
  has_many :studies, -> { where("protocols.type = 'Study'")}, through: :project_roles, source: :protocol
  has_many :submissions
  has_many :super_users, dependent: :destroy

  cattr_accessor :current_user

  validates_presence_of :last_name
  validates_presence_of :first_name
  validates_presence_of :email
  validates_format_of   :email, with: email_regexp, allow_blank: true, if: :email_changed?
  validates             :ldap_uid, uniqueness: {case_sensitive: false}, presence: true

  validates_presence_of     :password, if: :password_required?
  validates_length_of       :password, within: password_length, allow_blank: true
  validates_confirmation_of :password, if: :password_required?

  ###############################################################################
  ############################## DEVISE OVERRIDES ###############################
  ###############################################################################

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def email_required?
    false
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

 # Returns this user's first and last name humanized, with their email.
  def display_name
    "#{first_name.try(:humanize)} #{last_name.try(:humanize)} (#{email})".lstrip.rstrip
  end

  # Return the netid (ldap_uid without the @musc.edu)
  def netid
    if USE_LDAP then
      return ldap_uid.sub(/@#{Directory::DOMAIN}/, '')
    else
      return ldap_uid
    end
  end

  #replace old organization methods with new professional organization lookups
  def professional_org_lookup(org_type)
    professional_organization ? professional_organization.parents_and_self.select{|org| org.org_type == org_type}.first.try(:name) : ""
  end

  ###############################################################################
  ############################ ATTRIBUTE METHODS ################################
  ###############################################################################

  # Returns true if the user is a catalog overlord.  Should only be true for three uids:
  # lmf5, anc63, mas244
  def is_overlord?
    @is_overlord ||= self.catalog_overlord?
  end

  def is_super_user?
    @is_super_user ||= self.super_users.count > 0
  end

  def is_service_provider?(ssr)
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

  end

  ###############################################################################
  ############################# SEARCH METHODS ##################################
  ###############################################################################

  def self.search(term)
    return Directory.search(term)
  end

  ###############################################################################
  ########################### PERMISSION METHODS ################################
  ###############################################################################

  # DEVISE specific methods
  def self.find_for_shibboleth_oauth(auth, signed_in_resource=nil)
    identity = Identity.where(ldap_uid: auth.uid).first

    unless identity
      identity = Identity.create ldap_uid: auth.uid, first_name: auth.info.first_name, last_name: auth.info.last_name, email: auth.info.email, password: Devise.friendly_token[0,20], approved: true
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
    has_correct_project_role?(sr) || self.is_overlord?
  end

  # If a user has request or approve rights AND the request is editable, then the user can edit.
  def can_edit_sub_service_request? ssr
    ssr.can_be_edited? && has_correct_project_role?(ssr)
  end

  def has_correct_project_role?(request)
    can_edit_protocol?(request.protocol)
  end

  def can_view_protocol?(protocol)
    protocol.project_roles.where(identity_id: self.id, project_rights: ['view', 'approve', 'request']).any?
  end

  def can_edit_protocol?(protocol)
    protocol.project_roles.where(identity_id: self.id, project_rights: ['approve', 'request']).any?
  end

  # Determines whether this identity can edit a given organization's information in CatalogManager.
  # Returns true if this identity's catalog_manager_organizations includes the given organization.
  def can_edit_entity? organization, deep_search=false
    cm_org_ids = self.catalog_managers.map(&:organization_id)
    if deep_search
      org_ids = [organization.id].concat(organization.parents(true))
      org_ids -  cm_org_ids != org_ids
    else
      cm_org_ids.include?(organization.id)
    end
  end

  # Used in clinical fulfillment to determine whether the user can edit a particular core.
  def can_edit_core? org_id
    self.clinical_provider_organizations.map{|x| x.id}.include?(org_id) ? true : false
  end

  # Determines whether the user has permission to edit historical data for a given organization.
  # Returns true if the edit_historic_data flag is set to true on the relevant catalog_manager relationship.
  def can_edit_historical_data_for? organization
    if self.catalog_manager_organizations.include?(organization)
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
    # returns organizations for which user is service provider or super user
    Organization.authorized_for_identity(self.id)
  end

  # Collects all organizations that this identity has catalog manager permissions on, as well as
  # any child (deep) of any of those organizations.
  # Returns an array of organizations.
  def catalog_manager_organizations
    organizations = Organization.all
    orgs = []

    self.catalog_managers.map(&:organization).each do |org|
      orgs << org.all_children(organizations)
    end

    orgs.flatten.uniq
  end

  # Returns an array of organizations where the user has clinical provider rights.
  def clinical_provider_organizations
    organizations = Organization.all
    orgs = []

    self.clinical_providers.map(&:organization).each do |org|
      orgs << org.all_children(organizations)
    end

    self.admin_organizations({su_only: true}).each do |org|
      orgs << org
    end

    orgs.flatten.uniq
  end

  # Collects all organizations that this identity has super user or service provider permissions
  # on, as well as any child (deep) of any of those organizations.
  # Returns an array of organizations.
  # If you pass in "su_only" it only returns organizations for whom you are a super user.
  def admin_organizations su_only = {su_only: false}
    orgs = Organization.all
    organizations = []
    arr = organizations_for_users(orgs, su_only)

    arr.each do |org|
      organizations << org.all_children(orgs)
    end

    ##In case orgs is empty, return an empty array, instead of crashing.
    organizations.flatten!.compact.uniq rescue return []

    organizations
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

  def clinical_provider_rights?
    #TODO should look at all tagged with CTRC
    org = Organization.tagged_with("ctrc").first
    if !self.clinical_providers.empty? or self.admin_organizations({su_only: true}).include?(org)
      return true
    else
      return false
    end
  end

  def clinical_provider_for_ctrc?
    #TODO should look at all tagged with CTRC
    org = Organization.tagged_with("ctrc").first
    return false if org.nil? #if no orgs have nexus tag
    self.clinical_providers.each do |provider|
      if provider.organization_id == org.id
        return true
      end
    end

    return false
  end

  ###############################################################################
  ########################## NOTIFICATION METHODS ###############################
  ###############################################################################

  def all_notifications
    # Returns an array of Notifications.
    [sent_notifications, received_notifications].flatten
  end

  def unread_notification_count(sub_service_request_id=nil)
    Notification.of_ssr(sub_service_request_id).unread_by(id).count
  end
end
