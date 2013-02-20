class AddApprovalTypeToApprovals < ActiveRecord::Migration
  def change
    add_column :approvals, :approval_type, :string, :default => "Resource Approval"
    add_column :approvals, :sub_service_request_id, :integer
  end
end
