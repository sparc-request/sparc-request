require 'directory'

class Identity < ActiveRecord::Base
  after_create :send_admin_mail

  #Version.primary_key = 'id'
  #has_paper_trail

  #### DEVISE SETUP ####
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :company, :reason, :approved
  # attr_accessible :title, :body
  #### END DEVISE SETUP ####

  has_many :approvals, :dependent => :destroy
  has_many :project_roles, :dependent => :destroy
  has_many :protocols, :through => :project_roles
  has_many :projects, :through => :project_roles, :source => :protocol, :conditions => "protocols.type = 'Project'"
  has_many :studies, :through => :project_roles, :source => :protocol, :conditions => "protocols.type = 'Study'"
  has_many :super_users, :dependent => :destroy
  has_many :catalog_managers, :dependent => :destroy
  has_many :clinical_providers, :dependent => :destroy
  has_many :protocol_service_requests, :through => :protocols, :source => :service_requests
  has_many :requested_service_requests, :class_name => 'ServiceRequest', :foreign_key => 'service_requester_id'
  has_many :catalog_manager_rights, :class_name => 'CatalogManager'
  has_many :service_providers, :dependent => :destroy
  has_many :notifications, :foreign_key => 'originator_id'
  has_many :sent_messages, :class_name => 'Message', :foreign_key => 'from'
  has_many :received_messages, :class_name => 'Message', :foreign_key => 'to'
  has_many :user_notifications, :dependent => :destroy
  has_many :received_toast_messages, :class_name => 'ToastMessage', :foreign_key => 'to', :dependent => :destroy
  has_many :sent_toast_messages, :class_name => 'ToastMessage', :foreign_key => 'from', :dependent => :destroy
  has_many :notes, :dependent => :destroy

  # TODO: Identity doesn't really have many sub service requests; an
  # identity is the owner of many sub service requests.  We need a
  # better name here.
  # has_many :sub_service_requests, :foreign_key => 'owner_id'

  attr_accessible :ldap_uid
  attr_accessible :obisid
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
  validates_presence_of :ldap_uid

  ###############################################################################
  ############################## HELPER METHODS #################################
  ###############################################################################

  # Returns this user's first and last name humanized.
  def full_name
    "#{first_name.try(:humanize)} #{last_name.try(:humanize)}".lstrip.rstrip
  end

 # Returns this user's first and last name humanized, with their email.
  def display_name
    "#{first_name.try(:humanize)} #{last_name.try(:humanize)} (#{email})".lstrip.rstrip
  end

  ###############################################################################
  ############################ ATTRIBUTE METHODS ################################
  ###############################################################################

  # Returns true if the user is a catalog overlord.  Should only be true for three uids:
  # jug2, anc63, mas244
  def is_overlord?
    self.catalog_overlord?
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
    identity = Identity.where(:ldap_uid => auth.uid).first

    unless identity
      identity = Identity.create :ldap_uid => auth.uid, :first_name => auth.info.first_name, :last_name => auth.info.last_name, :email => auth.info.email, :password => Devise.friendly_token[0,20], :approved => true
    end
    identity
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
      where(conditions).where(["lower(ldap_uid) = :value", { :value => login.downcase }]).first
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
      Notifier.new_identity_waiting_for_approval(self).deliver
    end
  end

  # Determines whether this identity (that is a user) can edit a service request based on its status.
  # Users can only edit service requests (as a whole) if none of their constituent sub_service_requests
  # have been moved out of 'draft' or 'submitted' status.
  def can_edit_service_request? service_request
    # things to consider
    # service_request status == first_draft or draft or submitted or obtain_research_pricing
    # if all sub_service_request statuses == all draft or all submitted, no mix and match
    # identity project role, i believe only request and approve can edit
    statuses = ['draft', 'submitted', 'obtain_research_pricing']

    if service_request.status == 'first_draft' and (service_request.service_requester_id == self.id or service_request.service_requester_id.nil?)
      return true
    else
      sub_service_requests_statuses = service_request.sub_service_requests.map(&:status)
      if statuses.include?(service_request.status) and
         (sub_service_requests_statuses.map{|s| s == 'draft'}.all? or sub_service_requests_statuses.map{|s| s == 'submitted'}.all? or sub_service_requests_statuses.map{|s| s == 'obtain_research_pricing'}.all?) and
         !self.project_roles.select{|pr| pr.protocol_id == service_request.try(:protocol).try(:id) and ['approve', 'request'].include? pr.project_rights}.empty?
        return true
      end
    end

    return false
  end

  # Determines whether this identity (that is a user) can edit a given sub_service_request that is
  # a child of this service request.
  # TODO: Not sure why this method is on the ServiceRequest rather than on the SubServiceRequest
  def can_edit_sub_service_request? sub_service_request
    # things to consider
    # 1. sub_service_requests statuses == draft or submitted or obtain_research_pricing
    # 2. identity project role, i believe only request and approve can edit
    if (sub_service_request.status == 'draft' or sub_service_request.status == 'submitted' or sub_service_request.status == 'obtain_research_pricing') and
       self.project_roles.select{|pr| pr.protocol_id == sub_service_request.service_request.try(:protocol).try(:id) and ['approve', 'request'].include? pr.project_rights}
      return true
    end

    return false
  end

  # Determines whether this identity can edit a given organization's information in CatalogManager.
  # Returns true if this identity's catalog_manager_organizations includes the given organization.
  def can_edit_entity? organization
    self.catalog_manager_organizations.include?(organization) ? true : false
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

  # Determines whether the user has permission to access the admin portal for a given organization.
  # Returns true if the user is a super user or service provider for the given organization or
  # any of its parents. (Recursively calls itself to climb the tree of parents)
  def can_edit_fulfillment? organization
    arr = []
    arr << self.super_users.map(&:organization_id)
    arr << self.service_providers.map(&:organization_id)
    arr = arr.flatten.uniq
    if organization.type == 'Institution'
      arr.include? organization.id 
    else
      can_edit_fulfillment? organization.parent or arr.include? organization.id
    end
  end

  ###############################################################################
  ########################### COLLECTION METHODS ################################
  ###############################################################################

  # Collects all organizations that this identity has catalog manager permissions on, as well as
  # any child (deep) of any of those organizations.
  # Returns an array of organizations.
  def catalog_manager_organizations
    orgs = []

    self.catalog_managers.map(&:organization).each do |org|
      orgs << org.all_children
    end

    orgs.flatten.uniq
  end

  # Collects all organizations that this identity has super user or service provider permissions
  # on, as well as any child (deep) of any of those organizations.
  # Returns an array of organizations.
  # If you pass in "su_only" it only returns organizations for whom you are a super user.
  def admin_organizations su_only = {:su_only => false}
    orgs = []
    arr = []
    arr << self.super_users.map(&:organization)
    unless su_only[:su_only] == true
      arr << self.service_providers.map(&:organization)
    end
    arr = arr.flatten.compact.uniq

    arr.each do |org|
      orgs << org.all_children
    end
    orgs.flatten.compact.uniq
  end

  # Collects all workflow states that are available to the given user based on what organizations
  # they have permissions to.
  # Currently serves largely to insert CTRC statuses if this identity has permissions for the CTRC.
  # Returns an array of statuses as strings.
  def available_workflow_states
    available_statuses = AVAILABLE_STATUSES.collect { |k, v| v }
    ctrc_organizations = Organization.tagged_with 'ctrc'
    if ctrc_organizations.map(&:service_providers).flatten.map(&:identity_id).include?(self.id) || ctrc_organizations.map(&:super_users).flatten.map(&:identity_id).include?(self.id)
      available_statuses
    else
      available_statuses.delete('CTRC Review')
      available_statuses.delete('CTRC Approved')
      available_statuses
    end
  end  
  
  # Collects all sub service requests under this identity's admin_organizations and sorts that
  # list by the status of the sub service requests.
  # Used to populate the table (as selectable by the dropdown) in the admin index.
  def admin_service_requests_by_status org_id = nil
    ##Default to all ssrs, if we get an org_id, only get that organization's ssrs
    if org_id
      ssrs = Organization.find(org_id).sub_service_requests
    else
      ssrs = self.admin_organizations.map(&:sub_service_requests).flatten
    end

    hash = {}

    ssrs.each do |ssr|
      unless ssr.status.blank? or ssr.status == 'first_draft'
        if ssr.service_request
          if ssr.service_request.protocol
            ssr_status = ssr.status.to_s.gsub(/\s/, "_").gsub(/[^-\w]/, "").downcase
            hash[ssr_status] = [] unless hash[ssr_status]
            hash[ssr_status] << ssr
          end
        end
      else

      end
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
    ids = self.user_notifications.map {|x| x.notification_id}
    all_notifications = Notification.where(:id => ids)

    all_notifications
  end

  # Returns the count of unread notifications for this identity, based on their user_notifications
  # (where the :read flag is set).
  def unread_notification_count user
    notification_count = 0
    notifications = self.all_notifications
    
    notifications.each do |notification|
      notification_count += 1 unless notification.user_notifications_for_current_user(user).order('created_at DESC').first.read
    end

    notification_count
  end

end
