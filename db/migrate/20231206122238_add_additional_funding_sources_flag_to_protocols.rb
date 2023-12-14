class AddAdditionalFundingSourcesFlagToProtocols < ActiveRecord::Migration[5.2]
  def up
    add_column :protocols, :show_additional_funding_sources, :boolean
  end

  def down
    remove_column :protocols, :show_additional_funding_sources
  end
end
