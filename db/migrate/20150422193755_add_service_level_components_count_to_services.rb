class AddServiceLevelComponentsCountToServices < ActiveRecord::Migration
  def change
    add_column :services, :service_level_components_count, :integer, default: 0
  end
end
