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
  has_many :past_statuses, :dependent => :destroy
  has_many :line_items, :dependent => :destroy
  has_many :line_items_visits, through: :line_items
  has_and_belongs_to_many :documents
  has_many :notes, as: :notable, dependent: :destroy
  has_many :approvals, :dependent => :destroy
  has_many :payments, :dependent => :destroy
  has_many :cover_letters, :dependent => :destroy
  has_many :reports, :dependent => :destroy
  has_many :notifications, :dependent => :destroy
  has_many :subsidies
  has_one :approved_subsidy, :dependent => :destroy
  has_one :pending_subsidy, :dependent => :destroy

  delegate :percent_subsidy, to: :approved_subsidy, allow_nil: true

  accepts_nested_attributes_for :line_items, allow_destroy: true
  accepts_nested_attributes_for :payments, allow_destroy: true

  validates :ssr_id, presence: true, uniqueness: { scope: :service_request_id }

  scope :in_work_fulfillment, -> { where(in_work_fulfillment: true) }

  def consult_arranged_date=(date)
    write_attribute(:consult_arranged_date, Time.strptime(date, "%m/%d/%Y")) if date.present?
  end

  def requester_contacted_date=(date)
    write_attribute(:requester_contacted_date, Time.strptime(date, "%m/%d/%Y")) if date.present?
  end

  def status= status
    @prev_status = self.status
    super(status)
  end

  def previously_submitted?
    !submitted_at.nil?
  end

  def formatted_status
    if AVAILABLE_STATUSES.has_key? status
      AVAILABLE_STATUSES[status]
    else
      "STATUS MAPPING NOT PRESENT"
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
    line_items = LineItem.where(:sub_service_request_id => self.id).includes(:service)
    line_items.select {|li| li.service.one_time_fee}
  end

  def per_patient_per_visit_line_items
    line_items = LineItem.where(:sub_service_request_id => self.id).includes(:service)

    line_items.select {|li| !li.service.one_time_fee}
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
    # return true if work fulfillment has already been turned "on" or global variable FULFILLMENT_CONTINGENT_ON_CATALOG_MANAGER is set to false or nil
    # otherwise, return true only if FULFILLMENT_CONTINGENT_ON_CATALOG_MANAGER is true and the parent organization has tag 'clinical work fulfillment'
    if self.in_work_fulfillment || !FULFILLMENT_CONTINGENT_ON_CATALOG_MANAGER ||
        (FULFILLMENT_CONTINGENT_ON_CATALOG_MANAGER && self.organization.tag_list.include?('clinical work fulfillment'))
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
    to_notify = []
    if can_be_edited?
      available = AVAILABLE_STATUSES.keys
      editable = EDITABLE_STATUSES[organization_id] || available
      changeable = available & editable
      if changeable.include?(new_status)
        #  See Pivotal Stories: #133049647 & #135639799
        if (status != new_status) && ((new_status == 'submitted' && UPDATABLE_STATUSES.include?(status)) || new_status != 'submitted')
          ### For 'submitted' status ONLY:
          # Since adding/removing services changes a SSR status to 'draft', we have to look at the past status to see if we should notify users of a status change
          # We do NOT notify if updating from an un-updatable status or we're updating to a status that we already were previously 
          if new_status == 'submitted'
            past_status = PastStatus.where(sub_service_request_id: id).last
            past_status = past_status.nil? ? nil : past_status.status
            if status == 'draft' && ((UPDATABLE_STATUSES.include?(past_status) && past_status != new_status) || past_status == nil) # past_status == nil indicates a newly created SSR
              to_notify << id
            elsif status != 'draft'
              to_notify << id 
            end
          else
            to_notify << id 
          end

          new_status == 'submitted' ? update_attributes(status: new_status, submitted_at: Time.now, nursing_nutrition_approved: false, lab_approved: false, imaging_approved: false, committee_approved: false) : update_attribute(:status, new_status)
        end
      end
    end
    to_notify
  end

  def ctrc?
    self.organization.tag_list.include? "ctrc"
  end

  #A request is locked if the organization it's in isn't editable
  def is_locked?
    if organization.has_editable_statuses?
      return !EDITABLE_STATUSES[find_editable_id].include?(self.status)
    end
    false
  end

  # Can't edit a request if it's placed in an uneditable status
  def can_be_edited?
    if organization.has_editable_statuses?
      EDITABLE_STATUSES[find_editable_id].include?(self.status) && !is_complete?
    else
      !is_complete?
    end
  end

  def is_complete?
    return FINISHED_STATUSES.include?(status)
  end

  def find_editable_id
    parent_ids = self.organization.parents.map(&:id)
    EDITABLE_STATUSES.keys.each do |org_id|
      return org_id if (org_id == self.organization_id) || parent_ids.include?(org_id)
    end
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
    if self.status_changed? && !@prev_status.blank?
      past_status = self.past_statuses.create(status: @prev_status, date: Time.now)
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
    candidates = []
    self.organization.all_service_providers.each do |sp|
      candidates << sp.identity
    end
    if self.owner
      candidates << self.owner unless candidates.detect {|x| x.id == self.owner_id}
    end

    candidates
  end

  def generate_approvals current_user, params
    if params[:nursing_nutrition_approved]
      self.approvals.create({:identity_id => current_user.id, :sub_service_request_id => self.id, :approval_date => Date.today, :approval_type => "Nursing/Nutrition Approved"})
    end

    if params[:lab_approved]
      self.approvals.create({:identity_id => current_user.id, :sub_service_request_id => self.id, :approval_date => Date.today, :approval_type => "Lab Approved"})
    end

    if params[:imaging_approved]
      self.approvals.create({:identity_id => current_user.id, :sub_service_request_id => self.id, :approval_date => Date.today, :approval_type => "Imaging Approved"})
    end

    if params[:committee_approved]
      self.approvals.create({:identity_id => current_user.id, :sub_service_request_id => self.id, :approval_date => Date.today, :approval_type => "Committee Approved"})
    end
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
    unless available_surveys.blank?
      SurveyNotification.service_survey(available_surveys, primary_pi, self).deliver
    # only send survey email to both users if they are unique
      if primary_pi != service_requester
        SurveyNotification.service_survey(available_surveys, service_requester, self).deliver
      end
    end
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
        filtered_audit_trail[:line_items] << audit if LineItem.find(audit.auditable_id).sub_service_request_id == self.id
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
