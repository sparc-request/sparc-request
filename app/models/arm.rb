class Arm < ActiveRecord::Base
  belongs_to :service_request

  has_many :line_items_visits, :dependent => :destroy
  has_many :line_items, :through => :line_items_visits
  has_many :subjects
  has_many :visit_groups

  attr_accessible :name
  attr_accessible :visit_count
  attr_accessible :subject_count      # maximum number of subjects for any visit grouping

  def create_visit_grouping line_item
    vg = self.visit_groupings.create(:line_item_id => line_item.id, :arm_id => self.id, :subject_count => self.subject_count)
    vg.create_or_destroy_visits

    if visit_groupings.count > 1
      vg.update_visit_names self.visit_groupings.first
    end
  end

  def per_patient_per_visit_line_items
    line_items_visits.each.map do |vg|
      vg.line_item
    end.compact
  end

  def maximum_direct_costs_per_patient line_items_visits=self.line_items_visits
    total = 0.0
    line_items_visits.each do |vg|
      total += vg.direct_costs_for_visit_based_service_single_subject
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
  def add_visit position=nil
    result = self.transaction do
      # Add visits to each line item under the service request
      self.line_items_visits.each do |vg|
        if not vg.add_visit(position) then
          self.errors.initialize_dup(vg.errors) # TODO: is this the right way to do this?
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
      self.line_items_visits.each do |vg|
        if not vg.remove_visit(position) then
          self.errors.initialize_dup(vg.errors)
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

  def populate_subjects
    groups = self.visit_groups
    subject_count.times do
      subject = self.subjects.create
      subject.calendar.populate(groups)
    end
  end
end
