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

class Protocol < ApplicationRecord
  include RemotelyNotifiable
  include SanitizedData

  sanitize_setter :short_title, :special_characters, :squish
  sanitize_setter :title, :special_characters, :squish
  sanitize_setter :brief_description, :special_characters, :squish

  audited

  belongs_to :study_type_question_group

  has_one :research_types_info,           dependent: :destroy
  has_one :human_subjects_info,           dependent: :destroy
  has_one :vertebrate_animals_info,       dependent: :destroy
  has_one :investigational_products_info, dependent: :destroy
  has_one :ip_patents_info,               dependent: :destroy

  has_one :primary_pi_role,               -> { where(role: 'primary-pi', project_rights: 'approve') }, class_name: "ProjectRole", dependent: :destroy
  has_one :primary_pi,                    through: :primary_pi_role, source: :identity

  has_many :study_types,                  dependent: :destroy
  has_many :project_roles,                dependent: :destroy
  has_many :service_requests,             dependent: :destroy
  has_many :sub_service_requests
  has_many :affiliations,                 dependent: :destroy
  has_many :impact_areas,                 dependent: :destroy
  has_many :arms,                         dependent: :destroy
  has_many :study_type_answers,           dependent: :destroy
  has_many :notes, as: :notable,          dependent: :destroy
  has_many :documents,                    dependent: :destroy

  has_and_belongs_to_many :study_phases

  has_many :identities,                   through: :project_roles
  has_many :services,                     through: :service_requests
  has_many :line_items,                   through: :service_requests
  has_many :line_items_visits,            through: :arms
  has_many :visit_groups,                 through: :arms
  has_many :visits,                       through: :arms
  has_many :organizations,                through: :sub_service_requests
  has_many :study_type_questions,         through: :study_type_question_group
  has_many :responses,                    through: :sub_service_requests

  has_many :principal_inveestigator_roles, -> { where(role: ['pi', 'primary-pi']) }, class_name: "ProjectRole", dependent: :destroy
  has_many :principal_investigators, through: :principal_inveestigator_roles, source: :identity

  has_many :non_principal_investigator_roles, -> { where.not(project_roles: { role: ['pi', 'primary-pi'] }) }, class_name: "ProjectRole", dependent: :destroy
  has_many :non_pi_authorized_users, through: :non_principal_investigator_roles, source: :identity

  has_many :billing_managers, -> { where(project_roles: { role: 'business-grants-manager' }) },
    source: :identity, through: :project_roles
  has_many :coordinators, -> { where(project_roles: { role: 'research-assistant-coordinator' }) },
    source: :identity, through: :project_roles

  ########################
  ### CWF Associations ###
  ########################

  has_many :fulfillment_protocols, class_name: 'Shard::Fulfillment::Protocol', foreign_key: :sparc_id

  attr_accessor :requester_id
  attr_accessor :validate_nct
  attr_accessor :study_type_questions
  attr_accessor :bypass_rmid_validation
  attr_accessor :bypass_stq_validation

  mattr_accessor :rmid_server_down

  accepts_nested_attributes_for :research_types_info
  accepts_nested_attributes_for :human_subjects_info
  accepts_nested_attributes_for :vertebrate_animals_info
  accepts_nested_attributes_for :investigational_products_info
  accepts_nested_attributes_for :ip_patents_info
  accepts_nested_attributes_for :study_types,                   allow_destroy: true
  accepts_nested_attributes_for :impact_areas,                  allow_destroy: true
  accepts_nested_attributes_for :affiliations,                  allow_destroy: true
  accepts_nested_attributes_for :primary_pi_role,               allow_destroy: true
  accepts_nested_attributes_for :arms,                          allow_destroy: true
  accepts_nested_attributes_for :study_type_answers,            allow_destroy: true

  validates :research_master_id, numericality: { only_integer: true }, allow_blank: true
  validates :research_master_id, presence: true, if: :rmid_requires_validation?

  validate :validate_existing_rmid, if: -> protocol { Setting.get_value('research_master_enabled') && protocol.research_master_id.present? }
  validate :validate_unique_rmid, if: -> protocol { Setting.get_value('research_master_enabled') && protocol.research_master_id.present? }

  validates :indirect_cost_rate, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 1000 }, allow_blank: true, if: :indirect_cost_enabled

  validates_presence_of :short_title, 
                        :title,
                        :funding_status
  validates_presence_of :funding_source,            if: Proc.new{ |p| p.funded? || p.funding_status.blank? }
  validates_presence_of :potential_funding_source,  if: :pending_funding?
  validates_associated :human_subjects_info, message: "must contain 8 numerical digits", if: :validate_nct
  validates_associated :primary_pi_role, message: "You must add a Primary PI to the study/project"

  def rmid_requires_validation?
    # bypassing rmid validations for overlords, admins, and super users only when in Dashboard [#139885925] & [#151137513]
    self.bypass_rmid_validation ? false : Setting.get_value('research_master_enabled') && has_human_subject_info?
  end

  def has_human_subject_info?
    self.research_types_info.try(:human_subjects) || false
  end

  def self.rmid_status
    @@rmid_server_down = false
    begin
      HTTParty.get(Setting.get_value("research_master_api") + 'research_masters.json', headers: {'Content-Type' => 'application/json', 'Authorization' => "Token token=\"#{Setting.get_value("rmid_api_token")}\""})
      return true
    rescue
      @@rmid_server_down = true
      return false
    end
  end

  def self.get_rmid(rmid)
    @@rmid_server_down = false
    begin
      HTTParty.get("#{Setting.get_value('research_master_api')}research_masters/#{rmid}.json", headers: { "Content-Type" => "application/json", "Authorization" => "Token token=\"#{Setting.get_value('rmid_api_token')}\"" })
    rescue
      @@rmid_server_down = true
      nil
    end
  end

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

  filterrific(
    default_filter_params: { show_archived: 0 },
    available_filters: [
      :search_query,
      :admin_filter,
      :show_archived,
      :with_status,
      :with_organization,
      :with_owner
    ]
  )

  scope :sorted, -> (sort, order) {
    sort  = 'id' if sort.blank?
    order = 'desc' if order.blank?

    case sort
    when 'id'
      order(id: order)
    when 'short_title'
      order("TRIM(REPLACE(short_title, CHAR(9), ' ')) #{order}")
    when 'pis'
      joins(primary_pi_role: :identity).order("identities.first_name" => order)
    when 'requests'
      order("sub_service_requests_count" => order)
    end
  }

  scope :search_query, lambda { |search_attrs|
    # Searches protocols based on 'Authorized User', 'PI', 'Protocol ID', 'PRO#', 'RMID', 'Short/Long Title', OR 'Search All'
    # Protects against SQL Injection with ActiveRecord::Base::sanitize
    # inserts ! so that we can escape special characters
    escaped_search_term = search_attrs[:search_text].to_s.gsub(/[!%_]/) { |x| "\\#{x}" }
    like_search_term    = "%#{escaped_search_term}%"

    ### SEARCH QUERIES ###
    identity_query    = Arel::Nodes::NamedFunction.new('concat', [Identity.arel_table[:first_name], Arel::Nodes.build_quoted(' '), Identity.arel_table[:last_name]]).matches(like_search_term).or(Identity.arel_table[:email].matches(like_search_term))
    protocol_id_query = Protocol.arel_table[:id].eq(search_attrs[:search_text])
    pro_num_query     = HumanSubjectsInfo.arel_table[:pro_number].matches(like_search_term)
    rmid_query        = Protocol.arel_table[:research_master_id].eq(search_attrs[:search_text])
    title_query       = Protocol.arel_table[:short_title].matches(like_search_term).or(Protocol.arel_table[:title].matches(like_search_term))
    ### END SEARCH QUERIES ###

    case search_attrs[:search_drop]
    when "Authorized User"
      # To prevent overlap between the for_identity or for_admin scope, run the query unscoped
      # and combine with the old scope's values
      unscoped  = self.unscoped.joins(:non_pi_authorized_users).where(identity_query)
      others    = self.current_scope

      where(id: others & unscoped).distinct
    when "PI"
      unscoped  = self.unscoped.joins(:principal_investigators).where(identity_query)
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
      where(title_query).distinct
    when ""
      joins(:identities).left_outer_joins(:human_subjects_info).
        where(identity_query.or(protocol_id_query).or(title_query).or(pro_num_query).or(rmid_query)).
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
    service_provider_ssrs = SubServiceRequest.where.not(status: 'first_draft').where(organization_id: Organization.authorized_for_service_provider(identity_id))

    if SuperUser.where(identity_id: identity_id).any?
      self.for_super_user(identity_id, service_provider_ssrs)
    else
      joins(:sub_service_requests).merge(service_provider_ssrs).distinct
    end
  }

  scope :for_super_user, -> (identity_id, service_provider_ssrs = nil) {
    # returns protocols with ssrs in orgs authorized for identity
    ssrs = SubServiceRequest.where.not(status: 'first_draft').where(organization_id: Organization.authorized_for_super_user(identity_id))

    empty_protocol_ids  = includes(:sub_service_requests).where(sub_service_requests: { id: nil }).ids
    protocol_ids        = ssrs.distinct.pluck(:protocol_id)
    if SuperUser.where(identity_id: identity_id).where(access_empty_protocols: true).exists?
      all_protocol_ids    = protocol_ids + empty_protocol_ids
    else
      all_protocol_ids    = protocol_ids
    end

    if service_provider_ssrs
      all_protocol_ids << service_provider_ssrs.distinct.pluck(:protocol_id)
      all_protocol_ids.flatten!
    end

    where(id: all_protocol_ids.uniq)
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

  def validate_dates
    is_valid = true
    if self.start_date.blank?
      self.errors.add(:start_date, :blank)
      is_valid = false
    end
    if self.end_date.blank?
      self.errors.add(:end_date, :blank)
      invalid = false
    end
    if self.start_date && self.end_date && self.start_date > self.end_date
      self.errors.add(:start_date, :invalid)
      self.errors.add(:end_date, :invalid)
      is_valid = false
    end
    if self.recruitment_start_date && self.recruitment_end_date && self.recruitment_start_date > self.recruitment_end_date
      self.errors.add(:recruitment_start_date, :invalid)
      self.errors.add(:recruitment_end_date, :invalid)
      is_valid = false
    end
    is_valid
  end

  def initial_amount=(amount)
    write_attribute(:initial_amount, amount.to_f * 100)
  end

  def initial_amount
    read_attribute(:initial_amount) / 100.0 rescue 0
  end

  def initial_amount_clinical_services=(amount)
    write_attribute(:initial_amount_clinical_services, amount.to_f * 100)
  end

  def initial_amount_clinical_services
    read_attribute(:initial_amount_clinical_services) / 100.0 rescue 0
  end

  def negotiated_amount=(amount)
    write_attribute(:negotiated_amount, amount.to_f * 100) rescue 0
  end

  def negotiated_amount
    read_attribute(:negotiated_amount) / 100.0 rescue 0
  end

  def negotiated_amount_clinical_services=(amount)
    write_attribute(:negotiated_amount_clinical_services, amount.to_f * 100)
  end

  def negotiated_amount_clinical_services
    read_attribute(:negotiated_amount_clinical_services) / 100.0 rescue 0
  end

  def is_study?
    self.type == 'Study'
  end

  def is_epic?
    Setting.get_value("use_epic")
  end

  def is_project?
    self.type == 'Project'
  end

  def funded?
    self.funding_status == 'funded'
  end

  def pending_funding?
    self.funding_status == 'pending_funding'
  end

  def federally_funded?
    self.funding_source_based_on_status == 'federal'
  end

  def internally_funded?
    self.funding_source_based_on_status == 'internal'
  end

  def active?
    study_type_question_group.nil? ? false : study_type_question_group.active
  end

  def version_type
    study_type_question_group.nil? ? nil : study_type_question_group.version
  end

  def email_about_change_in_authorized_user(modified_roles, action)
    # Alert authorized users of deleted authorized user
    # Send emails if send_authorized_user_emails is set to true and if there are any non-draft SSRs
    # For example:  if a SR has SSRs all with a status of 'draft', don't send emails

    if Setting.get_value("send_authorized_user_emails") && self.service_requests.any?(&:previously_submitted?)
      alert_users     = Identity.where(id: (self.emailed_associated_users + modified_roles.reject{ |pr| pr.project_rights == 'none' }).map(&:identity_id))
      modified_roles  = modified_roles.map{ |pr| ModifiedRole.new(pr.attributes) }

      alert_users.each{ |u| UserMailer.delay.authorized_user_changed(self, u, modified_roles, action) }
    end
  end

  def primary_principal_investigator
    primary_pi_role.try(:identity)
  end

  def billing_business_manager_email
    billing_business_manager_static_email.blank? ?  billing_managers.map(&:email).try(:join, ', ') : billing_business_manager_static_email
  end

  def coordinator_emails
    coordinators.pluck(:email).join(', ')
  end

  def emailed_associated_users
    self.project_roles.where.not(project_rights: 'none')
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

  def duration_in_months
    (self.end_date.year * 12 + self.end_date.month) - (self.start_date.year * 12 + self.start_date.month)
  end

  def display_funding_source_value
    if funding_status == "funded"
      if funding_source == "internal"
        "#{PermissibleValue.get_value('funding_source', funding_source)}: #{funding_source_other}"
      else
        "#{PermissibleValue.get_value('funding_source', funding_source)}"
      end
    elsif funding_status == "pending_funding"
      if potential_funding_source == "internal"
        "#{PermissibleValue.get_value('potential_funding_source', potential_funding_source)}: #{potential_funding_source_other}"
      else
        "#{PermissibleValue.get_value('potential_funding_source', potential_funding_source)}"
      end
    end
  end

  def funding_source_based_on_status
    if self.funded?
      self.funding_source
    elsif self.pending_funding?
      self.potential_funding_source
    else
      nil
    end
  end

  # Note: this method is called inside a child thread by the service
  # requests controller.  Be careful adding code here that might not be
  # thread-safe.
  def push_to_epic(epic_interface, origin, identity_id=nil, withhold_calendar=false)
    begin
      self.last_epic_push_time = Time.now
      self.last_epic_push_status = 'started'
      save(validate: false)

      Rails.logger.info("Sending study message to Epic")
      withhold_calendar ? epic_interface.send_study_creation(self) : epic_interface.send_study(self)

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
    primary_pi_role.set_epic_rights.save
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
    self.build_primary_pi_role unless self.primary_pi_role
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

  def rmid_server_status
    existing_rm_id == "server_down" && type == "Study"
  end

  def should_push_to_epic?
    service_requests.any?(&:should_push_to_epic?)
  end

  def has_nexus_services?
    service_requests.where.not(status: 'first_draft').
      any?(&:has_ctrc_clinical_services?)
  end

  def has_clinical_services?
    service_requests.any?(&:has_per_patient_per_visit_services?)
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
    if Setting.get_value("use_indirect_cost")
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

  def industry_funded?
    self.funding_source_based_on_status == 'industry'
  end

  #############
  ### FORMS ###
  #############
  def has_completed_forms?
    self.sub_service_requests.any?(&:has_completed_forms?)
  end

  def all_forms_completed?
    self.sub_service_requests.all?(&:all_forms_completed?)
  end

  private

  def indirect_cost_enabled
    Setting.get_value('use_indirect_cost')
  end

  def notify_remote_around_update?
    true
  end

  def remotely_notifiable_attributes_to_watch_for_change
    ["short_title"]
  end

  def validate_existing_rmid
    rmid = Protocol.get_rmid(self.research_master_id)

    if self.research_master_id.present? && rmid['status'] == 404 && self.errors[:research_master_id].empty? 
      self.errors.add(:base, I18n.t('protocols.rmid.errors.not_found', rmid: self.research_master_id, rmid_link: Setting.get_value('research_master_link')))
    end
  end

  def validate_unique_rmid
    if existing_protocol = Protocol.where(research_master_id: self.research_master_id).where.not(id: self.id).first
      self.errors.add(:base, I18n.t('protocols.rmid.errors.taken', rmid: self.research_master_id, protocol_id: existing_protocol.id))
    end
  end
end
