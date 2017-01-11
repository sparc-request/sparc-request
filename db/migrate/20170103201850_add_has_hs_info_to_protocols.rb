class AddHasHsInfoToProtocols < ActiveRecord::Migration
  def change
    add_column :protocols, :has_human_subject_info, :boolean
  end
end
