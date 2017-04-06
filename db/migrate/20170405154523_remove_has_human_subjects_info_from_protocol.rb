class RemoveHasHumanSubjectsInfoFromProtocol < ActiveRecord::Migration[5.0]
  def change
    remove_column :protocols, :has_human_subject_info
  end
end
