class Arm < ActiveRecord::Base
  audited

  belongs_to :protocol

  has_many :line_items_visits, :dependent => :destroy
  has_many :line_items, :through => :line_items_visits
  has_many :subjects
  has_many :visit_groups, :order => "position", :dependent => :destroy
  has_many :visits, :through => :line_items_visits

  attr_accessible :name
  attr_accessible :visit_count
  attr_accessible :subject_count      # maximum number of subjects for any visit grouping
  attr_accessible :new_with_draft     # used for existing arm validations in sparc proper (should always be false unless in first draft)
  attr_accessible :subjects_attributes
  attr_accessible :protocol_id
  attr_accessible :minimum_visit_count
  attr_accessible :minimum_subject_count
  accepts_nested_attributes_for :subjects, allow_destroy: true

  after_save :update_liv_subject_counts

  def update_liv_subject_counts
    
    self.line_items_visits.each do |liv|
      if ['first_draft', 'draft', nil].include?(liv.line_item.service_request.status)  
        liv.update_attributes(:subject_count => self.subject_count)
      end
    end
  end

  def valid_visit_count?
    return !visit_count.nil? && visit_count > 0
  end

  def valid_subject_count?
    return !subject_count.nil? && subject_count > 0
  end

  # def valid_minimum_visit_count?
  #   return !visit_count.nil? && visit_count >= minimum_visit_count
  # end

  # def valid_minimum_subject_count?
  #   return !subject_count.nil? && subject_count >= minimum_subject_count
  # end

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
      self.maximum_direct_costs_per_patient(line_items_visits) * (self.protocol.indirect_cost_rate.to_f / 100)
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
  
  def add_visit position=nil, day=nil, window=0, name=''
    result = self.transaction do
      if not self.create_visit_group(position, name) then
        raise ActiveRecord::Rollback
      end

      position = position.to_i - 1 unless position.blank?

      if USE_EPIC
        if not self.update_visit_group_day(day, position) then
          raise ActiveRecord::Rollback
        end

        if not self.update_visit_group_window(window, position) then
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

    # If in CWF, build the appointments for the visit group
    if self.protocol.service_requests.map {|x| x.sub_service_requests.map {|y| y.in_work_fulfillment}}.flatten.include?(true)
      populate_subjects_for_new_visit_group(visit_group)
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

  def populate_subjects_on_edit
    subject_difference = self.subject_count - self.subjects.count
    if subject_difference > 0
      subject_difference.times do
        self.subjects.create
      end
    end
    self.subjects.each do |subject|
      # populate old appointments
      subject.calendar.appointments.each do |appointment|
        existing_liv_ids = appointment.procedures.map {|x| x.visit ? x.visit.line_items_visit.id : nil}.compact
        new_livs = self.line_items_visits.reject {|x| existing_liv_ids.include?(x.id)}
        new_livs.each do |new_liv|
          visit = new_liv.visits.where("visit_group_id = ?", appointment.visit_group_id).first
          appointment.procedures.create(:line_item_id => new_liv.line_item.id, :visit_id => visit.id) if new_liv.line_item.service.organization_id == appointment.organization_id
        end
      end
      # populate new appointments
      existing_group_ids = subject.calendar.appointments.map(&:visit_group_id)
      groups = self.visit_groups.reject {|x| existing_group_ids.include?(x.id)}
      subject.calendar.populate(groups)
    end
  end

  def populate_new_subjects
    self.subjects.each do |subject|
      if subject.calendar.appointments.empty?
        subject.calendar.populate(self.visit_groups)
      end
    end
  end

  def populate_subjects_for_new_visit_group visit_group
    self.subjects.each do |subject|
      subject.calendar.populate([visit_group])
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

  def service_list
    items = self.line_items_visits.map do |liv|
      liv.line_item.service.is_one_time_fee? ? nil : liv.line_item
    end.compact

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

  def update_minimum_counts
    self.update_attributes(:minimum_visit_count => self.visit_count, :minimum_subject_count => self.subject_count)
  end
  
  ### audit reporting methods ###
  
  def audit_label audit
    name
  end

  ### end audit reporting methods ###
end
