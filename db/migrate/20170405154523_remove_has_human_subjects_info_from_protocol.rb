class RemoveHasHumanSubjectsInfoFromProtocol < ActiveRecord::Migration[5.0]
  def change
    remove_column :protocols, :has_human_subjects_info
  end
end
