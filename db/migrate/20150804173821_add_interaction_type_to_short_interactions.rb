class AddInteractionTypeToShortInteractions < ActiveRecord::Migration[4.2]
  def change
    add_column :short_interactions, :interaction_type, :string
  end
end
