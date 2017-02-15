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

class ServiceRequest < ActiveRecord::Base

  include RemotelyNotifiable

  audited

  belongs_to :protocol
  has_many :sub_service_requests, :dependent => :destroy
  has_many :line_items, -> { includes(:service) }, :dependent => :destroy
  has_many :services, through: :line_items
  has_many :line_items_visits, through: :line_items
  has_many :subsidies, through: :sub_service_requests
  has_many :charges, :dependent => :destroy
  has_many :tokens, :dependent => :destroy
  has_many :approvals, :dependent => :destroy
  has_many :arms, :through => :protocol
  has_many :visit_groups, through: :arms
  has_many :notes, as: :notable, dependent: :destroy

  after_save :set_original_submitted_date

  validation_group :catalog do
    validate :validate_line_items
  end

  validation_group :protocol do
    validate :validate_line_items
    validate :validate_protocol
  end

  validation_group :service_details do
    validate :validate_service_details
    validate :validate_arms
  end

  validation_group :service_calendar do
    validate :validate_service_calendar
  end

  attr_accessible :protocol_id
  attr_accessible :status
  attr_accessible :notes
  attr_accessible :approved
  attr_accessible :submitted_at
  attr_accessible :line_items_attributes
  attr_accessible :sub_service_requests_attributes
  attr_accessor   :previous_submitted_at

  accepts_nested_attributes_for :line_items
  accepts_nested_attributes_for :sub_service_requests

  alias_attribute :service_request_id, :id

  #after_save :fix_missing_visits

  def validate_line_items
    if self.line_items.empty?
      errors.add(:base, I18n.t(:errors)[:service_requests][:line_items_missing])
    end
  end

  def validate_protocol
    if self.protocol_id.blank?
      errors.add(:base, I18n.t(:errors)[:service_requests][:protocol_missing])
    elsif !self.protocol.valid?
      errors.add(:base, I18n.t(:errors)[:service_requests][:protocol_errors])
    end
  end

  def validate_service_details
    if protocol
      if protocol.start_date.nil?
        errors.add(:base, I18n.t(:errors)[:protocols][:start_date_missing])
      end
      if protocol.end_date.nil?
        errors.add(:base, I18n.t(:errors)[:protocols][:end_date_missing])
      end
      if protocol.start_date && protocol.end_date && protocol.start_date > protocol.end_date
        errors.add(:base, I18n.t(:errors)[:protocols][:date_range_invalid])
      end
    else
      protocol
    end
  end

  def validate_arms
    if has_per_patient_per_visit_services? && protocol && protocol.arms.empty?
      errors.add(:base, I18n.t(:errors)[:service_requests][:arms_missing])
    end
  end

  def validate_service_calendar
    vg = visit_groups.to_a.find { |vg| !vg.in_order? }
    if vg
      errors.add(:base, I18n.t('errors.visit_groups.days_out_of_order', arm_name: vg.arm.name))
    end

    if USE_EPIC
      self.arms.each do |arm|
        days = arm.visit_groups.map(&:day)

        visit_group_errors = false
        invalid_day_errors = false

        unless days.all?{|x| !x.blank?}
          errors.add(:base, I18n.t('errors.arms.visit_day_missing', arm_name: arm.name))
          visit_group_errors = true
        end
      end
    end

    self.arms.map(&:visit_groups).flatten.map(&:visits).flatten.each do |visit|
      line_item = visit.line_items_visit.line_item
      unless line_item.valid_pppv_service_relation_quantity? visit
        line_item.reload.errors.each{ |k,v| errors.add(k, v) unless errors[k].include?(v)}
      end
    end
    self.one_time_fee_line_items.each do |li|
      unless li.valid_otf_service_relation_quantity?
        li.reload.errors.each{ |e| errors.add(e) }
      end
    end
  end

  # Given a service, create a line item for that service and for all
  # services it depends on.
  #
  # Required services will be marked non-optional; optional services
  # will be marked optional.
  #
  # Recursively adds services (e.g. if a service1 depends on service2,
  # and service2 depends on service3, then all 3 services will get line
  # items).
  #
  # Returns an array containing all the line items that were created.
  #
  # Parameters:
  #
  #   service:              the service for which to create line item(s)
  #
  #   optional:             whether the service is optional
  #
  #   existing_service_ids: an array containing the ids of all the
  #                         services that have already been added to the
  #                         service request.  This array will be
  #                         modified to contain the services for the
  #                         newly created line items.
  #
  def create_line_items_for_service(args)
    service = args[:service]
    optional = args[:optional]
    existing_service_ids = args[:existing_service_ids]
    allow_duplicates = args[:allow_duplicates]
    recursive_call = args[:recursive_call]

    # If this service has already been added, then do nothing
    unless allow_duplicates
      return if existing_service_ids.include?(service.id)
    end

    line_items = []

    # add service to line items
    line_items << create_line_item(
        service_id: service.id,
        optional: optional,
        quantity: service.displayed_pricing_map.quantity_minimum)

    existing_service_ids << service.id

    # add required services to line items
    service.required_services.each do |rs|
      next unless rs.parents_available?
      rs_line_items = create_line_items_for_service(
        service: rs,
        optional: false,
        existing_service_ids: existing_service_ids,
        recursive_call: true)
      rs_line_items.nil? ? line_items : line_items.concat(rs_line_items)
    end

    # add optional services to line items
    # if were in a recursive call, we don't want to add optional services
    unless recursive_call
      service.optional_services.each do |rs|
        next unless rs.parents_available?
        rs_line_items = create_line_items_for_service(
          service: rs,
          optional: true,
          existing_service_ids: existing_service_ids,
          recursive_call: true)
        rs_line_items.nil? ? line_items : line_items.concat(rs_line_items)
      end
    end

    return line_items
  end

  def create_line_item(args)
    quantity = args.delete('quantity') || args.delete(:quantity) || 1
    if line_item = self.line_items.create(args)

      if line_item.service.one_time_fee
        # quantity is only set for one time fee
        line_item.update_attribute(:quantity, quantity)

      else
        # only per-patient per-visit have arms
        self.arms.each do |arm|
          arm.create_line_items_visit(line_item)
        end
      end

      line_item.reload
      return line_item
    else
      return false
    end
  end

  def one_time_fee_line_items
    line_items.map do |line_item|
      line_item.service.one_time_fee ? line_item : nil
    end.compact
  end

  def per_patient_per_visit_line_items
    line_items.map do |line_item|
      line_item.service.one_time_fee ? nil : line_item
    end.compact
  end

  def set_visit_page page_passed, arm
    page = case
           when page_passed <= 0
             1
           when page_passed > (arm.visit_count / 5.0).ceil
             1
           else
             page_passed
           end
    page
  end

  def service_list(is_one_time_fee=nil, service_provider=nil, admin_ssr=nil)
    items = if service_provider
      service_provider_line_items(service_provider, line_items)
    elsif admin_ssr
      admin_ssr.line_items
    else
      line_items
    end

    items = if is_one_time_fee == true
      items.select { |i| i.service.one_time_fee? }
    elsif is_one_time_fee == false
      items.select { |i| !i.service.one_time_fee? }
    else
      items
    end

    groupings = {}
    items.each do |line_item|
      service = line_item.service
      name = []
      acks = []
      last_parent = nil
      last_parent_name = nil
      found_parent = false
      service.parents.reverse.each do |parent|
        next if !parent.process_ssrs? && !found_parent
        found_parent = true
        last_parent = last_parent || parent.id
        last_parent_name = last_parent_name || parent.name
        name << parent.abbreviation
        acks << parent.ack_language unless parent.ack_language.blank?
      end
      if found_parent == false
        service.parents.reverse.each do |parent|
          name << parent.abbreviation
          acks << parent.ack_language unless parent.ack_language.blank?
        end
        last_parent = service.organization.id
        last_parent_name = service.organization.name
      end

      if groupings.include? last_parent
        g = groupings[last_parent]
        g[:services] << service
        g[:line_items] << line_item
      else
        groupings[last_parent] = {:process_ssr_organization_name => last_parent_name, :name => name.reverse.join(' > '), :services => [service], :line_items => [line_item], :acks => acks.reverse.uniq.compact}
      end
    end

    groupings
  end

  def deleted_ssrs_since_previous_submission
    AuditRecovery.where("audited_changes LIKE '%service_request_id: #{id}%' AND auditable_type = 'SubServiceRequest' AND action = 'destroy' AND created_at BETWEEN '#{previous_submitted_at.utc}' AND '#{Time.now.utc}'")
  end

  def created_ssrs_since_previous_submission
    AuditRecovery.where("audited_changes LIKE '%service_request_id: #{id}%' AND auditable_type = 'SubServiceRequest' AND action = 'create' AND created_at BETWEEN '#{previous_submitted_at.utc}' AND '#{Time.now.utc}'")
  end

  def previously_submitted_ssrs
    sub_service_requests.where.not(submitted_at: nil).to_a
  end

  # Returns the line items that a service provider is associated with
  def service_provider_line_items(service_provider, items)
    service_provider_items = []
    items.map(&:sub_service_request_id).each do |ssr|
      if service_provider.identity.is_service_provider?(SubServiceRequest.find(ssr))
        service_provider_items << SubServiceRequest.find(ssr).line_items
      end
    end
    service_provider_items.flatten.uniq
  end

  def has_one_time_fee_services?
    one_time_fee_line_items.count > 0
  end

  def has_per_patient_per_visit_services?
    per_patient_per_visit_line_items.count > 0
  end

  def total_direct_costs_per_patient arms=self.arms, line_items=nil
    total = 0.0
    lids = line_items.map(&:id) unless line_items.nil?
    arms.each do |arm|
      livs = line_items.nil? ? arm.line_items_visits : arm.line_items_visits.reject{|liv| !lids.include? liv.line_item_id}
      total += arm.direct_costs_for_visit_based_service livs
    end

    total
  end

  def total_indirect_costs_per_patient arms=self.arms, line_items=nil
    total = 0.0
    if USE_INDIRECT_COST
      lids = line_items.map(&:id) unless line_items.nil?
      arms.each do |arm|
        livs = line_items.nil? ? arm.line_items_visits : arm.line_items_visits.reject{|liv| !lids.include? liv.line_item_id}
        total += arm.indirect_costs_for_visit_based_service
      end
    end

    total
  end

  def total_costs_per_patient arms=self.arms
    self.total_direct_costs_per_patient(arms) + self.total_indirect_costs_per_patient(arms)
  end

  def total_direct_costs_one_time line_items=self.line_items
    total = 0.0
    line_items.select {|x| x.service.one_time_fee}.each do |li|
      total += li.direct_costs_for_one_time_fee
    end

    total
  end

  def total_indirect_costs_one_time line_items=self.line_items
    total = 0.0
    if USE_INDIRECT_COST
      line_items.select {|x| x.service.one_time_fee}.each do |li|
        total += li.indirect_costs_for_one_time_fee
      end
    end

    total
  end

  def total_costs_one_time line_items=self.line_items
    self.total_direct_costs_one_time(line_items) + self.total_indirect_costs_one_time(line_items)
  end

  def direct_cost_total line_items=self.line_items
    self.total_direct_costs_one_time(line_items) + self.total_direct_costs_per_patient(self.arms, line_items)
  end

  def indirect_cost_total line_items=self.line_items
    self.total_indirect_costs_one_time(line_items) + self.total_indirect_costs_per_patient(self.arms, line_items)
  end

  def grand_total line_items=self.line_items
    self.direct_cost_total(line_items) + self.indirect_cost_total(line_items)
  end

  def relevant_service_providers_and_super_users
    identities = []

    self.sub_service_requests.each do |ssr|
      ssr.organization.all_service_providers.each do |sp|
        identities << sp.identity
      end
      ssr.organization.all_super_users.each do |su|
        identities << su.identity
      end
    end

    identities.flatten.uniq
  end

  def additional_detail_services
    services.joins(:questionnaires).where(questionnaires: { active: true })
  end

  # Change the status of the service request and all the sub service
  # requests to the given status.
  def update_status(new_status, use_validation=true, submit=false)
    to_notify = []
    self.assign_attributes(status: new_status)

    sub_service_requests.each do |ssr|
      next unless ssr.can_be_edited?
      available = AVAILABLE_STATUSES.keys
      editable = EDITABLE_STATUSES[ssr.organization_id] || available
      changeable = available & editable

      if changeable.include?(new_status)
        if (ssr.status != new_status) && (UPDATABLE_STATUSES.include?(ssr.status) || !submit)
          ssr.update_attribute(:status, new_status)
          # Do not notify (initial submit email) if ssr has been previously submitted
          if new_status == 'submitted'
            to_notify << ssr.id unless ssr.previously_submitted?
          else
            to_notify << ssr.id
          end
        end
      end
    end

    self.save(validate: use_validation)

    to_notify
  end

  # Make sure that all the sub service requests have an ssr id
  def ensure_ssr_ids
    next_ssr_id = self.protocol && self.protocol.next_ssr_id.present? ? self.protocol.next_ssr_id : 1

    self.sub_service_requests.each do |ssr|
      unless ssr.ssr_id
        ssr.update_attributes(ssr_id: "%04d" % next_ssr_id)
        next_ssr_id += 1
      end
      # If we have created a protocol, we don't want to ensure that the ssr_ids are sequential because the user may remove SSRs
      next_ssr_id += 1 unless self.protocol
    end

    self.protocol.update_attributes(next_ssr_id: next_ssr_id) if self.protocol
  end

  def add_or_update_arms
    return unless self.has_per_patient_per_visit_services?

    p = self.protocol
    if p
      if p.arms.empty?
        arm = p.arms.create(
          name: 'Screening Phase',
          visit_count: 1,
          new_with_draft: true)
        self.per_patient_per_visit_line_items.each do |li|
          arm.create_line_items_visit(li)
        end
      else
        p.arms.each do |arm|
          p.service_requests.each do |sr|
            sr.per_patient_per_visit_line_items.each do |li|
              arm.create_line_items_visit(li) if arm.line_items_visits.where(:line_item_id => li.id).empty?
            end
          end
        end
      end
    end
  end

  def should_push_to_epic?
    return self.line_items.any? { |li| li.should_push_to_epic? }
  end

  def has_ctrc_clinical_services?
    return self.line_items.any? { |li| li.service.is_ctrc_clinical_service? }
  end

  def update_arm_minimum_counts
    self.arms.each do |arm|
      arm.update_minimum_counts
    end
  end

  def arms_editable?
    true #self.sub_service_requests.all?{|ssr| ssr.arms_editable?}
  end

  def audit_report( identity, start_date=self.previous_submitted_at.utc, end_date=Time.now.utc )
    line_item_audits = AuditRecovery.where("audited_changes LIKE '%service_request_id: #{self.id}%' AND
                                      auditable_type = 'LineItem' AND user_id = #{identity.id} AND action IN ('create', 'destroy') AND
                                      created_at BETWEEN '#{start_date}' AND '#{end_date}'")
                                    .group_by(&:auditable_id)

    {:line_items => line_item_audits}
  end

  def cart_sub_service_requests
    active    = self.sub_service_requests.where.not(status: 'complete')
    complete  = self.sub_service_requests.where(status: 'complete')

    { active: active, complete: complete }
  end

  private

  def set_original_submitted_date
    if self.submitted_at && !self.original_submitted_date
      self.original_submitted_date = self.submitted_at
      self.save(validate: false)
    end
  end
end
