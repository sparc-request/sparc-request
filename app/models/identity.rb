# Copyright © 2011 MUSC Foundation for Research Development
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

class Identity < ActiveRecord::Base
  include RemotelyNotifiable

  audited

  after_create :send_admin_mail

  # Version.primary_key = 'id'
  # has_paper_trail

  #### DEVISE SETUP ####
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :omniauthable, omniauth_providers: [:cas, :developer]

  email_regexp = /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
  password_length = 6..128

  validates_format_of :email, with: email_regexp, allow_blank: true, if: :email_changed?

  validates_presence_of     :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of       :password, within: password_length, allow_blank: true

  attr_accessible :email
  attr_accessible :password
  attr_accessible :password_confirmation
  attr_accessible :remember_me
  attr_accessible :company
  attr_accessible :reason
  attr_accessible :approved
  #### END DEVISE SETUP ####

  has_many :approvals, dependent: :destroy
  has_many :project_roles, dependent: :destroy
  has_many :protocols, through: :project_roles
  has_many :projects, -> { where("protocols.type = 'Project'") }, through: :project_roles, source: :protocol
  has_many :studies, -> { where("protocols.type = 'Study'") }, through: :project_roles, source: :protocol
  has_many :super_users, dependent: :destroy
  has_many :catalog_managers, dependent: :destroy
  has_many :clinical_providers, dependent: :destroy
  has_many :protocol_service_requests, through: :protocols, source: :service_requests
  has_many :requested_service_requests, class_name: 'ServiceRequest', foreign_key: 'service_requester_id'
  has_many :catalog_manager_rights, class_name: 'CatalogManager'
  has_many :service_providers, dependent: :destroy
  has_many :notifications, foreign_key: 'originator_id'
  has_many :sent_messages, class_name: 'Message', foreign_key: 'from'
  has_many :received_messages, class_name: 'Message', foreign_key: 'to'
  has_many :user_notifications, dependent: :destroy
  has_many :received_toast_messages, class_name: 'ToastMessage', foreign_key: 'to', dependent: :destroy
  has_many :sent_toast_messages, class_name: 'ToastMessage', foreign_key: 'from', dependent: :destroy
  has_many :notes, dependent: :destroy

  # TODO: Identity doesn't really have many sub service requests; an
  # identity is the owner of many sub service requests.  We need a
  # better name here.
  # has_many :sub_service_requests, :foreign_key => 'owner_id'

  attr_accessible :ldap_uid
  attr_accessible :email
  attr_accessible :last_name
  attr_accessible :first_name
  attr_accessible :institution
  attr_accessible :college
  attr_accessible :department
  attr_accessible :era_commons_name
  attr_accessible :credentials
  attr_accessible :credentials_other
  attr_accessible :phone
  attr_accessible :catalog_overlord
  attr_accessible :subspecialty

  cattr_accessor :current_user

  validates_presence_of :last_name
  validates_presence_of :first_name
  validates :ldap_uid, uniqueness: { case_sensitive: false }, presence: true

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
    "#{first_name.try(:humanize)} #{last_name.try(:humanize)}".strip
  end

  # Returns this user's first and last name humanized, with their email.
  def display_name
    "#{first_name.try(:humanize)} #{last_name.try(:humanize)} (#{email})".strip
  end

  # Return the netid (ldap_uid without the @musc.edu)
  def netid
    if USE_LDAP
      return ldap_uid.sub(/@#{Directory::DOMAIN}/, '')
    else
      return ldap_uid
    end
  end

  ###############################################################################
  ############################ ATTRIBUTE METHODS ################################
  ###############################################################################

  # Returns true if the user is a catalog overlord.  Should only be true for three uids:
  # lmf5, anc63, mas244
  def is_overlord?
    @is_overlord ||= catalog_overlord?
  end

  def is_super_user?
    @is_super_user ||= super_users.count > 0
  end

  def is_service_provider?(ssr)
    is_provider = false
    orgs = []
    orgs << ssr.organization << ssr.organization.parents
    orgs.flatten!
    orgs.each do |org|
      provider_ids = org.service_providers_lookup.map(&:identity_id)
      is_provider = true if provider_ids.include?(id)
    end

    is_provider
  end

  ###############################################################################
  ############################# SEARCH METHODS ##################################
  ###############################################################################

  def self.search(term)
    Directory.search(term)
  end

  ###############################################################################
  ########################### PERMISSION METHODS ################################
  ###############################################################################

  # DEVISE specific methods
  def self.find_for_shibboleth_oauth(auth, _signed_in_resource = nil)
    identity = Identity.where(ldap_uid: auth.uid).first

    unless identity
      identity = Identity.create ldap_uid: auth.uid, first_name: auth.info.first_name, last_name: auth.info.last_name, email: auth.info.email, password: Devise.friendly_token[0, 20], approved: true
    end
    identity
  end

  def self.find_for_cas_oauth(auth, _signed_in_resource = nil)
    Directory.search(auth.uid).first
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
      where(conditions).where(['lower(ldap_uid) = :value', { value: login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def self.send_reset_password_instructions(attributes = {})
    recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    if !recoverable.approved?
      recoverable.errors[:base] << I18n.t('devise.failure.not_approved')
    elsif recoverable.persisted?
      recoverable.send_reset_password_instructions
    end
    recoverable
  end

  def send_admin_mail
    Notifier.new_identity_waiting_for_approval(self).deliver_now unless approved
  end

  # Only users with request or approve rights can edit.
  def can_edit_service_request?(sr)
    can_edit = false

    if (sr.service_requester_id == id || sr.service_requester_id.nil?) && sr.is_editable?
      can_edit = true
    elsif sr.is_editable? && has_correct_project_role?(sr)
      can_edit = true
    end

    can_edit
  end

  # If a user has request or approve rights AND the request is editable, then the user can edit.
  def can_edit_sub_service_request?(ssr)
    return true if ssr.can_be_edited? && has_correct_project_role?(ssr)

    false
  end

  def has_correct_project_role?(request)
    project_roles.each do |pr|
      if (pr.protocol_id == requests_protocol_id(request)) && %w(approve request).include?(pr.project_rights)
        return true
      end
    end

    false
  end

  def requests_protocol_id(request)
    id = if request.class == ServiceRequest
           request.try(:protocol).try(:id)
         else
           request.service_request.try(:protocol).try(:id)
         end

    id
  end

  # Determines whether this identity can edit a given organization's information in CatalogManager.
  # Returns true if this identity's catalog_manager_organizations includes the given organization.
  def can_edit_entity?(organization, deep_search = false)
    cm_org_ids = catalog_managers.map(&:organization_id)
    if deep_search
      org_ids = [organization.id].concat(organization.parents(true))
      org_ids - cm_org_ids != org_ids
    else
      cm_org_ids.include?(organization.id)
    end
  end

  # Used in clinical fulfillment to determine whether the user can edit a particular core.
  def can_edit_core?(org_id)
    clinical_provider_organizations.map(&:id).include?(org_id) ? true : false
  end

  # Determines whether the user has permission to edit historical data for a given organization.
  # Returns true if the edit_historic_data flag is set to true on the relevant catalog_manager relationship.
  def can_edit_historical_data_for?(organization)
    if catalog_manager_organizations.include?(organization)
      if catalog_managers.find_by_organization_id(organization.id)
        if catalog_managers.find_by_organization_id(organization.id).edit_historic_data
          return true
        else
          return can_edit_historical_data_for? organization.parent
        end
      else
        return can_edit_historical_data_for? organization.parent
      end
    end

    false
  end

  # Determines whether the user has permission to access the admin portal for a given organization.
  # Returns true if the user is a super user or service provider for the given organization or
  # any of its parents. (Recursively calls itself to climb the tree of parents)
  def can_edit_fulfillment?(organization)
    arr = []
    arr << super_users.map(&:organization_id)
    arr << service_providers.map(&:organization_id)
    arr = arr.flatten.uniq
    if organization.type == 'Institution'
      arr.include? organization.id
    else
      can_edit_fulfillment?(organization.parent) || arr.include?(organization.id)
    end
  end

  ###############################################################################
  ########################### COLLECTION METHODS ################################
  ###############################################################################

  # Collects all organizations that this identity has catalog manager permissions on, as well as
  # any child (deep) of any of those organizations.
  # Returns an array of organizations.
  def catalog_manager_organizations
    organizations = Organization.all
    orgs = []

    catalog_managers.map(&:organization).each do |org|
      orgs << org.all_children(organizations)
    end

    orgs.flatten.uniq
  end

  # Returns an array of organizations where the user has clinical provider rights.
  def clinical_provider_organizations
    organizations = Organization.all
    orgs = []

    clinical_providers.map(&:organization).each do |org|
      orgs << org.all_children(organizations)
    end

    admin_organizations(su_only: true).each do |org|
      orgs << org
    end

    orgs.flatten.uniq
  end

  # Collects all organizations that this identity has super user or service provider permissions
  # on, as well as any child (deep) of any of those organizations.
  # Returns an array of organizations.
  # If you pass in "su_only" it only returns organizations for whom you are a super user.
  def admin_organizations(su_only = { su_only: false })
    orgs = Organization.all
    organizations = []
    arr = organizations_for_users(orgs, su_only)

    arr.each do |org|
      organizations << org.all_children(orgs)
    end

    # #In case orgs is empty, return an empty array, instead of crashing.
    begin
      organizations.flatten!.compact.uniq
    rescue
      return []
    end

    organizations
  end

  def organizations_for_users(orgs, su_only)
    arr = []
    super_users.each do |user|
      orgs.each do |org|
        arr << org if user.organization_id == org.id
      end
    end

    unless su_only[:su_only] == true
      service_providers.each do |user|
        orgs.each do |org|
          arr << org if user.organization_id == org.id
        end
      end
    end
    arr = arr.flatten.compact.uniq

    arr
  end

  def clinical_provider_rights?
    # TODO: should look at all tagged with CTRC
    org = Organization.tagged_with('ctrc').first
    if !clinical_providers.empty? || admin_organizations(su_only: true).include?(org)
      return true
    else
      return false
    end
  end

  def clinical_provider_for_ctrc?
    # TODO: should look at all tagged with CTRC
    org = Organization.tagged_with('ctrc').first
    return false if org.nil? # if no orgs have nexus tag
    clinical_providers.each do |provider|
      return true if provider.organization_id == org.id
    end

    false
  end

  # Collects all sub service requests under this identity's admin_organizations and sorts that
  # list by the status of the sub service requests.
  # Used to populate the table (as selectable by the dropdown) in the admin index.
  def admin_service_requests_by_status(org_id = nil, admin_orgs = nil)
    # #Default to all ssrs, if we get an org_id, only get that organization's ssrs
    ssrs = []
    if org_id
      ssrs = Organization.find(org_id).sub_service_requests
    elsif admin_orgs && !admin_orgs.empty?
      ssrs = SubServiceRequest.where("sub_service_requests.organization_id in (#{admin_orgs.map(&:id).join(', ')})").includes(:owner, line_items: :service, service_request: [:service_requester, protocol: { project_roles: :identity }])
    else
      admin_organizations.each do |org|
        ssrs << SubServiceRequest.where(organization_id: org.id).includes(line_items: :service, service_request: :protocol).to_a
      end
      ssrs.flatten!
    end

    hash = {}

    ssrs.each do |ssr|
      next if ssr.status.blank? || ssr.status == 'first_draft'
      next unless ssr.service_request
      next unless ssr.service_request.protocol
      ssr_status = ssr.status.to_s.gsub(/\s/, '_').gsub(/[^-\w]/, '').downcase
      hash[ssr_status] = [] unless hash[ssr_status]
      hash[ssr_status] << ssr
    end

    hash
  end

  ###############################################################################
  ########################## NOTIFICATION METHODS ###############################
  ###############################################################################

  # Collects all notifications for this identity based on their user notifications (as notifications
  # do not belong to individual identities).
  # Returns an array of Notifications.
  def all_notifications
    ids = user_notifications.map(&:notification_id)
    all_notifications = Notification.where(id: ids)

    all_notifications
  end

  # Returns the count of unread notifications for this identity, based on their user_notifications
  # (where the :read flag is set).
  def unread_notification_count(user)
    notification_count = 0
    notifications = all_notifications

    notifications.each do |notification|
      notification_count += 1 unless notification.user_notifications_for_current_user(user).order('created_at DESC').first.read
    end

    notification_count
  end
end
