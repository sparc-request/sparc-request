class AddPositionInCwfAndShowInCwfToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :show_in_cwf, :boolean
    add_column :organizations, :position_in_cwf, :integer
  end
end
