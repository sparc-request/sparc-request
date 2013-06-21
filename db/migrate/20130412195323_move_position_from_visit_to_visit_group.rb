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
