class AddCatalogOverLord < ActiveRecord::Migration
  def up
    add_column :identities, :catalog_overlord, :boolean
  end

  def down
    remove_column :identities, :catalog_overlord
  end
end
