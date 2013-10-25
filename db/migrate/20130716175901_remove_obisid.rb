class RemoveObisid < ActiveRecord::Migration
  def up
    remove_column :identities, :obisid
    remove_column :organizations, :obisid
    remove_column :services, :obisid
    remove_column :protocols, :obisid
    remove_column :service_requests, :obisid
  end

  def down
    add_column :identities, :obisid
    add_column :organizations, :obisid
    add_column :services, :obisid
    add_column :protocols, :obisid
    add_column :service_requests, :obisid
  end
end
