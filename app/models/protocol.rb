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

class Protocol < ApplicationRecord

  include RemotelyNotifiable

  audited

  has_many :study_types,                  dependent: :destroy
  has_one :research_types_info,           dependent: :destroy
  has_one :human_subjects_info,           dependent: :destroy
  has_one :vertebrate_animals_info,       dependent: :destroy
  has_one :investigational_products_info, dependent: :destroy
  has_one :ip_patents_info,               dependent: :destroy
  has_many :project_roles,                dependent: :destroy
  has_one :primary_pi_role,               -> { where(role: 'primary-pi') }, class_name: "ProjectRole", dependent: :destroy
  has_many :identities,                   through: :project_roles
  has_many :service_requests
  has_many :services,                     through: :service_requests
  has_many :sub_service_requests
  has_many :line_items,                   through: :service_requests
  has_many :organizations,                through: :sub_service_requests
  has_many :affiliations,                 dependent: :destroy
  has_many :impact_areas,                 dependent: :destroy
  has_many :arms,                         dependent: :destroy
  has_many :study_type_answers,           dependent: :destroy
  has_many :notes, as: :notable,          dependent: :destroy
  has_many :study_type_questions,         through: :study_type_question_group
  has_many :documents,                    dependent: :destroy
  has_many :submissions,                  dependent: :destroy

  has_many :principal_investigators, -> { where(project_roles: { role: %w(pi primary-pi) }) },
    source: :identity, through: :project_roles
  has_many :non_pi_authorized_users, -> { where.not(project_roles: { role: %w(pi primary-pi) }) },
    source: :identity, through: :project_roles
  has_many :billing_managers, -> { where(project_roles: { role: 'business-grants-manager' }) },
    source: :identity, through: :project_roles
  has_many :coordinators, -> { where(project_roles: { role: 'research-assistant-coordinator' }) },
    source: :identity, through: :project_roles

  has_and_belongs_to_many :study_phases
  belongs_to :study_type_question_group

  validates :research_master_id, numericality: { only_integer: true }, allow_blank: true
  validates :research_master_id, presence: true, if: "RESEARCH_MASTER_ENABLED && has_human_subject_info?"

  validates :indirect_cost_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1000 }, allow_blank: true

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

  def has_human_subject_info?
    self.research_types_info.try(:human_subjects) || false
  end

  validate :existing_rm_id,
    if: -> record { RESEARCH_MASTER_ENABLED && !record.research_master_id.nil? }

  validate :unique_rm_id_to_protocol,
    if: -> record { RESEARCH_MASTER_ENABLED && !record.research_master_id.nil? }

  def self.to_csv(protocols)
    CSV.generate do |csv|
      ##Insert headers
      csv << ["Protocol ID", "Project/Study", "Short Title", "Primary Principal Investigator(s)"]
      ##Insert data for each protocol
      protocols.each do |p|
        csv << [p.id, p.is_study? ? "Study" : "Project", p.short_title, p.principal_investigators.map(&:full_name).join(', ')]
      end
    end
  end

  def existing_rm_id
    rm_ids = HTTParty.get(RESEARCH_MASTER_API + 'research_masters.json', headers: {'Content-Type' => 'application/json', 'Authorization' => "Token token=\"#{RMID_API_TOKEN}\""})
    ids = rm_ids.map{ |rm_id| rm_id['id'] }

    unless ids.include?(self.research_master_id)
      errors.add(:_, 'The entered Research Master ID does not exist. Please go to the Research Master website to create a new record.')
    end
  end

  def unique_rm_id_to_protocol
    Protocol.all.each do |protocol|
      if self.id != protocol.id
        if self.research_master_id == protocol.research_master_id
          errors.add(:_, "The Research Master ID is already taken by Protocol #{protocol.id}. Please enter another RMID.")
        end
      end
    end
  end

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

  scope :search_query, lambda { |search_attrs|
    # Searches protocols based on 'Authorized User', 'HR#', 'PI', 'Protocol ID', 'PRO#', 'RMID', 'Short/Long Title', OR 'Search All'
    # Protects against SQL Injection with ActiveRecord::Base::sanitize
    # inserts ! so that we can escape special characters
    escaped_search_term = search_attrs[:search_text].to_s.gsub(/[!%_]/) { |x| '!' + x }

    escaped_search_term = search_attrs[:search_text].to_s.gsub(/[!%_]/) { |x| '!' + x }

    like_search_term = ActiveRecord::Base.connection.quote("%#{escaped_search_term}%")
    exact_search_term = ActiveRecord::Base.connection.quote(search_attrs[:search_text])

    ### SEARCH QUERIES ###
    authorized_user_query  = "CONCAT(identities.first_name, ' ', identities.last_name) LIKE #{like_search_term} escape '!'"
    hr_query               = "human_subjects_info.hr_number LIKE #{like_search_term} escape '!'"
    pi_query               = "CONCAT(identities.first_name, ' ', identities.last_name) LIKE #{like_search_term} escape '!'"
    protocol_id_query      = "protocols.id = #{exact_search_term}"
    pro_num_query          = "human_subjects_info.pro_number LIKE #{like_search_term} escape '!'"
    rmid_query             = "protocols.research_master_id = #{exact_search_term}"
    title_query            = ["protocols.short_title LIKE #{like_search_term} escape '!'", "protocols.title LIKE #{like_search_term} escape '!'"]
    ### END SEARCH QUERIES ###
    hr_pro_ids = HumanSubjectsInfo.where([hr_query, pro_num_query].join(' OR ')).pluck(:protocol_id)
    hr_protocol_id_query = hr_pro_ids.empty? ? nil : "protocols.id in (#{hr_pro_ids.join(', ')})"

    case search_attrs[:search_drop]
    when "Authorized User"
      # To prevent overlap between the for_identity or for_admin scope, run the query unscoped
      # and combine with the old scope's values
      unscoped  = self.unscoped.joins(:non_pi_authorized_users).joins(:identities).where(authorized_user_query)
      others    = self.current_scope

      where(id: others & unscoped).distinct
    when "HR#"
      joins(:human_subjects_info).
        where(hr_query).distinct
    when "PI"
      unscoped  = self.unscoped.joins(:principal_investigators).where(pi_query)
      others    = self.current_scope

      where(id: others & unscoped).distinct
    when "Protocol ID"
      where(protocol_id_query).distinct
    when "PRO#"
      joins(:human_subjects_info).
        where(pro_num_query).distinct
    when "RMID"
      where(rmid_query).distinct
    when "Short/Long Title"
      where(title_query.join(' OR ')).distinct
    when ""
      all_query = [authorized_user_query, pi_query, protocol_id_query, title_query, hr_protocol_id_query, rmid_query]
      joins(:identities).
        where(all_query.compact.join(' OR ')).
        distinct
    end
  }

  scope :admin_filter, -> (params) {
    filter, id  = params.split(" ")
    if filter == 'for_admin'
      for_admin(id)
    elsif filter == 'for_identity'
      for_identity(id)
    end
  }

  scope :for_identity, -> (identity_id) {
    return nil if identity_id == '0'

    joins(:project_roles).
    where(project_roles: { identity_id: identity_id }).
    where.not(project_roles: { project_rights: 'none' })
  }

  scope :for_admin, -> (identity_id) {
    # returns protocols with ssrs in orgs authorized for identity
    return nil if identity_id == '0'

    ssrs = SubServiceRequest.where.not(status: 'first_draft').where(organization_id: Organization.authorized_for_identity(identity_id))

    if SuperUser.where(identity_id: identity_id).any?
      empty_protocol_ids  = includes(:sub_service_requests).where(sub_service_requests: { id: nil }).ids
      protocol_ids        = ssrs.distinct.pluck(:protocol_id)
      all_protocol_ids    = (protocol_ids + empty_protocol_ids).uniq

      where(id: all_protocol_ids)
    else
      joins(:sub_service_requests).merge(ssrs).distinct
    end
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
      order("protocols.id #{sort_order.upcase}")
    when 'short_title'
      order("TRIM(REPLACE(short_title, CHAR(9), ' ')) #{sort_order.upcase}")
    when 'pis'
      joins(primary_pi_role: :identity).order(".identities.first_name #{sort_order.upcase}")
    when 'requests'
      order("sub_service_requests_count #{sort_order.upcase}")
    end
  }

  def is_study?
    self.type == 'Study'
  end

  def is_epic?
    USE_EPIC
  end

  def is_project?
    self.type == 'Project'
  end

  def active?
    study_type_question_group.nil? ? false : study_type_question_group.active
  end

  def version_type
    study_type_question_group.nil? ? nil : study_type_question_group.version
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
  def push_to_epic(epic_interface, origin, identity_id=nil)
    begin
      self.last_epic_push_time = Time.now
      self.last_epic_push_status = 'started'
      save(validate: false)

      Rails.logger.info("Sending study message to Epic")
      epic_interface.send_study(self)

      self.last_epic_push_status = 'complete'
      save(validate: false)

      EpicQueueRecord.create(protocol_id: self.id, status: self.last_epic_push_status, origin: origin, identity_id: identity_id)
    rescue Exception => e
      Rails.logger.info("Push to Epic failed.")

      self.last_epic_push_status = 'failed'
      save(validate: false)
      EpicQueueRecord.create(protocol_id: self.id, status: self.last_epic_push_status, origin: origin, identity_id: identity_id)
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
    self.service_requests.
      where(id: service_request.id).
      or(service_requests.where.not(status: 'draft')).
      eager_load(:line_items, :arms).
      sum(&:direct_cost_total)
  end

  def indirect_cost_total(service_request)
    if USE_INDIRECT_COST
      self.service_requests.
        where(id: service_request.id).
        or(service_requests.where.not(status: ['first_draft', 'draft'])).
        eager_load(:line_items, :arms).
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

  def has_incomplete_additional_details?
    line_items.any?(&:has_incomplete_additional_details?)
  end

  private

  def notify_remote_around_update?
    true
  end

  def remotely_notifiable_attributes_to_watch_for_change
    ["short_title"]
  end
end
