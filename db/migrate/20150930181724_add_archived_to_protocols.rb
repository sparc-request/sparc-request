class AddArchivedToProtocols < ActiveRecord::Migration
  def change
    add_column :protocols, :archived, :boolean, default: false
  end
end
