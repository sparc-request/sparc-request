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

class SubServiceRequest < ApplicationRecord

  include RemotelyNotifiable

  audited

  before_create :set_protocol_id
  after_save :update_org_tree
  after_save :update_past_status

  belongs_to :service_requester, class_name: "Identity", foreign_key: "service_requester_id"
  belongs_to :owner, :class_name => 'Identity', :foreign_key => "owner_id"
  belongs_to :service_request
  belongs_to :organization
  belongs_to :protocol, counter_cache: true

  has_one :approved_subsidy, :dependent => :destroy
  has_one :pending_subsidy, :dependent => :destroy

  has_many :past_statuses, :dependent => :destroy
  has_many :line_items, :dependent => :destroy
  has_many :notes, as: :notable, dependent: :destroy
  has_many :approvals, :dependent => :destroy
  has_many :payments, :dependent => :destroy
  has_many :cover_letters, :dependent => :destroy
  has_many :reports, :dependent => :destroy
  has_many :notifications, :dependent => :destroy
  has_many :subsidies
  has_many :responses, as: :respondable, dependent: :destroy
  has_and_belongs_to_many :documents

  has_many :line_items_visits, through: :line_items
  has_many :services, through: :line_items

  has_many :service_forms, -> { active }, through: :services, source: :forms
  has_many :organization_forms, -> { active }, through: :organization, source: :forms

  ########################
  ### CWF Associations ###
  ########################

  has_one :fulfillment_protocol, class_name: 'Shard::Fulfillment::Protocol'

  delegate :percent_subsidy, to: :approved_subsidy, allow_nil: true

  accepts_nested_attributes_for :line_items, allow_destroy: true
  accepts_nested_attributes_for :payments, allow_destroy: true

  validates :ssr_id, presence: true, uniqueness: { scope: :service_request_id }

  scope :in_work_fulfillment, -> { where(in_work_fulfillment: true) }
  scope :imported_to_fulfillment, -> { where(imported_to_fulfillment: true) }

  def consult_arranged_date=(date)
    write_attribute(:consult_arranged_date, date.present? ? Time.strptime(date, "%m/%d/%Y") : nil)
  end

  def requester_contacted_date=(date)
    write_attribute(:requester_contacted_date, date.present? ? Time.strptime(date, "%m/%d/%Y") : nil)
  end

  def status= status
    @prev_status = self.status
    super(status)
  end

  def previously_submitted?
    self.submitted_at.present?
  end

  def formatted_status
    formatted_status = PermissibleValue.get_value('status', self.status)
    if formatted_status.nil?
      "STATUS MAPPING NOT PRESENT"
    else
      formatted_status
    end
  end

  def should_push_to_epic?
    return self.line_items.any? { |li| li.should_push_to_epic? }
  end

  def update_org_tree
    my_tree = nil
    if organization.type == "Core"
      my_tree = organization.parent.parent.try(:abbreviation) + "/" + organization.parent.try(:name) + "/" + organization.try(:name)
    elsif organization.type == "Program"
      my_tree = organization.parent.try(:abbreviation) + "/" + organization.try(:name)
    else
      my_tree = organization.try(:name)
    end

    self.update_column(:org_tree_display, my_tree)
  end

  def org_tree
    orgs = organization.parents
    orgs << organization
  end

  def process_ssrs_organization
    self.organization.process_ssrs_parent
  end

  def set_effective_date_for_cost_calculations
    self.line_items.each{|li| li.pricing_scheme = 'effective'}
  end

  def unset_effective_date_for_cost_calculations
    self.line_items.each{|li| li.pricing_scheme = 'displayed'}
  end

  def display_id
    return "#{protocol.try(:id)}-#{ssr_id || 'DRAFT'}"
  end

  def has_subsidy?
    pending_subsidy.present? or approved_subsidy.present?
  end

  def create_line_item(args)
    result = self.transaction do
      new_args = {
        sub_service_request_id: self.service_request_id
      }
      new_args.update(args)
      li = service_request.create_line_item(new_args)

      li
    end

    if result
      return result
    else
      self.reload
      return false
    end
  end

  def one_time_fee_line_items
    self.line_items.joins(:service).where(services: { one_time_fee: true })
  end

  def per_patient_per_visit_line_items
    self.line_items.joins(:service).where(services: { one_time_fee: false })
  end

  def has_one_time_fee_services?
    one_time_fee_line_items.count > 0
  end

  def has_per_patient_per_visit_services?
    per_patient_per_visit_line_items.count > 0
  end

  # Returns the total direct costs of the sub-service-request
  def direct_cost_total
    total = 0.0

    self.line_items.each do |li|
      if li.service.one_time_fee
        total += li.direct_costs_for_one_time_fee
      else
        total += li.direct_costs_for_visit_based_service
      end
    end

    return total
  end

  # Returns the total indirect costs of the sub-service-request
  def indirect_cost_total
    total = 0.0

    self.line_items.each do |li|
      if li.service.one_time_fee
       total += li.indirect_costs_for_one_time_fee
      else
       total += li.indirect_costs_for_visit_based_service
      end
    end

    return total
  end

  # Returns the grand total cost of the sub-service-request
  def grand_total
    self.direct_cost_total + self.indirect_cost_total
  end

  def subsidy_percentage
    funded_amount = direct_cost_total - subsidies.first.pi_contribution.to_f

    ((funded_amount.to_f / direct_cost_total.to_f).round(2) * 100).to_i
  end

  # Returns a list of candidate services for a given ssr (used in fulfillment)
  def candidate_services
    services = []
    if self.organization.process_ssrs
      services = self.organization.all_child_services.select {|x| x.is_available?}

    else
      begin
        services = self.organization.process_ssrs_parent.all_child_services.select {|x| x.is_available}
      rescue
        services = self.organization.all_child_services.select {|x| x.is_available?}
      end
    end

    services
  end

  def candidate_pppv_services
    candidate_services.reject(&:one_time_fee)
  end

  def update_line_item line_item, args
    if self.line_items.map {|li| li.id}.include? line_item.id
      line_item.update_attributes!(args)
    else
      raise ArgumentError, "Line item #{line_item.id} does not exist for sub service request #{self.id} "
    end

    line_item
  end

  def eligible_for_subsidy?
    # This defines when subsidies show up for SubServiceRequests across the app.
    if organization.eligible_for_subsidy? and not organization.funding_source_excluded_from_subsidy?(self.protocol.try(:funding_source_based_on_status))
      true
    else
      false
    end
  end

  ###############################################################################
  ######################## FULFILLMENT RELATED METHODS ##########################
  ###############################################################################
  def ready_for_fulfillment?
    # return true if work fulfillment has already been turned "on" or global variable fulfillment_contingent_on_catalog_manager is set to false or nil
    # otherwise, return true only if fulfillment_contingent_on_catalog_manager is true and the parent organization has tag 'clinical work fulfillment'
    if self.in_work_fulfillment || !Setting.get_value("fulfillment_contingent_on_catalog_manager") ||
        (Setting.get_value("fulfillment_contingent_on_catalog_manager") && self.organization.tag_list.include?('clinical work fulfillment'))
      return true
    else
      return false
    end
  end

  ########################
  ## SSR STATUS METHODS ##
  ########################

  # Returns the SSR id that need an initial submission email and updates
  # the SSR status to new status if appropriate
  def update_status_and_notify(new_status)
    if self.status != new_status && self.can_be_edited? && Status.updatable?(self.status)
      if new_status == 'submitted'
        ### For 'submitted' status ONLY:
        # Since adding/removing services changes a SSR status to 'draft', we have to look at the past status to see if we should notify users of a status change
        # We do NOT notify if updating from an un-updatable status or we're updating to a status that we already were previously
        # See Pivotal Stories: #133049647 & #135639799
        old_status      = self.status
        submitted_prior = self.previously_submitted?
        past_status     = self.past_statuses.last.try(:status)
        self.update_attributes(status: new_status, submitted_at: Time.now, nursing_nutrition_approved: false, lab_approved: false, imaging_approved: false, committee_approved: false)
        return self.id if !submitted_prior && (old_status != 'draft' || (old_status == 'draft' && (past_status.nil? || (past_status != new_status && Status.updatable?(past_status))))) # past_status == nil indicates a newly created SSR
      else
        self.update_attribute(:status, new_status)
        return self.id
      end
    end
  end

  def ctrc?
    self.organization.tag_list.include? "ctrc"
  end

  #A request is locked if the organization it's in isn't editable
  def is_locked?
    process_ssrs_org = self.organization.process_ssrs_parent || self.organization
    self.status != 'first_draft' && !process_ssrs_org.has_editable_status?(status)
  end

  # Can't edit a request if it's placed in an uneditable status
  def can_be_edited?
    process_ssrs_org = self.organization.process_ssrs_parent || self.organization
    self.status == 'first_draft' || (process_ssrs_org.has_editable_status?(self.status) && !self.is_complete?)
  end

  def is_complete?
    Status.complete?(self.status)
  end

  def set_to_draft
    self.update_attributes(status: 'draft') unless status == 'draft'
  end

  def switch_to_new_service_request
    old_sr = self.service_request
    new_sr = old_sr.dup
    new_sr.save validate: false

    #update line items
    self.line_items.each {|li| li.update_attributes(service_request_id: new_sr.id)}

    #create new documents and/or change service request id for existing documents
    documents_to_create = []

    self.documents.each do |doc|
      if doc.sub_service_requests.count == 1
        doc.update_attributes(service_request_id: new_sr.id)
      else
        documents_to_create << doc
      end
    end

    documents_to_create.each do |doc|
      new_document = Document.create :document => doc.document, :doc_type => doc.doc_type, :doc_type_other => doc.doc_type_other, :service_request_id => new_sr.id
      self.documents << new_document
      self.documents.delete doc
    end

    self.update_attributes(service_request_id: new_sr.id)
  end

  def arms_editable?
    !self.in_work_fulfillment?
  end

  def update_past_status
    if saved_change_to_status? && !@prev_status.blank?
      past_status = self.past_statuses.create(status: @prev_status, new_status: status, date: Time.now)
      user_id = AuditRecovery.where(auditable_id: past_status.id, auditable_type: 'PastStatus').first.user_id
      past_status.update_attribute(:changed_by_id, user_id)
    end
  end

  def past_status_lookup
    ps = []
    is_first = true
    previous_status = nil

    past_statuses.reverse.each do |past_status|
      next if past_status.status == 'first_draft'

      if is_first
        past_status.changed_to = self.status
      else
        past_status.changed_to = previous_status
      end
      is_first = false
      previous_status = past_status.status
      ps << past_status
    end

    ps.reverse
  end

  ###################
  ## SSR OWNERSHIP ##
  ###################
  def candidate_owners
    candidates = Identity.where(id: self.organization.all_service_providers.pluck(:identity_id)).distinct.to_a
    candidates << self.owner if self.owner
    candidates.uniq
  end

  def generate_approvals current_user, params
    if params[:nursing_nutrition_approved]
      self.approvals.create({:identity_id => current_user.id, :sub_service_request_id => self.id, :approval_date => Time.now, :approval_type => "Nursing/Nutrition Approved"})
    end

    if params[:lab_approved]
      self.approvals.create({:identity_id => current_user.id, :sub_service_request_id => self.id, :approval_date => Time.now, :approval_type => "Lab Approved"})
    end

    if params[:imaging_approved]
      self.approvals.create({:identity_id => current_user.id, :sub_service_request_id => self.id, :approval_date => Time.now, :approval_type => "Imaging Approved"})
    end

    if params[:committee_approved]
      self.approvals.create({:identity_id => current_user.id, :sub_service_request_id => self.id, :approval_date => Time.now, :approval_type => "Committee Approved"})
    end
  end

  #############
  ### FORMS ###
  #############
  def forms_to_complete
    completed_ids = self.responses.pluck(:survey_id)

    (self.service_forms + self.organization_forms).select{ |f| !completed_ids.include?(f.id) }
  end

  def form_completed?(form)
    self.responses.where(survey: form).any?
  end

  def has_completed_forms?
    self.responses.where(survey: self.service_forms + self.organization_forms).any?
  end

  def all_forms_completed?
    (self.service_forms + self.organization_forms).count == self.responses.joins(:survey).where(surveys: { type: 'Form' }).count
  end

  ##########################
  ## SURVEY DISTRIBUTTION ##
  ##########################
  # Distributes all available surveys to primary pi and ssr requester
  def distribute_surveys
    primary_pi = protocol.primary_principal_investigator
    # send all available surveys at once
    available_surveys = line_items.map{|li| li.service.available_surveys}.flatten.compact.uniq
    # do nothing if we don't have any available surveys
    unless available_surveys.empty?
      SurveyNotification.service_survey(available_surveys, primary_pi, self).deliver
    # only send survey email to both users if they are unique
      if primary_pi != service_requester
        SurveyNotification.service_survey(available_surveys, service_requester, self).deliver
      end
    end
  end

  def surveys_completed?
    self.line_items.
      eager_load(service: [:associated_surveys, :organization]).
      map{ |li| li.service.available_surveys }.flatten.compact.uniq.
      all?{ |s| s.responses.where(respondable: self).joins(:question_responses).any? }
  end

  def survey_latest_sent_date
    survey_response = self.responses.joins(:survey).where(surveys: { type: 'SystemSurvey' })
    survey_response.any? ? survey_response.first.updated_at.try(:strftime, '%D') : 'N/A'
  end

  ###############################
  ### AUDIT REPORTING METHODS ###
  ###############################

  # Collects all the added/deleted line_items that need to be displayed in the audit report for emails
  def audit_line_items(identity)
    filtered_audit_trail = {:line_items => []}
    ssr_submitted_at_audit = AuditRecovery.where("audited_changes LIKE '%submitted_at%' AND auditable_id = #{id} AND auditable_type = 'SubServiceRequest' AND action IN ('update') AND user_id = #{identity.id}")
    ssr_submitted_at_audit = ssr_submitted_at_audit.present? ? ssr_submitted_at_audit.order(created_at: :desc).first : nil

    ### start_date = last time SSR was submitted
    ### if SSR has never been submitted, start_date == nil
    if !ssr_submitted_at_audit.nil? && (ssr_submitted_at_audit.audited_changes['submitted_at'].include?(nil) || ssr_submitted_at_audit.audited_changes['submitted_at'].nil?)
      start_date = nil
    else
      if !ssr_submitted_at_audit.nil?
        start_date = ssr_submitted_at_audit.audited_changes['submitted_at']
        start_date = start_date.present? ? start_date.first.utc : Time.now.utc
      end
    end
    end_date = Time.now.utc

    deleted_line_item_audits = AuditRecovery.where("audited_changes LIKE '%sub_service_request_id: #{id}%' AND auditable_type = 'LineItem' AND user_id = #{identity.id} AND action IN ('destroy') AND created_at BETWEEN '#{start_date}' AND '#{end_date}'")

    added_line_item_audits = AuditRecovery.where("audited_changes LIKE '%service_request_id: #{service_request.id}%' AND auditable_type = 'LineItem' AND user_id = #{identity.id} AND action IN ('create') AND created_at BETWEEN '#{start_date}' AND '#{end_date}'")

    ### Takes all the added LIs and filters them down to the ones specific to this SSR ###
    added_li_ids = added_line_item_audits.present? ? added_line_item_audits.map(&:auditable_id) : []
    li_ids_added_to_this_ssr = line_items.present? ? line_items.map(&:id) : []
    added_lis = added_li_ids & li_ids_added_to_this_ssr

    if !added_lis.empty?
      added_lis.each do |li_id|
        filtered_audit_trail[:line_items] << added_line_item_audits.where(auditable_id: li_id).first
      end
    end

    if deleted_line_item_audits.present?
      deleted_line_item_audits.each do |deleted_li|
        filtered_audit_trail[:line_items] << deleted_li
      end
    end

    filtered_audit_trail[:sub_service_request_id] = self.id
    filtered_audit_trail
  end


  def audit_label audit
    "Service Request #{display_id}"
  end

  # filtered audit trail based off service requests and only return data that we need
  # in future may want to return full filtered audit trail, currently this is only used in e-mailing service providers
  def audit_report(identity, start_date, end_date=Time.now.utc)
    filtered_audit_trail = {:line_items => []}

    full_trail = service_request.audit_report(identity, start_date, end_date)

    full_line_items_audits = full_trail[:line_items]

    full_line_items_audits.each do |k, audits|
      # if line item was created and destroyed in the same session we don't care to see it because it wasn't submitted
      actions = audits.map(&:action).to_set
      test_actions = Set['create', 'destroy']
      next if test_actions.subset? actions

      audit = audits.sort_by(&:created_at).last
      # create action
      if audit.audited_changes["sub_service_request_id"].nil?
        line_item = LineItem.where(id: audit.auditable_id).first
        filtered_audit_trail[:line_items] << audit if (line_item && (line_item.sub_service_request_id == self.id))
      # destroy action
      else
        filtered_audit_trail[:line_items] << audit if audit.audited_changes["sub_service_request_id"] == self.id
      end
    end
    filtered_audit_trail[:sub_service_request_id] = self.id
    filtered_audit_trail
  end
  ### end audit reporting methods ###

  private

  def set_protocol_id
    self.protocol_id = service_request.try(:protocol_id)
  end

  def notify_remote_around_update?
    true
  end

  def remotely_notifiable_attributes_to_watch_for_change
    ['in_work_fulfillment']
  end
end
