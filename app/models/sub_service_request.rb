class SubServiceRequest < ActiveRecord::Base
  audited

  after_save :update_past_status

  belongs_to :owner, :class_name => 'Identity', :foreign_key => "owner_id"
  belongs_to :service_request
  belongs_to :organization
  has_many :past_statuses, :dependent => :destroy
  has_many :line_items, :dependent => :destroy
  has_many :documents, :dependent => :destroy
  has_many :notes, :dependent => :destroy
  has_many :approvals, :dependent => :destroy
  has_many :payments, :dependent => :destroy
  has_many :cover_letters, :dependent => :destroy
  has_one :subsidy, :dependent => :destroy
  has_many :reports, :dependent => :destroy

  # These two ids together form a unique id for the sub service request
  attr_accessible :service_request_id
  attr_accessible :ssr_id

  attr_accessible :organization_id
  attr_accessible :owner_id
  attr_accessible :status_date
  attr_accessible :status
  attr_accessible :consult_arranged_date
  attr_accessible :nursing_nutrition_approved
  attr_accessible :lab_approved
  attr_accessible :imaging_approved
  attr_accessible :src_approved
  attr_accessible :requester_contacted_date
  attr_accessible :subsidy_attributes
  attr_accessible :payments_attributes
  attr_accessible :in_work_fulfillment
  attr_accessible :routing

  accepts_nested_attributes_for :subsidy
  accepts_nested_attributes_for :payments, allow_destroy: true

  after_save :work_fulfillment

  def work_fulfillment
    if self.in_work_fulfillment_changed?
      if self.in_work_fulfillment
        self.service_request.arms.each do |arm|
          arm.populate_subjects if arm.subjects.empty?
        end
      end
    end
  end

  def display_id
    return "#{service_request.try(:protocol).try(:id)}-#{ssr_id}"
  end

  def create_line_item(args)
    result = self.transaction do
      new_args = {
        sub_service_request_id: self.service_request_id
      }
      new_args.update(args)
      li = service_request.create_line_item(new_args)

      # Update subject visit calendars if present
      update_cwf_data_for_new_line_item(li)

      li
    end

    if result
      return result
    else
      self.reload
      return false
    end
  end

  def update_cwf_data_for_new_line_item(li)
    if self.in_work_fulfillment
      self.service_request.arms.each do |arm|
        visits = Visit.joins(:line_items_visit).where(visits: { visit_group_id: arm.visit_groups}, line_items_visits:{ line_item_id: li.id} )
        visits.group_by{|v| v.visit_group_id}.each do |vg_id, group_visits|
          Appointment.where(visit_group_id: vg_id).each do |appointment|
            if appointment.organization_id == li.service.organization_id
              group_visits.each do |visit|
                appointment.procedures.create(:line_item_id => li.id, :visit_id => visit.id)
              end
            end
          end
        end
      end
    end
  end

  def one_time_fee_line_items
    self.line_items.select {|li| li.service.is_one_time_fee?}
  end

  def per_patient_per_visit_line_items
    self.line_items.select {|li| !li.service.is_one_time_fee?}    
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
      if li.service.is_one_time_fee?
        total += li.direct_costs_for_one_time_fee
      else
        total += li.direct_costs_for_visit_based_service
      end
    end

    return total
  end

  # percent of cost
  def percent_of_cost
    subsidy.pi_contribution ? (subsidy.pi_contribution/direct_cost_total * 100).round(2) : nil
  end

  # Returns the total indirect costs of the sub-service-request
  def indirect_cost_total
    total = 0.0

    self.line_items.each do |li|
      if li.service.is_one_time_fee?
       total += li.indirect_costs_for_one_time_fee
      else
       total += li.indirect_costs_for_visit_based_service
      end
    end

    return total
  end

  # Returns the grant total cost of the sub-service-request
  def grand_total
    self.direct_cost_total + self.indirect_cost_total
  end

  def subsidy_percentage
    funded_amount = self.direct_cost_total - self.subsidy.pi_contribution.to_f

    ((funded_amount.to_f / self.direct_cost_total.to_f).round(2) * 100).to_i
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

  def update_line_item line_item, args
    if self.line_items.map {|li| li.id}.include? line_item.id
      line_item.update_attributes!(args)
    else
      raise ArgumentError, "Line item #{line_item.id} does not exist for sub service request #{self.id} "
    end

    line_item
  end

  def eligible_for_subsidy?
    if organization.eligible_for_subsidy? and not organization.funding_source_excluded_from_subsidy?(self.service_request.protocol.try(:funding_source_based_on_status))
      true
    else
      false
    end
  end

  ###############################################################################
  ######################## FULFILLMENT RELATED METHODS ##########################
  ###############################################################################

  ########################
  ## SSR STATUS METHODS ##
  ########################
  def ctrc?
    self.organization.tag_list.include? "ctrc"
  end

  def can_be_edited?
    ['first_draft', 'draft', 'submitted', nil, 'obtain_research_pricing'].include?(self.status) ? true : false
  end

  def arms_editable?
    self.can_be_edited?
  end

  def candidate_statuses
    candidates = ["draft", "submitted", "in process", "complete"]
    #candidates.unshift("submitted") if self.can_be_edited?
    #candidates.unshift("draft") if self.can_be_edited?
    candidates << "ctrc review" if self.ctrc?
    candidates << "ctrc approved" if self.ctrc?
    candidates << "awaiting pi approval"
    candidates << "on hold"

    candidates
  end

  # Make sure that @prev_status is set whenever status is changed.
  def status= status
    @prev_status = self.status
    super(status)
  end

  # Callback which gets called after the ssr is saved to ensure that the
  # past status is properly updated.  It should not normally be
  # necessarily to call this method.
  def update_past_status
    old_status = self.past_statuses.last
    if @prev_status and (not old_status or old_status.status != @prev_status)
      self.past_statuses.create(:status => @prev_status, :date => Time.now)
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

  def generate_approvals current_user
    if self.nursing_nutrition_approved?
      self.approvals.create({:identity_id => current_user.id, :sub_service_request_id => self.id, :approval_date => Date.today, :approval_type => "Nursing/Nutrition Approved"}) unless self.approvals.find_by_approval_type("Nursing/Nutrition Approved")
    end

    if self.lab_approved?
      self.approvals.create({:identity_id => current_user.id, :sub_service_request_id => self.id, :approval_date => Date.today, :approval_type => "Lab Approved"}) unless self.approvals.find_by_approval_type("Lab Approved")
    end

    if imaging_approved?
      self.approvals.create({:identity_id => current_user.id, :sub_service_request_id => self.id, :approval_date => Date.today, :approval_type => "Imaging Approved"}) unless self.approvals.find_by_approval_type("Imaging Approved")
    end

    if src_approved?
      self.approvals.create({:identity_id => current_user.id, :sub_service_request_id => self.id, :approval_date => Date.today, :approval_type => "SRC Approved"}) unless self.approvals.find_by_approval_type("SRC Approved")
    end
  end

  ##########################
  ## SURVEY DISTRIBUTTION ##
  ##########################
 
  def distribute_surveys
    # e-mail primary PI and requester
    primary_pi = service_request.protocol.primary_principal_investigator
    requester = service_request.service_requester

    # send all available surveys at once
    available_surveys = line_items.map{|li| li.service.available_surveys}.flatten.compact.uniq

    # do nothing if we don't have any available surveys
    
    unless available_surveys.blank?
      SurveyNotification.service_survey(available_surveys, primary_pi, self).deliver
      SurveyNotification.service_survey(available_surveys, requester, self).deliver
    end
  end
  
  ### audit reporting methods ###
  
  def audit_label audit
    "Service Request #{display_id}"
  end

  ### end audit reporting methods ###
end
