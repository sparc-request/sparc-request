class Protocol < ActiveRecord::Base
  audited

  has_many :study_types, :dependent => :destroy
  has_one :research_types_info, :dependent => :destroy
  has_one :human_subjects_info, :dependent => :destroy
  has_one :vertebrate_animals_info, :dependent => :destroy
  has_one :investigational_products_info, :dependent => :destroy
  has_one :ip_patents_info, :dependent => :destroy
  has_many :project_roles, :dependent => :destroy
  has_many :identities, :through => :project_roles
  has_many :service_requests
  has_many :affiliations, :dependent => :destroy
  has_many :impact_areas, :dependent => :destroy
  has_many :arms, :dependent => :destroy

  attr_accessible :identity_id
  attr_accessible :next_ssr_id
  attr_accessible :short_title
  attr_accessible :title
  attr_accessible :sponsor_name
  attr_accessible :brief_description
  attr_accessible :indirect_cost_rate
  attr_accessible :study_phase
  attr_accessible :udak_project_number
  attr_accessible :funding_rfa
  attr_accessible :funding_status
  attr_accessible :potential_funding_source
  attr_accessible :potential_funding_start_date
  attr_accessible :funding_source
  attr_accessible :funding_start_date
  attr_accessible :federal_grant_serial_number
  attr_accessible :federal_grant_title
  attr_accessible :federal_grant_code_id
  attr_accessible :federal_non_phs_sponsor
  attr_accessible :federal_phs_sponsor
  attr_accessible :potential_funding_source_other
  attr_accessible :funding_source_other
  attr_accessible :research_types_info_attributes
  attr_accessible :human_subjects_info_attributes
  attr_accessible :vertebrate_animals_info_attributes
  attr_accessible :investigational_products_info_attributes
  attr_accessible :ip_patents_info_attributes
  attr_accessible :study_types_attributes
  attr_accessible :impact_areas_attributes
  attr_accessible :affiliations_attributes
  attr_accessible :project_roles_attributes
  attr_accessible :arms_attributes
  attr_accessible :requester_id
  attr_accessible :start_date
  attr_accessible :end_date
  attr_accessible :last_epic_push_time
  attr_accessible :last_epic_push_status
  attr_accessible :billing_business_manager_static_email
  attr_accessible :recruitment_start_date
  attr_accessible :recruitment_end_date

  attr_accessor :requester_id
  
  accepts_nested_attributes_for :research_types_info
  accepts_nested_attributes_for :human_subjects_info
  accepts_nested_attributes_for :vertebrate_animals_info
  accepts_nested_attributes_for :investigational_products_info
  accepts_nested_attributes_for :ip_patents_info
  accepts_nested_attributes_for :study_types, :allow_destroy => true
  accepts_nested_attributes_for :impact_areas, :allow_destroy => true
  accepts_nested_attributes_for :affiliations, :allow_destroy => true
  accepts_nested_attributes_for :project_roles, :allow_destroy => true
  accepts_nested_attributes_for :arms, :allow_destroy => true

  validation_group :protocol do
    validates :short_title, :presence => true
    validates :title, :presence => true
    validates :funding_status, :presence => true  
    validate  :validate_funding_source
    validates :sponsor_name, :presence => true, :if => :is_study?
  end

  validation_group :user_details do
    validate :validate_proxy_rights
    validate :requester_included, :on => :create
    validate :primary_pi_exists
  end

  def is_study?
    self.type == 'Study'
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

  def principal_investigators
    project_roles.reject{|pr| !['pi', 'primary-pi'].include?(pr.role)}.map(&:identity)
  end

  def primary_principal_investigator
    primary_pi_project_role.try(:identity)
  end

  def primary_pi_project_role
    project_roles.detect { |pr| pr.role == 'primary-pi' }
  end

  def billing_managers
    project_roles.reject{|pr| pr.role != 'business-grants-manager'}.map(&:identity)
  end

  def billing_business_manager_email
    billing_business_manager_static_email.blank? ?  billing_managers.map(&:email).try(:join, ', ') : billing_business_manager_static_email
  end

  def emailed_associated_users
    project_roles.reject {|pr| pr.project_rights == 'none'}
  end

  def requester_included
    errors.add(:base, "You must add yourself as an authorized user") unless project_roles.map(&:identity_id).include?(requester_id.to_i)
  end

  def primary_pi_exists
    errors.add(:base, "You must add a Primary PI to the study/project") unless project_roles.map(&:role).include? 'primary-pi'
    errors.add(:base, "Only one Primary PI is allowed. Please ensure that only one exists") if project_roles.select { |pr| pr.role == 'primary-pi'}.count > 1
  end

  def role_for identity
    project_roles.detect{|pr| pr.identity_id == identity.id}.try(:role)
  end
  
  def role_other_for identity
    project_roles.detect{|pr| pr.identity_id == identity.id}.try(:role)
  end

  def subspecialty_for identity
    identity.subspecialty
  end

  def all_child_sub_service_requests
    arr = []
    self.service_requests.each do |sr|
      sr.sub_service_requests.each do |ssr|
        arr << ssr
      end
    end
    
    arr
  end

  def display_protocol_id_and_title
    "#{self.id} - #{self.short_title}"
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

    rescue Exception => e
      Rails.logger.info("Push to Epic failed.")

      self.last_epic_push_status = 'failed'
      save(validate: false)
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
    self.primary_pi_project_role.set_epic_rights
    self.primary_pi_project_role.save
  end

  # Returns true if there is a push to epic in progress, false
  # otherwise.  If no push has been initiated, return false.
  def push_to_epic_in_progress?
    return self.last_epic_push_status == 'started' ||
           self.last_epic_push_status == 'sent_study'
  end

  # Returns true if the most push to epic has completed.  Returns false
  # if no push has been initiated.
  def push_to_epic_complete?
    return self.last_epic_push_status == 'complete' ||
           self.last_epic_push_status == 'failed'
  end

  def populate_for_edit
    project_roles.each do |pr|
      pr.populate_for_edit
    end
  end
  
  def create_arm(args)
    arm = self.arms.create(args)
    self.service_requests.each do |service_request|
      service_request.per_patient_per_visit_line_items.each do |li|
        arm.create_line_items_visit(li)
      end
    end
    # Lets return this in case we need it for something else
    arm
  end
  
  def should_push_to_epic?
    return self.service_requests.any? { |sr| sr.should_push_to_epic? }
  end

  def has_ctrc_clinical_services? current_service_request_id
    self.service_requests.each do |sr|
      next if sr.id == current_service_request_id
      if sr.has_ctrc_clinical_services? and sr.status != 'first_draft'
        return sr.id
      end
    end

    return nil
  end

  def find_sub_service_request_with_ctrc current_service_request_id
    id = has_ctrc_clinical_services? current_service_request_id
    service_request = self.service_requests.find id
    service_request.sub_service_requests.each do |ssr|
      if ssr.ctrc?
        return ssr.ssr_id
      end
    end
  end

  def any_service_requests_to_display?
    return self.service_requests.detect { |sr| !['first_draft', 'draft'].include?(sr.status) }
  end

  def has_one_time_fees?
    return self.service_requests.detect { |sr| sr.has_one_time_fee_services? && !['first_draft', 'draft'].include?(sr.status)}
  end

end
