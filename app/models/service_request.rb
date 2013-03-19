class ServiceRequest < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :service_requester, :class_name => "Identity", :foreign_key => "service_requester_id"
  belongs_to :protocol
  has_many :sub_service_requests, :dependent => :destroy
  has_many :line_items, :include => [:service], :dependent => :destroy
  has_many :charges, :dependent => :destroy
  has_many :tokens, :dependent => :destroy
  has_many :approvals, :dependent => :destroy
  has_many :documents, :through => :sub_service_requests
  has_many :document_groupings, :dependent => :destroy
  has_many :arms, :dependent => :destroy

  validation_group :protocol do
    validates :protocol_id, :presence => {:message => "You must identify the service request with a study/project before continuing."} 
  end

  validation_group :service_details do
    # TODO: Fix validations for this area
    # validates :visit_count, :numericality => { :greater_than => 0, :message => "You must specify the estimated total number of visits (greater than zero) before continuing.", :if => :has_per_patient_per_visit_services?}
    # validates :subject_count, :numericality => {:message => "You must specify the estimated total number of subjects before continuing.", :if => :has_per_patient_per_visit_services?}
  end
  
  validation_group :service_details_back do
    # TODO: Fix validations for this area
    # validates :visit_count, :numericality => { :greater_than => 0, :message => "You must specify the estimated total number of visits (greater than zero) before continuing.", :if => :has_visits?}
    # validates :subject_count, :numericality => {:message => "You must specify the estimated total number of subjects before continuing.", :if => :has_visits?}
  end

  validation_group :service_calendar do
    #insert group specific validation
  end

  validation_group :calendar_totals do
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
  
  validation_group :obtain_research_pricing do
    #insert group specific validation
  end

  validation_group :confirmation do
    #insert group specific validation
  end

  def has_visits?
    visits.count > 0 
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
  attr_accessible :arms_attributes

  accepts_nested_attributes_for :line_items
  accepts_nested_attributes_for :sub_service_requests
  accepts_nested_attributes_for :arms, :allow_destroy => true

  alias_attribute :service_request_id, :id

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
        groupings[last_parent] = {:process_ssr_organization_name => last_parent_name, :name => name.reverse.join(' -- '), :services => [service], :line_items => [line_item], :acks => acks.reverse.uniq.compact}
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

  def total_direct_costs_per_patient arms=self.arms
    total = 0.0
    arms.each do |arm|
      total += arm.direct_costs_for_visit_based_service
    end

    total
  end

  def total_indirect_costs_per_patient arms=self.arms
    total = 0.0
    arms.each do |arm|
      total += arm.indirect_costs_for_visit_based_service
    end

    total
  end

  def total_costs_per_patient arms=self.arms
    self.total_direct_costs_per_patient(arms) + self.total_indirect_costs_per_patient(arms)
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
    self.total_direct_costs_one_time(line_items) + self.total_direct_costs_per_patient
  end

  def indirect_cost_total line_items=self.line_items
    self.total_indirect_costs_one_time(line_items) + self.total_indirect_costs_per_patient
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
    # TODO This possibly needs to be fixed
    # if self.visit_count_changed?
    #   self.per_patient_per_visit_line_items.each do |li|
    #     li.fix_missing_visits(self.visit_count)
    #   end
    # end
  end

  def insure_visit_count
    # TODO: Fix for arms
    # if self.visit_count.nil? or self.visit_count <= 0
    #   self.update_attribute(:visit_count, 1)
    #   self.reload
    # end
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
