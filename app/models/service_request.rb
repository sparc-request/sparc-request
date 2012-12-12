class ServiceRequest < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  include Entity

  belongs_to :service_requester, :class_name => "Identity", :foreign_key => "service_requester_id"
  belongs_to :protocol
  has_many :sub_service_requests, :dependent => :destroy
  has_many :line_items, :include => [:visits, :service], :dependent => :destroy
  has_many :charges, :dependent => :destroy
  has_many :tokens, :dependent => :destroy
  has_many :approvals, :dependent => :destroy
  has_many :documents, :through => :sub_service_requests
  has_many :document_groupings, :dependent => :destroy

  validation_group :protocol do
    validates :protocol_id, :presence => {:message => "You must identify the service request with a study/project before continuing."} 
  end

  validation_group :service_details do
    validates :visit_count, :numericality => { :greater_than => 0, :message => "You must specify the estimated total number of visits (greater than zero) before continuing.", :if => :has_per_patient_per_visit_services?}
    validates :subject_count, :numericality => {:message => "You must specify the estimated total number of subjects before continuing.", :if => :has_per_patient_per_visit_services?}
  end

  validation_group :service_calendar do
    #insert group specific validation
  end

  validation_group :service_subsidy do
    #insert group specific validation
  end

  validation_group :document_management do
    #insert group specific validation
  end

  validation_group :review do
    #insert group specific validation
  end
  
  validation_group :confirmation do
    #insert group specific validation
  end

  attr_accessible :protocol_id
  attr_accessible :obisid
  attr_accessible :status
  attr_accessible :service_requester_id
  attr_accessible :notes
  attr_accessible :approved
  attr_accessible :start_date
  attr_accessible :end_date
  attr_accessible :visit_count
  attr_accessible :subject_count
  attr_accessible :consult_arranged_date
  attr_accessible :pppv_complete_date
  attr_accessible :pppv_in_process_date
  attr_accessible :requester_contacted_date
  attr_accessible :submitted_at
  attr_accessible :line_items_attributes
  attr_accessible :sub_service_requests_attributes

  accepts_nested_attributes_for :line_items
  accepts_nested_attributes_for :sub_service_requests

  alias_attribute :service_request_id, :id

  before_validation :assign_obisid, :on => :create

  after_save :fix_missing_visits

  def init
    self.visit_count = 0
  end

  def one_time_fee_line_items
    line_items.map do |line_item|
      line_item.service.is_one_time_fee? ? line_item : nil
    end.compact
  end
  
  def per_patient_per_visit_line_items
    line_items.map do |line_item|
      line_item.service.is_one_time_fee? ? nil : line_item
    end.compact
  end

  def set_visit_page page_passed
    return 1 if visit_count == nil or visit_count <= 5

    page = case 
           when page_passed <= 0
             1
           when page_passed > (visit_count / 5.0).ceil
             1
           else 
             page_passed
           end
    page
  end

  def service_list is_one_time_fee=nil
    items = []
    case is_one_time_fee
    when nil
      items = line_items
    when true
      items = one_time_fee_line_items
    when false
      items = per_patient_per_visit_line_items
    end

    groupings = {}
    items.each do |line_item|
      service = line_item.service
      name = []
      acks = []
      last_parent = nil
      last_parent_name = nil
      service.parents.each do |parent|
        name << parent.abbreviation
        acks << parent.ack_language unless parent.ack_language.blank?
        last_parent = parent.id
        if parent.process_ssrs?
          last_parent = parent.id
          last_parent_name = parent.name
          break
        end
      end
      if groupings.include? last_parent
        g = groupings[last_parent]
        g[:services] << service
        g[:line_items] << line_item
      else
        groupings[last_parent] = {:process_ssr_organization_name => last_parent_name, :name => name.join(' -- '), :services => [service], :line_items => [line_item], :acks => acks.uniq.compact}
      end
    end

    groupings
  end

  def has_one_time_fee_services?
    one_time_fee_line_items.count > 0
  end

  def has_per_patient_per_visit_services?
    per_patient_per_visit_line_items.count > 0
  end

  def type
    'service_request'
  end

  def total_direct_costs_per_patient line_items=self.line_items
    total = 0.0
    line_items.select {|x| !x.service.is_one_time_fee?}.each do |li|
      total += li.direct_costs_for_visit_based_service
    end

    total
  end

  def total_indirect_costs_per_patient line_items=self.line_items
    total = 0.0
    line_items.select {|x| !x.service.is_one_time_fee?}.each do |li|
      total += li.indirect_costs_for_visit_based_service
    end

    total
  end

  def total_costs_per_patient line_items=self.line_items
    self.total_direct_costs_per_patient(line_items) + self.total_indirect_costs_per_patient(line_items)
  end

  def maximum_direct_costs_per_patient line_items=self.line_items
    total = 0.0
    line_items.select {|x| !x.service.is_one_time_fee?}.each do |li|
      total += li.direct_costs_for_visit_based_service_single_subject
    end

    total
  end

  def maximum_indirect_costs_per_patient line_items=self.line_items
    self.maximum_direct_costs_per_patient(line_items) * (self.protocol.indirect_cost_rate.to_f / 100)
  end

  def maximum_total_per_patient line_items=self.line_items
    self.maximum_direct_costs_per_patient(line_items) + maximum_indirect_costs_per_patient(line_items)
  end

  def total_direct_costs_one_time line_items=self.line_items
    total = 0.0
    line_items.select {|x| x.service.is_one_time_fee?}.each do |li|
      total += li.direct_costs_for_one_time_fee
    end

    total
  end

  def total_indirect_costs_one_time line_items=self.line_items
    total = 0.0
    line_items.select {|x| x.service.is_one_time_fee?}.each do |li|
      total += li.indirect_costs_for_one_time_fee
    end

    total
  end

  def total_costs_one_time line_items=self.line_items
    self.total_direct_costs_one_time(line_items) + self.total_indirect_costs_one_time(line_items)
  end

  def direct_cost_total line_items=self.line_items
    self.total_direct_costs_one_time(line_items) + self.total_direct_costs_per_patient(line_items)
  end

  def indirect_cost_total line_items=self.line_items
    self.total_indirect_costs_one_time(line_items) + self.total_indirect_costs_per_patient(line_items)
  end

  def grand_total line_items=self.line_items
    self.direct_cost_total(line_items) + self.indirect_cost_total(line_items)
  end

  # Add a single visit.  Returns true upon success and false upon
  # failure.  If there is a failure, any changes are rolled back.
  # 
  # TODO: I don't quite like the way this is written.  Perhaps we should
  # rename this method to add_visit! and make it raise exceptions; it
  # would be easier to read.  But I'm not sure how to get access to the
  # errors object in that case.
  def add_visit position=nil
    result = self.transaction do
      # Add visits to each line item under the service request
      self.per_patient_per_visit_line_items.each do |li|
        if not li.add_visit(position) then
          self.errors.initialize_dup(li.errors) # TODO: is this the right way to do this?
          raise ActiveRecord::Rollback
        end
      end

      # Reload to force refresh of the visits
      self.reload

      self.visit_count ||= 0 # in case we import a service request with nil visit count
      self.visit_count += 1

      self.save or raise ActiveRecord::Rollback
    end

    if result then
      return true
    else
      self.reload
      return false
    end
  end

  def remove_visit position
    result = self.transaction do
      self.per_patient_per_visit_line_items.each do |li|
        if not li.remove_visit(position) then
          self.errors.initialize_dup(li.errors)
          raise ActiveRecord::Rollback
        end
      end

      self.reload

      self.visit_count -= 1

      self.save or raise ActiveRecord::Rollback
    end
    
    if result
      return true
    else
      self.reload
      return false
    end
  end

  def fix_missing_visits
    if self.visit_count_changed?
      self.per_patient_per_visit_line_items.each do |li|
        if li.visits.count < self.visit_count
          n = self.visit_count - li.visits.count
          Visit.bulk_create(n, :line_item_id => li.id)
        end
      end
    end
  end

  def insure_visit_count
    if self.visit_count.nil? or self.visit_count <= 0
      self.update_attribute(:visit_count, 1)
      self.reload
    end
  end

  def insure_subject_count
    if subject_count.nil? or subject_count < 0
      self.update_attribute(:subject_count, 1)
      self.reload
    end
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

end

class ServiceRequest::ObisEntitySerializer < Entity::ObisEntitySerializer
  def sub_service_requests(service_request, options)
    sub_service_requests = service_request.sub_service_requests.map { |ssr|
      [ ssr.ssr_id, ssr.as_json(options) ]
    }

    return Hash[sub_service_requests]
  end

  def approval_data(service_request, options)
    approval_data = [{
      'approvals'  => Hash[service_request.approvals.as_json(options)],
      'charges'    => Hash[service_request.charges.as_json(options)],
      'tokens'     => Hash[service_request.tokens.as_json(options)],
    }]

    return approval_data
  end

  def subsidies(service_request, options)
    subsidies = service_request.sub_service_requests.map { |ssr| ssr.subsidy }
    return Hash[subsidies.as_json(options)]
  end

  def as_json(srq, options = nil)
    h = super(srq, options)

    h['identifiers'].update(
      'service_request_id'        => srq.id.to_s,
    )

    h['attributes'].update(
      'status'                    => srq.status,
      'line_items'                => srq.line_items.as_json(options),
      'friendly_id'               => srq.id.to_s,
      'sub_service_requests'      => sub_service_requests(srq, options),
      'approval_data'             => approval_data(srq, options),
      'subsidies'                 => subsidies(srq, options),
    )

    optional_attributes = {
      'approved'                  => srq.approved,
      'subject_count'             => srq.subject_count,
      'visit_count'               => srq.visit_count,
      'notes'                     => srq.notes,
      'submitted_at'              => srq.submitted_at.try(:utc)    .try(:strftime, '%F %T %Z'),
      'start_date'                => srq.start_date                .try(:strftime, '%Y-%m-%d'),
      'end_date'                  => srq.end_date                  .try(:strftime, '%Y-%m-%d'),
      'pppv_in_process_date'      => srq.pppv_in_process_date      .try(:strftime, '%Y-%m-%d'),
      'pppv_complete_date'        => srq.pppv_complete_date        .try(:strftime, '%Y-%m-%d'),
      'requester_contacted_date'  => srq.requester_contacted_date  .try(:strftime, '%Y-%m-%d'),
      'consult_arranged_date'     => srq.consult_arranged_date     .try(:strftime, '%Y-%m-%d'),
      'service_requester_id'      => srq.service_requester         .try(:obisid),
    }

    optional_attributes.delete_if { |k, v| v.nil? }

    h['attributes'].update(optional_attributes)

    return h
  end

  def update_attributes_from_json(entity, h, options = nil)
    super(entity, h, options)

    identifiers = h['identifiers']
    attributes = h['attributes']

    # TODO: ignore anything past index 0?
    approval_data_list = h['attributes']['approval_data'] || [ ]
    approval_data = approval_data_list[0] || { }

    if attributes['service_requester_id'] then
      service_requester = Identity.find_by_obisid(attributes['service_requester_id'])
      raise ArgumentError, "Could not find identity with obisid #{attributes['service_requester_id']}" if not service_requester
      service_requester_id = service_requester.id
    else
      service_requester_id = nil
    end

    entity.attributes = {
        :status                    => attributes['status'],
        :approved                  => attributes['approved'],
        :subject_count             => attributes['subject_count'],
        :visit_count               => attributes['visit_count'],
        :notes                     => attributes['notes'],
        :submitted_at              => attributes['submitted_at'] ? Time.parse(attributes['submitted_at']) : nil,
        :start_date                => legacy_parse_date(attributes['start_date']),
        :end_date                  => legacy_parse_date(attributes['end_date']),
        :pppv_in_process_date      => attributes['pppv_in_process_date'],
        :pppv_complete_date        => attributes['pppv_complete_date'],
        :requester_contacted_date  => legacy_parse_date(attributes['requester_contacted_date']),
        :consult_arranged_date     => legacy_parse_date(attributes['consult_arranged_date']),
        :service_requester_id      => service_requester_id
    }
    entity.save!(:validate => false) # TODO

    # Delete all sub service requests for the service request; they will
    # be re-created in the next step.
    entity.sub_service_requests.each do |ssr|
      ssr.destroy()
    end

    # Create a new sub service request for each one that is passed in.
    # Note that this must happen before the line items are
    # created/updated, since line items reference sub service requests.
    attributes['sub_service_requests'].each do |ssr_id, h_sub_service_request|
      sub_service_request = entity.sub_service_requests.create()
      sub_service_request.update_from_json(h_sub_service_request, options)
    end

    # Delete all line items for the service request; they will be
    # re-created in the next step.
    entity.line_items.each do |line_item|
      line_item.destroy()
    end

    # Create a new line item for each one that is passed in.
    attributes['line_items'].each do |h_line_item|
      line_item = entity.line_items.create()
      line_item.update_from_json(h_line_item, options)
    end

    # Delete all approvals for the service request; they will be
    # re-created in the next step.
    entity.approvals.each do |approval|
      approval.destroy()
    end

    # Create a new approval for each one that is passed in.
    (approval_data['approvals'] || { }).each do |h_approval|
      approval = entity.approvals.create()
      approval.update_from_json(h_approval, options)
    end

    # Delete all charges for the service request; they will be
    # re-created in the next step.
    entity.charges.each do |charge|
      charge.destroy()
    end

    # Create a new charge for each one that is passed in.
   (approval_data['charges'] || { }).each do |h_charge|
      charge = entity.charges.create()
      charge.update_from_json(h_charge, options)
    end

    # Delete all tokens for the service request; they will be
    # re-created in the next step.
    entity.tokens.each do |token|
      token.destroy()
    end

    # Create a new charge for each one that is passed in.
    (approval_data['tokens'] || { }).each do |h_token|
      token = entity.tokens.create()
      token.update_from_json(h_token, options)
    end

    # Delete all subsidies for the service request; they will be
    # re-created in the next step.
    entity.sub_service_requests.each do |ssr|
      ssr.subsidy.destroy() if ssr.subsidy
    end

    # Create a new subsidy for each one that is passed in.
    (attributes['subsidies'] || { }).each do |organization_obisid, h_subsidy|
      organization = Organization.find_by_obisid(organization_obisid)
      ssr = entity.sub_service_requests.find_by_organization_id(organization.id)
      subsidy = Subsidy.create(sub_service_request_id: ssr.id)
      subsidy.update_from_json([organization_obisid, h_subsidy], options)
    end
  end

  def self.create_from_json(entity_class, h, options = nil)
    if h['identifiers'] and h['identifiers']['service_request_id'] then
      obj = entity_class.new
      obj.id = h['identifiers']['service_request_id']
      obj.save!(:validate => false) # TODO: shouldn't skip all validations
    else
      obj = entity_class.create()
    end

    obj.update_from_json(h, options)

    return obj
  end

end

class ServiceRequest::ObisSimpleSerializer < Entity::ObisSimpleSerializer
  def as_json(entity, options = nil)
    h = super(entity, options)
    h['project_id'] = entity.protocol.obisid if entity.protocol
    return h
  end

  def self.create_from_json(entity_class, h, options = nil)
    if h['friendly_id'] then
      obj = entity_class.new
      obj.id = h['friendly_id']
      obj.save!
    else
      obj = entity_class.create()
    end

    obj.update_from_json(h, options)

    return obj
  end

  def update_from_json(entity, h, options = { })
    service_request = super(entity, h, options)
    if h['project_id'] then
      protocol = Protocol.find_by_obisid(h['project_id'])
      raise ArgumentError, "Could not find project with obisid #{h['project_id']}" if protocol.nil?
      service_request.update_attribute(:protocol_id, protocol.id)
    end
    return service_request
  end
end

class ServiceRequest
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
  json_serializer :relationships, RelationshipsSerializer
  json_serializer :obissimple, ObisSimpleSerializer
  json_serializer :simplerelationships, ObisSimpleRelationshipsSerializer
end

