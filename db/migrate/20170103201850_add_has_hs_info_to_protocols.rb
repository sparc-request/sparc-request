class AddHasHsInfoToProtocols < ActiveRecord::Migration[4.2]
  def change
    add_column :protocols, :has_human_subject_info, :boolean
  end
end
