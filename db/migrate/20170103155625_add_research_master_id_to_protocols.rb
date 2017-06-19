class AddResearchMasterIdToProtocols < ActiveRecord::Migration[4.2]
  def change
    add_column :protocols, :research_master_id, :integer
  end
end
