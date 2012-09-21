class CreateApprovals < ActiveRecord::Migration
  def change
    create_table :approvals do |t|
      t.integer :service_request_id
      t.integer :identity_id
      t.datetime :approval_date

      t.timestamps
    end

    add_index :approvals, :service_request_id
  end
end
