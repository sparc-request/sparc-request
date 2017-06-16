class AddResearchMasterIdToProtocols < ActiveRecord::Migration[5.1]
  def change
    add_column :protocols, :research_master_id, :integer
  end
end
