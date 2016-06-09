class RemoveMinimumCountsFromArms < ActiveRecord::Migration
  def change
    remove_column :arms, :minimum_visit_count
    remove_column :arms, :minimum_subject_count
  end
end
