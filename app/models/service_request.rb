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
    validate :service_details_page
  end
  
  validation_group :service_details_back do
    # TODO: Fix validations for this area
    # validates :visit_count, :numericality => { :greater_than => 0, :message => "You must specify the estimated total number of visits (greater than zero) before continuing.", :if => :has_visits?}
    # validates :subject_count, :numericality => {:message => "You must specify the estimated total number of subjects before continuing.", :if => :has_visits?}
    validate :service_details_page
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

  attr_accessible :protocol_id
  attr_accessible :obisid
  attr_accessible :status
  attr_accessible :service_requester_id
  attr_accessible :notes
  attr_accessible :approved
  attr_accessible :start_date
  attr_accessible :end_date
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

  #after_save :fix_missing_visits

  def service_details_page
    if has_per_patient_per_visit_services?
      if start_date.nil?
        errors.add(:start_date, "You must specify the start date of the study.")
      end

      if end_date.nil?
        errors.add(:end_date, "You must specify the end date of the study.")
      end
    end

    arms.each do |arm|
      if arm.valid_visit_count? == false
        errors.add(:visit_count, "You must specify the estimated total number of visits (greater than zero) before continuing.")
        break
      end
    end

    arms.each do |arm|
      if arm.valid_subject_count? == false
        errors.add(:subject_count, "You must specify the estimated total number of subjects before continuing.")
        break
      end
    end
  end

  def create_arm(args)
    arm = self.arms.create(args)
    self.per_patient_per_visit_line_items.each do |li|
      arm.create_visit_grouping(li)
    end
    # Lets return this in case we need it for something else
    arm
  end

  def create_line_item(args)
    quantity = args.delete(:quantity) || 1
    if line_item = self.line_items.create(args)

      if line_item.service.is_one_time_fee?
        # quantity is only set for one time fee
        line_item.update_attribute(:quantity, quantity)

      else
        # only per-patient per-visit have arms
        self.arms.each do |arm|
          arm.create_visit_grouping(line_item)
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
