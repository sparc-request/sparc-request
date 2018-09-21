class RenameUdakColumn < ActiveRecord::Migration[5.2]
  def up
    rename_column :protocols, :udak_project_number, :project_number
  end

  def down
    rename_column :protocols, :project_number, :udak_project_number
  end
end
