# Copyright © 2011-2020 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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
