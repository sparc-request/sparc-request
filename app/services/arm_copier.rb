class ArmCopier < ApplicationService

  def initialize(new_arm, copied_arm)
    @new_arm = new_arm
    @copied_arm = copied_arm
  end

  def call
    @new_arm.update_attributes(subject_count: @copied_arm.subject_count, new_with_draft: @copied_arm.new_with_draft,
                               minimum_visit_count: @copied_arm.minimum_visit_count, minimum_subject_count: @copied_arm.minimum_subject_count)
    visit_groups = @copied_arm.visit_groups

    visit_groups.each_with_index do |group, group_index|
      if group_index == 0
        update_first_group(group)
      else
        create_groups_and_visits(group)
      end
    end

    @new_arm
  end

  # Update the first visit group and associated visits created by after_create arm callback
  def update_first_group(group)
    @new_arm.visit_groups.first.update_attributes(name: group.name, day: group.day, window_before: group.window_before,
                                                  window_after: group.window_after)
    group.visits.each_with_index do |visit, visit_index|
      @new_arm.visit_groups.first.visits[visit_index].update_attributes(quantity: visit.quantity, billing: visit.billing,
                                                                        research_billing_qty: visit.research_billing_qty,
                                                                        insurance_billing_qty: visit.insurance_billing_qty,
                                                                        effort_billing_qty: visit.effort_billing_qty)
    end
  end

  # Create all required new visit groups and update auto-created visits
  def create_groups_and_visits(group)
    new_group = VisitGroup.create(name: group.name, arm_id: @new_arm.id, position: group.position, day: group.day,
                                  window_before: group.window_before, window_after: group.window_after)
    new_group.visits.each_with_index do |visit, visit_index|
      visit.update_attributes(quantity: group.visits[visit_index].quantity, billing: group.visits[visit_index].billing,
                              research_billing_qty: group.visits[visit_index].research_billing_qty,
                              insurance_billing_qty: group.visits[visit_index].insurance_billing_qty,
                              effort_billing_qty: group.visits[visit_index].effort_billing_qty)
    end
  end
end
