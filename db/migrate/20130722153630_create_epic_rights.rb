class CreateEpicRights < ActiveRecord::Migration
  def up
  	create_table :epic_rights do |t|
  		t.integer :project_role_id
  		t.string :right

  		t.timestamps
  	end
  end

  def down
  	drop_table :epic_rights
  end
end
