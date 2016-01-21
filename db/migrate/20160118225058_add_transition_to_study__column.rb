class AddTransitionToStudyColumn < ActiveRecord::Migration
  def up
  	add_column :protocols, :can_edit_study, :boolean, :default => false
  end

  def down
  	remove_column :protocols, :can_edit_study
  end
end
