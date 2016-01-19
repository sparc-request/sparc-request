class AddTransitionToStudyColumn < ActiveRecord::Migration
  def up
  	add_column :protocols, :transition_to_study, :boolean, :default => false
  end

  def down
  	remove_column :protocols, :transition_to_study
  end
end
