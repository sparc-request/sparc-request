class AddResearchMasterIdToProtocols < ActiveRecord::Migration
  def change
    add_column :protocols, :research_master_id, :integer
  end
end
