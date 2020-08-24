class AddAllResearchToProtocols < ActiveRecord::Migration[5.2]
  def change
    add_column :protocols, :all_research_billing, :boolean, default: true
  end
end
