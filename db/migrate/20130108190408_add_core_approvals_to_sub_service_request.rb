class AddCoreApprovalsToSubServiceRequest < ActiveRecord::Migration
  def change
    add_column :sub_service_requests, :nursing_nutrition_approved, :boolean, :default => false
    add_column :sub_service_requests, :lab_approved, :boolean, :default => false
    add_column :sub_service_requests, :imaging_approved, :boolean, :default => false
  end
end
