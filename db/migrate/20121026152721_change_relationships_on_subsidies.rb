class ChangeRelationshipsOnSubsidies < ActiveRecord::Migration
  def change
    remove_column :subsidies, :service_request_id
    remove_column :subsidies, :organization_id
    add_column :subsidies, :sub_service_request_id, :integer
  end
end
