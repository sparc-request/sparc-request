class RemoveServiceRequestApprovals < ActiveRecord::Migration[5.2]
  def change
    Approval.where(approval_type: "Resource Approval").destroy_all

    remove_column :approvals, :service_request_id
  end
end
