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

class Protocol < ActiveRecord::Base

  include RemotelyNotifiable

  audited

  has_many :study_types,                  dependent: :destroy
  has_one :research_types_info,           dependent: :destroy
  has_one :human_subjects_info,           dependent: :destroy
  has_one :vertebrate_animals_info,       dependent: :destroy
  has_one :investigational_products_info, dependent: :destroy
  has_one :ip_patents_info,               dependent: :destroy
  has_many :project_roles,                dependent: :destroy
  has_many :identities,                   through: :project_roles
  has_many :service_requests
  has_many :services,                     through: :service_requests
  has_many :sub_service_requests,         through: :service_requests
  has_many :organizations,                through: :sub_service_requests
  has_many :affiliations,                 dependent: :destroy
  has_many :impact_areas,                 dependent: :destroy
  has_many :arms,                         dependent: :destroy
  has_many :study_type_answers,           dependent: :destroy
  has_many :notes, as: :notable,          dependent: :destroy
  has_many :study_type_questions,         through: :study_type_question_group
  has_many :documents,                    dependent: :destroy

  has_many :principal_investigators, -> { where(project_roles: { role: %w(pi primary-pi) }) },
    source: :identity, through: :project_roles
  has_many :billing_managers, -> { where(project_roles: { role: 'business-grants-manager' }) },
    source: :identity, through: :project_roles
  has_many :coordinators, -> { where(project_roles: { role: 'research-assistant-coordinator' }) },
    source: :identity, through: :project_roles

  belongs_to :study_type_question_group

  attr_accessible :affiliations_attributes
  attr_accessible :archived
  attr_accessible :arms_attributes
  attr_accessible :billing_business_manager_static_email
  attr_accessible :brief_description
  attr_accessible :end_date
  attr_accessible :federal_grant_code_id
  attr_accessible :federal_grant_serial_number
  attr_accessible :federal_grant_title
  attr_accessible :federal_non_phs_sponsor
  attr_accessible :federal_phs_sponsor
  attr_accessible :funding_rfa
  attr_accessible :funding_source
  attr_accessible :funding_source_other
  attr_accessible :funding_start_date
  attr_accessible :funding_status
  attr_accessible :human_subjects_info_attributes
  attr_accessible :identity_id
  attr_accessible :impact_areas_attributes
  attr_accessible :indirect_cost_rate
  attr_accessible :investigational_products_info_attributes
  attr_accessible :ip_patents_info_attributes
  attr_accessible :last_epic_push_status
  attr_accessible :last_epic_push_time
  attr_accessible :next_ssr_id
  attr_accessible :potential_funding_source
  attr_accessible :potential_funding_source_other
  attr_accessible :potential_funding_start_date
  attr_accessible :project_roles_attributes
  attr_accessible :recruitment_end_date
  attr_accessible :recruitment_start_date
  attr_accessible :requester_id
  attr_accessible :research_types_info_attributes
  attr_accessible :selected_for_epic
  attr_accessible :short_title
  attr_accessible :sponsor_name
  attr_accessible :start_date
  attr_accessible :study_phase
  attr_accessible :study_type_answers_attributes
  attr_accessible :study_type_question_group_id
  attr_accessible :study_types_attributes
  attr_accessible :title
  attr_accessible :type
  attr_accessible :udak_project_number
  attr_accessible :vertebrate_animals_info_attributes

  attr_accessor :requester_id
  attr_accessor :validate_nct
  attr_accessor :study_type_questions

  accepts_nested_attributes_for :research_types_info
  accepts_nested_attributes_for :human_subjects_info
  accepts_nested_attributes_for :vertebrate_animals_info
  accepts_nested_attributes_for :investigational_products_info
  accepts_nested_attributes_for :ip_patents_info
  accepts_nested_attributes_for :study_types,                   allow_destroy: true
  accepts_nested_attributes_for :impact_areas,                  allow_destroy: true
  accepts_nested_attributes_for :affiliations,                  allow_destroy: true
  accepts_nested_attributes_for :project_roles,                 allow_destroy: true
  accepts_nested_attributes_for :arms,                          allow_destroy: true
  accepts_nested_attributes_for :study_type_answers,            allow_destroy: true

  validation_group :protocol do
    validates :short_title,                    presence: true
    validates :title,                          presence: true
    validates :funding_status,                 presence: true
    validate  :validate_funding_source
    validates_associated :human_subjects_info, message: "must contain 8 numerical digits", if: :validate_nct
  end

  validation_group :user_details do
    validate :validate_proxy_rights
    validate :primary_pi_exists
  end

  scope :for_identity, -> (identity) {
    joins(:project_roles).
    where(project_roles: { identity_id: identity.id }).
    where.not(project_roles: { project_rights: 'none' })
  }

  filterrific(
    default_filter_params: { show_archived: 0 },
    available_filters: [
      :search_query,
      :admin_filter,
      :show_archived,
      :with_status,
      :with_organization,
      :with_owner,
      :sorted_by
    ]
  )

  scope :search_query, -> (search_term) {
    # Searches protocols based on short_title, title, id, and associated_users
    # Protects against SQL Injection with ActiveRecord::Base::sanitize

    # inserts ! so that we can escape special characters
    escaped_search_term = search_term.to_s.gsub(/[!%_]/) { |x| '!' + x }

    like_search_term = ActiveRecord::Base::sanitize("%#{escaped_search_term}%")
    exact_search_term = ActiveRecord::Base::sanitize(search_term)

    #TODO temporary replacement for "MATCH(identities.first_name, identities.last_name) AGAINST (#{exact_search_term})"
    where_clause = ["CONCAT(identities.first_name, ' ', identities.last_name) LIKE #{like_search_term} escape '!'"]

    where_clause += ["protocols.short_title like #{like_search_term} escape '!'",
      "protocols.title like #{like_search_term} escape '!'",
      "protocols.id = #{exact_search_term}"]

    joins(:identities).
      where(where_clause.compact.join(' OR ')).
      distinct
  }

  scope :for_identity_id, -> (identity_id) {
    return nil if identity_id == '0'
    joins(:project_roles).
      where(project_roles: { identity_id: identity_id }).
      where.not(project_roles: { project_rights: 'none' })
  }

  scope :admin_filter, -> (params) {
    filter, id  = params.split(" ")
    if filter == 'for_admin'
      for_admin(id)
    elsif filter == 'for_identity'
      for_identity_id(id)
    end
  }

  scope :for_admin, -> (identity_id) {
    # returns protocols with ssrs in orgs authorized for identity_id
    return nil if identity_id == '0'

    ssrs = SubServiceRequest.where.not(status: 'first_draft').where(organization_id: Organization.authorized_for_identity(identity_id))

    joins(:sub_service_requests).
      merge(ssrs).distinct
  }

  scope :show_archived, -> (boolean) {
    where(archived: boolean)
  }

  scope :with_status, -> (statuses) {
    # returns protocols with ssrs in statuses
    statuses = statuses.split.flatten.reject(&:blank?)
    return nil if statuses.empty?
    joins(:sub_service_requests).
      where(sub_service_requests: { status: statuses }).distinct
  }

  scope :with_organization, -> (org_ids) {
    # returns protocols with ssrs in org_ids
    org_ids = org_ids.split.flatten.reject(&:blank?)
    return nil if org_ids.empty?
    joins(:sub_service_requests).
      where(sub_service_requests: { organization_id: org_ids }).distinct
  }

  scope :with_owner, -> (owner_ids) {
    owner_ids = owner_ids.split.flatten.reject(&:blank?)
    return nil if owner_ids.empty?
    joins(:sub_service_requests).
    where(sub_service_requests: {owner_id: owner_ids}).
      where.not(sub_service_requests: {status: 'first_draft'})
  }

  scope :sorted_by, -> (key) {
    arr         = key.split(' ')
    sort_name   = arr[0]
    sort_order  = arr[1]
    case sort_name
    when 'id'
      order("id #{sort_order.upcase}")
    when 'short_title'
      order("TRIM(REPLACE(short_title, CHAR(9), ' ')) #{sort_order.upcase}")
    when 'pis'
      joins(project_roles: :identity).where(project_roles: { role: 'primary-pi' }).order(".identities.first_name #{sort_order.upcase}")
    end
  }

  def is_study?
    self.type == 'Study'
  end

  def is_epic?
    USE_EPIC
  end

  # virgin project:  a project that has never been a study
  def virgin_project?
    selected_for_epic.nil?
  end

  def is_project?
    self.type == 'Project'
  end

  # Determines whether a protocol contains a service_request with only a "first draft" status
  def has_first_draft_service_request?
    service_requests.any? && service_requests.map(&:status).all? { |status| status == 'first_draft'}
  end

  def active?
    study_type_question_group.active
  end

  def activate
    update_attribute(:study_type_question_group_id, StudyTypeQuestionGroup.active.pluck(:id).first)
  end

  def email_about_change_in_authorized_user(modified_role, action)
    # Alert authorized users of deleted authorized user
    # Send emails if SEND_AUTHORIZED_USER_EMAILS is set to true and if there are any non-draft SSRs
    # For example:  if a SR has SSRs all with a status of 'draft', don't send emails
    if SEND_AUTHORIZED_USER_EMAILS && sub_service_requests.where.not(status: 'draft').any?
      alert_users = emailed_associated_users << modified_role
      alert_users.flatten.uniq.each do |project_role|
        UserMailer.authorized_user_changed(project_role.identity, self, modified_role, action).deliver unless project_role.identity.email.blank?
      end
    end
  end

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

  def primary_principal_investigator
    primary_pi_project_role.try(:identity)
  end

  def primary_pi_project_role
    project_roles.find_by(role: 'primary-pi')
  end

  def billing_business_manager_email
    billing_business_manager_static_email.blank? ?  billing_managers.map(&:email).try(:join, ', ') : billing_business_manager_static_email
  end

  def coordinator_emails
    coordinators.pluck(:email).join(', ')
  end

  def emailed_associated_users
    project_roles.reject {|pr| pr.project_rights == 'none'}
  end

  def primary_pi_exists
    errors.add(:base, "You must add a Primary PI to the study/project") unless project_roles.map(&:role).include? 'primary-pi'
    errors.add(:base, "Only one Primary PI is allowed. Please ensure that only one exists") if project_roles.select { |pr| pr.role == 'primary-pi'}.count > 1
  end

  def role_for(identity)
    project_roles.find_by(identity_id: identity.id).try(:role)
  end

  def role_other_for(identity)
    role_for(identity)
  end

  def subspecialty_for(identity)
    identity.subspecialty
  end

  def all_child_sub_service_requests
    sub_service_requests
  end

  def display_protocol_id_and_title
    "#{self.id} - #{self.short_title}"
  end

  def epic_title
    epic_title = "#{self.short_title} - #{self.title}"
    epic_title.truncate(195)
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

  # Note: this method is called inside a child thread by the service
  # requests controller.  Be careful adding code here that might not be
  # thread-safe.
  def push_to_epic(epic_interface)
    begin
      self.last_epic_push_time = Time.now
      self.last_epic_push_status = 'started'
      save(validate: false)

      Rails.logger.info("Sending study message to Epic")
      epic_interface.send_study(self)

      self.last_epic_push_status = 'complete'
      save(validate: false)

      EpicQueueRecord.create(protocol_id: self.id, status: self.last_epic_push_status)
    rescue Exception => e
      Rails.logger.info("Push to Epic failed.")

      self.last_epic_push_status = 'failed'
      save(validate: false)
      EpicQueueRecord.create(protocol_id: self.id, status: self.last_epic_push_status)
      raise e
    end
  end

  def awaiting_approval_for_epic_push
    self.last_epic_push_time = nil
    self.last_epic_push_status = 'awaiting_approval'
    save(validate: false)
  end

  def awaiting_final_review_for_epic_push
    self.last_epic_push_time = nil
    self.last_epic_push_status = 'awaiting_final_review'
    save(validate: false)
  end

  def ensure_epic_user
    primary_pi_project_role.set_epic_rights.save
    project_roles.reload
  end

  # Returns true if there is a push to epic in progress, false
  # otherwise.  If no push has been initiated, return false.
  def push_to_epic_in_progress?
    %w(started sent_study).include? last_epic_push_status
  end

  # Returns true if the most push to epic has completed.  Returns false
  # if no push has been initiated.
  def push_to_epic_complete?
    %w(complete failed).include? last_epic_push_status
  end

  def populate_for_edit
    project_roles.each do |pr|
      pr.populate_for_edit
    end
  end

  def create_arm(args)
    arm = self.arms.new(args)
    if arm.valid?
      arm.save
      self.service_requests.each do |service_request|
        service_request.per_patient_per_visit_line_items.each do |li|
          arm.create_line_items_visit(li)
        end
      end
    end

    # Lets return this in case we need it for something else
    arm
  end

  def should_push_to_epic?
    service_requests.any?(&:should_push_to_epic?)
  end

  def has_nexus_services?
    service_requests.where.not(status: 'first_draft').
      any?(&:has_ctrc_clinical_services?)
  end

  def find_sub_service_request_with_ctrc(service_request)
    service_request.sub_service_requests.find(&:ctrc?).try(:ssr_id)
  end

  def any_service_requests_to_display?
    service_requests.where.not(status: 'first_draft').first
  end

  def has_line_items_of_type?(current_request, portal, type)
    return self.service_requests.detect do |sr|
      next unless ((type == "otf") ? sr.has_one_time_fee_services? : sr.has_per_patient_per_visit_services?)
      #Only return first_draft sr's if NOT in portal, AND the current_request == the sr variable
      sr.status == "first_draft" ? (!portal && current_request == sr) : true
    end
  end

  def direct_cost_total(service_request)
    service_requests.where('status != ? OR id = ?', 'first_draft', service_request.id).
      to_a.sum(&:direct_cost_total)
  end

  def indirect_cost_total(service_request)
    if USE_INDIRECT_COST
      service_requests.where('(status != ? AND status != ?) OR id = ?', 'first_draft', 'draft', service_request.id).
        to_a.sum(&:indirect_cost_total)
    else
      0
    end
  end

  def grand_total(service_request)
    direct_cost_total(service_request) + indirect_cost_total(service_request)
  end

  def arm_cleanup
    return unless self.arms.count > 0

    remove_arms = true

    self.service_requests.each do |sr|
      if sr.has_per_patient_per_visit_services?
        remove_arms = false
        break
      end
    end

    if remove_arms
      self.arms.destroy_all
    end
  end

  def has_non_first_draft_ssrs?
    sub_service_requests.where.not(status: 'first_draft').any?
  end

  private

  def notify_remote_around_update?
    true
  end

  def remotely_notifiable_attributes_to_watch_for_change
    ["short_title"]
  end
end
