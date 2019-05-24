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

class ServiceRequest < ApplicationRecord

  include RemotelyNotifiable

  audited

  belongs_to :protocol
  has_many :sub_service_requests, :dependent => :destroy
  has_many :line_items, :dependent => :destroy
  has_many :charges, :dependent => :destroy
  has_many :tokens, :dependent => :destroy
  has_many :approvals, :dependent => :destroy
  has_many :notes, as: :notable, dependent: :destroy

  has_many :arms, through: :protocol
  has_many :services, through: :line_items
  has_many :line_items_visits, through: :line_items
  has_many :subsidies, through: :sub_service_requests
  has_many :visit_groups, through: :arms

  after_save :set_original_submitted_date
  after_save :set_ssr_protocol_id

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
      self.protocol.errors.full_messages.each{ |e| errors.add(:base, e) }
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

    if Setting.get_value("use_epic") && (arms = self.arms.joins(:visit_groups).where(visit_groups: { day: nil })).any?
      arms.each{ |arm| errors.add(:base, I18n.t('errors.arms.visit_day_missing', arm_name: arm.name)) }
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
      end

      line_item.reload
      return line_item
    else
      return false
    end
  end

  def one_time_fee_line_items
    line_items.joins(:service).where(services: { one_time_fee: true })
  end

  def per_patient_per_visit_line_items
    line_items.joins(:service).where(services: { one_time_fee: false })
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
      service.parents.each do |parent|
        next if !parent.process_ssrs? && !found_parent
        found_parent = true
        last_parent = last_parent || parent.id
        last_parent_name = last_parent_name || parent.name
        name << parent.abbreviation
        acks << parent.ack_language unless parent.ack_language.blank?
      end
      if found_parent == false
        service.parents.each do |parent|
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

  def deleted_ssrs_since_previous_submission(start_time_at_previous_sub_time=false)
    ### start_time varies depending on if the submitted_at has been updated or not
    if start_time_at_previous_sub_time
      start_time = previous_submitted_at.nil? ? Time.now.utc : previous_submitted_at.utc
    else
      start_time = submitted_at.nil? ? Time.now.utc : submitted_at.utc
    end
    AuditRecovery.where("audited_changes LIKE '%service_request_id: #{id}%' AND auditable_type = 'SubServiceRequest' AND action = 'destroy' AND created_at BETWEEN '#{start_time}' AND '#{Time.now.utc}'")
  end

  def created_ssrs_since_previous_submission
    start_time = submitted_at.nil? ? Time.now.utc : submitted_at.utc
    AuditRecovery.where("audited_changes LIKE '%service_request_id: #{id}%' AND auditable_type = 'SubServiceRequest' AND action = 'create' AND created_at BETWEEN '#{start_time}' AND '#{Time.now.utc}'")
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
    arms.each do |arm|
      livs = (line_items.nil? ? arm.line_items_visits : arm.line_items_visits.where(line_item: line_items)).eager_load(line_item: [:admin_rates, service_request: :protocol, service: [:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, :parent]]]]])
      total += arm.direct_costs_for_visit_based_service(livs)
    end
    total
  end

  def total_indirect_costs_per_patient arms=self.arms, line_items=nil
    total = 0.0
    if Setting.get_value("use_indirect_cost")
      arms.each do |arm|
        livs = (line_items.nil? ? arm.line_items_visits : arm.line_items_visits.where(line_item: line_items)).eager_load(line_item: [:admin_rates, service_request: :protocol, service: [:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, :parent]]]]])
        total += arm.indirect_costs_for_visit_based_service(livs)
      end
    end

    total
  end

  def total_costs_per_patient arms=self.arms
    self.total_direct_costs_per_patient(arms) + self.total_indirect_costs_per_patient(arms)
  end

  def total_direct_costs_one_time(line_items=self.line_items)
    line_items.
      eager_load(:admin_rates, service_request: :protocol).
      includes(service: [:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, :parent]]]]).
      where(services: { one_time_fee: true }).
      sum(&:direct_costs_for_one_time_fee)
  end

  def total_indirect_costs_one_time(line_items=self.line_items)
    total = 0.0
    if Setting.get_value("use_indirect_cost")
      total += line_items.
        eager_load(:admin_rates, service_request: :protocol).
        includes(service: [:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, :parent]]]]).
        where(services: { one_time_fee: true }).
        sum(&:indirect_costs_for_one_time_fee)
    end
    total
  end

  def total_costs_one_time(line_items=self.line_items)
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

  #############
  ### Forms ###
  #############
  def has_associated_forms?
    self.services.joins(:forms).where(surveys: { active: true }).any? || self.sub_service_requests.joins(organization: :forms).where(surveys: { active: true }).any?
  end

  def associated_forms
    forms = []
    # Because there can be multiple SSRs with the same services/organizations we need to loop over each one
    self.sub_service_requests.each do |ssr|
      ssr.organization_forms.each{ |f| forms << [f, ssr] }
      ssr.service_forms.each{ |f| forms << [f, ssr] }
    end
    forms
  end

  def completed_forms
    forms = []
    # Because there can be multiple SSRs with the same services/organizations we need to loop over each one
    self.sub_service_requests.each do |ssr|
      ssr.organization_forms.joins(:responses).where(responses: { respondable: ssr }).each{ |f| forms << [f, ssr] }
      ssr.service_forms.joins(:responses).where(responses: { respondable: ssr }).each{ |f| forms << [f, ssr] }
    end
    forms
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

  # Returns the SSR ids that need an initial submission email, updates the SR status,
  # and updates the SSR status to new status if appropriate
  def update_status(new_status)
    # Do not change the Service Request if it has been submitted
    update_attribute(:status, new_status) unless self.previously_submitted?
    update_attribute(:submitted_at, Time.now) if new_status == 'submitted'

    self.sub_service_requests.map do |ssr|
      ssr.update_status_and_notify(new_status)
    end.compact
  end

  # Make sure that all the sub service requests have an ssr id
  def ensure_ssr_ids
    next_ssr_id = self.protocol && self.protocol.next_ssr_id.present? ? self.protocol.next_ssr_id : 1

    self.sub_service_requests.each do |ssr|
      unless ssr.ssr_id && self.protocol
        ssr.update_attributes(ssr_id: "%04d" % next_ssr_id)
        next_ssr_id += 1
      end
    end

    if protocol
      protocol.next_ssr_id = next_ssr_id
      protocol.save(validate: false)
    end
  end

  def previously_submitted?
    self.submitted_at.present?
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

    line_item_audits = line_item_audits.present? ? line_item_audits.group_by(&:auditable_id) : {}

    {:line_items => line_item_audits}
  end

  def cart_sub_service_requests
    active    = self.sub_service_requests.select{ |ssr| !ssr.is_complete? }
    complete  = self.sub_service_requests.select{ |ssr| ssr.is_complete? }

    { active: active, complete: complete }
  end

  private

  def set_original_submitted_date
    if self.submitted_at && !self.original_submitted_date
      self.original_submitted_date = self.submitted_at
      self.save(validate: false)
    end
  end

  def set_ssr_protocol_id
    if saved_change_to_protocol_id?
      sub_service_requests.each do |ssr|
        ssr.update_attributes(protocol_id: protocol_id)
      end
    end
  end
end
