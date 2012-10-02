class AddEditHistoricalDataToCatalogManager < ActiveRecord::Migration
  def change
    add_column :catalog_managers, :edit_historic_data, :boolean
  end
end
