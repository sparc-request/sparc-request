class AddAllResearchToProtocols < ActiveRecord::Migration[5.2]
  def change
    add_column :protocols, :all_research, :boolean, default: true
  end
end
