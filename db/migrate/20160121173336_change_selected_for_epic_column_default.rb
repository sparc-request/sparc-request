class ChangeSelectedForEpicColumnDefault < ActiveRecord::Migration
   def change
    change_column :protocols, :selected_for_epic, :boolean, :default => nil
  end
end
