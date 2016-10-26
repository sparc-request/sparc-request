# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class MovePositionFromVisitToVisitGroup < ActiveRecord::Migration
  class Arm < ActiveRecord::Base
    has_many :line_items_visits, :dependent => :destroy
    has_many :visit_groups
    has_many :visits, :through => :line_items_visits
    attr_accessible :visit_count
  end
  class Visit < ActiveRecord::Base
    attr_accessible :position
    attr_accessible :visit_group_id
    belongs_to :visit_group
    belongs_to :line_items_visit
  end
  class VisitGroup < ActiveRecord::Base
    attr_accessible :arm_id
    attr_accessible :name
    acts_as_list :scope => :arm
  end
  class LineItemsVisit < ActiveRecord::Base
    belongs_to :arm
    has_many :visits, -> { includes :visit_group }, :dependent => :destroy  # Order doesn't matter for this migration
  end
  def up
  	add_column :visit_groups, :position, :integer

    ##Move Position data over to visit groups, before the data is destroyed.
  	Arm.all.each do |arm|
      if arm.line_items_visits.any?
        visit_count = arm.line_items_visits.first.visits.count
        if arm.visit_count != visit_count
          arm.update_attributes(visit_count: visit_count)
        end
        puts "Arm visit count: #{arm.visit_count}"
        (arm.visit_count || 0).times do |index|
          puts "Index: #{index}"
          VisitGroup.create(arm_id: arm.id, position: index + 1)
        end
        puts "Arm Id:"
        puts arm.id
        arm.visits.each do |visit|
          puts "Visit ID: #{visit.id}"
          puts "Visit Position: #{visit.position}"
          visit_group = VisitGroup.where("arm_id = ? AND position = ?", arm.id, visit.position).first
          puts "Visit Group ID: #{visit_group.id}"
          visit.update_attributes(visit_group_id: visit_group.id)
          visit_group.update_attributes(name: visit.name) unless visit.name.blank?
        end
      end
    end

  	remove_column :visits, :position
  end

  def down
  	add_column :visits, :position, :integer
  	remove_column :visit_groups, :position
  end
end
