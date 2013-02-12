class AddSrcApprovalToSubServiceRequest < ActiveRecord::Migration
  def change
    add_column :sub_service_requests, :src_approved, :boolean, :default => false
  end
end
