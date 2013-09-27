class AddMinimumVisitCountToArms < ActiveRecord::Migration
  def up
    add_column :arms, :minimum_visit_count, :integer, :default => 0
    add_column :arms, :minimum_subject_count, :integer, :default => 0

    Arm.reset_column_information

    Arm.all.each do |arm|
      arm.update_attribute(:minimum_visit_count, arm.visit_count)
      arm.update_attribute(:minimum_subject_count, arm.subject_count)
    end
  end

  def down
    remove_column :arms, :minimum_visit_count
    remove_column :arms, :minimum_subject_count
  end
end
