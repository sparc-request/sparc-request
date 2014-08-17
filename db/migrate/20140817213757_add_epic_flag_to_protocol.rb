class AddEpicFlagToProtocol < ActiveRecord::Migration
  def change
    add_column :protocols, :selected_for_epic, :boolean, :default => false
  end
end
