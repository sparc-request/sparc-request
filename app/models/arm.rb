class Arm < ActiveRecord::Base
  audited

  belongs_to :service_request

  has_many :line_items_visits, :dependent => :destroy
  has_many :line_items, :through => :line_items_visits
  has_many :subjects
  has_many :visit_groups, :order => "position"
  has_many :visits, :through => :line_items_visits

  attr_accessible :name
  attr_accessible :visit_count
  attr_accessible :subject_count      # maximum number of subjects for any visit grouping
  attr_accessible :subjects_attributes
  accepts_nested_attributes_for :subjects, allow_destroy: true

  after_create :populate_cwf_if_active

  def populate_cwf_if_active
    if self.service_request
      unless self.service_request.sub_service_requests.empty?
        # There is no direct link between sub service requests and arms
        # Thus here we figure out if we are in CWF by establishing whether:
        # 1 - There are any CTRC SSRS on the parent SR
        # 2 - Are any of those CTRC SSRS (there should be only one) in CWF status?
        if self.service_request.sub_service_requests.select {|x| x.ctrc?}.map(&:in_work_fulfillment).include?(true)
          self.populate_subjects
        end
      end
    end
  end

  def valid_visit_count?
    return !visit_count.nil? && visit_count > 0
  end

  def valid_subject_count?
    return !subject_count.nil? && subject_count > 0
  end

  def create_line_items_visit line_item
    while self.visit_groups.size < self.visit_count
      visit_group = self.visit_groups.new
      if not visit_group.save(validate: false) then
        raise ActiveRecord::Rollback
      end
    end
    
    liv = LineItemsVisit.for(self, line_item)
    liv.create_visits

    if line_items_visits.count > 1
      liv.update_visit_names self.line_items_visits.first
    end
  end

  def per_patient_per_visit_line_items
    line_items_visits.each.map do |vg|
      vg.line_item
    end.compact
  end

  def maximum_direct_costs_per_patient line_items_visits=self.line_items_visits
    total = 0.0
    line_items_visits.each do |liv|
      total += liv.direct_costs_for_visit_based_service_single_subject
    end

    total
  end

  def maximum_indirect_costs_per_patient line_items_visits=self.line_items_visits
    if USE_INDIRECT_COST
      self.maximum_direct_costs_per_patient(line_items_visits) * (self.service_request.protocol.indirect_cost_rate.to_f / 100)
    else
      return 0
    end
  end

  def maximum_total_per_patient line_items_visits=self.line_items_visits
    self.maximum_direct_costs_per_patient(line_items_visits) + maximum_indirect_costs_per_patient(line_items_visits)
  end

  def direct_costs_for_visit_based_service
    total = 0.0
    line_items_visits.each do |vg|
      total += vg.direct_costs_for_visit_based_service
    end
    return total
  end

  def indirect_costs_for_visit_based_service
    total = 0.0
    line_items_visits.each do |vg|
      total += vg.indirect_costs_for_visit_based_service
    end
    return total
  end

  def total_costs_for_visit_based_service
    direct_costs_for_visit_based_service + indirect_costs_for_visit_based_service
  end
  
  # Add a single visit.  Returns true upon success and false upon
  # failure.  If there is a failure, any changes are rolled back.
  # 
  # TODO: I don't quite like the way this is written.  Perhaps we should
  # rename this method to add_visit! and make it raise exceptions; it
  # would be easier to read.  But I'm not sure how to get access to the
  # errors object in that case.
  def add_visit position=nil, day=nil, window=0, name=''
    result = self.transaction do
      if not self.create_visit_group(position, name) then
        raise ActiveRecord::Rollback
      end

      position = position.to_i - 1 unless position.blank?

      if not self.update_visit_group_day(day, position) then
        raise ActiveRecord::Rollback
      end

      if not self.update_visit_group_window(window, position) then
        raise ActiveRecord::Rollback
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

  def create_visit_group position=nil, name=''
    if not visit_group = self.visit_groups.create(position: position, name: name) then
      return false
    end

    # Add visits to each line item under the service request
    self.line_items_visits.each do |liv|
      if not liv.add_visit(visit_group) then
        self.errors.initialize_dup(liv.errors) # TODO: is this the right way to do this?
        return false
      end
    end

    return visit_group
  end

  def remove_visit position
    self.update_attribute(:visit_count, (self.visit_count - 1))
    visit_group = self.visit_groups.find_by_position(position)
    return visit_group.destroy
  end

  def populate_subjects
    groups = self.visit_groups
    subject_count.times do
      subject = self.subjects.create
      subject.calendar.populate(groups)
    end
  end

  def update_visit_group_day day, position
    position = position.blank? ? self.visit_groups.count - 1 : position.to_i
    before = self.visit_groups[position - 1] unless position == 0
    current = self.visit_groups[position]
    after = self.visit_groups[position + 1] unless position >= self.visit_groups.size - 1

    valid_day = Integer(day) rescue false
    if !valid_day
      self.errors.add(:invalid_day, "You've entered an invalid number for the day. Please enter a valid number.")
      return false
    end

    if !before.nil? && !before.day.nil?
      if before.day > valid_day
        self.errors.add(:out_of_order, "The days are out of order. This day appears to go before the previous day.")
        return false
      end
    end

    if !after.nil? && !after.day.nil?
      if valid_day > after.day
        self.errors.add(:out_of_order, "The days are out of order. This day appears to go after the next day.")
        return false
      end
    end

    return current.update_attributes(:day => valid_day)
  end

  def update_visit_group_window window, position
    position = position.blank? ? self.visit_groups.count - 1 : position.to_i

    valid = Integer(window) rescue false
    if !valid || valid < 0
      self.errors.add(:invalid_window, "You've entered an invalid number for the +/- window. Please enter a positive valid number")
      return false
    end

    visit_group = self.visit_groups[position]
    return visit_group.update_attributes(:window => window)
  end
end
