class Protocol < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

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

  attr_accessible :obisid
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
  attr_accessible :requester_id

  attr_accessible :last_epic_push_time
  attr_accessible :last_epic_push_status

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

  validates :short_title, :presence => true
  validates :title, :presence => true
  validates :funding_status, :presence => true  
  validate  :requester_included, :on => :create
  validate  :pi_exists
  validate  :billing_manager_exists
  validate  :validate_funding_source
  validate  :validate_proxy_rights

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
    project_roles.reject{|pr| pr.role != 'pi'}.map(&:identity)
  end

  def billing_managers
    project_roles.reject{|pr| pr.role != 'business-grants-manager'}.map(&:identity)
  end

  def emailed_associated_users
    project_roles.reject {|pr| pr.project_rights == 'none'}
  end

  def requester_included
    errors.add(:base, "You must add yourself as an authorized user") unless project_roles.map(&:identity_id).include?(requester_id.to_i)
  end

  def pi_exists
    errors.add(:base, "You must add a PI to the study/project") unless project_roles.map(&:role).include? 'pi'
  end

  def billing_manager_exists
    errors.add(:base, "You must add a Billing/Business Manager to the study/project") unless project_roles.map(&:role).include? 'business-grants-manager'
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
      update_attributes(
          last_epic_push_time: Time.now,
          last_epic_push_status: 'started')

      Rails.logger.info("Sending study creation message to Epic")
      epic_interface.send_study(self)

      update_attributes(
          last_epic_push_status: 'sent_study')

      Rails.logger.info("Sending billing calendar to Epic")
      epic_interface.send_billing_calendar(self)

      update_attributes(
          last_epic_push_status: 'complete')

    rescue Exception => e
      Rails.logger.info("Push to Epic failed.")

      update_attributes(
          last_epic_push_status: 'failed')
      raise e
    end
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
end
