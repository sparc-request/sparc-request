class AddArmEditedToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :arm_edited, :boolean
  end
end
